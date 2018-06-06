#lang racket/base

(require racket/list
         struct-like-struct-type-property)
(module+ test
  (require rackunit))

;; -----------------

(define-struct-like-struct-type-property foo [a b c])

(define-struct-like-struct-type-property fuuuu [a b c d]
  #:property prop:foo
  (λ (self) (foo (fuuuu-a self) (fuuuu-b self) (fuuuu-c self))))

;; -----------------

(module+ test
  (check-equal? (foo-a (foo 1 2 3)) 1)
  (check-equal? (foo-b (foo "a" "b" "c")) "b")
  (check-equal? (foo? (foo 'd 'e 'f)) #true)
  (check-equal? (foo? "something else") #false)

  (check-exn #rx"expected: foo\n *given: \"another value\""
             (λ () (foo-a "another value")))

  (struct bar [x]
    #:property prop:foo
    (λ (self)
      (foo (first (bar-x self))
           (second (bar-x self))
           (third (bar-x self)))))

  (struct baaaaa [x] #:transparent)

  (check-equal? (foo-a (bar (list 1 2 3))) 1)
  (check-equal? (foo-b (bar (list "a" "b" "c"))) "b")
  (check-equal? (foo? (bar (list 'd 'e 'f))) #true)
  (check-equal? (foo? (baaaaa (list 'd 'e 'f))) #false)

  (check-match (foo 1 2 3) (foo 1 x y)
               (and (even? x) (odd? y)))
  (check-match (bar (list "a" "b" "ab")) (foo x y z)
               (string=? (string-append x y) z))

  ;; -------------------------

  (check-equal? (foo-a (fuuuu 1 2 3 4)) 1)
  (check-equal? (foo-c (fuuuu 1 2 3 4)) 3)
  (check-equal? (fuuuu-d (fuuuu 1 2 3 4)) 4)
  (check-equal? (foo? (fuuuu 1 2 3 4)) #true)
  (check-equal? (fuuuu? (fuuuu 1 2 3 4)) #true)

  (check-match (fuuuu 1 2 3 4) (and (foo a b c)
                                    (fuuuu a b c d))
               (equal? (+ a b c) (+ b d)))
  )

