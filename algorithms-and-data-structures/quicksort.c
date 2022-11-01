#include <stdio.h>
#include <stdlib.h>
int *array;
int compare(unsigned long i, unsigned long j){  
    if (array[i] == array[j]) return 0; 
    return array[i]<array[j] ? -1 : 1;
}

void swap(unsigned long i, unsigned long j){ 
    int t;
    t=array[i]; 
    array[i]=array[j]; 
    array[j]=t; 
}

void selectsort(int low,int high,int *array) {
        int k,i;
        int j=high;
        while (j>low){
                k=j;
                i=j-1;
                while(i>=0){
                        if(compare(k,i)==-1)
                            k=i;
                        i-=1;
                }
                swap(j,k);
                j-=1;
        }
}

int partition (int low , int high , int *array) {
        int i,j;
        i = low;/*граница разделения левее a[i] эл-ты меньше опроного*/
        j = low;
        while (j<high) {
                if (compare(j,high)==-1) {
                        swap(i,j);
                        i +=1;
                }
                j +=1;
        }
        swap(i,high);
        return i;
}

void quicksort(int low, int high,int m, int *array){
        int q;
        while (low<high){
                if (high-low<m) {
                        selectsort(low,high,array);
                        break;
                }
                q=partition(low,high,array);
                if (q<(high+low)/2){
                    quicksort(low,q-1,m,array);
                    low=q+1;
                }
                else{
                    quicksort (q+1,high,m,array);
                    high=q-1;
                }
        }
}
int main() {
        int i,n,m; 
        scanf("%d %d", &n, &m);  
        array=(int*)malloc(n*sizeof(int));
        for (i = 0; i < n; i++) 
            scanf("%d", &array[i]);  
        quicksort(0,n-1,m,array); 
        for (i = 0; i < n; i++) 
            printf("%d ", array[i]); 
        free(array);    
        return 0; 
} 