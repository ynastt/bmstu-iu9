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



; ==================
; Лексический анализ
; ==================

; Лексика:
; <tokens> ::= <token> <tokens>
;            | <spaces> <tokens>
;            | <empty>
; <spaces> ::= SPACE <spaces> | <empty>
; <token> ::=  <bracket> | <operator> | <variable> | <digit>
; <bracket> ::= "(" | ")"
; <operator> "+" | "-" | "/" | "*" | "^"
; <variable> ::= LETTER <variable-tail>
; <variable-tail> ::= <empty> | LETTER <variable-tail>
; <digit> ::= DIGIT <digit-tail>
; <digit-tail> ::= <empty> |DIGIT <digit-tail>


(define (tokenize str)
  (let* ((EOF (integer->char 0))
         (stream (make-stream (string->list str) EOF)))
    
    (call-with-current-continuation
     (lambda (error)
       (define result (tokens stream error))
       (and (equal? (peek stream) EOF)
            result)))))


(define char-letter? char-alphabetic?)
(define char-digit? char-numeric?)
; <bracket> ::= "(" | ")"
(define (bracket? exp)
  (or (equal? exp #\( ) (equal? exp #\) )))
; <operator> "+" | "-" | "/" | "*" | "^"
(define (operator? exp)
  (member exp '(#\+ #\- #\/ #\* #\^)))

; <tokens> ::= <spaces> <tokens>
;            | <token> <tokens>
;            | <empty>
;
; (tokens stream error) -> list of tokens
(define (tokens stream error)
  (define (start-token? char)
    (or (char-letter? char)
        (char-digit? char)
        (bracket? char)
        (operator? char)))
  
  (cond ((char-whitespace? (peek stream))
         (spaces stream error)
         (tokens stream error))
        ((start-token? (peek stream))
         (cons (token stream error)
               (tokens stream error)))
        (else '())))  
; <spaces> ::= SPACE <spaces> | <empty>
;
; (spaces stream error) -> <void>
(define (spaces stream error)
  (cond ((char-whitespace? (peek stream))
         (next stream)
         (spaces stream error))
        (else #t)))


; <token> ::= <bracket> | <operator> | <variable> | <digit>
;
; (token stream error) -> token
(define (token stream error)
  (cond ((bracket? (peek stream))
         (string (next stream)))
        ((operator? (peek stream))
         (string->symbol (string (next stream))))
        ((char-letter? (peek stream))
         (variable stream error))
        ((char-digit? (peek stream))
         (digit stream error))
        (else (error #f))))

; <variable> ::= LETTER <variable-tail>
;
; (variable stream error) -> SYMBOL
(define (variable stream error)
  (cond ((char-letter? (peek stream))
         (string->symbol
          (list->string (cons (next stream)
                              (variable-tail stream error)))))
        (else (error #f))))

; <variable-tail> ::= LETTER <variable-tail> | <empty>
;
; (variable-tail stream error) -> List of CHARs
(define (variable-tail stream error)
  (cond ((char-letter? (peek stream))
         (cons (next stream)
               (variable-tail stream error)))
        (else '())))

; <digit> ::= DIGIT <digit-tail>
;
;(digit stream error) -> NUMBER
(define (digit stream error)
  (cond ((char-digit? (peek stream))
         (string->number
          (list->string (cons (next stream)
                              (digit-tail stream error)))))
        (else (error #f))))

; <digit-tail> ::= <empty> |DIGIT <digit-tail>
;
; (digit-tail stream error) -> List of CHARs
(define (digit-tail stream error)
  (cond ((char-digit? (peek stream))
         (cons (next stream)
               (digit-tail stream error)))
        (else '())))


; =====================
; Синтаксический анализ
; =====================

;Expr    ::= Term Expr' .
;Expr'   ::= AddOp Term Expr' | .    
;Term    ::= Factor Term' .
;Term'   ::= MulOp Factor Term' | .          
;Factor  ::= Power Factor' .
;Factor' ::= PowOp Power Factor' | .           
;Power   ::= value | "(" Expr ")" | unaryMinus Power .   

(define (parse tokens)
  (let* ((EOF (integer->char 0))
         (stream (make-stream tokens EOF)))
    (call-with-current-continuation
     (lambda (error)
       (define result (expr stream error))
       (and (equal? (peek stream) EOF)
            result)))))

(define (value? x)
  (and (or (number? x)
           (symbol? x))
       (not (equal? x '+))
       (not (equal? x '-))
       (not (equal? x '*))
       (not (equal? x '/))
       (not (equal? x '^))))

;Expr    ::= Term Expr' .
;Expr'   ::= AddOp Term Expr' | .    
(define (expr stream error)
  (let ((e (term stream error)))
    (define (expr-tail e)
      (if (or (equal? (peek stream) '+) (equal? (peek stream) '-)) ;AddOp
          (expr-tail (append (list e (next stream)) (list (term stream error))))
          e))
    (expr-tail e)))
         
;Term    ::= Factor Term' .
;Term'   ::= MulOp Factor Term' | .          
(define (term stream error)
  (let ((t (factor stream error)))
    (define (term-tail t)
      (if (or (equal? (peek stream) '*) (equal? (peek stream) '/)) ;MulOp
          (term-tail (append (list t (next stream)) (list (factor stream error))))
          t))
    (term-tail t)))

;Factor  ::= Power Factor' .
;Factor' ::= PowOp Power Factor' | .           
(define (factor stream error)
  (let ((f (power stream error)))
    (if (equal? (peek stream) '^) ;PowOp
        (list f (next stream) (factor stream error))
        f)))

;Power   ::= value | "(" Expr ")" | unaryMinus Power .
(define (power stream error)
  (cond ((value? (peek stream))
         (next stream))
        ((equal? (peek stream) "(")
         (next stream)
         (let ((e (expr stream error)))
           (if (equal? (next stream) ")")
               e
               (error #f))))
        ((equal? (peek stream) '-)
         (cons (next stream) (power stream error)))
        (else (error #f))))

; ====================================================
; Преобразователь дерева разбора в выражение на Scheme
; ====================================================

(define (tree->scheme xs)
  (if (and (pair? xs) (= (length xs) 3))
      (let ((arg1 (car xs))
            (op (cadr xs))
            (arg2 (caddr xs)))
        (cond ((equal? op '^) (list 'expt (tree->scheme arg1) (tree->scheme arg2)))
              (else (list op (tree->scheme arg1) (tree->scheme arg2)))))
      xs))

;;testing
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
  (list (test (tokenize "-a + b * x^2 + dy") '(- a + b * x ^ 2 + dy))
        (test (tokenize "(a - 1)/(b + 1)") '("(" a - 1 ")" / "(" b + 1 ")"))
        (test (tokenize "-a") '(- a))
        (test (tokenize "1") '(1))
        (test (parse (tokenize "a/b/c/d")) '(((a / b) / c) / d))
        (test (parse (tokenize "a^b^c^d")) '(a ^ (b ^ (c ^ d))))
        (test (parse (tokenize "a/(b/c)")) '(a / (b / c)))
        (test (parse (tokenize "a + b/c^2 - d")) '((a + (b / (c ^ 2))) - d))
        (test (eval (tree->scheme (parse (tokenize "2^2^2^2")))
                    (interaction-environment)) 65536)
        (test (tree->scheme (parse (tokenize "x^(a + 1)"))) '(expt x (+ a 1)))
        (test (parse (tokenize "(10")) #f)
        ))

;(run-tests the-tests)