
#include <stdio.h>

int main()
{
	int i,j,n,m,k=0,x, sedi, sedj;
        scanf("%d %d", &m, &n);
        long min[n],  max[m];
        for (i = 0; i < m; i++)
        	max[i]=-2147483649;/*-2^31-1*/
        for (j = 0; j < n; j++)
        	min[j]=2147483648; /*2^31*/
        		
        for (i = 0; i < m; i++)
        	
		for (j = 0; j < n; j++){ 
			scanf("%d", &x);
	                if(x>max[i]) max[i]=x;
        	        if(x<min[j]) min[j]=x;
                }
        for (i = 0; i < m; i++)
		for (j = 0; j < n; j++)
			if(max[i]==min[j] ){
				k++;
				sedi=i;
				sedj=j;
				
			}
	if (k==1)
            printf("%d %d", sedi, sedj);
        else 
            printf("none");
	return 0;
}

