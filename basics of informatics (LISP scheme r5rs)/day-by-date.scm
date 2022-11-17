#lang racket
(define (day-of-week d m y)
(if ( < m 3)
    (+ 1 (remainder (+ (+ d 3) (- y 1) (quotient (- y 1) 4) (-( quotient (- y 1) 100)) ( quotient (- y 1) 400) (quotient (+ (* 31 m) 10) 12)) 7))
    (+ 1 (remainder (+ d y (quotient y 4) (-( quotient y 100)) ( quotient y 400) (quotient (+ (* 31 m) 10) 12)) 7))))