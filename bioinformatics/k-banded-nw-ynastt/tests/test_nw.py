import src.nw as align

# ОБОЗНАЧИМ действия: 
# С - соответствие, Н - несоотвествие, В - вставка '-'
def test_nw_1():
    """Identical sequences, match=5, mismatch=-4, gap=-10, k=1
    """
    seq1 = 'ACGT'
    seq2 = 'ACGT'
    k = 1
    # A C G T 
    # | | | | 
    # A C G T
    #  
    # С С С С => 5 * 4 = 20
    score, k, aligned_seq1, aligned_seq2 = align.k_band_needleman_wunsch(seq1, 
                                                 seq2,
                                                 k, 
                                                 score_fun=lambda x, y: 5 if x == y else -4, 
                                                 gap_penalty=-10)
    assert score == 20
    assert aligned_seq1 == 'ACGT'
    assert aligned_seq2 == 'ACGT'

def test_nw_2():
    """empty sequences, match=5, mismatch=-4, gap=0, k=1
    """
    seq1 = ''
    seq2 = ''
    k = 1
    score, k, aligned_seq1, aligned_seq2 = align.k_band_needleman_wunsch(seq1, 
                                                 seq2,
                                                 k,  
                                                 score_fun=lambda x, y: 5 if x == y else -4, 
                                                 gap_penalty=0)
    assert score == 0
    assert aligned_seq1 == ''
    assert aligned_seq2 == ''

def test_nw_3():
    """second sequence is the reversed first sequence, match=5, mismatch=-4, gap=6, k=14
    score of gap is bigger than score for match => hence its better to make gaps

    тут обратное выравнивание будет проходить по последнему столбцу и первой строке матрицы 
    => тест будет работать верно (оптимальное выравнивае будет достигнуто) при ширине полосы равной len(seq1) * 2
    """
    seq1 = 'AAAAAAACCCCCCC'
    seq2 = 'CCCCCCCAAAAAAA'
    # --------------AAAAAAACCCCCCC
    # 
    # CCCCCCCAAAAAAA--------------
    #  
    # В * 14 * 2  = 28 вставок
    # => 6 * 28  = 168
    k = 14
    score, k, aligned_seq1, aligned_seq2 = align.k_band_needleman_wunsch(seq1, 
                                                 seq2,
                                                 k, 
                                                 score_fun=lambda x, y: 5 if x == y else -4, 
                                                 gap_penalty=6)
    assert score == 168
    assert aligned_seq1 == '--------------AAAAAAACCCCCCC'
    assert aligned_seq2 == 'CCCCCCCAAAAAAA--------------'


def test_nw_4():
    """different length of sequences, but there are some overlaps, match=2, mismatch=-1, gap=-2, k=3
    
    здесь ширина полосы выбрана достаточно большой, поэтому тест пройдет
    обратное выравнивание в матрице идет практически по главной диагонали 

    погрешность на то, что строки разной длины
    """
    seq1 = 'ATCACAG'
    seq2 = 'TGCAGTAG'
    # максимально сопоставим одиноквые нуклеотиды
    # A T - C A C - A G
    #   |   | |     | |
    # - T G C A G T A G
    #  
    # В С В С С Н В С С => -2 + 2 -2 + 2 + 2 -1 -2 + 2 + 2 = 2 -1 + 2  = 3
    k = 3
    score, k, aligned_seq1, aligned_seq2 = align.k_band_needleman_wunsch(seq1, 
                                                 seq2,
                                                 k, 
                                                 score_fun=lambda x, y: 2 if x == y else -1, 
                                                 gap_penalty=-2)
    assert score == 3
    assert aligned_seq1 == 'ATCA-CAG'
    assert aligned_seq2 == 'TGCAGTAG'

def test_nw_5():
    """same length sequences, but there is overlap of 4 symbols in a row and score for match id bigger than score for mismath
    there should not be gaps
    match=3, mismatch=-2, gap=-2, k=1

    обратное выравнивание по главной диагонали, можно выбрать любую положительную ширину полосы 
    """
    seq1 = 'GTCAGTCT'
    seq2 = 'ATCAGAGT'
    
    k = 1 # при k = 0 сломается
    score, k, aligned_seq1, aligned_seq2 = align.k_band_needleman_wunsch(seq1, 
                                                 seq2,
                                                 k, 
                                                 score_fun=lambda x, y: 3 if x == y else -2, 
                                                 gap_penalty=-2)
    assert score == 9
    assert aligned_seq1 == 'GTCAGTCT'
    assert aligned_seq2 == 'ATCAGAGT'

def test_nw_6():
    """same length sequences, but there is overlap of 4 symbols in a row and score for match id bigger than score for mismath
    there should not be gaps
    match=3, mismatch=-6, gap=-2, k=1

    пример аналогичен предыдущему, но изменено значение за mismatch
    получаем не самое оптимальное выравнивание 
    """
    seq1 = 'GTCAGTCT'
    seq2 = 'ATCAGAGT'
    
    k = 1 # при k = 0 сломается
    score, k, aligned_seq1, aligned_seq2 = align.k_band_needleman_wunsch(seq1, 
                                                 seq2,
                                                 k, 
                                                 score_fun=lambda x, y: 3 if x == y else -6, 
                                                 gap_penalty=-2)
    assert score == 3
    assert aligned_seq1 == '-GTCAG-T-CT'
    assert aligned_seq2 == 'A-TCAGA-G-T'

def test_nw_7():
    """
    match=5, mismatch=-10, gap=-7, k=10
    """
    seq1 = 'CAAT'
    seq2 = 'TTAA'
    k = 1

    score, k, aligned_seq1, aligned_seq2 = align.k_band_needleman_wunsch(seq1, 
                                                 seq2,
                                                 k, 
                                                 score_fun=lambda x, y: 5 if x == y else -10, 
                                                 gap_penalty=-7)
    assert score == -14
    assert aligned_seq1 == '-CAAT'
    assert aligned_seq2 == 'TTAA-'