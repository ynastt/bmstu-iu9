% Лабораторная работа № 2.3 «Синтаксический анализатор на основе
  предсказывающего анализа»
% 18 апреля 2023 г.
% Яровикова Анастасия, ИУ9-61Б

# Цель работы
Целью данной работы является изучение алгоритма построения таблиц предсказывающего анализатора.

# Индивидуальный вариант
```
' аксиома
<axiom <E>>
' правила грамматики
<E    <T E'>>
<E'   <+ T E'> <>> 
<T    <F T'>>
<T'   <* F T'> <>>
<F    <n> <( E )>>
```

# Реализация

## Неформальное описание синтаксиса входного языка
В качестве входного языка выступает язык представления правил грамматики, 
лексика и синтаксис которого восстанавливаются из примера в индивидуальном варианте.
Отметим, что каждое определение грамматики заключено в угловых скобках.
Таким образом, имеем:  
`PROG ::= StartBrace DEF EndBrace PROG | $$\varepsilon$$`  
где PROG - программа (входной текст), StartBrace и EndBrace - угловые скобк,
DEF - определение грамматики.  
При этом определение представляет собой либо правило переписывания нетерминала, 
либо аксиому:  
`DEF ::= RULE | AXIOM`  
Правило грамматики выглядит как нетерминальный символ, за которым следует правая
часть правила в виде перечисления альтернатив:  
`RULE ::= NonTerm RP`  
Аксиома начинается с ключевого слова "axiom", после которого следует нетерминал в 
угловых скобках:  
`AXIOM ::= AxiomSign StartBrace NonTerm EndBrace`  
Каждая правая часть правила представляет собой последовательность альтернатив, 
заключенных в угловые скобки:  
`RP ::= StartBody BODY EndBrace RP | $$\varepsilon$$`  
А сама альтернатива, расположенная внутри угловых скобок является последовательностью
терминальных и нетерминальных символов:  
`BODY ::= NonTerm BODY | Term BODY | $$\varepsilon$$`  

Таким образом, имеем следующие токены:  
- Терминал (имя с маленькой буквы или знак пунктуации, кроме угловых скобок);  
- Нетерминал (имя с заглавной буквы, с возможной одинарной кавычкой после);  
- Ключевое слово "axiom";  
- Открывающие и закрывающие угловые кавычки.

## Лексическая структура
StartBrace ::= '<'  
EndBrace ::= '>'  
Term ::= 'a' | 'b' | ... | 'z' | '+' | '*' | '(' | ')'  
NonTerm ::= 'A' | 'B' | ... | 'Z' | 'A'' | 'B'' | ... | 'Z''  
AxiomSign ::= "axiom"  
Comment ::= '.*   
(то есть комментарий это любые слова после одинарной кавычки)

## Грамматика языка
PROG ::= StartBrace DEF EndBrace PROG | $\varepsilon$  
DEF ::= RULE | AXIOM  
AXIOM ::= AxiomSign StartBrace NonTerm EndBrace  
RULE ::= NonTerm RP  
RP ::= StartBody BODY EndBrace RP | $\varepsilon$ 
BODY ::= NonTerm BODY | Term BODY | $\varepsilon$  

## Программная реализация

Класс Main
```java
package com.company;
import java.io.*;
import java.util.ArrayList;

public class Main {
    public static void main(String args[]){
        ArrayList<Fragment> comments  = new ArrayList<>();
        int indInFile = 0;
        ArrayList<Token> tokens = new ArrayList<Token>();
        try(BufferedReader b = new BufferedReader(new FileReader("test.txt")))
        {
            String str;
            str = b.readLine();
            while(str != null ){
                indInFile++;
                Lexer ide = new Lexer();
                ArrayList<Token> t = ide.main(str, indInFile);
                tokens.addAll(t);
                comments.addAll(ide.getComments());
                str = b.readLine();
            }
        }
        catch(IOException ex){
            System.out.println(ex.getMessage());
        }

        Token t = new Token();
        t.type = "EOF";
        tokens.add(t);
        Parser parser = new Parser();
        parser.init_table();
        System.out.println("\nTREE:");
        Node tree = parser.topDownParse(tokens);
        tree.print("");
        System.out.println("\nCOMMENTS:");
        for(Fragment comm : comments){
            System.out.println(comm.toString());
        }
    }
}
```

Класс Lexer
```java
package com.company;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.ArrayList;

public class Lexer {
    ArrayList<Token> tokens = new ArrayList<Token>();
    private ArrayList<Fragment> comments = new ArrayList<>();
    public void match(String text, int line){

        String Term = "\\s*(a(!?=x)|[b-z+*)(])";
        String NonTerm = "\\s*[A-Z]+'?";
        String AxiomSign = "axiom";
        String StartBrace =  "<";
        String EndBrace = ">";
        String comment = "\\'.*";
        String pattern = "(?<Term>^" + Term + ")|(?<NonTerm>^" + NonTerm +
                ")|(?<comment>^" + comment + ")|(?<AxiomSign>^" + AxiomSign +
                ")|(?<StartBrace>^" + StartBrace + ")|(?<EndBrace>^" + EndBrace + ")";

        Pattern p = Pattern.compile(pattern);
        boolean flag = true;
        boolean wasStart = false;
        String cur = text;
        int start = 0;
        int index = 0;
        while (flag) {
            if (text.length() == 0) {
                flag = false;
            } else {
                if (m.find()) {
                    if (m.group("comment") != null) {
                        if (m.group("comment") == text) {
                            flag = false;
                        }
                        Position s = new Position(line, index);
                        index += m.group("comment").length();
                        Position e = new Position(line, index);
                        Fragment f = new Fragment(m.group("comment"), s, e);
                        comments.add(f);
                        text = text.substring(m.group("comment").length());

                    } else if (m.group("AxiomSign") != null) {
                        if (m.group("AxiomSign") == text) {
                            flag = false;
                        }
                        Token token = new Token();
                        token.token = m.group("AxiomSign");
                        token.type = "AxiomSign";
                        index += m.group("AxiomSign").length();
                        token.column = index;
                        token.row = line;
                        this.tokens.add(token);
                        text = text.substring(m.group("AxiomSign").length());

                    } else if (m.group("StartBrace") != null) {
                        if (m.group("StartBrace") == text) {
                            flag = false;
                        }
                        Token token = new Token();
                        token.token = m.group("StartBrace");
                        token.type = "StartBrace";
                        if (start == 0) {
                            text = text.substring(1);
                            start++;
                        } else {
                            text = text.substring(m.group("StartBrace").length());
                        }
                        index += m.group("StartBrace").length();
                        token.column = index;
                        token.row = line;
                        this.tokens.add(token);

                    } else if (m.group("EndBrace") != null) {
                        if (m.group("EndBrace") == text) {
                            flag = false;
                        }
                        Token token = new Token();
                        token.token = m.group("EndBrace");
                        token.type = "EndBrace";
                        index += m.group("EndBrace").length();
                        token.column = index;
                        token.row = line;
                        this.tokens.add(token);
                        text = text.substring(m.group("EndBrace").length());

                    } else if (m.group("Term") != null){
                        if (m.group("Term") == text) {
                            flag = false;
                        }
                        Token token = new Token();
                        token.token = m.group("Term");
                        token.type = "Term";
                        index += m.group("Term").length();
                        token.column = index;
                        token.row = line;
                        this.tokens.add(token);
                        text = text.substring(m.group("Term").length());

                    } else if (m.group("NonTerm") != null){
                        if (m.group("NonTerm") == text) {
                            flag = false;
                        }
                        Token token = new Token();
                        token.token = m.group("NonTerm");
                        token.type = "NonTerm";
                        index += m.group("NonTerm").length();
                        token.column = index;
                        token.row = line;
                        this.tokens.add(token);
                        text = text.substring(m.group("NonTerm").length());
                    }
                } else {
                    index++;
                    if (text.charAt(0) != ' ') {
                        System.out.println(String.format("syntax error (%s-%s)", line, index));
                    }
                    text = text.substring(1);
                }
            }
        }
    }

    public ArrayList<Fragment> getComments() {
        return this.comments;
    }
    
    public ArrayList<Token> main(String text, int lineNum) {
        match(text, lineNum);
        return this.tokens;
    }
}
```

Класс Parser
```java
package com.company;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Stack;

public class Parser {
    HashMap<String, String[]> crossing = new HashMap<String, String[]>();
    void init_table() {
        this.crossing.put("PROG StartBrace", new String[]{"StartBrace", "DEF", "EndBrace", "PROG"});
        this.crossing.put("PROG EOF", new String[]{});
        this.crossing.put("DEF NonTerm", new String[]{"RULE"});
        this.crossing.put("DEF AxiomSign", new String[]{"AXIOM"});
        this.crossing.put("AXIOM AxiomSign", new String[]{"AxiomSign", "StartBrace", "NonTerm", "EndBrace"});
        this.crossing.put("RULE NonTerm", new String[]{"NonTerm", "RP"});
        this.crossing.put("RP StartBrace", new String[]{"StartBrace", "BODY", "EndBrace", "RP"});
        this.crossing.put("RP EndBrace", new String[]{});
        this.crossing.put("BODY NonTerm", new String[]{"NonTerm", "BODY"});
        this.crossing.put("BODY Term", new String[]{"Term", "BODY"});
        this.crossing.put("BODY EndBrace", new String[]{});
    }

    boolean isTerminal(String s){
       return !(s == "PROG" || s == "DEF" || s == "AXIOM" || s == "RULE" || s == "RP" || s == "BODY");
    }

    Node topDownParse(ArrayList<Token> tokens) {
        Inner sparent = new Inner();    // Фиктивный родитель для аксиомы
        Stack<Inner> stackIn = new Stack<Inner>();
        Stack<String> stackStr = new Stack<String>();
        stackIn.push(sparent);
        stackStr.push("PROG");
        int i = 0;
        // next token
        Token a = tokens.get(i);
        i++;
        while(i < tokens.size()) {

            Inner parent = stackIn.pop();
            String X = stackStr.pop();
            if (isTerminal(X)) {
                if (X.equals(a.type)) {
                    parent.children.add(new Leaf(a));
                    a = tokens.get(i);
                    i++;
                } else {
                    this.err("11 Ожидался " + X + ", получен " + a.type, a);
                }
            } else if (crossing.containsKey(X + " " + a.type)) {
                Inner inner = new Inner();
                inner.nterm = X;
                inner.children = new ArrayList<>();
                parent.children.add(inner);
                String[] array = crossing.get(X + " " + a.type);
                for (int j = array.length - 1; j >= 0; j--) {
                    stackIn.push(inner);
                    stackStr.push(array[j]);
                }
            } else {
                this.err("22 Ожидался " + X + ", получен " + a.type, a);
            }
        }
        return sparent.children.get(0);
    }

    void err(String err_str, Token tok) {
        System.out.print("(" + tok.row + "," + tok.column + ") ");
        System.out.println("" + err_str);
    }
}
```

Класс Token
```java
package com.company;

public class Token {
    int column;
    int row;
    String token;
    String type;
}
```

Классы Node, Inner, Leaf
```java
package com.company;
import java.util.ArrayList;

abstract public class Node {
    abstract void print(String indent);
}

public class Inner extends Node {
    String nterm;
    ArrayList<Node> children = new ArrayList<>();
    public Inner() {
        this.nterm = "";
        this.children = new ArrayList<>();
    }
    void print(String indent) {
        System.out.println(indent + "Внутренний узел: " + nterm);
        for (int i = 0; i < children.size(); i++) {
            Node child = children.get(i);
            child.print(indent + "\t");
        }
    }
}

public class Leaf extends Node {
    Token tok;

    public Leaf(Token a) {
        this.tok = a;
    }

    void print(String indent) {
        if (tok.type.equals("Term") || tok.type.equals("NonTerm") || 
            tok.type.equals("StartBrace") || tok.type.equals("EndBrace") {
            System.out.println(indent + String.format("Лист: %s\t%s", 
                tok.type, tok.token));
        } else {
            System.out.println(indent + "Лист: " + tok.type);
        }
    }
}
```

Классы Position, Fragment
```java
package com.company;

public class Position {
    private final int row, column;

    public Position(int row, int column) {
        this.row = row;
        this.column = column;
    }

    @Override
    public String toString() {
        return  String.format("(%d, %d)", row, column);
    }
}

public class Fragment {
    private String image;
    private Position start, follow;

    public Fragment(String image, Position start, Position follow) {
        this.image = image;
        this.start = start;
        this.follow = follow;
    }

    @Override
    public String toString(){
        return String.format("COMMENT %s-%s:\t%s", start, follow, image);
    }
}
```

# Тестирование

Входные данные

```
' аксиома
<axiom <E>>

' правила грамматики
<E    <T E'>>
<E'    <+ T E'> <>>
<T    <F T'>  >
```

Вывод на `stdout`

```
TREE:
Внутренний узел: PROG
	Лист: StartBrace	<
	Внутренний узел: DEF
		Внутренний узел: AXIOM
			Лист: AxiomSign
			Лист: StartBrace	<
			Лист: NonTerm	E
			Лист: EndBrace	>
	Лист: EndBrace	>
	Внутренний узел: PROG
		Лист: StartBrace	<
		Внутренний узел: DEF
			Внутренний узел: AXIOM
				Лист: AxiomSign
				Лист: StartBrace	<
				Лист: NonTerm	E
				Лист: EndBrace	>
		Лист: EndBrace	>
		Внутренний узел: PROG
			Лист: StartBrace	<
			Внутренний узел: DEF
				Внутренний узел: RULE
					Лист: NonTerm	E
					Внутренний узел: RP
						Лист: StartBrace	<
						Внутренний узел: BODY
							Лист: NonTerm	T
							Внутренний узел: BODY
								Лист: NonTerm	 E'
								Внутренний узел: BODY
						Лист: EndBrace	>
						Внутренний узел: RP
			Лист: EndBrace	>
			Внутренний узел: PROG
				Лист: StartBrace	<
				Внутренний узел: DEF
					Внутренний узел: RULE
						Лист: NonTerm	E
						Внутренний узел: RP
							Лист: StartBrace	<
							Внутренний узел: BODY
								Лист: NonTerm	T
								Внутренний узел: BODY
									Лист: NonTerm	 E'
									Внутренний узел: BODY
							Лист: EndBrace	>
							Внутренний узел: RP
				Лист: EndBrace	>
				Внутренний узел: PROG
					Лист: StartBrace	<
					Внутренний узел: DEF
						Внутренний узел: RULE
							Лист: NonTerm	E'
							Внутренний узел: RP
								Лист: StartBrace	<
								Внутренний узел: BODY
									Лист: Term	+
									Внутренний узел: BODY
										Лист: NonTerm	 T
										Внутренний узел: BODY
											Лист: NonTerm	 E'
											Внутренний узел: BODY
								Лист: EndBrace	>
								Внутренний узел: RP
									Лист: StartBrace	<
									Внутренний узел: BODY
									Лист: EndBrace	>
									Внутренний узел: RP
					Лист: EndBrace	>
					Внутренний узел: PROG
						Лист: StartBrace	<
						Внутренний узел: DEF
							Внутренний узел: RULE
								Лист: NonTerm	E'
								Внутренний узел: RP
									Лист: StartBrace	<
									Внутренний узел: BODY
										Лист: Term	+
										Внутренний узел: BODY
											Лист: NonTerm	 T
											Внутренний узел: BODY
												Лист: NonTerm	 E'
												Внутренний узел: BODY
									Лист: EndBrace	>
									Внутренний узел: RP
										Лист: StartBrace	<
										Внутренний узел: BODY
										Лист: EndBrace	>
										Внутренний узел: RP
						Лист: EndBrace	>
						Внутренний узел: PROG
							Лист: StartBrace	<
							Внутренний узел: DEF
								Внутренний узел: RULE
									Лист: NonTerm	T
									Внутренний узел: RP
										Лист: StartBrace	<
										Внутренний узел: BODY
											Лист: NonTerm	F
											Внутренний узел: BODY
												Лист: NonTerm	 T'
												Внутренний узел: BODY
										Лист: EndBrace	>
										Внутренний узел: RP
							Лист: EndBrace	>
							Внутренний узел: PROG
								Лист: StartBrace	<
								Внутренний узел: DEF
									Внутренний узел: RULE
										Лист: NonTerm	T
										Внутренний узел: RP
											Лист: StartBrace	<
											Внутренний узел: BODY
												Лист: NonTerm	F
												Внутренний узел: BODY
													Лист: NonTerm	 T'
													Внутренний узел: BODY
											Лист: EndBrace	>
											Внутренний узел: RP
								Лист: EndBrace	>

COMMENTS:
COMMENT (1, 0)-(1, 9):	' аксиома
COMMENT (4, 0)-(4, 20):	' правила грамматики
```

# Вывод
В ходе данной лабораторной работы был изучен алгоритм построения таблиц
предсказывающего анализатора. Синтаксический анализатор, разработанный на 
основе предсказывающего анализа, принимает на входе текст на входном языке в 
соответствии с индивидуальным вариантом, а на выходе порождает дерево вывода 
для входного текста.
