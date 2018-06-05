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
                     "util/id-transformer.rkt"))

(begin-for-syntax
  ;; Syntax FmtString PlaceFiller ... -> Id
  (define (fmt-id ctx fmt . args)
    (apply format-id ctx fmt #:source ctx #:props ctx args))

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
  (define-struct-like-struct-type-property name:id [field:id ...])

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
      (make-struct-type-property 'name))

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

