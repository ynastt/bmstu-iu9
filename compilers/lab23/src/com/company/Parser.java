package com.company;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Stack;

public class Parser {
    HashMap<String, String[]> crossing = new HashMap<String, String[]>();
    void init_table() {
        this.crossing.put("GRAMMAR NonTerm", new String[]{"RULES", "GRAMMAR"});
        this.crossing.put("GRAMMAR AxiomSign", new String[]{"AXIOM", "GRAMMAR"});
        this.crossing.put("GRAMMAR EOF", new String[]{});
        this.crossing.put("RULES NonTerm", new String[]{"RULE", "RULES"});
        this.crossing.put("RULES AxiomSign", new String[]{});
        this.crossing.put("AXIOM AxiomSign", new String[]{"AxiomSign", "StartBrace", "BODY", "EndBrace", "RP"});
        this.crossing.put("RULE NonTerm", new String[]{"NonTerm", "Arrow", "RP"});
        this.crossing.put("RP Term", new String[]{"Term", "RP"});
        this.crossing.put("RP NonTerm", new String[]{});
        this.crossing.put("RP AxiomSign", new String[]{});
        this.crossing.put("RP StartBrace", new String[]{"StartBrace", "BODY", "EndBrace", "RP"});
        this.crossing.put("BODY Term", new String[]{"Term", "BODY"});
        this.crossing.put("BODY NonTerm", new String[]{"NonTerm", "BODY"});
        this.crossing.put("BODY Open", new String[]{"Open", "BODY", "Close", "BODY"});
        this.crossing.put("BODY ArithmeticOp", new String[]{"ArithmeticOp", "BODY"});
        this.crossing.put("BODY Close", new String[]{});
        this.crossing.put("BODY EndBrace", new String[]{});
    }

    boolean isTerminal(String s){
       return !(s == "GRAMMAR" || s == "AXIOM" || s == "RULES" || s == "RULE" || s == "RP" || s == "BODY");

    }

    Node topDownParse(ArrayList<Token> tokens) {
        Inner sparent = new Inner();    // Фиктивный родитель для аксиомы
        Stack<Inner> stackIn = new Stack<>();
        Stack<String> stackStr = new Stack<>();
        stackIn.push(sparent);
        stackStr.push("GRAMMAR");

        int i = 0;
        // next token
        Token a = tokens.get(i);
        i++;
        while(i < tokens.size()) { //i < tokens.size() && !tokens.get(i).type.equals("EOF")
            Inner parent = stackIn.pop();
            String X = stackStr.pop();
            if (isTerminal(X)) {
                if (X.equals(a.type)) {
                    parent.children.add(new Leaf(a));
                    a = tokens.get(i);
                    i++;
                } else {
                    this.err("Ожидался " + X + ", получен " + a.type, a);
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
                this.err("Ожидался " + X + ", получен " + a.type, a);
            }
        }
        return sparent.children.get(0);
    }

    void err(String err_str, Token tok) {
        System.out.print("(" + tok.row + "," + tok.column + ") ");
        System.out.println("" + err_str);
    }
}
