#lang r5rs
;2 множества
(define (list->set xs)
  (if (null? xs)
      '()
      (if (member (car xs) (cdr xs))
          (list->set (cdr xs))
          (cons (car xs) (list->set (cdr xs))))))
;
(define (set? xs)
  (or (null? xs)
      (and (not(member (car xs) (cdr xs)))
           (set? (cdr xs)))))
;
(define (union xs ys)
  (if (null? xs)
      ys
      (if (member (car xs) ys)
          (union (cdr xs) ys)
          (cons (car xs) (union (cdr xs) ys)))))

;другой способ
;(define (union xs ys)
;  (list->set (append xs ys)))
;
(define (intersection xs ys)
  (cond ((null? xs) '())
        ((member (car xs) ys) (cons (car xs)(intersection (cdr xs) ys))) 
        (else (intersection (cdr xs) ys))))
;
(define (difference xs ys)
  (if (null? xs)
      '()
      (if (member (car xs) ys)
          (difference (cdr xs) ys)
          (cons (car xs) (difference (cdr xs) ys)))))
;
(define (symmetric-difference xs ys)
  (union (difference xs ys) (difference ys xs)))
;
(define (set-eq? xs ys)
  (and (equal? (difference xs ys) '()) (equal? (difference ys xs) '())))
