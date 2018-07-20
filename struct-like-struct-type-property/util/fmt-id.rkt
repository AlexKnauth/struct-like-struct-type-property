#lang racket/base

(provide fmt-id)

(require racket/syntax)

;; Syntax FmtString PlaceFiller ... -> Id
(define (fmt-id ctx fmt . args)
  (apply format-id ctx fmt #:source ctx #:props ctx args))

