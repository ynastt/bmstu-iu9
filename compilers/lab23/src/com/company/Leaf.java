package com.company;

import java.util.Objects;

public class Leaf extends Node {
    Token tok;

    public Leaf(Token a) {
        this.tok = a;
    }

    void print(String indent) {
        if (tok.type.equals("Term") || tok.type.equals("NonTerm") || 
            tok.type.equals("StartBrace") || tok.type.equals("EndBrace") {
            System.out.println(indent + String.format("Лист: %s\t%s", tok.type, tok.token));
        } else {
            System.out.println(indent + "Лист: " + tok.type);
        }
    }
}
