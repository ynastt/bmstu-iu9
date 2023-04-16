import java.util.ArrayList;
import java.util.List;

public class SScanner {
    public final String program;

    private Compiler compiler;
    private Position cur;
    private List<Fragment> comments;

    public SScanner(String program, Compiler compiler) {
        this.compiler = compiler;
        this.cur = new Position(program);
        this.program = program;
        this.comments = new ArrayList<>();
    }

    public void outputComments() {
        System.out.println("\nComments:");

        for (Fragment f : comments) {
            int commStart = f.starting.getIndex();
            int commEnd = f.following.getIndex();
            System.out.println(f.toString() + ": " +
                    program.substring(commStart, commEnd).replaceAll("\n", " "));
        }
    }

    public Token nextToken() {
        if (cur.getCp() == -1) {
            return new EOPToken("", cur.copy() , cur.copy());
        }
        while (cur.getCp() != -1){
            while (cur.isWhiteSpace())
                cur.next();
            Position start = cur.copy();
            String currWord = "";
            Position curCopy;

            switch(cur.getCp()) {
                case('0'):
                    currWord = "";
                    while(cur.isLetterOrDigit()) {
                        currWord += (char)(cur.getCp());
                        cur.next();
                    }
                    curCopy = cur.copy();
                    return new NumberToken(Long.parseLong(currWord, 16), currWord, start, curCopy);

                case('q'):
                    do {
                        currWord += (char)(cur.getCp());
                        cur.next();
                    } while(cur.isLetterOrDigit());

                    Position lastLetter = new Position(currWord.substring(currWord.length()-1));
                    curCopy = cur.copy();
                    if (currWord.equals("qeq")) {
                        return new KeywordToken(DomainTag.KEYWORD_QEQ, currWord, start, curCopy);
                    } else if (!lastLetter.isLetter()) {
                        compiler.addMessage(true, start, "ident cannot end with not a letter");
                    } else {
                        return new IdentToken(compiler.addName(currWord), currWord, start, curCopy);
                    }
                case('x'):
                    do {
                        currWord += (char)(cur.getCp());
                        cur.next();
                    } while(cur.isLetterOrDigit());
                    if (currWord.equals("xx")) {
                        return new KeywordToken(DomainTag.KEYWORD_XX, currWord, start, cur.copy());
                    }
                    if (currWord.equals("xxx")) {
                        return new KeywordToken(DomainTag.KEYWORD_XXX, currWord, start, cur.copy());
                    }
                    lastLetter = new Position(currWord.substring(currWord.length()-1));
                    curCopy = cur.copy();
                    if (!lastLetter.isLetter()) {
                        compiler.addMessage(true, start, "ident cannot end with not a letter");
                    } else {
                        return new IdentToken(compiler.addName(currWord), currWord, start, curCopy);
                    }

                default:
                    if (cur.isLetter()) {
                        do {
                            currWord += (char)(cur.getCp());
                            cur.next();
                        } while(cur.isLetterOrDigit());
                        lastLetter = new Position(currWord.substring(currWord.length()-1));
                        curCopy = cur.copy();
                        if (!lastLetter.isLetter()) {
                            compiler.addMessage(true, start, "ident cannot end with not a letter");
                        } else {
                            return new IdentToken(compiler.addName(currWord), currWord, start, curCopy);
                        }
                    } else if (cur.isDigit()) {
                        int StartedWithdigit = 0;
                        Boolean isError = false;
                        do {
                            if (cur.isLetter()) {
                                if (StartedWithdigit == 1) {
                                    currWord = "";
                                    compiler.addMessage(true, start, "ident cannot start with not a letter");
                                    isError = true;
                                    while (cur.getCp() != '\n' && cur.getCp() != ' ' && cur.getCp() != -1) {
                                        cur.next();
                                    }

                                }
                            } else {
                                StartedWithdigit = 1;
                                currWord += (char)(cur.getCp());
                                cur.next();
                            }
                        } while(cur.isLetterOrDigit());
                        curCopy = cur.copy();
                        if (!isError) {
                            return new NumberToken(Long.parseLong(currWord, 16), currWord, start, curCopy);
                        }
                    } else {
                        while (cur.getCp() != '\n' && cur.getCp() != ' ' && cur.getCp() != -1) {
                            cur.next();
                        }
                    }
            }
            cur.next();
        }
        return new EOPToken("", cur.copy() , cur.copy());
    }
}
