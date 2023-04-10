public enum DomainTag {
    IDENT(0),
    NUMBER(1),
    KEYWORD_QEQ(2),
    KEYWORD_XX(3),
    KEYWORD_XXX(4),
    EOP(5);

    private final int val;

    DomainTag(int val) {
        this.val = val;
    }
}