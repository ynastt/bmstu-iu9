#include  <stdio.h>

int strdiff(char *a, char *b)
{
	char c,d;
        int diff=0,i=1;
        if (strcmp(a,b) == 0) 
                return -1;
        if (strlen(a) == 0 || strlen(b) == 0)
                return 0;
        else {
       	
                c=*a;
                d=*b;
                while ((c & 1) == (d & 1)) {
                        diff+=1;
                        c=c>>1;
                        d=d>>1;
                        if (!(diff % 8)) {
                                c=*(a+i);
                                d=*(b+i);
                                i+=1;
                        }
                }
        }
        return diff;
}

int main(int argc, char **argv)
{
        char s1[1000], s2[1000];
        gets(s1);
        gets(s2);
        printf("%d\n", strdiff(s1, s2));

        return 0;
}