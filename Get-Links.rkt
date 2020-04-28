#lang racket
(require (planet neil/html-parsing:2:0)
         net/url
         xml
         html
         sxml/sxpath
         threading)

(define invalid-suffixes '("./" ".xml" ".jpg" ".jpeg" ".png" ".gif" ".tiff" ".psd" ".eps" ".ai" ".indd" ".raw" ".svg"))
(define invalid-prefixes '("#" "mailto:"))
(define (different-domain? baseUrl l)
  (define url (string->url l))
  (and (url-host url) (not (equal? (url-host baseUrl) (url-host url)))))

(define (good-link? baseUrl l) (not (or (different-domain? baseUrl l)
                                        (ormap (curry string-suffix? l) invalid-suffixes)
                                        (ormap (curry string-prefix? l) invalid-prefixes))))

(define (xexp->links xexp) (flatten (map cdr ((sxpath "//a/@href") xexp))))

;; See full alternative at https://stackoverflow.com/questions/28195841/how-to-extract-element-from-html-in-racket 
(define (url->links url)
  (~>> (call/input-url url get-pure-port html->xexp)
       xexp->links
       (filter (curry good-link? url))))

(define uri->links
  (λ~> string->url url->links))

(define url->baseUrl
  (λ~> (struct-copy url _ [path '()])))

(define rel->abs combine-url/relative)

(define (uri->nestedLinks-rec baseUrl uri visited levels)
  (define abs-url (combine-url/relative baseUrl uri))
  
  ;(printf "~a, ~a, ~a:~a~n" (url->string baseUrl) levels uri (url->string abs-url))
  (cond [(not (good-link? baseUrl uri)) visited]
        [(member abs-url visited)  visited]
        [(zero? levels)  (cons abs-url visited)]
        [else  (for/fold ([acc (cons abs-url visited)])
                         ([l (url->links abs-url)])
                 (uri->nestedLinks-rec abs-url l acc (sub1 levels)))]))

(define (uri->nestedLinks uri levels) (reverse (uri->nestedLinks-rec (string->url uri) "" '() levels)))

(define (uri->nestedLinksNl uri levels)
  (~>> (uri->nestedLinks uri levels) (for-each (λ~> url->string displayln))))
  

(define tests '(
  ;("https://www.lucabol.com" 3)
  ;("https://beautifulracket.com/" 3)
  ;("https://en.wikipedia.org/wiki/Typeface" 1)
  ;("https://brieferhistoryoftime.com" 3)
  ;("https://mobydick.wales/" 3)
  ;("https://resilientwebdesign.com" 3)
  ;("https://www.c82.net/euclid/" 3)
))

(for-each (λ (test) (uri->nestedLinksNl (first test) (second test))) tests)