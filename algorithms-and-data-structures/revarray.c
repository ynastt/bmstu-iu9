#include <stdio.h>

int array[] = {
        1000000000,
        2000000000,
        3000000000,
        4000000000,
        5000000000
};

void revarray(void *base, unsigned long nel, unsigned long width){
	int i,j;
	unsigned char *a, *b, c;
                for (i=0; i<nel/2;i++) 
                        for (j=0; j<width;j++){
                                a=((unsigned char*)base +j + width*i);
                                b=((unsigned char*)base +j + width*(nel- i-1));
                                c=*a;
                                *a=*b;
                                *b=c;
                        }
}

int main(int argc, char **argv)
{
        revarray(array, 5, sizeof(int));

        int i;
        for (i = 0; i < 5; i++) {
                printf("%d\n", array[i]);
        }

        return 0;
}


