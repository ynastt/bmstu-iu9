public class Position implements Comparable<Position> {

    private String text;
    private int line, pos, index;

    Position(String text) {
        this.text = text;
        line = pos = 1;
        index = 0;
    }

    public Position copy() {
        Position p = new Position(this.text);
        p.setPos(this.pos);
        p.setLine(this.line);
        p.setIndex(this.index);
        return p;
    }

    // operator++
    public Position next() {
        if (index < text.length()) {
            if (isNewLine()) {
                if (text.charAt(index) == '\r') {
                    index++;
                }
                line++;
                pos = 1;
            } else {
                if (Character.isHighSurrogate(text.charAt(index))) {
                    index++;
                }
                pos++;
            }
            index++;
        }
        return this;
    }

    public int getLine() {
        return line;
    }

    public void setLine(int line) {
        this.line = line;
    }

    public int getPos() {
        return pos;
    }

    public void setPos(int pos) {
        this.pos = pos;
    }

    public int getIndex() {
        return index;
    }

    public void setIndex(int index) {
        this.index = index;
    }

    public int getCp() {
        return (index == text.length()) ?
                -1 : Character.codePointAt(text.toCharArray(), index);
    }

    public Boolean isWhiteSpace() {
        return index != text.length() &&
                Character.isWhitespace(this.getCp());
    }

    public Boolean isLetter() {
        return index != text.length() &&
                Character.isLetter(this.getCp());
    }

    public Boolean isDigit() {
        return index != text.length() &&
                Character.isDigit(this.getCp());
    }

    public Boolean isDecimalDigit() {
        return index != text.length() &&
                this.getCp() >= '0' && this.getCp() <= '9';
    }

    public Boolean isLetterOrDigit() {
        return index != text.length() &&
                Character.isLetterOrDigit(this.getCp());
    }

    public Boolean isNewLine() {
        if (index == text.length())
            return true;

        if (text.charAt(index) == '\r' && index + 1 < text.length())
            return (text.charAt(index + 1) == '\n');

        return (text.charAt(index) == '\n');
    }

    @Override
    public int compareTo(Position other) {
        return Integer.compare(this.index, other.index);
    }

    @Override
    public String toString() {
        return "(" + line + ", " + pos + ")";
    }
}
