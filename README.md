# struct-like-struct-type-property
Creating struct-type properties with a struct-like interface.

[_Documentation_](https://docs.racket-lang.org/struct-like-struct-type-property/index.html).

```racket
(require struct-like-struct-type-property)
```

```racket
(define-struct-like-struct-type-property name [field ...]
  prop-option ...)
  
  prop-option = #:property prop-expr val-expr
```

Defines these identifiers:
 - `prop:name`
 - `name`
 - `name?`
 - `name-field` ...
 
The property `prop:name` expects a function that takes a
"self" argument and returns a `name` result. When someone
wants to use the value as a `prop:name`, this function
should construct a more basic structure that contains the
field values.

Example:
```racket
(define-struct-like-struct-type-property foo [a b c])

> (foo-a (foo 1 2 3))
1
> (foo? (foo "a" "b" "c"))
#true
> (struct bar [x]
    #:property prop:foo
    (lambda (self)
      (foo (first (bar-x self))
           (second (bar-x self))
           (third (bar-x self)))))
> (foo-a (bar (list 4 5 6)))
4
> (foo? (bar (list 'd 'e 'f)))
#true
> (match (bar (list 1 3 5))
    [(foo a b c) c])
5
```

The `#:property prop-expr val-expr` options specify
super-properties. Anything that implements `prop:name` will
automatically implement all the properties specified by the
given `prop-exprs`.

Example:
```racket
(define-struct-like-struct-type-property quadratic [a b c]
  #:property prop:procedure
  (λ (self x)
    (+ (* (quadratic-a self) (sqr x))
       (* (quadratic-b self) x)
       (quadratic-c self))))

> (define f (quadratic 1 -2 -3))
> (f 0)
-3
> (f 1)
-4
> (f 2)
-3
> (f 3)
0
> (f 4)
5
```

