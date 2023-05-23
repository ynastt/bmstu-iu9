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
