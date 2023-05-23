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
