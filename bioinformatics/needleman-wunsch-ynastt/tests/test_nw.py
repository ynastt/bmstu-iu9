import src.nw as align

# ОБОЗНАЧИМ действия: 
# С - соответствие, Н - несоотвествие, В - вставка '-'
def test_nw_1():
    """Identical sequences, match=5, mismatch=-4, gap=-10
    """
    seq1 = 'ACGT'
    seq2 = 'ACGT'
    # A C G T 
    # | | | | 
    # A C G T
    #  
    # С С С С => 5 * 4 = 20
    score, aligned_seq1, aligned_seq2 = align.needleman_wunsch(seq1, 
                                                 seq2, 
                                                 score_fun=lambda x, y: 5 if x == y else -4, 
                                                 gap_penalty=-10)
    assert score == 20
    assert aligned_seq1 == 'ACGT'
    assert aligned_seq2 == 'ACGT'

def test_nw_2():
    """empty sequences, match=5, mismatch=-4, gap=0
    """
    seq1 = ''
    seq2 = ''
    score, aligned_seq1, aligned_seq2 = align.needleman_wunsch(seq1, 
                                                 seq2, 
                                                 score_fun=lambda x, y: 5 if x == y else -4, 
                                                 gap_penalty=0)
    assert score == 0
    assert aligned_seq1 == ''
    assert aligned_seq2 == ''

def test_nw_3():
    """second sequence is the reversed first sequence, match=5, mismatch=-4, gap=6
    score of gap is bigger than score for match => hence its better to make gaps
    """
    seq1 = 'AAAAAAACCCCCCC'
    seq2 = 'CCCCCCCAAAAAAA'
    # --------------AAAAAAACCCCCCC
    # 
    # CCCCCCCAAAAAAA--------------
    #  
    # В * 14 * 2  = 28 вставок
    # => 6 * 28  = 168
    score, aligned_seq1, aligned_seq2 = align.needleman_wunsch(seq1, 
                                                 seq2, 
                                                 score_fun=lambda x, y: 5 if x == y else -4, 
                                                 gap_penalty=6)
    assert score == 168
    assert aligned_seq1 == '--------------AAAAAAACCCCCCC'
    assert aligned_seq2 == 'CCCCCCCAAAAAAA--------------'


def test_nw_3():
    """different length of sequences, but there are some overlaps, match=2, mismatch=-1, gap=-2
    """
    seq1 = 'ATCACAG'
    seq2 = 'TGCAGTAG'
    # максимально сопоставим одиноквые нуклеотиды
    # A T - C A C - A G
    #   |   | |     | |
    # - T G C A G T A G
    #  
    # В С В С С Н В С С => -2 + 2 -2 + 2 + 2 -1 -2 + 2 + 2 = 2 -1 + 2  = 3

    score, aligned_seq1, aligned_seq2 = align.needleman_wunsch(seq1, 
                                                 seq2, 
                                                 score_fun=lambda x, y: 2 if x == y else -1, 
                                                 gap_penalty=-2)
    assert score == 3
    assert aligned_seq1 == 'ATCA-CAG'
    assert aligned_seq2 == 'TGCAGTAG'

def test_nw_4():
    """same length sequences, but there is overlap of 4 symbols in a row and score for match id bigger than score for mismath
    there should not be gaps
    match=3, mismatch=-2, gap=-2
    """
    seq1 = 'GTCAGTCT'
    seq2 = 'ATCAGAGT'
    # максимально сопоставим одиноквые нуклеотиды
    # G T C A G T C T
    #   | | | |     |
    # A T C A G A G T
    #  
    # Н С С С С Н Н С => -2 + 3 + 3 + 3 + 3 -2 -2 + 3 = 9

    score, aligned_seq1, aligned_seq2 = align.needleman_wunsch(seq1, 
                                                 seq2, 
                                                 score_fun=lambda x, y: 3 if x == y else -2, 
                                                 gap_penalty=-2)
    assert score == 9
    assert aligned_seq1 == 'GTCAGTCT'
    assert aligned_seq2 == 'ATCAGAGT'