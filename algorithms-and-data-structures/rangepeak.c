#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int peak(int *array, int index , int n){
            if(index==0 && n==1) return 1;
            if(index==n-1 && array[index-1]<=array[index]) return 1;
            if(index==0 && array[index]>=array[index+1]) return 1;
            if (index==0 && array[index]<=array[index+1]) return 0;
	    if (index==n-1 && array[index-1]>array[index]) return 0;
            if((index>0) && (index<n-1) && array[index-1]<=array[index] && array[index]>=array[index+1])
                return 1;
            else
                return 0;
                  
            
           
}
void build(int *array, int f, int a, int b, int *t, int n){
    int m;
    if (a==b)
        t[f]=peak(array,a,n);

    else{
        m=(a + b)/2;
        build(array, f*2+1, a, m, t,n);
        build(array, f*2+2, m+1, b, t,n);
        t[f]=t[f*2+1]+t[f*2+2];
    }
}

void update(int i, int x, int f, int a, int b, int *t, int *array,int n){
    int m;
    if (a==b){
        if(a==i)
            t[f]=peak(array,a,n);
            
    }
    else{
        m=(a + b)/2;
        if(i<=m)
	        update(i, x, f*2+1, a, m, t,array,n);
        else
	        update(i, x, f*2+2, m+1, b, t,array,n);
        t[f]=t[f*2+1]+t[f*2+2];
    }
}

int query(int *t, int l, int r, int f, int a, int b){
    int m;
    if (l==a && r==b)
        return t[f];
    else{
        m=(a + b)/2;
        if(r<=m)
	        query(t, l, r, f*2+1, a, m);
        else if (l>m)
	        query(t, l, r, f*2+2, m + 1, b);
        else
	        return query(t, l,  m, f*2+1, a, m)+query(t, m+1, r, f*2+2, m+1, b);
    }
}


int main (){
    int n, i, m, k, in, num;
    char str[5];
    scanf ("%d", &n);
    int *array=(int*)malloc(n*sizeof(int));
    for (i=0;i<n;i++)
        scanf("%d", &array[i]);

    int *t=(int*)malloc(4*n*sizeof(int));
    
    build (array, 0, 0, n - 1, t,n);
    scanf ("%d", &m);
    k=0;
    int *c=(int*)malloc(m*sizeof(int));
    for (i=0;i<m;i++){
        scanf ("%s %d %d", str, &in, &num);
        if (strcmp(str, "PEAK")==0){
	        *(c+k)=query(t, in, num, 0, 0, n-1);
	        k+=1;
	    }
        if (strcmp(str, "UPD")==0){
           
            array[in]=num;
            if (in-1>=0)
                update(in-1, num,0,0, n-1,t,array,n); 
            if (in+1<=n-1)
                update(in+1, num,0,0, n-1,t,array,n);
	    update(in, num, 0, 0, n-1, t,array,n);
        }
    }
    for (i=0;i<k;i++)
        printf("%d\n", c[i]);
    free (array);
    free (t);
    free (c);
    return 0;
}