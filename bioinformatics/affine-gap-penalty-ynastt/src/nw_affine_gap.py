from typing import Callable, Tuple

DEBUG = False

#  modified function for printing my RES table
def print_array(matrix: list):
    print('result table:')
    for row in matrix:
        for element in row:
            print(f"{element[0]}", end="") # modified for printing RES table
        print()
    print()

def score_fun(a: str, 
              b: str,
              match_score: int = 5, 
              mismatch_score: int = -4) -> int:
    return match_score if a == b else mismatch_score

def needleman_wunsch_affine(seq1: str, 
                            seq2: str, 
                            score_fun: Callable = score_fun, 
                            gap_open: int = -10, 
                            gap_extend: int = -1) -> Tuple[str, str, int]:
    '''
    Inputs:
    seq1 - first sequence
    seq2 - second sequence
    score_fun - function that takes two characters and returns score
    gap_open - gap open penalty
    gap_extend - gap extend penalty
    Outputs:
    aln1 - first aligned sequence
    aln2 - second aligned sequence
    score - score of the alignment
    '''

    #infinity = 2 * gap_open + (n + m - 2) * gap_extend + 1
    # infinity >= 2 * open + (n + m) * extend + 1
    infinity = float('-inf')

    # 1. Initialize matrices
    n = len(seq1) + 1
    m = len(seq2) + 1
    # for (A, A)
    M = [[0 for _ in range(m)] for _ in range(n)] 
    # for (A, -)
    I = [[0 for _ in range(m)] for _ in range(n)]
    # for (-, A)
    D = [[0 for _ in range(m)] for _ in range(n)]

    # RES - matrix of pairs [score, flag]
    # flag can be set to:
    # 0 - For match/mismatch,
    # 1 - For insertion
    # 2 - For deletion
    RES = [[[0, 2] for _ in range(m)] for _ in range(n)]

    I[0][0], D[0][0] = infinity, infinity
    # RES[0][0] = [0, 2]

    for i in range(1, n):
        M[i][0] = infinity
        I[i][0] = gap_open + (i - 1) * gap_extend
        D[i][0] = infinity
        RES[i][0] = [I[i][0], 2]

    for j in range(1, m):
        M[0][j] = infinity
        I[0][j] = infinity
        D[0][j] = gap_open + (j - 1) * gap_extend
        RES[0][j] = [D[0][j], 1]

    # 2. Fill matrices
    # We assume that consecutive gaps on different sequences are not allowed
    for i in range(1, n):
        for j in range(1, m):
            cost = score_fun(seq1[i - 1], seq2[j - 1])
            # Match / Mismatch (A, A)
            M[i][j] = max(
                M[i - 1][j - 1],
                I[i - 1][j - 1],
                D[i - 1][j - 1]) + cost
            # Insertion (A, -)
            I[i][j] = max(
                I[i][j - 1] + gap_extend, 
                M[i][j - 1] + gap_open)
            # Deletion (-, A)
            D[i][j] = max(
                D[i - 1][j] + gap_extend, 
                M[i - 1][j] + gap_open)
            
            res_score = max(M[i][j], I[i][j], D[i][j])
            if res_score == D[i][j]:
                RES[i][j] = [res_score, 2]
            elif res_score == I[i][j]:
                RES[i][j] = [res_score, 1]
            elif res_score == M[i][j]:
                RES[i][j] = [res_score, 0]
            
    # print_array(RES)

    # 3. Traceback
    aln1 = ''
    aln2 = ''
    i = len(seq1)
    j = len(seq2)
    while i > 0 or j > 0:
        flag = RES[i][j][1]
        if flag == 0: # if match/mismatch
            aln1 += seq1[i - 1]
            aln2 += seq2[j - 1]
            i -= 1
            j -= 1
        elif flag == 1: # if insertion
            aln1 += "-"
            aln2 += seq2[j - 1]
            j -= 1
        elif flag == 2: # if deletion
            aln1 += seq1[i - 1]
            aln2 += "-"
            i -= 1

    # print_array(RES)
    
    # result square of table
    score = RES[n - 1][m - 1]
    print(f'result score: {score[0]}')
    print(f'last action: {score[1]}') # 0 - For match/mismatch, # 1 - For insertion, # 2 - For deletion
    return aln1[::-1], aln2[::-1], score[0]

def main():
    aln1, aln2, score = needleman_wunsch_affine("ACGT", "TAGT", gap_open=-10, gap_extend=-1) 
    print(f'str 1: {aln1}')
    print(f'str 2: {aln2}')
    print(f'score: {score}')
    

if __name__ == "__main__":
    main()

    print("\nTest 1")
    aln1, aln2, score = needleman_wunsch_affine("ACGT", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACGT"
    assert score == 20

    print("\nTest 2")
    aln1, aln2, score = needleman_wunsch_affine("ACG", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACG-"
    assert aln2 == "ACGT"
    assert score == 5

    print("\nTest 3")
    aln1, aln2, score = needleman_wunsch_affine("ACGT", "ACG")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACGT"
    assert aln2 == "ACG-"
    assert score == 5

    print("\nTest 4")
    aln1, aln2, score = needleman_wunsch_affine("ACAGT", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACAGT"
    assert aln2 == "AC-GT"
    assert score == 10

    print("\nTest 5")
    aln1, aln2, score = needleman_wunsch_affine("ACGT", "ACAGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "AC-GT"
    assert aln2 == "ACAGT"
    assert score == 10

    print("\nTest 6")
    aln1, aln2, score = needleman_wunsch_affine("CAGT", "ACAGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "-CAGT"
    assert aln2 == "ACAGT"
    assert score == 10

    print("\nTest 7")
    aln1, aln2, score = needleman_wunsch_affine("ACAGT", "CAGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACAGT"
    assert aln2 == "-CAGT"
    assert score == 10

    print("\nTest 8")
    aln1, aln2, score = needleman_wunsch_affine("ACGT", "A")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACGT"
    assert aln2 == "A---"
    assert score == -7

    print("\nTest 9")
    aln1, aln2, score = needleman_wunsch_affine("ACGT", "")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACGT"
    assert aln2 == "----"
    assert score == -13

    print("\nTest 10")
    aln1, aln2, score = needleman_wunsch_affine("A", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "A---"
    assert aln2 == "ACGT"
    assert score == -7

    print("\nTest 11")
    aln1, aln2, score = needleman_wunsch_affine("", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "----"
    assert aln2 == "ACGT"
    assert score == -13

    print("\nTest 12")
    aln1, aln2, score = needleman_wunsch_affine("", "")
    assert aln1 == ""
    assert aln2 == ""
    assert score == 0

    print("\nTest 13")
    aln1, aln2, score = needleman_wunsch_affine("TACGT", "ATGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "TACGT"
    assert aln2 == "-ATGT"
    assert score == 1

    print("\nTest 14")
    aln1, aln2, score = needleman_wunsch_affine("TACGT", "ACTGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "TAC-GT"
    assert aln2 == "-ACTGT"
    assert score == 0
    
    print("\nTest 15")
    aln1, aln2, score = needleman_wunsch_affine("ACGT", "TAGTA")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACGT-"
    assert aln2 == "TAGTA"
    assert score == -8

    print("\nTest 16")
    aln1, aln2, score = needleman_wunsch_affine("TAGTA", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "TAGTA"
    assert aln2 == "ACGT-"
    assert score == -8

    print("\nTest 17")
    aln1, aln2, score = needleman_wunsch_affine("ACGT", "TAGT", gap_open=-1, gap_extend=0)
    assert len(aln1) == len(aln2)
    assert aln1 == "-ACGT"
    assert aln2 == "TA-GT"
    assert score == 13

    print("\nTest 18")
    aln1, aln2, score = needleman_wunsch_affine("TAGT", "ACGT", gap_open=10, gap_extend=10)
    assert len(aln1) == len(aln2)
    assert len(aln1) == 8
    assert score == 80

    print("\nTest 19")
    aln1, aln2, score = needleman_wunsch_affine("GGAGCCAAGGTGAAGTTGTAGCAGTGTGTCC", 
                                   "GACTTGTGGAACCTCTGTCCTCCGAGCTCTC", gap_open=-5, gap_extend=-5)
    assert len(aln1) == len(aln2)
    assert len(aln1) == 36
    assert score == 8

    print("\nTest 20")
    aln1, aln2, score = needleman_wunsch_affine("AAAAAAATTTTTTT", "TTTTTTTAAAAAAA", gap_open=-5, gap_extend=-5)
    assert len(aln1) == len(aln2)
    assert len(aln1) == 21
    assert score == -35

    print("\nTest 21")
    aln1, aln2, score = needleman_wunsch_affine("ACGGCTT", "ACGT")
    assert aln1 == "ACGGCTT"
    assert aln2 == "ACG---T"
    assert score == 8

    print("\nTest 22")
    aln1, aln2, score = needleman_wunsch_affine("ACGT", "TAGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACGT"
    assert aln2 == "TAGT"
    assert score == 2