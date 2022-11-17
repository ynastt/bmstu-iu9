#include <stdio.h>

int main()
{
        int n, k, i;
	scanf("%d %d", &k, &n);
	char a[n+1];
	for (i = 0; i <= n; i++)
		a[i] = 1;
	
	for (i = 2; i < n; i++) {
		if (a[i]>=1)
			for(int k=i*2; k<=n; k+=i)
				a[k]=a[i]+1;
	}
	for (i = 2; i < n+1; i++)
                if (a[i] == k)
		        printf("%d ", i);
	return 0;
}
