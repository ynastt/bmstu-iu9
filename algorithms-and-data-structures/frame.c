
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char** argv)
{
        int i = 0, j = 0, ot = 0, c = 0;
        if (argc != 4) {
                printf("Usage: frame <height> <width> <text>");
                return 0;
        } 
        else {
                ot = (atoi(argv[2]) - strlen(argv[3])) / 2;
                if (ot <= 0 || atoi(argv[1]) <= 2) {
                        printf("Error");
                        return 0;
                }
                c = (atoi(argv[1]) - 1) / 2;
                for (i = 0; i < atoi(argv[1]); i++) {
                        if (i == 0 || i == atoi(argv[1])-1)
                                for (j = 0; j < atoi(argv[2]); j++)
                                        printf("*");
                        else {
                                if (i == c) {
                                        printf("*");
                                        for (j = 0;j < ot-1; j++)
                                                printf(" ");
                                        printf("%s", argv[3]);
                                        for (j = ot + strlen(argv[3]) + 1; j <= atoi(argv[2]); j++)
                                                if (j == atoi(argv[2]))
                                                        printf("*");
                                                else 
                                                        printf(" ");

                                }
                                else {
                                        for (j = 0; j < atoi(argv[2]); j++) {
                                                if (j == 0 || j == atoi(argv[2])-1)
                                                        printf("*");
                                                else 
                                                        printf(" ");
                                        }
                                }
                        }
                printf("\n");
                }
        }
return 0;
}