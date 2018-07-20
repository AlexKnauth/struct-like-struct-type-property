#lang racket/base

(provide
 define-struct-like-struct-type-property-syntax-class
 define-struct-like-struct-type-property/syntax-class)

(require syntax/parse/define
         syntax/parse
         racket/match
         "main.rkt"
         (submod "main.rkt" private)
         (for-syntax racket/base
                     racket/syntax
                     "util/fmt-id.rkt"))

;; ---------------------------------------------------------

;; (define-struct-like-struct-type-property-syntax-class
;;   class-name
;;   prop-constructor-name)

(define-simple-macro
  (define-struct-like-struct-type-property-syntax-class
    class-name
    prop:struct-like-property-id)

  ; -->
  #:with tmp (generate-temporary #'prop)
  #:with tmp.value (fmt-id #'tmp "~a.value" #'tmp)
  #:with prop-str (symbol->string (syntax-e #'prop))
  #:with [field-name ...] (attribute prop.field-symbols)
  #:with [field-val ...] (generate-temporaries (attribute prop.field-symbols))
  #:with [[attr-decl ...] ...]
  #'[[#:attr field-name field-val] ...]

  (define-syntax-class class-name
    #:attributes [field-name ...]
    [pattern {~var tmp (static prop.predicate 'prop-str)}
      #:do [(match-define (prop field-val ...)
              (attribute tmp.value))]
      attr-decl ... ...]))

;; ---------------------------------------------------------

;; (define-struct-like-struct-type-property/syntax-class
;;   name
;;   [field ...]
;;   options)

(define-simple-macro
  (define-struct-like-struct-type-property/syntax-class
    name:id
    [field:id ...]
    options ...)

  ;-->
  #:with class-name (fmt-id #'name "~a-id" #'name)

  (begin
    (define-struct-like-struct-type-property
      name
      [field ...]
      options ...)
    (define-struct-like-struct-type-property-syntax-class
      class-name
      name)))

;; ---------------------------------------------------------

