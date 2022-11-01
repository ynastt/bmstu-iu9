#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int max(int a, int b){
  return (a>b) ? a : b;
}

void build(int *array, int f, int a, int b, int *t){
    int m;
    if (a==b)
        t[f]=array[b];
    else{
        m=(a + b)/2;
        build(array, f * 2 + 1, a, m, t);
        build(array, f * 2 + 2, m + 1, b, t);
        t[f]=max(t[f * 2 + 1], t[f * 2 + 2]);
    }
}

void update(int i, int x, int f, int a, int b, int *t){
    int m;
    if (a==b)
        t[f]=x;
    else{
        m=(a + b)/2;
        if(i<=m)
	        update(i, x, f * 2 + 1, a, m, t);
        else
	        update(i, x, f * 2 + 2, m + 1, b, t);
        t[f]=max(t[f * 2 + 1], t[f * 2 + 2]);
    }
}

int query(int *t, int l, int r, int f, int a, int b){
    int m;
    if (l==a && r==b)
        return t[f];
    else{
        m=(a + b)/2;
        if(r<=m)
	        query(t, l, r, f * 2 + 1, a, m);
        else if (l>m)
	        query(t, l, r, f * 2 + 2, m + 1, b);
        else
	        return max( (query(t, l,  m, f * 2 + 1, a, m)),
	                (query(t, m + 1, r, f * 2 + 2, m + 1, b)));
    }
}


int main (){
    int n, i, m, k, a, b;
    char str[4];
    scanf ("%d", &n);
    int *array=(int*)malloc(n*sizeof(int));
    for (i=0;i<n;i++)
        scanf("%d", &array[i]);

    int *t=(int*)malloc(4*n*sizeof(int));
    build (array, 0, 0, n - 1, t);
    scanf ("%d", &m);
    k=0;
    int *c=(int*)malloc(m*sizeof(int));
    for (i=0;i<m;i++){
        scanf ("%s %d %d", str, &a, &b);
        if (strcmp(str, "MAX")==0){
	        *(c+k)=query(t, a, b, 0, 0, n - 1);
	        k+=1;
	    }
        if (strcmp(str, "UPD")==0)
	        update(a, b, 0, 0, n - 1, t);
    }
    for (i=0;i<k;i++)
        printf("%d\n", c[i]);
    
    free (array);
    free (t);
    free (c);
    return 0;
}