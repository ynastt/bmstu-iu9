#lang racket
;Нод
(define (my-gcd a b)
     (if (> a b) (gcd (- a b) b)
     (if (< a b) (gcd a (- b a))
        a)))
;НОК
(define (my-lcm a b) (/ (* a b) (my-gcd a b)))

;Проверка на простоту
(define (factorial-classic n)
  (if (zero? n) 1 (* n (factorial-classic (- n 1)))))

(define (prime? n)
  (= (remainder (+ (factorial-classic (- n 1)) 1) n) 0))
;проверка на простоту через делители
(define (my-prime? n)
  (define (prime n b)
    (if (= (remainder n b) 0)
        (= n b)
        (prime n (+ b 1))))
  (prime n 2))
  

              