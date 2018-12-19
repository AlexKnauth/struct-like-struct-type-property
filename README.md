# struct-like-struct-type-property
Creating struct-type properties with a struct-like interface.

[_Documentation_](https://docs.racket-lang.org/struct-like-struct-type-property/index.html).

```racket
(require struct-like-struct-type-property)
```

```racket
(define-struct-like-struct-type-property name [field ...])
```

Defines these identifiers:
 - `prop:name`
 - `name`
 - `name?`
 - `name-field` ...
 
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
