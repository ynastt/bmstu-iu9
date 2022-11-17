#lang r5rs
;; Конструктор потока
(define (make-stream items . eos)
  (if (null? eos)
      (make-stream items #f)
      (list items (car eos))))

;; Запрос текущего символа
(define (peek stream)
  (if (null? (car stream))
      (cadr stream)
      (caar stream)))

;; Запрос первых двух символов
(define (peek2 stream)
  (if (null? (car stream))
      (cadr stream)
      (if (null? (cdar stream))
          (list (caar stream))
          (list (caar stream) (cadar stream)))))

;; Продвижение вперёд
(define (next stream)
  (let ((n (peek stream)))
    (if (not (null? (car stream)))
        (set-car! stream (cdr (car stream))))
    n))

;1 check-frac scan-frac scan-many-fracs

; <простая дробь> :: = <десятичное-целое> 'знак дроби' <десятичное-целое-без-знака>
; <десятичное-целое> :: = <знак> <десятичное-целое-без-знака> | <десятичное-целое-без-знака>
; <знак> :: = - | +
; <десятичное-целое-без-знака> :: = <цифра> <десятичное-целое-без-знака-ост>
; <десятичное-целое-без-знака-ост> :: = <цифра> <десятичное-целое-без-знака-ост> | <пустота>

(define (check-frac str)
  (let* ((EOF (integer->char 0))
         (stream (make-stream (string->list str) EOF)))
    (call-with-current-continuation
     (lambda (error)
       (chfrac stream error)
       (equal? (peek stream) EOF)))))

; <знак> :: = - | +
(define (sign? a)
  (or (equal? a #\+) (equal? a #\-)))

(define (chfrac stream error)
  ; <десятичное-целое-без-знака> :: = <цифра> <десятичное-целое-без-знака-ост>
  (define (number-without-sign stream error)
    (cond ((char-numeric? (peek stream))
           (next stream)
           (number-without-sign-ost stream error))
          (else (error #f))))
  ; <десятичное-целое-без-знака-ост> :: = <цифра> <десятичное-целое-без-знака-ост> |<пустота>
  (define (number-without-sign-ost stream error)
    (cond ((char-numeric? (peek stream))
           (next stream)
           (number-without-sign-ost stream error))
          (else '())))
 
  ; <десятичное-целое> :: = <знак> <десятичное-целое-без-знака> | <десятичное-целое-без-знака> 
  (define (number stream error)
    (cond ((sign? (peek stream))
           (next stream)
           (number-without-sign stream error))
          ((char-numeric? (peek stream))
           (number-without-sign stream error))
          (else (error #f))))
  ;'знак дроби' 
  (define (d stream error)
    (cond ((equal? (peek stream) #\/)
           (next stream))
          (else (error #f))))
  ; <простая дробь> :: = <десятичное-целое> 'знак дроби' <десятичное-целое-без-знака>
  (number stream error)
  (d stream error)
  (number-without-sign stream error))

(define (scan-frac str)
  (let* ((EOF (integer->char 0))
         (stream (make-stream (string->list str) EOF)))
    (call-with-current-continuation
     (lambda (error)
       (define result (frac stream error))
       (and (equal? (peek stream) EOF) result)))))

(define (frac stream error)
  ; <десятичное-целое-без-знака> :: = <цифра> <десятичное-целое-без-знака-ост>
  (define (number-without-sign stream error)
    (cond ((char-numeric? (peek stream))
           (cons (next stream) (number-without-sign-ost stream error)))
          (else (error #f))))
  ; <десятичное-целое-без-знака-ост> :: = <цифра> <десятичное-целое-без-знака-ост> |<пустота>
  (define (number-without-sign-ost stream error)
    (cond ((char-numeric? (peek stream))
           (cons (next stream) (number-without-sign-ost stream error)))
          (else '())))
  ; <десятичное-целое> :: = <знак> <десятичное-целое-без-знака> | <десятичное-целое-без-знака> 
  (define (number stream error)
    (cond ((sign? (peek stream))
           (cons (next stream) (number-without-sign stream error)))
          ((char-numeric? (peek stream))
           (number-without-sign stream error))
          (else (error #f))))
  ;'знак дроби' 
  (define (d stream error)
    (cond ((equal? (peek stream) #\/)
           (next stream))
          (else (error #f))))
  ;результат работы scan-frac
  (define (function sign sp i res)
    (cond ((null? sp) (sign res))
          ((sign? (car sp)) (function (if (equal? (car sp) #\-)
                                     -
                                     +) (cdr sp) (- i 1) res))
          
          (else (function sign (cdr sp) (- i 1) (+ res (* (- (char->integer (car sp)) 48) (expt 10 i))) ))))

  (let ((up (number stream error)) ;числитель
        (div (d stream error))
        (down (number-without-sign stream error)));знаменатель
    (/ (function + up (- (length up) 1) 0) (function + down (- (length down) 1) 0))))
    
  
; <дроби> :: = <пробельные символы> <дроби> |<простая дробь> <дроби> | <пустота>
; <пробельные символы> :: = <ПРОБЕЛЬНЫЙ СИМВОЛ> <пробельные символы> | <пустота>
; <простая дробь> :: = <десятичное-целое> 'знак дроби' <десятичное-целое-без-знака>
; <десятичное-целое> :: = <знак> <десятичное-целое-без-знака> | <десятичное-целое-без-знака>
; <знак> :: = - | +
; <десятичное-целое-без-знака> :: = <цифра> <десятичное-целое-без-знака-ост>
; <десятичное-целое-без-знака-ост> :: = <цифра> <десятичное-целое-без-знака-ост> | <пустота>

(define (scan-many-fracs str)
  (let* ((EOF (integer->char 0))
         (stream (make-stream (string->list str) EOF)))
    (call-with-current-continuation
     (lambda (error)
       (define result (fracs stream error))
       (and (equal? (peek stream) EOF) result)))))

; <пробельные символы> :: = <ПРОБЕЛЬНЫЙ СИМВОЛ> <пробельные символы> | <пустота>
(define (space stream error)
  (cond ((char-whitespace? (peek stream))
         (next stream)
         (space stream error))
        (else #t)))

; <дроби> :: = <пробельные символы> <дроби> |<простая дробь> <дроби> | <пустота>
(define (fracs stream error)
  (cond ((char-whitespace? (peek stream))
         (next stream)
         ;(space stream error)
         (fracs stream error))                  
        ((or (sign? (peek stream)) (char-numeric? (peek stream)))
         (cons (frac stream error) (fracs stream error)))
        (else '())))

 
    
;2 parser

;<Program>  ::= <Articles> <Body> .
;<Articles> ::= <Article> <Articles> | .
;<Article>  ::= define word <Body> end .
;<Body>     ::= if <Body> endif <Body> | integer <Body> | word <Body> | .

(define (parse vec)
  (let* ((EOF (integer->char 0))
         (stream (make-stream (vector->list vec) EOF))) 
    (call-with-current-continuation
     (lambda (error)
       (define result (program stream error))
       (and (equal? (peek stream) EOF)
            result)))))

;<Program>  ::= <Articles> <Body> .
(define (program stream error)
  (list (articles stream error)
        (body stream error)))

;<Articles> ::= <Article> <Articles> | .
(define (articles stream error)
  (cond ((equal? (peek stream) 'define)
         (next stream)
         (cons (article stream error) (articles stream error)))
        (else '())))

;<Article>  ::= define word <Body> end .
(define (article stream error)
  (let* ((w (next stream))
         (b (body stream error))
         (e (next stream)))
    
    (if (and (word? w) (equal? e 'end))
        (list w b)
        (error #f))))
  

;<Body> ::= if <Body> endif <Body> | integer <Body> | word <Body> | .
(define (body stream error)
  (cond ((equal? (peek stream) 'if)
         (let* ((i (next stream))
                (b (body stream error))
                (e (next stream)))           
           (if (equal? e 'endif)
               (cons (list i b) (body stream error))
               (error #f))))
        ((or (integer? (peek stream)) (word? (peek stream)))
         (cons (next stream) (body stream error)))
        (else '())))

(define (word? a)
  (and (symbol? a) (not (or (equal? a 'define) (equal? a 'if) (equal? a 'end) (equal? a 'endif)))))


;testing
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

(define the-tests
  (list (test (check-frac "110/111") #t) 
        (test (check-frac "-4/3") #t)    
        (test (check-frac "+5/10") #t)   
        (test (check-frac "5.0/10") #f)
        (test (check-frac "/") #f)
        (test (check-frac "/1") #f)
        (test (check-frac "-/") #f)
        (test (check-frac "FF/10") #f)
        (test (scan-frac "110/111") 110/111)
        (test (scan-frac "-4/3") -4/3)
        (test (scan-frac "+5/10") 1/2)
        (test (scan-frac "5.0/10") #f)
        (test (scan-frac "FF/10")#f )
        (test (scan-many-fracs "\t1/2 1/3\n\n10/8") '(1/2 1/3 5/4))
        (test (scan-many-fracs "\t1/2 1/3\n\n2/-5") #f)
        (test (parse #(1 2 +)) '(() (1 2 +)))
        (test (parse #(x dup 0 swap if drop -1 endif)) '(() (x dup 0 swap (if (drop -1)))))
        (test (parse #( define -- 1 - end
                         define =0? dup 0 = end
                         define =1? dup 1 = end
                         define factorial
                         =0? if drop 1 exit endif
                         =1? if drop 1 exit endif
                         dup --
                         factorial
                         *
                         end
                         0 factorial
                         1 factorial
                         2 factorial
                         3 factorial
                         4 factorial )) '(((-- (1 -))
                                           (=0? (dup 0 =))
                                           (=1? (dup 1 =))
                                           (factorial
                                            (=0? (if (drop 1 exit)) =1? (if (drop 1 exit)) dup -- factorial *)))
                                          (0 factorial 1 factorial 2 factorial 3 factorial 4 factorial))
                                        )
        (test (parse #(define word w1 w2 w3)) #f)
        (test (parse #(define if end endif)) #f)
        (test (parse #(if if endif endif)) '(() ((if ((if ()))))))
        (test (parse #(if if if  if if endif endif  endif endif endif)) '(() ((if ((if ((if ((if ((if ())))))))))))) ))

;(run-tests the-tests)