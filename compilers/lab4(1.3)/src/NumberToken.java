public class NumberToken extends Token {
    public long value;

    public NumberToken(long val, String image, Position starting, Position following) {
        super(DomainTag.NUMBER, Long.toString(val), starting, following);
        this.value = val;
    }

    @Override
    public String toString() {
        return super.toString();
    }
}
