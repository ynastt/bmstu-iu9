#include <stdio.h>
#include <stdlib.h>
#include <math.h>
int *array;
int compare(unsigned long i, unsigned long j){  
    if (abs(array[i]) == abs(array[j])) return 0; 
    return abs(array[i]) < abs(array[j]) ? -1 : 1; 
}

void swap(unsigned long i, unsigned long j){ 
    int t;
    t=array[i]; 
    array[i]=array[j]; 
    array[j]=t; 
}

void insertsort(long i,unsigned long nel,
    int (*compare)(unsigned long i, unsigned long j)){
        int n,loc,d;
        d=i;
        while (d<nel){
                loc=d;
                while (loc>=i && compare(loc,loc+1)==1){
                        swap(loc,loc+1);
                        loc-=1;
                }
                d+=1;      
        }       
}
void merge(unsigned long i,unsigned long med,unsigned long nel,
    int (*compare)(unsigned long i, unsigned long j)){
        int t[nel-i+1],k,l,h,j,f;
        
        for (j=0;j<(nel-i+1); j++)
                t[j]=0;
        
        k=i;
        l=med+1;
        h=0;
        while (h<(nel-i+1)){
                if ((l<=nel) && (k==l || (compare(k,l)>0) || (!(k<med+1)))){
                        t[h]=array[l];
                        l+=1;
                }
                else{
                        t[h]=array[k];
                        k+=1;
                }
                h+=1;
        }
        f=0;
        for (j=i;j<nel+1;j++){               
                array[j]=t[f];
                f+=1;
        } 
}

void mergesort(unsigned long i,unsigned long nel,
    int (*compare)(unsigned long i, unsigned long j)){
        int med;
        if (i<nel){
                med=(i+nel)/2;
                if (med>=5){
                    mergesort(i,med,compare);
                    mergesort(med+1,nel,compare);                       
                }
                else{
                    insertsort(i,med,compare);
                    insertsort(med+1,nel,compare);
                }
                merge(i,med,nel,compare);
        }
}

int main(){ 
    int i, n; 
    scanf("%d", &n);  
    array = (int*)malloc(n * sizeof(int)); 
    for (i=0; i<n; i++)
        scanf("%d", array+i);  
    mergesort(0,n-1,compare); 
    for (i=0; i<n; i++)
        printf("%d ", array[i]);  
    free(array); 
    return 0; 
} 