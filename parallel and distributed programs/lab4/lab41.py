# без синхронизации потоков 
import threading

import time
import random
import os

s = []
r = []

n = 10

def a():
    print('A started')
    global s
    for i in range(n):
        s.append(i + 1)
        time.sleep(0.5)
    print('A finished')

def b():
    print('B started')
    global s, r
    for i in range(n):
        if len(s) == 0:
            time.sleep(1)
        else:
            el : s.pop()    
            r.append(el**2)
    print('B finished')    

def c():
    print('C started')
    global s, r
    for i in range(n):
        if len(s) == 0:
            time.sleep(1)
        else:
            el : s.pop()    
            r.append(el/3)
    print('C finished')

def d():
    print('D started')
    global s, r
    for i in range(n):
        if len(r) == 0:
            print('list R is empty')
            time.sleep(1)
        else:
            print(f'last element from D is {r.pop()}')   
    print('D finished')        

def main():
    print(f'starting at: {time.ctime()}') 
    threads = [ threading.Thread(target=a), threading.Thread(target=b), threading.Thread(target=c), threading.Thread(target=d)] 
    # запуск потоков
    for t in threads:
        t.start()

    # ожидание завершения всех потоков
    for t in threads:
        t.join()

    print(f'ALL DONE at: {time.ctime()}')    