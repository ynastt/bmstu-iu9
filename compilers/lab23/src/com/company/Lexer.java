package com.company;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.ArrayList;

public class Lexer {

    ArrayList<Token> tokens = new ArrayList<Token>();
    private ArrayList<Fragment> comments = new ArrayList<>();
    public void match(String text, int line){
        // Регулярные выражения
        String Term = "<[a-z]>";
        String NonTerm = "[A-Z]+'?";
        String ArithmeticOp = "[\\+\\*]";
        String AxiomSign = "axiom\\s";
        String StartBrace = "<";
        String EndBrace = ">";
        String Open = "\\(";
        String Close = "\\)";
        String Arrow = "^ {2,3}(?:\\s)";
        String comment = "\\'.*";
        String pattern = "(?<Term>^" + Term + ")|(?<NonTerm>^" + NonTerm +
                ")|(?<ArithmeticOp>^" + ArithmeticOp +
                ")|(?<comment>^" + comment + ")|(?<AxiomSign>^" + AxiomSign +
                ")|(?<StartBrace>^" + StartBrace + ")|(?<EndBrace>^" + EndBrace +
                ")|(?<Open>^" + Open + ")|(?<Close>^" + Close +
                ")|(?<Arrow>^" + Arrow + ")";

        Pattern p = Pattern.compile(pattern);
        boolean flag = true;
        int index = 0;
        while (flag) {
            if (text.length() == 0) {
                flag = false;
            } else {
                Matcher m = p.matcher(text);
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

                    } else if (m.group("Arrow") != null) {
                        if (m.group("Arrow") == text) {
                            flag = false;
                        }
                        Token token = new Token();
                        token.token = m.group("Arrow");
                        token.type = "Arrow";
                        index += m.group("Arrow").length();
                        token.column = index;
                        token.row = line;
                        this.tokens.add(token);
                        text = text.substring(m.group("Arrow").length());

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
                        index += m.group("StartBrace").length();
                        token.column = index;
                        token.row = line;
                        this.tokens.add(token);
                        text = text.substring(m.group("StartBrace").length());

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

                    } else if (m.group("Open") != null) {
                        if (m.group("Open") == text) {
                            flag = false;
                        }
                        Token token = new Token();
                        token.token = m.group("Open");
                        token.type = "Open";
                        index += m.group("Open").length();
                        token.column = index;
                        token.row = line;
                        this.tokens.add(token);
                        text = text.substring(m.group("Open").length());

                    } else if (m.group("Close") != null) {
                        if (m.group("Close") == text) {
                            flag = false;
                        }
                        Token token = new Token();
                        token.token = m.group("Close");
                        token.type = "Close";
                        index += m.group("Close").length();
                        token.column = index;
                        token.row = line;
                        this.tokens.add(token);
                        text = text.substring(m.group("Close").length());

                    } else if (m.group("ArithmeticOp") != null){
                        if (m.group("ArithmeticOp") == text) {
                            flag = false;
                        }
                        Token token = new Token();
                        token.token = m.group("ArithmeticOp");
                        token.type = "ArithmeticOp";
                        index += m.group("ArithmeticOp").length();
                        token.column = index;
                        token.row = line;
                        this.tokens.add(token);
                        text = text.substring(m.group("ArithmeticOp").length());

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