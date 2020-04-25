#lang racket
(require (planet neil/html-parsing:2:0)
         net/url
         xml
         html
         xml/path
         threading)

(define (good-link? l) (not (or (~> l string->url url-path-absolute?)
                                (string-prefix? l "#")
                                (string-suffix? l "xml")
                                (equal? l "./"))))

(define (read-html-as-xexpr in) ;; input-port? -> xexpr?
  (caddr
   (xml->xexpr
    (element #f #f 'root '()
             (read-html-as-xml in)))))

;; See full alternative at https://stackoverflow.com/questions/28195841/how-to-extract-element-from-html-in-racket 
(define (url->links url)
  (~>> (call/input-url url get-pure-port html->xexp)
       (se-path*/list '(a @ href))
       (filter good-link?)))

(define url->links1
  (λ~> get-pure-port
       html->xexp
       (se-path*/list '(a @ href) _)
       (filter good-link? _)
       ))
(define uri->links
  (λ~> string->url url->links))

(define url->baseUrl
  (λ~> (struct-copy url _ [path '()])))

(define (uri->nestedLinks2 uri levels)
  (define baseUrl (~> uri string->url url->baseUrl))

  (define (wrap uri visited-levels)
    (let* ([visited (car visited-levels)]
           [levels (cdr visited-levels)]
           [absUrl (combine-url/relative baseUrl uri)]
           [absUri (url->string absUrl)])

      (cond
        [(member absUri visited) visited-levels]
        [(zero? levels) (cons (cons absUri visited) levels)]
        [else (foldl wrap
                     (cons (cons absUri visited) (sub1 levels))
                     (url->links absUrl))]
        )))
  (reverse (car (wrap uri (cons '() levels)))))

(define (uri->nestedLinksNl uri levels)
  (~>> (uri->nestedLinks uri levels) (for-each displayln)))
  
#;
(uri->nestedLinksNl "https://www.lucabol.com" 2)
(uri->nestedLinksNl "https://beautifulracket.com/" 4)
#;
(uri->nestedLinksNl "https://en.wikipedia.org/wiki/Typeface" 4)
#;
(uri->nestedLinksNl "http://www.reddit.com/r/programming/search?q=racket&sort=relevance&restrict_sr=on&t=all" 4)

