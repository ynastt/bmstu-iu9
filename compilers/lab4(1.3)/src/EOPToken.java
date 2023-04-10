public class EOPToken extends Token{

    public EOPToken(String image, Position starting, Position following) {
        super(DomainTag.EOP, image, starting, following);
    }

    @Override
    public String toString() {
        return super.toString();
    }
}
