#include  <stdio.h>

int array[] = {
        1000000000,
        4000000000,
        3000000000,
        5000000000,
        2000000000
};

int compare(void  *a, void  *b)
{
        int va =  *(int*)a;
        int vb =  *(int*)b;
        if (va == vb) return 0;
        return va  < vb ? -1 : 1;
}

int maxarray(void  *base, unsigned long nel, unsigned long width,int (*compare)(void *a, void *b)){
      int i,max=0,c;
      for(i=0;i<nel;i++){
              c=(compare ((char*) base+ width*i, (char*) base+ width*max ));
              if(c>0)
                max=i;		
       }
      return max;	 
}

int main(int argc, char  **argv)
{
        printf("%d\n", maxarray(array, 5, sizeof(int), compare));
        return 0;
}