# спровоцирована блокировка вследствие состязания
# зависание потоков А, В, С, проявляется в постоянно пустом списке R
import threading
import time

s = []
r = []

#lists length
n = 10
# lock oblect
locking = threading.Lock()
locking1 = threading.Lock()


def a():
    print('A started')
    global s
    for i in range(n):
        locking.acquire()
        s.append(i + 1)
        locking.release()
        print('A added', i + 1)
        time.sleep(0.4)
    print('A finished')


def b():
    print('B started')
    global s, r
    for i in range(n):
        if len(s) == 0:
            time.sleep(1)
        else:
            locking.acquire()
            time.sleep(0.5)
            locking1.acquire()
            el = s.pop()    
            print('B got', el)
            r.append(el * el)
            locking1.release()
            time.sleep(0.5)
            locking.release()
    print('B finished')    


def c():
    print('C started')
    global s, r
    for i in range(n):
        if len(s) == 0:
            time.sleep(1)
        else:
            locking1.acquire()
            time.sleep(0.5)
            locking.acquire()
            el = s.pop()  
            print('C got', el)  
            r.append(el // 3)
            locking.release()
            time.sleep(0.5)
            locking1.release()
    print('C finished')


def d():
    print('D started')
    global s, r
    for i in range(n):
        if len(r) == 0:
            print('list R is empty')
            time.sleep(1)
        else:
            locking1.acquire()
            el = r.pop() 
            print(f'last element from D is {el}') 
            locking1.release()
            # if el == n//3 or el == n**2:
            #     print('D finished')
            #     os._exit(0)   
    print('D finished') 
            

threads = [ threading.Thread(target=a), threading.Thread(target=b), threading.Thread(target=c), threading.Thread(target=d)] 
# запуск потоков
for t in threads:
    t.start()

# ожидание завершения всех потоков
for t in threads:
    t.join()
     
