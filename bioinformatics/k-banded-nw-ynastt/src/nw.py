from typing import Callable, Tuple
import argparse
import sys
import numpy as np

PRINT_MAX_LINE_LENGTH = 80
DEBUG = False

# скоринг-функция для вычисления оценки при сравнении двух строк
# Args:
#       a и b - строки для сравнения,
#       необязательные аргументы match_score и mismatch_score, соответствующие оценкам за совпадение и несовпадение
def score_fun(a: str, 
              b: str,
              match_score: int = 1, 
              mismatch_score: int = -1) -> int:
    return match_score if a == b else mismatch_score

# проверка, что значение х находится внутри границ
# Если x находится внутри границ, то функция 
# возвращает True, в противном случае - False.
def belongs_to_band(left, right, x):
    return left <= x <= right

# Стандартный алгоритм Нидлмана-Вунша реализован в соответствии со статьей https://ru.wikipedia.org/wiki/Алгоритм_Нидлмана_—_Вунша

# функция реализации алгоритма Нидлмана-Вунша с ограниченной шириной диагонали. Отличается от лаб №1 тем, что
# расчет матрицы ограничивается диагональной полосой шириной k
# Args:
# seq1: The first sequence, e.g. 'ACCGT'
#         seq2: The second sequence, e.g. 'ACGT'
#         score_fun: The scoring function, e.g. score_fun('A', 'A') returns 5
#         gap_penalty: The gap penalty value, e.g. -10
#      matrix - Полученная в алгоритме матрица выравнивания
# Функция возвращает кортеж из оптимальной оценки выравнивания (т.н. score), ширины полосы и двух выровенных строк
def k_band_needleman_wunsch(seq1: str,
                     seq2: str,
                     k: int,
                     score_fun: Callable[[str, str], int] = score_fun,
                     gap_penalty: int = -2) -> Tuple[int, int, str, str]:
    
    # создаем таблицу с размерами:
    height = len(seq1) + 1
    width = len(seq2) + 1
    
    # инициализируем таблицу (матрицу) и заполняем 1-ю стркоу и 1-й столбец в соответствии с k
    score_matrix = [[0] * width for _ in range(height)]

    for j in range(0, min(width, k + 1)):
        score_matrix[0][j] = gap_penalty * j

    for i in range(0, min(height, k + 1)):
        score_matrix[i][0] = i * gap_penalty

    #  Заполняем матрицу в полосе шириной k
    for i in range(1, height):
        for c in range(-k, k + 1):
            j = i + c
            #  для столбцов, что входят в полосу ширины k
            if belongs_to_band(1, width - 1, j):
                match = score_matrix[i - 1][j - 1] + score_fun(seq1[i - 1], seq2[j - 1])
                delete = score_matrix[i - 1][j] + gap_penalty
                insert = score_matrix[i][j - 1] + gap_penalty
                if belongs_to_band(-k, k, (i - 1) - j):
                    score_matrix[i][j] = max(match, delete)
                    match = score_matrix[i][j]
                if belongs_to_band(-k, k, i - (j - 1)):
                    score_matrix[i][j] = max(match, insert)

    # Процесс обратного выравнивания
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
        print(f'DEBUG PRINT\nmatrix:\n')
        print_array(score_matrix)
        print(f'seq1: {aligned_seq1}')
        print(f'seq2: {aligned_seq2}')

    return score_matrix[-1][-1], k, aligned_seq1[::-1], aligned_seq2[::-1]

# функция поэлементной печати матрицы
# Args:
#      matrix - Полученная в алгоритме матрица выравнивания
def print_array(matrix: list):
    for row in matrix:
        for element in row:
            print(f"{element:6}", end="")
        print()

# функция печати результатов алгоритма
# Args:
#      seq1 - Первая выровненная последовательность, например 'ACCGT'
#      seq2 - Вторая выровненная последовательность, например 'AC-GT'
#      k: Значение ширины полосы для алгоримта, например 2
#      score: Оптимальная оценка (т.н. score) выравнивания, например 2
#      file: Файл, в который печатаем результат (если None, печать выполняется в терминал)
def print_results(seq1: str, seq2: str, k: int, score: int, file = None):
    if file is None:
        file = sys.stdout

    def print_subseq(i, n, s):
        print("%s: %s" % (n, s[i: i + PRINT_MAX_LINE_LENGTH]), file=file)

    print("Pairwise alignment:", file=file)
    for i in range(0, len(seq1), PRINT_MAX_LINE_LENGTH):
        print_subseq(i, 'seq1', seq1)
        print_subseq(i, 'seq2', seq2)
        print(file=file)
    print("K: %d" % k)
    print("Score: %s" % score, file=file)

# старт
# прмиер запуска:
# python /src/nw.py AACGT ACGT --match5 --mismatch -4 --gap -10 --kband 5
def main():
    parser = argparse.ArgumentParser(description='Needleman-Wunsch algorithm')
    parser.add_argument('seq1', help='first sequence')
    parser.add_argument('seq2', help='second sequence')
    parser.add_argument('--match', type=int, help='match score')
    parser.add_argument('--mismatch', type=int, help='mismatch score')
    parser.add_argument('--gap', type=int, default=-10, help='gap penalty')
    parser.add_argument('--kband', type=int, default=10, help='k')
    parser.add_argument('--debug', action='store_true', help='debug mode')
    args = parser.parse_args()

    global DEBUG
    DEBUG = args.debug
    # print(args.match, args.mismatch, args.gap, args.kband)
    if args.match and args.mismatch:
        score, k, aln1, aln2 = k_band_needleman_wunsch(args.seq1, 
                                             args.seq2,
                                             args.kband, 
                                             score_fun=lambda x, y: args.match if x == y else args.mismatch, 
                                             gap_penalty=args.gap)
    else:
        assert not args.match and not args.mismatch, "match and mismatch must be specified together"
        score, k, aln1, aln2 = k_band_needleman_wunsch(args.seq1, 
                                             args.seq2,
                                             args.kband, 
                                             score_fun=score_fun,
                                             gap_penalty=args.gap)
    print_results(aln1, aln2, k, score)

    return score, aln1, aln2

if __name__ == '__main__':
    main()