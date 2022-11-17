#lang r5rs
;1 обработка списков
(define (my-range a b d)
  (if (>= a b)
      '()
      (cons a (my-range (+ a d) b d) )))

(define (my-flatten xs)
  (if (null? xs)
      '()
      (if (pair? (car xs))
          (append (my-flatten (car xs)) (my-flatten (cdr xs)))
          (cons (car xs) (my-flatten (cdr xs))))))


(define (my-element? x xs) 
  (if (null? xs)
      (= 0 1)
      (if (equal? x (car xs))
          (= 0 0)
          (my-element? x (cdr xs)))))
    ;(or (equal? x (car xs)) (my-element? x (cdr xs)))
    
(define (my-filter pred? xs) 
    (cond ((null? xs) (list))
          ((not (pred? (car xs))) (my-filter pred? (cdr xs)))
          ((cons (car xs) (my-filter pred?(cdr xs))))))

 (define (my-fold-left op xs)
  (if (not (null? (cdr xs)))
     (my-fold-left op (cons (op (car xs) (cadr xs)) (cdr (cdr xs))))
      (car xs)))


(define ( my-fold-right op xs)
  (define ( loop res xs)
    (if (null? xs)
        res
        (op res (loop (car xs) (cdr xs)))))
  (loop (car xs) (cdr xs)))

;3 работа со строками
(define (string-trim-left st)
  (if (or (equal? (car (string->list st)) #\tab) (equal? (car (string->list st)) #\newline) (equal? (car (string->list st)) #\space))
      (string-trim-left (list->string (cdr (string->list st))))
      st))
(define (string-trim-right st)
  (if (or (equal? (car (reverse (string->list st))) #\tab) (equal? (car (reverse (string->list st))) #\newline) (equal? (car (reverse (string->list st))) #\space))
      (string-trim-right (list->string (reverse (cdr (reverse (string->list st))))))
      st))
(define (string-trim st)
  (string-trim-left (string-trim-right st)))

(define (string-prefix? a b)
  (if (null? (string->list a))
      (= 1 1)
      (begin
        (if (equal? (string-length a) (string-length b)) 
            (begin   ;если длины строк совпадают
              (if (null? (cdr (string->list a)))
                  (= 1 1)
                  (begin
                    (if (equal? (car (string->list a)) (car (string->list b)))
                        (string-prefix? (list->string (cdr (string->list a))) (list->string  (cdr (string->list b))))
                        (= 1 0)))))
            (begin ;если нет
               (if (< (string-length a) (string-length b))
                  (string-prefix? a (list->string (reverse (cdr (reverse (string->list b))))))
                  (string-prefix? (list->string (reverse (cdr (reverse (string->list a))))) b)))))))

(define (string-suffix? a b)
  (if (null? (string->list a))
      (= 1 1)
      (begin
        (if (equal? (string-length a) (string-length b))
            (begin
              (if (null? (cdr (string->list a)))
                  (= 1 1)
                  (begin
                    (if (equal? (car (string->list a)) (car (string->list b)))
                        (string-suffix? (list->string (cdr (string->list a))) (list->string  (cdr (string->list b))))
                        (= 1 0)))))
            (begin
              (if (< (string-length a) (string-length b))
                  (string-suffix? a (list->string (cdr (string->list b))))
                  (string-suffix? (list->string (cdr (string->list a))) b)))))))
      

(define (string-infix? a b)
  (if (null? (string->list b))
      (= 1 0)
      (begin
        (if (or (string-prefix? a b) (string-suffix? a b))
            (= 1 1)
            (begin
              (if (equal? (string-length a) (string-length b))
                  (= 1 0)
                  (begin
                    (if (< (string-length a) (string-length b))
                        (string-infix? a (list->string  (cdr (string->list b))))
                        (string-infix? (list->string  (cdr (string->list a))) b)))))))))
;;
(define (delete str sep)
  (if (not (null? (string->list sep)))
      (begin
        (if (not (null? (string->list str)))
            (begin
              (if (equal? (car (string->list str)) (car (string->list sep)))
                  (delete (list->string (cdr (string->list str))) (list->string (cdr (string->list sep))))
                  (cons (list->string (cons (car (string->list str)) '())) (delete (list->string (cdr (string->list str))) sep)))) 
            '()))
      str))
(define (string-split str sep)
  (define k 1)
  (if (and (not (equal? (string->list str) '())) (not (equal? (cdr (string->list str)) '())) (member (car (string->list sep)) (string->list str)))
      (begin
        (if (equal? (car (string->list str)) (car (string->list sep)))
            (begin
              (if (= (string-length sep) 1)
                  (string-split (list->string (cdr (string->list str))) sep)
                  (string-split (delete str sep) sep)))
            (begin
              (if (equal? (car (cdr (string->list str))) (car (string->list sep)))
                  (begin
                    (cons (make-string k (car (string->list str))) (string-split (list->string (cdr (string->list str))) sep)))          
                  (begin
                    (list->string (append (list->string (car (string->list str))) (string-split (list->string (cdr (string->list str))) sep))))))))    
      (cons str '())))


;5 композиция
(define (f x) (+ x 2))
(define (g x) (* x 3))
(define (h x) (- x))

(define (o . xs)
  (define (loop x  xs)
        (if (null?  xs)
            x
            ((car xs) (loop x (cdr xs)))))
  (lambda (x) (loop x  xs)))

