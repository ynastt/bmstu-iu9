package com.company;

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
