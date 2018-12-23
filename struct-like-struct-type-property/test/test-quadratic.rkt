#lang racket/base

(require racket/match
         racket/math
         struct-like-struct-type-property)
(module+ test
  (require rackunit))

;; -----------------

(define-struct-like-struct-type-property quadratic [a b c]
  #:property prop:procedure
  (λ (self x)
    (match-define (quadratic a b c) self)
    (+ (* a (sqr x)) (* b x) c)))

(struct vertex-form [a vertex]
  #:property prop:quadratic
  (λ (self)
    (match-define (vertex-form a (list h k)) self)
    (define b (* -2 a h))
    (define c (+ (* a (sqr h)) k))
    (quadratic a b c)))

;; -----------------

(module+ test
  (define f (quadratic 1 -2 -3))
  (check-equal? (f 0) -3)
  (check-equal? (f 1) -4)
  (check-equal? (f 2) -3)
  (check-equal? (f 3) 0)
  (check-equal? (f 4) 5)
  
  (define g (vertex-form 1 '(1 -4)))
  (check-equal? (g 0) -3)
  (check-equal? (g 1) -4)
  (check-equal? (g 2) -3)
  (check-equal? (g 3) 0)
  (check-equal? (g 4) 5)
  )