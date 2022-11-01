
#include <stdio.h>
#include <stdlib.h>

int max(int a, int b) {
    if (a>b) 
        return a;
    else return b;
}

struct q {
    int *data, *max, cap, top1, top2;
};

int StackEmpty1(struct q* s) {
    if (s->top1 == 0)
        return 1;
    else return 0;
}

int StackEmpty2(struct q* s) {
    if (s->top2 == (s->cap - 1))
        return 1;
    else return 0;
}

void Push1 (struct q* s, int x) {
    if (s->top2 < s->top1) printf("переполнение");
    s->data[s->top1]=x;
    if (s->top1 == 0) /*пополняем не только стек1 но и массив максимумов слева*/
        s->max[0]=x;   
    else {
        if (x > s->max[s->top1-1])
            s->max[s->top1]=x;
        else 
            s->max[s->top1] = s->max[s->top1-1];
    }        
    s->top1+=1;
}

void Push2 (struct q* s, int x) {
    if (s->top2 < s->top1) printf("переполнение");
    s->data[s->top2]=x;
    if (s->top2 == (s->cap-1)) /*пополняем не только стек2 но и массив максимумов справа*/
        s->max[s->top2]=x;
    else { 
        if (x > s->max[s->top2+1])
            s->max[s->top2]=x;
        else 
            s->max[s->top2]=s->max[s->top2+1];
    }        
    s->top2-=1;
}

int Pop1 (struct q* s) {
    if (StackEmpty1(s)==1) printf("опустошение");
    int x;
    s->top1-=1;
    x=s->data[s->top1];
    return x;
}

int Pop2 (struct q* s) {
    if (StackEmpty2(s)==1) printf("опустошение");
    int x;
    s->top2+=1;
    x=s->data[s->top2];
    return x;
}

int QueueEmpty(struct q* s) {
    if ((StackEmpty1(s) == 1) && (StackEmpty2(s) == 1))
        return 1;
    else return 0;
}

void Enqueue(struct q* s,int x) {
    Push1(s, x);
}

int Dequeue(struct q* s) {
    int x;
    if (StackEmpty2(s) == 1) {
        while (StackEmpty1(s) != 1) {
                Push2(s, Pop1(s));
            }
    }
    x=Pop2(s);
    return x;
}

int Maximum(struct q* s) {
    if (StackEmpty1(s) == 1 && StackEmpty2(s) == 0)
        return s->max[s->top2+1];
    if (StackEmpty1(s) == 0 && StackEmpty2(s) == 1) 
        return s->max[s->top1-1];
    else if (StackEmpty1(s) == 0 && StackEmpty2(s) == 0){
        if (s->max[s->top1-1] > s->max[s->top2+1])
		    return s->max[s->top1-1];
		else 
		   return s->max[s->top2+1]; 
    }    
}

struct q InitDoubleStack(int n) {
    struct q s;
    s.data=(int*)malloc(n*sizeof(int));
    s.cap=n;
    s.top1=0;
    s.top2=n-1;
    s.max=(int*)malloc(n*sizeof(int)); /*сделаем отдельное поле - массив максимумов - который заполняется параллельно с очередью*/
    return s;    
}
    
int main() {
    int n, i, x, f, m;
    char s[5];
    scanf("%d", &n);
    struct q z=InitDoubleStack(100000); /*0 < n ≤ 100000 зададим сразу максимальный случай, чтобы не перевыделять память*/
    for (i=0; i<n; i++) {
        scanf("%s", s);
        if (strcmp(s,"ENQ") == 0) {
            scanf("%d", &x);       
            Enqueue(&z,x);
        }
        if (strcmp(s,"DEQ") == 0) {
            x=Dequeue(&z);
            printf("%d\n", x);                      
        }
        if (strcmp(s,"EMPTY")==0) {
            f=QueueEmpty(&z);
            if (f==1)
                printf("true\n");
            else printf("false\n");
        }
        if (strcmp(s,"MAX")==0) { 
            m=Maximum(&z);
            printf("%d\n", m);
        }
    }
    free(z.data);
    free(z.max);
    return 0;
}