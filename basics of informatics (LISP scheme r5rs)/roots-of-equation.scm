#lang racket
(define (dis a b c)
  ( cond
     [( < (- (* b b) (* 4 a c)) 0) (list)]
     [( = (- (* b b) (* 4 a c)) 0) (list (/ (- b) (* 2 a )))]
     [(> (- (* b b) (* 4 a c)) 0) (list (/ (- (- b) (sqrt (- (* b b) (* 4 a c)))) (* 2 a ))
                                        (/ (+ (- b) (sqrt(- (* b b) (* 4 a c)))) (* 2 a )))]))