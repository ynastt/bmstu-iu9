from typing import Callable, Tuple
import argparse
import sys
import numpy as np

PRINT_MAX_LINE_LENGTH = 80
DEBUG = False

def score_fun(a: str, 
              b: str,
              match_score: int = 5, 
              mismatch_score: int = -4) -> int:
    return match_score if a == b else mismatch_score

# В соответствии со статьей https://ru.wikipedia.org/wiki/Алгоритм_Нидлмана_—_Вунша
def needleman_wunsch(seq1: str,
                     seq2: str,
                     score_fun: Callable[[str, str], int] = score_fun,
                     gap_penalty: int = -10) -> Tuple[int, str, str]:

    """Given two sequences, aligns them using the Needleman-Wunsch algorithm.

    This function takes two sequences and optionally a scoring function and a
    gap penalty value as arguments. 
    The function returns a tuple containing the optimal alignment score and the
    aligned sequences, e.g. (10, 'ACCGT', 'AC-GT').

    Args:
        seq1: The first sequence, e.g. 'ACCGT'
        seq2: The second sequence, e.g. 'ACGT'
        score_fun: The scoring function, e.g. score_fun('A', 'A') returns 5
        gap_penalty: The gap penalty value, e.g. -10

    Returns:
        score: The optimal alignment score, e.g. 10
        aligned_seq1: The first aligned sequence, e.g. 'ACCGT'
        aligned_seq2: The second aligned sequence, e.g. 'AC-GT'
    """ 
    # Initialize the score matrix.
    len1 = len(seq1)
    len2 = len(seq2)
    # создание таблички, которая заполнена нулями
    score_matrix = np.zeros(shape=(len1 + 1, len2 + 1))
    # заполнение таблички согласно алгоритму
    for i in range(0, len1 + 1):
        for j in range(0, len2 + 1):
            if j == 0:
                score_matrix[i, 0] = gap_penalty * i
            elif i == 0:
                score_matrix[0, j] = gap_penalty * j
            else:
                match_score = score_matrix[i - 1, j - 1] + score_fun(seq1[i - 1], seq2[j - 1])
                delete_score = score_matrix[i - 1, j] + gap_penalty
                insert_score = score_matrix[i, j - 1] + gap_penalty
                score_matrix[i, j] = max(match_score, delete_score, insert_score)
    
    aligned_seq1 = ''
    aligned_seq2 = ''
    i = len(seq1)
    j = len(seq2)
    # Проход с нижней правой ячейки (Для вычисления самого выравнивания)
    # начиная с правой нижней клетки и сравнивая значения в ней с тремя возможными
    # источниками (соответствие, вставка или удаление), чтобы увидеть, откуда оно появилось
    while i > 0 or j > 0:
        score = score_matrix[i][j]
        score_diag = score_matrix[i - 1][j - 1]
        score_up = score_matrix[i][j - 1]
        score_left = score_matrix[i - 1][j]

        if i > 0 and j > 0 and score == score_diag + score_fun(seq1[i - 1], seq2[j - 1]):
            aligned_seq1 += seq1[i - 1]
            aligned_seq2 += seq2[j - 1]
            i -= 1
            j -= 1
        elif i > 0 and score == score_left + gap_penalty:
            aligned_seq1 += seq1[i - 1]
            aligned_seq2 += '-'
            i -= 1
        elif j > 0 and score == score_up + gap_penalty:
            aligned_seq1 += '-'
            aligned_seq2 += seq2[j - 1]
            j -= 1
    
    while i > 0:
        aligned_seq1 += seq1[i - 1]
        aligned_seq2 += '-'
        i -= 1
    while j > 0:
        aligned_seq1 += '-'
        aligned_seq2 += seq2[j - 1]
        j -= 1
        
    if DEBUG:
        print_array(score_matrix)

    return score_matrix[-1][-1], aligned_seq1[::-1], aligned_seq2[::-1]

def print_array(matrix: list):
    for row in matrix:
        for element in row:
            print(f"{element:6}", end="")
        print()

def print_results(seq1: str, seq2: str, score: int, file = None):
    """Prints the results of the Needleman-Wunsch algorithm.

    This function takes two aligned sequences and the optimal alignment score
    as arguments. It prints the sequences and the score to the standard output
    or to a file.

    Args:
        seq1: The first aligned sequence, e.g. 'ACCGT'
        seq2: The second aligned sequence, e.g. 'AC-GT'
        score: The optimal alignment score, e.g. 10
        file: The file to print to. If None, prints to the standard output.

    Returns:
        None
    """
    if file is None:
        file = sys.stdout

    def print_subseq(i, n, s):
        print("%s: %s" % (n, s[i: i + PRINT_MAX_LINE_LENGTH]), file=file)

    print("Pairwise alignment:", file=file)
    for i in range(0, len(seq1), PRINT_MAX_LINE_LENGTH):
        print_subseq(i, 'seq1', seq1)
        print_subseq(i, 'seq2', seq2)
        print(file=file)
    print("Score: %s" % score, file=file)

def main():
    parser = argparse.ArgumentParser(description='Needleman-Wunsch algorithm')
    parser.add_argument('seq1', help='first sequence')
    parser.add_argument('seq2', help='second sequence')
    parser.add_argument('--match', type=int, help='match score')
    parser.add_argument('--mismatch', type=int, help='mismatch score')
    parser.add_argument('--gap', type=int, default=-10, help='gap penalty')
    parser.add_argument('--debug', action='store_true', help='debug mode')
    args = parser.parse_args()

    global DEBUG
    DEBUG = args.debug
    print(args.match, args.mismatch, args.gap)
    
    if args.match and args.mismatch:
        score, aln1, aln2 = needleman_wunsch(args.seq1, 
                                             args.seq2, 
                                             score_fun=lambda x, y: args.match if x == y else args.mismatch, 
                                             gap_penalty=args.gap)
    else:
        assert not args.match and not args.mismatch, "match and mismatch must be specified together"
        score, aln1, aln2 = needleman_wunsch(args.seq1, 
                                             args.seq2, 
                                             score_fun=score_fun,
                                             gap_penalty=args.gap)
    print_results(aln1, aln2, score)

    return score, aln1, aln2

if __name__ == '__main__':
    main()