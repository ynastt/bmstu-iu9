# без синхронизации потоков 
import threading
import time
# import os

s = []
r = []

#lists length
n = 10


def a():
    print('A started')
    global s
    for i in range(n):
        s.append(i + 1)
        print('A added', i + 1)
        time.sleep(0.2)
    print('A finished')


def b():
    print('B started')
    global s, r
    for i in range(n):
        if len(s) == 0:
            time.sleep(1)
        else:
            el = s.pop()    
            print('B got', el)
            r.append(el * el)
        print('B finished')    


def c():
    print('C started')
    global s, r
    for i in range(n):
        if len(s) == 0:
            time.sleep(1)
        else:
            el = s.pop()  
            print('C got', el)  
            r.append(el // 3)
        print('C finished')


def d():
    print('D started')
    global s, r
    for i in range(n):
        if len(r) == 0:
            print('list R is empty')
            time.sleep(1)
        else:
            el = r.pop() 
            print(f'last element from D is {el}') 
        print('D finished')        


threads = [ threading.Thread(target=a), threading.Thread(target=b), threading.Thread(target=c), threading.Thread(target=d)] 
# запуск потоков
for t in threads:
    t.start()

# ожидание завершения всех потоков
for t in threads:
    t.join()
   