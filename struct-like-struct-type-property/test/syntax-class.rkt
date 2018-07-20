#lang racket/base

(require syntax/parse/define
         (for-syntax racket/base
                     struct-like-struct-type-property
                     struct-like-struct-type-property/syntax-class))
(module+ test
  (require rackunit))

;; ---------------------------------------------------------

(begin-for-syntax
  (define-struct-like-struct-type-property/syntax-class
    foo-info
    [a b c]))

(define-simple-macro (m foo:foo-info-id)
  '(foo.a foo.b foo.c))

;; ---------------------------------------------------------

(module+ test
  (define-syntax x (foo-info #'1 #'2 #'3))
  (check-equal? (m x) '(1 2 3)))

