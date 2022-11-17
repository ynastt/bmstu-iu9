
#include <stdlib.h> 
#include <stdio.h> 
 
int *array; 
 
int compare(unsigned long i, unsigned long j) 
{ 
        if (i <= j) { 
                printf("COMPARE␣%d␣%d\n", i, j); 
        } else { 
                printf("COMPARE␣%d␣%d\n", j, i); 
        } 
 
        if (array[i] == array[j]) return 0; 
        return array[i] < array[j] ? -1 : 1; 
} 
 
void swap(unsigned long i, unsigned long j) 
{ 
        if (i <= j) { 
                printf("SWAP␣%d␣%d\n", i, j); 
        } else { 
                printf("SWAP␣%d␣%d\n", j, i); 
        } 
 
        int t = array[i]; 
        array[i] = array[j]; 
        array[j] = t; 
} 
 
void bubblesort(unsigned long nel, 
        int (*compare)(unsigned long i, unsigned long j), 
        void (*swap)(unsigned long i, unsigned long j)) {
                unsigned long t,bound1,bound2,i,f;
                t = nel-1;
                bound1 = t;
                t = 0;
                i = 0;
                f = 0;
                bound2 = 0;
                while (t!=bound1) { 
                        while (i<bound1) {
                                if (compare (i,i+1) == 1) {
                                        swap (i,i+1);
                                        t=i;
                                }
                                i+=1;
                        }
                        i = t;
                        if (f == t) break;
                        f = i;
                        while (i>bound2) {
                                if (compare (i-1,i) == 1) {
                                        swap (i-1,i);
                                        f=i;
                                }
                                i-=1;
                        }
                        i = f;
                        bound2 = f;
                        bound1 = t;
                        t = f;
               }
}
 
int main(int argc, char **argv) 
{ 
        int i, n; 
        scanf("%d", &n); 
 
        array = (int*)malloc(n * sizeof(int)); 
        for (i = 0; i < n; i++) scanf("%d", array+i); 
 
        bubblesort(n, compare, swap); 
        for (i = 0; i < n; i++) printf("%d␣", array[i]); 
        printf("\n"); 
 
        free(array); 
        return 0; 
}