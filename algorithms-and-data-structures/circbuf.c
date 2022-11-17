#include <stdio.h>
#include <stdlib.h>

struct queue{ 
    int *data, cap, count, head, tail;
};

struct queue InitQueue(int n){
    struct queue q;
    q.data=(int*)malloc(n*sizeof(int));
    q.cap=n;
    q.count=0;
    q.head=0;
    q.tail=0;
    return q;
}

int QueueEmpty(struct queue* q){
    if(q->count==0)
        return 1;
    else return 0;
}

void Enqueue(struct queue* q,int x){
        int l,i ;
        l=q->cap;
        if (q->count==q->cap){ /*переполнение->увеличиваем буфер в 2 раза*/ 
		q->cap*=2;
		q->head+=l;    
                q->data=realloc(q->data, (q->cap)*sizeof(int));  /* void* realloc (void* ptr, size_t size);*/
		for(int i=q->tail; i<l; i++)                     /*ptr - указатель на блок ранее выделенной памяти*/
			q->data[l+i] = q->data[i];               /*size - новый размер, в байтах, выделяемого блока памяти*/
	}
        q->data[q->tail]=x;
        q->tail+=1;
        if(q->tail==q->cap)
                q->tail=0;
        q->count+=1;
}

int Dequeue(struct queue* q){
    int g=QueueEmpty(q);
    if (g==1) printf("опустошение");
    int x;
    x=q->data[q->head];
    q->head+=1;
    if(q->head==q->cap)
        q->head=0;
    q->count-=1;
    return x;
}

int main(){
        int n, i, x, f;
        char s[5];
        struct queue z = InitQueue(4);
        scanf("%d", &n);
        for(i=0; i<n; i++){
                scanf("%s", s);
                if(strcmp(s,"ENQ")==0){
                        scanf("%d", &x);	
                        Enqueue(&z,x);
                }
                if(strcmp(s,"DEQ")==0){
                        x=Dequeue(&z);
                        printf("%d\n", x);                      
                }
                if(strcmp(s,"EMPTY")==0){
                        f=QueueEmpty(&z);
                        if (f==1)
                                printf("true\n");
                        else printf("false\n");
                }
        }
        free(z.data);
        return 0;
}