public abstract class Token {
    private DomainTag tag;
    private Fragment coords;
    private String val;

    Token(DomainTag tag, String value, Position starting, Position following) {
        this.tag = tag;
        this.coords = new Fragment(starting, following);
        this.val = value;
    }

    public DomainTag getTag(){
        return this.tag;
    }

    @Override
    public String toString() {
        return tag.toString() + " " + coords.toString() + ": " + val;
    }
}