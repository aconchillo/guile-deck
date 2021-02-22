(define-module (deck core types matrix-content-uri)
  #:use-module (oop goops)
  #:export (<matrix-content-uri>
            matrix-content-uri-server
            matrix-content-uri-protocol
            matrix-content-uri-media-id))


(define-class <matrix-content-uri> ()
  ;; <string>
  (server
   #:init-value   #f
   #:init-keyword #:server
   #:getter       matrix-content-uri-server)

  ;; <string>
  (protocol
   #:init-value   "mxc"
   #:init-keyword #:protocol
   #:getter       matrix-content-uri-protocol)

  ;; <string>
  (media-id
   #:init-value   #f
   #:init-keyword #:media-id
   #:getter       matrix-content-uri-media-id))



(define-method (display (uri <matrix-content-uri>) (port <port>))
  (format port "#<matrix-content-uri ~a://~a/~a ~a>"
          (matrix-content-uri-protocol uri)
          (matrix-content-uri-server uri)
          (matrix-content-uri-media-id uri)
          (number->string (object-address pipe) 16)))

(define-method (write (uri <matrix-content-uri>) (port <port>))
  (display uri port))

(define-method (display (uri <matrix-content-uri>))
  (next-method)
  (display uri (current-output-port)))

(define-method (write (uri <matrix-content-uri>))
  (next-method)
  (display uri (current-output-port)))



