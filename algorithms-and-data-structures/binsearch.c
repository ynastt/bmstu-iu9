#include  <stdio.h>

int array[] = { 1, 2, 30, 45, 50, 51, 55, 60 };
const int k = 51;

int compare(unsigned long i)
{
        if (array[i] == k) return 0;
        if (array[i]  < k) return -1;
        return 1;
}

unsigned long binsearch(unsigned long nel, int (*compare)(unsigned long i)){
        unsigned long i, a, z, center;
        int b;
        a = 0;
        z = nel-1;
        for (i=a; i<nel; i++) {
                center = (a+z+1)/2;
                b=compare(center);
                if (b == -1) a = center+1;
                else if (b == 0) return center;
                else if (b == 1) z = center-1; 
                else return nel;
        }
}

int main(int argc, char  **argv)
{
        printf("%lu\n", binsearch(8, compare));
        return 0;
}