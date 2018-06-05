#lang racket/base

(provide make-var-like-transformer)

(require syntax/stx)

(define (make-var-like-transformer reference-stx)
  (define (transformer stx)
    (cond
      [(identifier? stx) reference-stx]
      [(stx-pair? stx)
       (datum->syntax stx `(#%app ,(stx-car stx) . ,(stx-cdr stx)) stx stx)]
      [else
       (raise-syntax-error #f "bad syntax" stx)]))
  transformer)

