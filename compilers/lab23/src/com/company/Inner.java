package com.company;

import java.util.ArrayList;

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
