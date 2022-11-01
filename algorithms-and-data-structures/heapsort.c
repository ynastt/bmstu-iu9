#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int compare (const void *a, const void *b) {
        char *c;
        int i=0,ina=0,inb=0,len_a,len_b;
        len_a=strlen(a);
        len_b=strlen(b);
        c=a;
        for(i=0; i<len_a; i++){
                if (*(c+i)=='a')
                        ina++;
        }
        c=b;
        for(i=0; i<len_b; i++){
                if (*(c+i)=='a')
                        inb++;
        }
        if (ina == inb) return 0;
        if (ina> inb) return 1;
        if(ina<inb) return -1;
}

void swap(const void *a, const void *b, int width){
        int i;
        char *sa=(char*)a; 
        char *sb=(char*)b;
        char t;
        for( i=0; i<width; i++){
                
                t=*(sa+i);
                *(sa+i)=*(sb+i);
                *(sb+i)=t;
        }
}
void heapify (void *base,size_t width,
        int (*compare)(const void *a, const void *b),size_t i,size_t nel){
                
        int f=1;
        int l,r,j;
        while (f>0){        
                l=2*i+1;
                r=l+1;
                j=i;
                if ((l<nel) && (compare((char*)base + width*i,(char*)base + width*l)==-1))
                    i=l;
                if ((r<nel) && (compare((char*)base + width*i,(char*)base + width*r)==-1))
                    i=r;
                if (i==j)
                        break;
                swap((char*)base + width*i, (char*)base + width*j, width);
        }
}
void  buildheap (void *base,size_t width,
        int (*compare)(const void *a, const void *b),size_t nel){
                
        int i;
        i=nel/2-1;
        while (i>=0){
                heapify(base,width,compare,i,nel);
                i-=1; 
        }
}

void hsort(void *base, size_t nel, size_t width, 
        int (*compare)(const void *a, const void *b)) 
{    
    int i;
    buildheap (base,width,compare,nel);
    i = nel-1;
    while(i>0){
            swap((char*)base, (char*)base + i * width, width);
            heapify(base,width,compare,0,i);
            i-=1;
    }
}
int main(){
        int n,i;
        scanf("%d", &n);
        char s[n][1000];
        for (i=0;i<n;i++)
                scanf("%s", s[i]);
        hsort(s,n,1000,compare);
        for (i=0;i<n;i++)
                printf("%s\n", s[i]);
    return 0;
}