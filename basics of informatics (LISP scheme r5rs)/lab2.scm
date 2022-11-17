#lang r5rs
;1 сколько раз встречается элемент x в списке xs
(define (count x xs)
  (cond ((null? xs) 0)
        ((equal? x (car xs)) (+ 1 (count x (cdr xs))))
        ((count x (cdr xs)))))

;2 "удаляет" из списка все элементы, удовлетворяющие предикату pred?
(define (delete pred? xs)
  (cond ((null? xs) (list))
        ((pred? (car xs)) (delete pred? (cdr xs)))
        ((cons (car xs) (delete pred?(cdr xs))))))

;3
(define (iterate f x n)
 (define (loop res x n)
   (if (= n 0) (reverse res)
       (loop (cons x res) (f x)
             (- n 1))))
  (loop '() x n))

;4 вставка элемента
(define (intersperse e xs)
  (cond ((null? xs) '())
        ((= 1 (length xs)) xs)
        (cons (car xs)( cons e (intersperse e (cdr xs))))))

;5 all 
(define (all? pred? xs)
  (or (null? xs) (and (pred? (car xs))(all? pred? (cdr xs)))))
; any
(define (any? pred? xs)
  (and (not(null? xs)) (or (pred? (car xs))(any? pred? (cdr xs)))))

;6 композиция
(define (f x) (+ x 2))
(define (g x) (* x 3))
(define (h x) (- x))

(define (o . xs)
  (define (loop x  xs)
        (if (null?  xs)
            x
            ((car xs) (loop x (cdr xs)))))
  (lambda (x) (loop x  xs)))


    