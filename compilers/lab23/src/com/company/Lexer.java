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
               // System.out.println(text);
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