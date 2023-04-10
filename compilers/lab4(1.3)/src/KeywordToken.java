public class KeywordToken extends Token {

    public KeywordToken(DomainTag tag, String image, Position starting, Position following) {
        super(tag, image, starting, following);
        assert(tag == DomainTag.KEYWORD_XX || tag == DomainTag.KEYWORD_XXX || tag == DomainTag.KEYWORD_QEQ);
    }

    @Override
    public String toString() {
        return super.toString();
    }
}