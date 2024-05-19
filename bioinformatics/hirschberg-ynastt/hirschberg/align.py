from typing import Callable, Tuple
DEBUG = False

def score_fun(a: str, 
              b: str,
              match_score: int = 5, 
              mismatch_score: int = -4) -> int:
    return match_score if a == b else mismatch_score

#  Функция, которая вычисляет последнюю строку алгоритма Нидлмана-Вунша
def get_nw_score(seq1, seq2, gap_penalty):
    '''
    Inputs:
    seq1 - first sequence
    seq2 - second sequence
    gap_penalty - score for gap in final alignment

    Outputs:
    score - array = the last line of the Needleman–Wunsch score matrix
    '''
    # Значения в score_start - начальные оценки для сравнения символов с  гэпами
    score_start = [i * gap_penalty for i in range(len(seq1) + 1)]
    # score_ инициализируется как копия score_start
    score_ = [i * gap_penalty for i in range(len(seq1) + 1)]
    # Вычисляем значения для каждой ячейки score_ 
    for i in range(1, len(seq2) + 1):
        score_[0] = i * gap_penalty
        for j in range(1, len(seq1) + 1):
            diag = score_start[j - 1] + score_fun(seq2[i - 1], seq1[j - 1])   # match
            left = score_start[j] + gap_penalty                               # delete
            up = score_[j - 1] + gap_penalty                                  # insert
            score_[j] = max(diag, left, up)
        # Обновляем список score_start по значению score_ для следующей итерации
        score_start = score_[:]
    return score_

def needleman_wunsch(seq1: str, seq2: str, score_fun: Callable = score_fun, gap_score: int = -5):

    m, n = len(seq1) + 1, len(seq2) + 1

    matrix = [[0] * n for _ in range(m)]
    
    for i in range(m):
        matrix[i][0]  = i * gap_score
    for j in range(n):
        matrix[0][j] = j * gap_score
    
    for i in range(1, m):
        for j in range(1, n):
            matrix[i][j] = max(matrix[i - 1][j - 1] + score_fun(seq1[i - 1], seq2[j - 1]), 
                               matrix[i - 1][j] + gap_score, 
                               matrix[i][j - 1] + gap_score)
    if DEBUG:
        print_array(matrix)

    score = matrix[-1][-1]
    i, j = m - 1, n - 1
    aln1 = ""
    aln2 = ""
    while i > 0 or j > 0:
        a, b = '-', '-'
        # (A, B)
        if i > 0 and j > 0 and matrix[i][j] == matrix[i-1][j-1] + score_fun(seq1[i - 1], seq2[j - 1]):
            a = seq1[i - 1]
            b = seq2[j - 1]
            i -= 1
            j -= 1

        # (A, -)
        elif i > 0 and matrix[i][j] == matrix[i - 1][j] + gap_score:
            a = seq1[i - 1]
            i -= 1

        # (-, A)
        elif j > 0 and matrix[i][j] == matrix[i][j - 1] + gap_score:
            b = seq2[j - 1]
            j -= 1     
        
        aln1 += a
        aln2 += b
    return aln1[::-1], aln2[::-1], score

def print_array(matrix: list):
    for row in matrix:
        for element in row:
            print(f"{element:6}", end="")
        print()



def hirschberg(seq1: str, 
               seq2: str, 
               score_fun: Callable = score_fun, 
               gap_score: int = -5) -> Tuple[str, str, int]:
    '''
    Inputs:
    seq1 - first sequence
    seq2 - second sequence
    score_fun - function that returns score for two symbols
    gap_score - score for gap in final alignment

    Outputs:
    aln1 - first sequence in alignment
    aln2 - second sequence in alignment
    score - score of alignment
    '''
    # Длины входных последовательностей
    len1 = len(seq1)
    len2 = len(seq2)

    # Если хотя бы одна последовательность имеет длину меньше 2, 
    # используем алгоритм Нидлмана-Вунша
    if len1 < 2 or len2 < 2:
        return needleman_wunsch(seq1, seq2, score_fun, gap_score)

    # Находим середину
    mid = len1 // 2
    # Делим на половины и высчитываем результаты для левой части и правой части
    # Для левой части используем всю seq1 и половину seq2
    # Для правой части используем перевернутые seq1 и половину se2
    left = get_nw_score(seq1, seq2[:mid], gap_score)
    right = get_nw_score(seq1[::-1], (seq2[mid:])[::-1], gap_score)[::-1]
    # Объединяем
    full = []
    for i in range(len(left)):
        full.append(left[i] + right[i])
    # Находим индекс максимального значения скора
    max_index = full.index(max(full))
    # Делим аналогично, но уже относительного максимального элемента
    # и запускаем рекурсивно наш алогритм выравнивания
    left_aln = hirschberg(seq1[:max_index], seq2[:mid], gap_score=gap_score)
    right_aln = hirschberg(seq1[max_index:], seq2[mid:], gap_score=gap_score)
    # Объединяем результаты выравнивания левой и правой рекурсии
    # print(f'left_aln[0] {left_aln[0]}')
    # print(f'left_aln[1] {left_aln[1]}')
    # print(f'right_aln[0] {right_aln[0]}')
    # print(f'right_aln[1] {right_aln[1]}')
    aln1 = left_aln[0] + right_aln[0]
    aln2 = left_aln[1] + right_aln[1]
    # Вычисляем скор выравнивания
    score = 0
    for i in range(len(aln1)):
        first = aln1[i]
        second = aln2[i]
        if first == '-' or second == '-':
            score += gap_score
        else:
            score += score_fun(first, second)

    return aln1, aln2, score


if __name__ == "__main__":    
    
    aln1, aln2, score = needleman_wunsch("ATCT", "ACT", gap_score=-5)
    
    assert len(aln1) == len(aln2)
    print(aln1)
    print(aln2)
    print(score)

    print()
    aln3, aln4, score_ = hirschberg("ATCT", "ACT", gap_score=-2)
    print(aln3)
    print(aln4)
    print(score_)

    print('\ntest1')
    aln1, aln2, score = hirschberg("ACGT", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACGT"
    assert score == 20

    print('\ntest2')
    aln1, aln2, score = hirschberg("ACG", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACG-"
    assert aln2 == "ACGT"
    assert score == 10

    print('\ntest3')
    aln1, aln2, score = hirschberg("ACGT", "ACG")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACGT"
    assert aln2 == "ACG-"
    assert score == 10

    print('\ntest4')
    aln1, aln2, score = hirschberg("ACAGT", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACAGT"
    assert aln2 == "AC-GT"
    assert score == 15

    print('\ntest5')
    aln1, aln2, score = hirschberg("ACGT", "ACAGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "AC-GT"
    assert aln2 == "ACAGT"
    assert score == 15

    print('\ntest6')
    aln1, aln2, score = hirschberg("CAGT", "ACAGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "-CAGT"
    assert aln2 == "ACAGT"
    assert score == 15

    print('\ntest7')
    aln1, aln2, score = hirschberg("ACAGT", "CAGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACAGT"
    assert aln2 == "-CAGT"
    assert score == 15

    print('\ntest8')
    aln1, aln2, score = hirschberg("ACGT", "A")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACGT"
    assert aln2 == "A---"
    assert score == -10

    print('\ntest9')
    aln1, aln2, score = hirschberg("ACGT", "")
    assert len(aln1) == len(aln2)
    assert aln1 == "ACGT"
    assert aln2 == "----"
    assert score == -20

    print('\ntest10')
    aln1, aln2, score = hirschberg("A", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "A---"
    assert aln2 == "ACGT"
    assert score == -10

    print('\ntest11')
    aln1, aln2, score = hirschberg("", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "----"
    assert aln2 == "ACGT"
    assert score == -20

    print('\ntest12')
    aln1, aln2, score = hirschberg("", "")
    assert aln1 == ""
    assert aln2 == ""
    assert score == 0

    print('\ntest13')
    aln1, aln2, score = hirschberg("TACGT", "ATGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "TACGT"
    assert aln2 == "-ATGT"
    assert score == 6

    print('\ntest14')
    aln1, aln2, score = hirschberg("TACGT", "ACTGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "TAC-GT"
    assert aln2 == "-ACTGT"
    assert score == 10
    
    print('\ntest15')
    aln1, aln2, score = hirschberg("ACGT", "TAGTA")
    assert len(aln1) == len(aln2)
    assert aln1 == "-ACGT-"
    assert aln2 == "TA-GTA"
    assert score == 0

    print('\ntest16')
    aln1, aln2, score = hirschberg("TAGTA", "ACGT")
    assert len(aln1) == len(aln2)
    assert aln1 == "TA-GTA"
    assert aln2 == "-ACGT-"
    assert score == 0

    print('\ntest17')
    aln1, aln2, score = hirschberg("ACGT", "TAGT", gap_score=0)
    assert len(aln1) == len(aln2)
    assert aln1 == "-ACGT"
    assert aln2 == "TA-GT"
    assert score == 15

    print('\ntest18')
    aln1, aln2, score = hirschberg("TAGT", "ACGT", gap_score=10)
    assert len(aln1) == len(aln2)
    assert len(aln1) == 8
    assert score == 80

    print('\ntest19')
    aln1, aln2, score = hirschberg("GGAGCCAAGGTGAAGTTGTAGCAGTGTGTCC", 
                                   "GACTTGTGGAACCTCTGTCCTCCGAGCTCTC", gap_score=-5)
    assert len(aln1) == len(aln2)
    assert len(aln1) == 36
    assert score == 8

    print('\ntest20')
    aln1, aln2, score = hirschberg("AAAAAAATTTTTTT", "TTTTTTTAAAAAAA", gap_score=-5)
    assert len(aln1) == len(aln2)
    assert len(aln1) == 21
    assert score == -35
