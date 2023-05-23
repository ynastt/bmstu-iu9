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
                System.out.println();
                for (int j = 0; j < t.size(); j++) {
                    tokens.add(t.get(j));
                    System.out.printf("%s (%d,%d): %s%n",
                            t.get(j).type, t.get(j).row, t.get(j).column + 1, t.get(j).token);
                }
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

