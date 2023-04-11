% Лабораторная работа № 1.3 «Объектно-ориентированный
  лексический анализатор»
% 21 марта 2023 г.
% Яровикова Анастасия, ИУ9-61Б

# Цель работы
Целью данной работы является приобретение навыка реализации лексического анализатора на 
объектно-ориентированном языке без применения каких-либо средств автоматизации решения 
задачи лексического анализа.

# Индивидуальный вариант
Идентификаторы: последовательности буквенных символов Unicode и десятичных цифр, начинающиеся 
и заканчивающиеся на букву. Числовые литералы: последовательности шестнадцатеричных цифр 
(чтобы литерал не был похож на идентификатор, его можно предварять нулём, цифры в любом 
регистре). Ключевые слова: «qeq», «xx», «xxx».

# Реализация
Описанный лексический анализатор реализован на объектно-ориентированном языке Java.

класс Main:
```java
import java.io.File;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        String text = "";
        Scanner sc;

        try {
            sc = new Scanner(new File("in.txt"));
        } catch (java.io.FileNotFoundException e) {
            System.out.println(e.toString());
            return;
        }

        int i = 1;
        while (sc.hasNextLine()) {
            String l = sc.nextLine();
            text += l + "\n";
            i++;
        }

        Compiler compiler = new Compiler();
        SScanner scanner = new SScanner(text, compiler);

        System.out.println();
        System.out.println("Tokens:");

        Token t = scanner.nextToken();
        while (t.getTag() != DomainTag.EOP) {
            System.out.println(t.toString());
            t = scanner.nextToken();
            if (t.getTag() == DomainTag.EOP) {
                System.out.println(t.toString());
                break;
            }
        }
        //scanner.outputComments();
        compiler.outputMessages();
    }
}
```

класс Position:
```java
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
```

класс Fragment:
```java
public class Fragment {
    public final Position starting, following;

    Fragment(Position starting, Position following) {
        this.starting = starting;
        this.following = following;
    }

    @Override
    public String toString() {
        return starting.toString() + "-" + following.toString();
    }
}
```

класс Token:
```java
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
```

класс EOPToklen:
```java
public class EOPToken extends Token{

    public EOPToken(String image, Position starting, Position following) {
        super(DomainTag.EOP, image, starting, following);
    }

    @Override
    public String toString() {
        return super.toString();
    }
}
```

класс IdentToken:
```java
public class IdentToken extends Token {
    public int code;

    public IdentToken(int code, String image, Position starting, Position following) {
        super(DomainTag.IDENT, image, starting, following);
        this.code = code;
    }

    @Override
    public String toString() {
        return super.toString();
    }
}
```

класс KeywordToken:
```java
public class KeywordToken extends Token {

    public KeywordToken(DomainTag tag, String image, Position starting, Position following) {
        super(tag, image, starting, following);
        assert(tag == DomainTag.KEYWORD_XX || tag == DomainTag.KEYWORD_XXX ||
        tag == DomainTag.KEYWORD_QEQ);
    }

    @Override
    public String toString() {
        return super.toString();
    }
}
```

класс NumberToken:
```java
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
```

класс Message:
```java
public class Message {
    public final Boolean isError;
    public final String text;

    public Message(Boolean isError, String text) {
        this.isError = isError;
        this.text = text;
    }
}
```

класс DomainTag:
```java
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
```

класс Compiler:
```java
import java.io.BufferedReader;
import java.io.IOException;
import java.util.*;

public class Compiler {

    private SortedMap<Position, Message> messages;
    private HashMap<String, Integer> nameCodes;
    private List<String> names;

    public Compiler() {
        messages = new TreeMap<>();
        nameCodes = new HashMap<>();
        names = new ArrayList<>();
    }

    public int addName(String name) {
        if (nameCodes.containsKey(name)) {
            return nameCodes.get(name);
        } else {
            int code = names.size();
            names.add(name);
            nameCodes.put(name, code);
            return code;
        }
    }
    public String getName(int code) {
        return names.get(code);
    }
    public void addMessage(boolean isErr, Position c, String text) {
        messages.put(c, new Message(isErr, text));
    }

    public void outputMessages() {
        System.out.println("\nMessages:");
        for (Map.Entry<Position, Message> pair : messages.entrySet()) {
            System.out.print(pair.getValue().isError ? "Error" : "Warning");
            System.out.print(" " + pair.getKey() + ": ");
            System.out.println(pair.getValue().text);
        }
    }
}
```

класс SScanner:
```java
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
                    return new NumberToken(Long.parseLong(currWord, 16), currWord, start,
                                            curCopy);

                case('q'):
                    do {
                        currWord += (char)(cur.getCp());
                        cur.next();
                    } while(cur.isLetterOrDigit());

                    Position lastLetter = new Position(currWord.substring(currWord.length()-1));
                    curCopy = cur.copy();
                    if (currWord.equals("qeq")) {
                        return new KeywordToken(DomainTag.KEYWORD_QEQ, currWord, start, 
                                                curCopy);
                    } else if (!lastLetter.isLetter()) {
                        compiler.addMessage(true, start, "ident cannot end with not a letter");
                    } else {
                        return new IdentToken(compiler.addName(currWord), currWord, start, 
                                                curCopy);
                    }
                case('x'):
                    do {
                        currWord += (char)(cur.getCp());
                        cur.next();
                    } while(cur.isLetterOrDigit());
                    if (currWord.equals("xx")) {
                        return new KeywordToken(DomainTag.KEYWORD_XX, currWord, start, 
                                                    cur.copy());
                    }
                    if (currWord.equals("xxx")) {
                        return new KeywordToken(DomainTag.KEYWORD_XXX, currWord, start, 
                                                    cur.copy());
                    }
                    lastLetter = new Position(currWord.substring(currWord.length()-1));
                    curCopy = cur.copy();
                    if (!lastLetter.isLetter()) {
                        compiler.addMessage(true, start, "ident cannot end with not a letter");
                    } else {
                        return new IdentToken(compiler.addName(currWord), currWord, start, 
                                                curCopy);
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
                            return new IdentToken(compiler.addName(currWord), currWord, start, 
                                                        curCopy);
                        }
                    } else if (cur.isDigit()) {
                        int StartedWithdigit = 0;
                        Boolean isError = false;
                        do {
                            if (cur.isLetter()) {
                                if (StartedWithdigit == 1) {
                                    currWord = "";
                                    compiler.addMessage(true, start,
                                                        "ident cannot start with not a letter");
                                    isError = true;
                                    while (cur.getCp() != '\n' && cur.getCp() != ' ' &&
                                            cur.getCp() != -1) {
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
                            return new NumberToken(Long.parseLong(currWord, 16), currWord, start, 
                                                    curCopy);
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
```

# Тестирование

Входные данные

```
qeq 0fF 4rsf 1234  FF 0fF
xx 0Ab12 Ab12
xxf xxx 56
f4sdf54h
```

Вывод на `stdout`

```
Tokens:
KEYWORD_QEQ (1, 1)-(1, 4): qeq
NUMBER (1, 5)-(1, 8): 255
NUMBER (1, 14)-(1, 18): 4660
IDENT (1, 20)-(1, 22): FF
NUMBER (1, 23)-(1, 26): 255
KEYWORD_XX (2, 1)-(2, 3): xx
NUMBER (2, 4)-(2, 9): 43794
IDENT (3, 1)-(3, 4): xxf
KEYWORD_XXX (3, 5)-(3, 8): xxx
NUMBER (3, 9)-(3, 11): 86
IDENT (4, 1)-(4, 9): f4sdf54h
EOP (5, 1)-(5, 1): 

Messages:
Error (1, 9): ident cannot start with not a letter
Error (2, 10): ident cannot end with not a letter
```

# Вывод
В ходе данной лабораторной работы был получен навык реализации лексического анализатора на 
объектно-ориентированном языке без применения каких-либо средств автоматизации решения задачи 
лексического анализа. Также в соответствии с индивидуальным вариантом были реализованы необходимые 
первые фазы стадии анализа (чтение входного потока и лексических анализ). Работа была написана на 
языке Java, с особенностями которого также пришлось ознакомиться при выполнении работы.

