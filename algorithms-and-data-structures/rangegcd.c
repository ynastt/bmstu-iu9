    
#include <stdio.h>
#include <stdlib.h>

int gcd(int x, int y){
    return y? gcd(y,x%y) : abs(x);
}

long degree2(int n){
        int i;
        unsigned long s=1;
            for(i=n;i>0;i--) 
                s*=2;
    	if (n==0) return 1;
    	else return s;
}

void Computelog(int x, int *lg){
        int i,j;
        i=1;
        j=0;
        while(i<x){
            while(j<degree2(i)){
                    lg[j]=i-1;
                    j+=1;
            }
            i+=1;
        }
}

int sparsetable_query(int **st,int l,int r,int *lg){
        int j,v;
        j=lg[r-l+1];
        v=gcd(st[j][l],st[j][r-degree2(j)+1]);
        return v;
}

void sparsetable_build(int *array, int n, int *lg, int **st){
        int m,i,j,p,pj;
        m=lg[n]+1;
        i=0;
        while(i<n){
            st[0][i]=array[i];
            i+=1;       
        }
        j = 1;
        while(j<m){
                i=0;
                p=degree2(j);
                while (i<=(n-p)){
                        pj=degree2(j-1);
                        st[j][i]=gcd(st[j-1][i],st[j-1][i+pj]);
                        i+=1;
                }
                j +=1;
        }
}

int main(int argc, char** argv) {
        int n,i,m,a,b;
        scanf("%d", &n);
        int *array=(int*)malloc(n*sizeof(int));
        for (i=0;i<n;i++)
            scanf ("%d", &array[i]);
        
        int *lg=(int*)malloc(2000000*sizeof(int));
        Computelog(20,lg);
        int **s;
        s=(int**)malloc(100000*sizeof(int));
        for (i=0;i<=lg[n];i++)
            s[i]=(int*)malloc(300001*sizeof(int));/*0 < n ≤ 300000*/
            
        sparsetable_build(array,n,lg,s);
        
        scanf("%d", &m);
        
        int *res=(int*)malloc(m*sizeof(int));
        for (i=0;i<m;i++){        
            scanf("%d %d", &a, &b);
            *(res+i)=sparsetable_query(s,a,b,lg);
        }
        for (i=0;i<m;i++)
            printf("%d\n", res[i]);
        
        free(array);
        free(lg);       
        free(res);
        free(s);
        return 0;
}