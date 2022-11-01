#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Elem {
        struct Elem* next;
        int k, v;
};

struct Elem* ListSearch(struct Elem *l, int i) {
        struct Elem *x = l;
        while (x != NULL && x->k != i)
            x = x->next;
        return x;
}

struct Elem* ListSearchUPD(struct Elem *l, int i) {
        struct Elem *x = l;
        while (x != NULL && x->next != NULL && x->k != i)
            x = x->next;
        return x;
}

void Insert(struct Elem *l, struct Elem **a, int i, int u, int m) {
        if (l != NULL && (l->k == i)) 
                l->v = u;
        else if (l != NULL) {
                l->next = (struct Elem*)malloc(sizeof(struct Elem));
                l = l->next;
                l->k = i;
                l->v = u;
                l->next = NULL;
        }
        else {
                a[i%m] = (struct Elem*)malloc(sizeof(struct Elem));
                l = a[i%m];
                l->k = i;
                l->v = u;
                l->next = NULL;
        }
}        

int main() {
        int n, m, j, i, u;
        char s[6];
        scanf("%d\n%d", &n, &m);
        struct Elem **a = calloc(m,sizeof(struct Elem*)); //calloc инициализирует нулями
        struct Elem *p;
        for (j=0; j<n; j++) {
                scanf("%s", s);
                if (strcmp(s,"AT")==0) {
                        int value;
                        scanf("%d", &i);
                        struct Elem *t;
                        t = a[i%m];
                        p=ListSearch(t,i);
                        if (p != 0) 
                                value = p->v;
                        else value = 0;
                        printf("%d\n", value);
                }
                if (strcmp(s,"ASSIGN")==0) {
                        scanf("%d %d", &i, &u);
                        if (u!=0) {
                                struct Elem *t;
                                t = a[i%m];
                                p = ListSearchUPD(t, i);
                                Insert(p, a, i, u, m);
                        }
                        else { //удаление из ассоциативного массива пары с ключом k
                                p = a[i%m];
                                if (p!=NULL){
                                        if (p->k == i) {
                                                struct Elem *t = p;
                                                a[i%m] = p->next;
                                                free(t);
                                        }
                                        else {
                                                while (p->next != NULL && (p->next->k != i))
                                                        p = p->next;
                                                if (p->next!=NULL) {
                                                        struct Elem* t = p->next;
                                                        p->next = p->next->next;
                                                        free(t);
                                                }
                                        }
                                }
                        }
                }                
        }
        //free
        for (int i=0;i<m;i++) {
                struct Elem *w=a[i]; 
                while (w!=NULL) {
                        struct Elem *z = w;
                        w = w->next;
                        free(z);
                }
                free(w);
        } 
        free(a);
        return 0;
}