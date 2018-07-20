#lang racket/base

(provide define-struct-like-struct-type-property)

;; (define-struct-like-struct-type-property name [field ...])
;;
;; defines:
;;  - prop:name
;;  - name
;;  - name?
;;  - name-field ...

(require racket/function
         racket/match
         syntax/parse/define
         (for-syntax racket/base
                     racket/syntax
                     (only-in syntax/parse [attribute @])
                     "util/fmt-id.rkt"
                     "util/id-transformer.rkt"))

(begin-for-syntax

  ;; "super" properties, or properties that it implies
  (define-splicing-syntax-class super-property-clause
    #:attributes [pair]
    [pattern {~seq #:property prop value}
      #:with pair #'(cons prop (const value))])

  (define-splicing-syntax-class options
    #:attributes [[other-arg 1]]
    [pattern {~seq} #:with [other-arg ...] '()]
    [pattern {~seq super:super-property-clause ...}
      #:with [other-arg ...]
      #'[#f
         (list super.pair ...)]])

  ;; Nat Id Id Id -> [Syntax -> Syntax]
  (define (make-struct-like-property-match-transformer
           N
           name?
           internal-normalize-prop
           name-struct)
    (syntax-parser
      [(_ pat:expr ...)
       #:do [(define n (length (@ pat)))]
       #:fail-when (< n N) "not enough fields"
       #:fail-when (> n N) "too many fields"
       #`(? #,name?
            (app #,internal-normalize-prop
                 (#,name-struct pat ...)))])))

(define-simple-macro
  (define-struct-like-struct-type-property name:id [field:id ...]
    options:options)

  #:with prop-name (fmt-id #'name "prop:~a" #'name)
  #:with name-str  (symbol->string (syntax-e #'name))
  #:with name?     (fmt-id #'name "~a?" #'name)
  #:with [name-field ...]
  (for/list ([field (in-list (@ field))])
    (fmt-id #'name "~a-~a" #'name field))

  #:with name-struct (fmt-id #'here "~a-struct" #'name)
  #:with name-struct? (fmt-id #'here "~a-struct?" #'name)
  #:with [name-struct-field ...]
  (for/list ([field (in-list (@ field))])
    (fmt-id #'here "~a-struct-~a" #'name field))

  #:with N (length (@ field))

  (begin
    (define-values [prop-name name? internal-prop-ref]
      (make-struct-type-property 'name options.other-arg ...))

    (struct name-struct [field ...]
      #:property prop-name identity)

    ;; name? -> name-struct?
    (define (internal-normalize-prop v)
      (cond [(name-struct? v) v]
            [(name? v)
             (internal-normalize-prop ((internal-prop-ref v) v))]
            [else
             (raise-argument-error 'prop-name 'name-str v)]))

    (define (name-field v)
      (name-struct-field (internal-normalize-prop v)))
    ...

    (define-match-expander name
      (make-struct-like-property-match-transformer
       'N
       (quote-syntax name?)
       (quote-syntax internal-normalize-prop)
       (quote-syntax name-struct))
      (make-var-like-transformer
       (quote-syntax name-struct)))))

