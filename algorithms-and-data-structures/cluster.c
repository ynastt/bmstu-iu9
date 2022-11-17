#include <stdio.h>
#include <stdlib.h>

struct th {
    int v1, v2, k; /*поля index нет, т.к. не реализуем IncreaseKey*/
};

struct queue {
    struct th *heap;
    int cap, count;
};

void swap (struct queue* q, int i, int j) {
    int a, b, c;
    a=q->heap[i].v1;
    b=q->heap[i].v2;
    c=q->heap[i].k;
    q->heap[i].v1 = q->heap[j].v1;
    q->heap[i].v2 = q->heap[j].v2;
    q->heap[i].k = q->heap[j].k;
    q->heap[j].v1 = a;
    q->heap[j].v2 = b;
    q->heap[j].k = c;
}

void Heapify (int i, int n, struct queue* q) {
    int l, r ,j, f=1;
    while (f==1) {
        l=2*i+1;
        r=l+1;
        j=i;
        if ((l < n) && (q->heap[i].k > q->heap[l].k))       
            i = l;
        if ((r < n) && (q->heap[i].k > q->heap[r].k))
            i=r;
        if (i==j)
            break;
        swap(q, i, j);
    }        
}

struct th ExtractMin(struct queue* q) {
    struct th ptr;
    if (q->count == 0) printf("Ошибка: очередь пуста");
    ptr = q->heap[0];
    q->count-=1;
    if (q->count>0) {
        q->heap[0] = q->heap[q->count];
        Heapify(0, q->count, q);
    }
    return ptr;
}

void Insert(struct queue* q,struct th ptr)
{
    int i;   
    i=q->count;
    if (i == q->cap) printf("Ошибка: переполнение");
    q->count=i+1;
    q->heap[i]=ptr;
    while ((i > 0) && (q->heap[(i - 1)/2 ].k > q->heap[i].k)) {
        swap(q, (i - 1)/2, i);
        i=(i - 1)/2;
    }
}

struct queue InitPriorityQueue (int n){
    struct queue q;
    q.heap=(struct th*)malloc(n*sizeof(struct th));
    q.cap=n;
    q.count=0;
    return q;
}

int main() {
    int n, m, i;
    scanf("%d", &n); 
    scanf("%d", &m); 
    struct queue z = InitPriorityQueue(m);
    struct th* t=(struct th*)malloc(m*sizeof(struct th));
    for (i=0;i<m;++i) {
        scanf("%d", &t[i].v1);
        scanf("%d", &t[i].v2);
    }
    for (i=0;i<n;++i) {
        t[i].k = t[i].v1 + t[i].v2;
        Insert(&z, t[i]);
    }
    struct th mi;
    int d;
    i=n; 
    while (z.count > 0) {
        mi = ExtractMin(&z);
        if (i<m) {                        
            if (mi.k < t[i].v1)
                d=t[i].v1;
            else 
                d=mi.k;
            t[i].k = d + t[i].v2;
            Insert(&z, t[i]);
            i++;                 
        }
    }
    printf("%d", mi.k);
    free(t);
    free(z.heap);
    return 0;
}