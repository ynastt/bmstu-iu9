#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct tree {
    int k, count;
    struct tree *parent, *left, *right;
    char v[10];
};

struct tree* InitTree (struct tree *t) {
    t = NULL;
    return t;
}

struct tree* Insert(struct tree *t, int k) {
    int z=1;
    struct tree *y = (struct tree*)malloc(sizeof(struct tree));
    y->k = k;
    y->count = 0;
    y->parent = NULL;
    y->left = NULL;
    y->right = NULL;
    scanf("%s", y->v);
    if (t == NULL) 
        t = y;
    else {
        struct tree *x = t;
        while(z>0) {
            x->count++;
            if (x->k > k) {
                if (x->left == NULL) {
                    x->left = y;
                    y->parent = x;
                    break;
                }
                x = x->left;
            }
            else {
                if (x->right == NULL) {
                    x->right = y;
                    y->parent = x;
                    break;
                }
                x = x->right;
            }
        }
    }
    return t;
}

struct tree* LookUp(struct tree *t, int k, int d) {
    struct tree *x = t;
    while (x != NULL && x->k != k) {
        if (d == 1) 
            x->count--;
        if (k < x->k) 
            x = x->left;
        else 
            x = x->right ;
    }
    return x;
}

struct tree* Minimum(struct tree *t) {
    struct tree *x;
    if (t == NULL) 
        x = NULL;
    else {
        x = t;
        while (x->left != NULL) {
            x->count--;
            x = x->left;
        }
    }
    return x;
}

struct tree* Succ(struct tree *x) {
    struct tree *y;
    if (x->right != NULL) 
        y = Minimum(x->right);
    else {
        y = x->parent;
        while (y!=NULL && x == y->right) {
            x = y;
            y = y->parent;
        }
    }
    return y;
}

struct tree* ReplaceNode(struct tree *t, struct tree *x,struct tree *y) {
    if (x == t) {
        t = y;
        if (y != NULL) y->parent = NULL;
    }
    else {
        struct tree *p = x->parent;
        if (y != NULL) 
            y->parent = p;
        if (p->left == x) 
            p->left = y;
        else 
            p->right = y;
    }
    return t;
}

struct tree* Delete(struct tree* t, int k) {
    struct tree *x = LookUp(t, k, 1);
    if (x->left == NULL && x->right ==NULL) 
        t = ReplaceNode(t, x, NULL);
    else {
        if (x->left == NULL) 
            t = ReplaceNode(t, x , x->right);
        else if (x->right == NULL) 
            t = ReplaceNode(t, x, x->left);
        else {
            struct tree *y = Succ(x);
            t = ReplaceNode(t, y, y->right);
            x->left->parent = y;
            y->left = x->left;
            if (x->right != NULL) x->right->parent = y;
            y->right = x->right;
            y->count = x->count - 1;
            t = ReplaceNode(t, x, y);
        }
    }
    free(x);
    return t;
}

struct tree* Search(struct tree *t, int n) {
    struct tree *x = t;
    int f=1;
    while(f>0) {
        if (x->left == NULL) {
            if (n == 0) 
                return x;
            else {
                x = x->right;
                n-=1;
            }
        }
        else {
            if (x->left->count + 1 == n) 
                return x;
            else {
                if (x->left->count + 1 > n) 
                    x = x->left;
                else {
                    n -= x->left->count + 2;
                    x = x->right;
                }
            }
        }
    }
}

void Free(struct tree *t) {
    if (t != NULL) {
        Free(t->left); 
        Free(t->right);
        free(t);
    }
}

int main () {
    struct tree *t = InitTree(t);
    struct tree *x;
    int n, k, i;
    scanf("%d", &n);
    char s[6];
    for (i=0; i<n; i++){
        scanf("%s", s);
        if (strcmp(s, "INSERT") == 0) {
            scanf("%d", &k);
            t = Insert(t, k);
        }
        if (strcmp(s, "SEARCH") == 0) {
            scanf("%d", &k);
            x = Search(t, k);
            printf("%s\n", x->v);
        }
        if (strcmp(s, "LOOKUP") == 0) {
            scanf("%d", &k);
            x = LookUp(t, k, 0);
            printf("%s\n", x->v);
        }
        if (strcmp(s, "DELETE") == 0) {
            scanf("%d", &k);
            t = Delete(t, k);
        }

    }
    Free(t);
    return 0;
}