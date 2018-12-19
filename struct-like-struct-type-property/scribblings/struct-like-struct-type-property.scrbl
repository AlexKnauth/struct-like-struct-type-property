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

@defform[(define-struct-like-struct-type-property name [field ...])]{

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
]}

