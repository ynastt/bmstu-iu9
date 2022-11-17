#lang r5rs
(define-syntax test
  (syntax-rules ()
    ((_ expr exp-result)  (list 'expr exp-result))))


(define (run-test the-test)
  (let ((expr (car the-test)))
    (display expr)
    (let* ((res (eval expr (interaction-environment))) ;глоб перем
           (sign (equal? (cadr the-test) res))) ;признак #t или #f
      (if sign
          (display " OK")
          (begin
            (display " FAIL")
            (newline)
            (display "  Expected: ") (display (cadr the-test))
            (newline)
            (display "  Returned: ") (display res)))
      (newline)
      sign))) ;Функция возвращает #t, если тест пройден и #f в противном случае


(define (run-tests the-tests)
  (define (func x xs)
    (if (null? xs)
        x
        (func (and x (car xs)) (cdr xs))))
  (func #t (map run-test the-tests)))

;example
(define (signum x)
  (cond
    ((< x 0) -1)
    ((= x 0)  1) ; Ошибка здесь!
    (else     1)))

;(define the-tests
 ; (list (test (signum -2) -1)
  ;      (test (signum  0)  0)
   ;     (test (signum  2)  1)))

