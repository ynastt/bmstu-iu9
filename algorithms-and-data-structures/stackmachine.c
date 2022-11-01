#include <stdio.h>
#include <stdlib.h>

int maximum (int a, int b){
        if (a>b)
                return a;
        else return b;
}

int minimum (int a, int b){
        if (a>b)
                return b;
	else return a;
}

int main(){
        int n, i, c=0, x;
        char s[5];
        scanf("%d", &n);
        int *a=(int*)malloc(100000*sizeof(int));
        for(i=0; i<n; i++){
                scanf ("%s", s);
                if(strcmp(s, "CONST")==0){
	                scanf("%d", &x);
	                *(a+c)=x;
	                c++;
                }
                if(strcmp(s, "ADD")==0){
	                c--;
	                *(a+c-1) = *(a+c) + *(a+c-1);
	        }
                if(strcmp(s, "SUB")==0){
	                c--;
	                *(a+c-1) = *(a+c) - *(a+c-1);
	        }
                if(strcmp(s, "MUL")==0){
	                c--;
	                *(a+c-1) = *(a+c) * (*(a+c-1));
	        }
                if(strcmp(s, "DIV")==0){
	                c--;
	                *(a+c-1) = *(a+c) / (*(a+c-1));
	        }
                if(strcmp(s, "MAX")==0){
	                c--;
	                *(a+c-1) = maximum(*(a+c), *(a+c-1));
                }
                if(strcmp(s, "MIN")==0){
	                c--;
	                *(a+c-1) = minimum(*(a+c), *(a+c-1));
	        }
                if(strcmp(s, "NEG")==0){
	                c--;
	                x= *(a+c);
	                *(a+c)= -x;
	                c++;
	       }
                if(strcmp(s, "DUP")==0){
	                *(a+c) = *(a+c-1);
	                c++;
	        }
                if(strcmp(s, "SWAP")==0){
	                c--;
	                x= *(a+c-1);
	                *(a+c-1) = *(a+c);
	                *(a+c)=x;
	                c++;
	        }
        }
        printf("%d", *(a+c-1));
        free(a);
        return 0;
}