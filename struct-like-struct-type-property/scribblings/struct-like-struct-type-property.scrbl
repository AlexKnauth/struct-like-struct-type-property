#lang scribble/manual

@(require scribble/eval
          (for-label racket
                     struct-like-struct-type-property
                     struct-like-struct-type-property/syntax-class))

@title{Struct-type properties with a struct-like interface}

Source code:
@url{https://github.com/AlexKnauth/struct-like-struct-type-property}.

@defmodule[struct-like-struct-type-property]

@(define (make-ev)
   (define ev (make-base-eval))
   (ev '(require racket
                 struct-like-struct-type-property))
   ev)

@defform[(define-struct-like-struct-type-property name [field ...]
           prop-option ...)
         #:grammar ([prop-option {code:line #:property prop-expr val-expr}])]{

Defines these identifiers:

@itemlist[
  @item{@racket[prop:name], a struct-type property}
  @item{@racket[name], a constructor for a struct that implements the property}
  @item{@racket[name?], a predicate for values that have the property}
  @item{@racket[name-field ...], an accessor for each field}
]

The property @racket[prop:name] expects a function that
takes a "self" argument and returns a @racket[name] result.
When someone wants to use the value as a @racket[prop:name],
this function should construct a more basic structure that
contains the field values.

@examples[
  #:eval (make-ev)
  (require struct-like-struct-type-property)
  (define-struct-like-struct-type-property foo [a b c])
  (foo-a (foo 1 2 3))
  (foo? (foo "a" "b" "c"))
  (struct bar [x]
    #:property prop:foo (code:comment "when a bar is used as a foo, do this")
    (lambda (self)
      (foo (first (bar-x self))
           (second (bar-x self))
           (third (bar-x self)))))
  (foo-a (bar (list 4 5 6)))
  (foo? (bar (list 'd 'e 'f)))
  (match (bar (list 1 3 5))
    [(foo a b c) c])
]

The @racket[#:property prop-expr val-expr] options specify
super-properties. Anything that implements @racket[prop:name]
will automatically implement all the properties specified by
the given @racket[prop-expr]s.

@examples[
  #:eval (make-ev)
  (require struct-like-struct-type-property)
  (define-struct-like-struct-type-property quadratic [a b c]
    #:property prop:procedure
    (λ (self x)
      (+ (* (quadratic-a self) (sqr x))
         (* (quadratic-b self) x)
         (quadratic-c self))))
  (define f (quadratic 1 -2 -3))
  (f 0)
  (f 1)
  (f 2)
  (f 3)
  (f 4)
  (struct vertex-form [a vertex]
    #:property prop:quadratic
    (λ (self)
      (match (vertex-form-vertex self)
        [(list h k)
         (define a (vertex-form-a self))
         (define b (* -2 a h))
         (define c (+ (* a (sqr h)) k))
         (quadratic a b c)])))
  (define g (vertex-form 1 '(1 -4)))
  (g 0)
  (g 1)
  (g 2)
  (g 3)
  (g 4)
]}

