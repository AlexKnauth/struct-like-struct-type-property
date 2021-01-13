#lang racket/base

(provide make-struct-type-property/generic
         make-generic-struct-type-property)

(require racket/function
         racket/private/generic-methods
         syntax/parse/define
         (for-syntax racket/base))
(module+ test
  (require rackunit
           racket/dict))

(begin-for-syntax
  (define-splicing-syntax-class pmreotpheordtsy
    #:attributes [prop-super-pair]
    (pattern (~seq #:property prop:expr val:expr)
      #:with prop-super-pair
      #'(cons prop (const val)))
    (pattern (~seq #:methods gen-interface:id
                   [method-def
                    ...])
      #:with prop-super-pair
      #'(cons (generic-property gen-interface)
              (const (generic-method-table gen-interface method-def ...))))))

(define-simple-macro
  (make-struct-type-property/generic
   name:expr
   (~optional guard:expr #:defaults [(guard #'#f)])
   (~optional supers:expr #:defaults [(supers #''())])
   (~optional can-impersonate?:expr #:defaults [(can-impersonate? #'#f)])
   pm:pmreotpheordtsy
   ...)
  (make-struct-type-property name
                             guard
                             (list* pm.prop-super-pair ... supers)
                             can-impersonate?))

(define-simple-macro
  (make-generic-struct-type-property gen-interface:id method-def:expr ...)
  (let-values [((prop _pred _ref)
                (make-struct-type-property/generic 'gen-interface
                  #:methods gen-interface
                  [method-def
                   ...]))]
    prop))

(module+ test
  (test-case "silly-dict"
    (define prop:silly-dict
      (make-generic-struct-type-property
       gen:dict
       (define (dict-ref self k [default #f])
         'i-am-a-dict)))
    (struct example ()
      #:transparent
      #:property prop:silly-dict #f)
    (check-equal? (dict-ref (example) 42) 'i-am-a-dict)))
