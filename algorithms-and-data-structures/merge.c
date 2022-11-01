#include <stdio.h>
#include <stdlib.h>

struct th {
        int v, index;
};

struct queue {
        struct th *heap;
        int cap,  count;
};

void swap (struct queue* q, int i, int j) {
        int a, c;
        a=q->heap[i].v;
        c=q->heap[i].index;
        q->heap[i].v = q->heap[j].v;
        q->heap[i].index = q->heap[j].index;
        q->heap[j].v = a;
        q->heap[j].index = c;
}

void Heapify (int i, int n, struct queue* q) {
        int l, r ,j, f=1;
        while (f==1) {
                l=2*i+1;
                r=l+1;
                j=i;
                if ((l < n) && (q->heap[i].v > q->heap[l].v))       
                        i = l;
                if ((r < n) && (q->heap[i].v > q->heap[r].v))
                        i=r;
                if (i==j)
                        break;
                swap(q, i, j);
        }        
}

void Insert(struct queue* q,struct th ptr) {
        int j;   
        j=q->count;
        //if (j == q->cap) printf("Ошибка: переполнение");
        q->count=j+1;
        q->heap[j]=ptr;
        while ((j > 0) && (q->heap[(j - 1)/2 ].v > q->heap[j].v)) {
                swap(q, (j - 1)/2, j);
                j=(j - 1)/2;
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

struct queue InitPriorityQueue (int n) {
        struct queue q;
        q.heap=(struct th*)malloc(n*sizeof(struct th));
        q.cap=n;
        q.count=0;
    return q;
}

int main() {
        int k, n, kol, i, a;
        struct queue q;
        scanf("%d", &k);
        kol=0;
        for (i=0; i<k; i++){
                scanf("%d", &n);
                kol += n;
        }
        q = InitPriorityQueue(kol);
        struct th* t=(struct th*)malloc(kol*sizeof(struct th));
        for (i=0; i<kol; i++){
                scanf("%d", &a);
                t[i].v = a;
                t[i].index = i;
                Insert(&q, t[i]);
        }
        for (i=0; i<kol; i++){
                struct th z = ExtractMin(&q);
                printf("%d ", z.v);
        }
        free(t);
        free(q.heap);
    return 0;
}
