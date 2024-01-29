;;;; Kristian Kovacev 885839
;;;; Marco Fagnani 879215

(defparameter { '#\{)
(defparameter } '#\})
(defparameter [ '#\[)
(defparameter ] '#\])
(defparameter ws '(#\space #\newline #\tab #\return #\backspace))
(defparameter colon '#\:)
(defparameter double-quote '#\"); "
(defparameter backslash '#\\)
(defparameter escape '(#\" #\\ #\/ #\b #\f #\n #\r #\t))
(defparameter comma '#\,)
(defparameter digits '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9))
(defparameter dot '#\.)
(defparameter exponent '(#\e #\E))
(defparameter sign '(#\+ #\-))
(defparameter minus '#\-)

(defun is-whitespace (chars)
  (if (member (car chars) ws)
      (is-whitespace (cdr chars))
      (append chars))

  )


(defun is-escape (char)
  (member char escape)
  )

(defun is-string-aux (char-list)
  (cond ((eql (car char-list) double-quote) (list (car char-list))) ; se ho il " ho finito
        ((eql (car char-list) backslash)
         (if (is-escape (cadr char-list))
             (append (list (car char-list)(cadr char-list))
                     (is-string-aux (cddr char-list)))
             (error "ERROR: syntax error")))
        (T (append (list (car char-list))
                   (is-string-aux (cdr char-list))))) ; tutto il resto lo accetto
  )



(defun is-string (char-list)
  (if (eql (car char-list) double-quote) ; controllo solo le prime " e se non ci sono vado in errore
      (cons (car char-list) (is-string-aux (cdr char-list)))
      ;(is-string-aux (cdr char-list))
      (error "ERROR: string not valid"))
  )
(defun is-colon (char-list)
  (if (eql colon (car char-list))
     (cdr char-list)
     (error "ERROR: syntax error"))
  )

(defun list-to-string (lst)
    (format nil "~{~A~}" lst))

(defun toggle-quote (char-list)
  (if (eql (car char-list) double-quote)
      ()
      (cons (car char-list) (toggle-quote (cdr char-list))))
  )

(defun is-digit (char-list)
  (cond ((or (eql (car char-list) dot) (member (car char-list) exponent)
             (eql (car char-list) }) (eql (car char-list) ])
             (eql (car char-list) comma)); (member (car char-list) ws))
         ())
        ((member (car char-list) ws)
         (if (or (eql (car (is-whitespace char-list)) comma)
                 (eql (car (is-whitespace char-list)) ])
                 (eql (car (is-whitespace char-list)) }))
             ()
             (error "ERROR: syntax error"))
         )
        ((member (car char-list) digits)
         (cons (car char-list) (is-digit (cdr char-list))))
        (T (error "ERROR: syntax error")))
  )
(defun is-integer (char-list)
  (cond ((member (first char-list) digits) (is-digit char-list))
        ((and (eql (first char-list) minus)
              (member (second char-list) digits))
         (cons (first char-list) (is-digit (cdr char-list))))
        ))

(defun is-fraction (char-list)
      (cond ((or (eql (car char-list) exponent) (eql (car char-list) })
                 ) ())
            ((member (car char-list) digits)
             (cons (car char-list) (is-fraction (cdr char-list))))
            ((member (car char-list) ws) (error "ERROR: syntax error")))
  )

(defun is-dot (char-list)
  (if (eql (first char-list) dot)
      (if (member (second char-list) digits)
          (cons dot (is-fraction (cdr char-list)))
          (error "ERROR: syntax error"))
      )
  )

(defun is-exponent-rest (char-list)
      (cond ((or (eql (car char-list) })
                 ;(member (car char-list) ws)
                 ) ())
            ((member (car char-list) ws)
             (if (or (eql (car (is-whitespace (cdr char-list))) comma)
                      (eql (car (is-whitespace (cdr char-list))) })
                      (eql (car (is-whitespace (cdr char-list))) ]))
                  ()
                  (error "ERROR: syntax error")))
            ((member (car char-list) digits)
             (cons (car char-list)
                   (is-exponent-rest (cdr char-list))))))

(defun is-exponent (char-list)
  (if (member (first char-list) exponent)
      ;(if (member (second char-list) ws)
      ;    (error "is-exp syntax error"))

      (cond ((member (second char-list) ws)
             (error "ERROR: syntax error"))
            ((member (second char-list) digits)
             (cons (first char-list) (is-exponent-rest
                                      (cdr char-list))))
            ((and (member (second char-list) sign)
                  (member (caddr char-list) digits))
             (cons (first char-list)
                   (cons (second char-list)
                         (is-exponent-rest (cddr char-list))))))
      ))


(defun has-whitespace (char-list)
  (if (null char-list)
      ()
      (or (eql (member (car char-list) ws) ws)
          (has-whitespace (cdr char-list))))

  )



(defun is-number (char-list)
  (let* ((integer (is-integer char-list))
         (rest-str (get-rest-string char-list integer))
         (fraction (is-dot rest-str))
         (rest-str (get-rest-string rest-str fraction))
         (exponent (is-exponent rest-str)))

    (append integer fraction exponent)

    )
  )





(defun get-rest-string (char-list string-output)
  (if (eql (car char-list) (car string-output))
      (get-rest-string (cdr char-list) (cdr string-output))
      (append char-list))
  )

(defun check (string-output counter)
  (cond ((eql string-output nil)
         (= counter 0))
        ((or (eql (car string-output) {)
             (eql (car string-output) [))
         (c-obj (cdr string-output) (+ counter 1)))
        ((or (eql (car string-output) })
             (eql (car string-output) ]))
        (c-obj (cdr string-output) (- counter 1)))
        (T (c-obj (cdr string-output) counter))
        )

  )



(defun c-obj (string-output counter)
  (cond ((eql string-output nil)
         ())
        ((or (eql (car string-output) {)
             (eql (car string-output) [))
         (c-obj (cdr string-output) (+ counter 1)))
        ((or (eql (car string-output) })
             (eql (car string-output) ]))
        (c-obj (cdr string-output) (- counter 1)))
        ((= counter 0)
         (append string-output))
        (T (c-obj (cdr string-output) counter))
        )

  )


(defun get-rest (char-list string-output)
    (cond ((or (eql (car string-output) 'jsonobj)
               (eql (car string-output) 'jsonarray))
           (c-obj char-list 0))
          (T (get-rest-string char-list string-output))
          )
  )

(defun is-value (char-list)
  (cond ((and (eql (car char-list) '#\t)
              (eql (cadr char-list) '#\r)
              (eql (caddr char-list) '#\u)
              (eql (cadddr char-list) '#\e))
         (list #\t #\r #\u #\e)) ;   true
        ((and (eql (car char-list) '#\f)
              (eql (cadr char-list) '#\a)
              (eql (caddr char-list) '#\l)
              (eql (cadddr char-list) '#\s)
              (eql (fifth char-list) '#\e))
         (list #\f #\a #\l #\s #\e))

        ((and (eql (car char-list) '#\n)
              (eql (cadr char-list) '#\u)
              (eql (caddr char-list) '#\l)
              (eql (cadddr char-list) '#\l))
         (list #\n #\u #\l #\l)))
  )



(defun is-element (char-list)
  (cond ((eql (car char-list) double-quote) (is-string char-list))
        ((eql (car char-list) {) (is-object (cdr char-list)))
        ((or (eql (car char-list) minus) (member (car char-list) digits))
         (is-number char-list))
        ((eql (car char-list) [) (is-array (cdr char-list)))
        ((or
          (eql (car char-list) '#\t)
          (eql (car char-list) '#\f)
          (eql (car char-list) '#\n)) (is-value char-list))))



(defun is-pair (char-list)
  (let* ((string-output (is-string (is-whitespace char-list)))
         (rest-str (is-whitespace
                    (get-rest-string
                     (is-whitespace char-list) string-output)))
         (string-output (toggle-quote (cdr string-output)))
         (element (is-element (is-whitespace
                               (is-colon rest-str)))) ; (toggle_quote (cdr ())) qui
         (rest-str (is-whitespace
                    (get-rest (is-whitespace (is-colon rest-str)) element)))
         (element (if (eql (car element) double-quote)
                      (toggle-quote (cdr element))
                      (append element)))
         )
        (if (eql comma (car rest-str))
            (cond ((or (eql (car element) 'jsonobj)
             (eql (car element) 'jsonarray)) ;true
             
                   (cons (list (coerce string-output 'string) element)
                    (is-pair (cdr rest-str))))
                  ((or (eql (car element) #\t) (eql (car element) #\f)
                       (eql (car element) #\n) (eql (car element) minus)
                       (member (car element) digits))
                   (cons (list (coerce string-output 'string)
                               (read-from-string(coerce element 'string)))
                         (is-pair (cdr rest-str)))) ;number
                  ;((or (eql (car element) '#\t) (eql (car element) '#\f) (eql (car element) '#\n))
                   ;(cons (list (coerce string-output 'string) )))
                  ((not (null element))
                   (cons (list (coerce string-output 'string)
                               (coerce element 'string))
                         (is-pair (cdr rest-str))))
                  (T(error "ERROR: syntax error")))
            (cond ((or (eql (car element) 'jsonobj)
                       (eql (car element) 'jsonarray)) ; false
                   (list (cons (coerce string-output 'string)
                               (cons element nil))))
                  ((or (eql (car element) #\t)
                       (eql (car element) #\f)
                       (eql (car element) #\n)
                       (eql (car element) minus)
                       (member (car element) digits))
                   (list (cons (coerce string-output 'string)
                               (cons
                                (read-from-string
                                 (coerce element 'string)) nil))))
                  ((not (null element))
                   (list (cons (coerce string-output 'string)
                               (cons (coerce element 'string) nil))))
                  (T (error "ERROR: syntax error"))))

    )
  )
(defun count-par (char-list counter)
  ;(print (car char-list))
  (cond ((car char-list) (= counter 0))
        ((eql { (car char-list))
         (count-par (cdr char-list) (+ counter 1)))
        ((eql } (car char-list))
         (count-par (cdr char-list) (- counter 1)))
        ((= counter 0) (= counter 0))
        (T (count-par (cdr char-list) counter))))


(defun get-char (char-list counter)
  (cond ((= counter 0) (car char-list))

    ((> counter 1)
          (cond

        ((eql (cdr char-list) nil)
         (car char-list))
        ((or (eql (car char-list) {)
             (eql (car char-list) [))
         (get-char (cdr char-list) (+ counter 1)))
        ((or (eql (car char-list) })
             (eql (car char-list) ]))
        (get-char (cdr char-list) (- counter 1)))
        (T (get-char (cdr char-list) counter))))

         ((= counter 1)
           (cond ((eql (cdr char-list) nil)
                  (car char-list))
        ((or (eql (car char-list) {)
             (eql (car char-list) [))
         (get-char (cdr char-list) (+ counter 1)))
        ((or (eql (car char-list) })
             (eql (car char-list) ]))
        (get-char char-list (- counter 1)))
        (T (get-char (cdr char-list) counter)))

           )
        )
  )



(defun is-object (char-list)
    (if (eql (get-char char-list 1) })
        (if (eql (car (is-whitespace char-list)) })
            (cons 'jsonobj nil)
            (cons 'jsonobj (is-pair (is-whitespace char-list))))
        (error "ERROR: syntax error"))

  )

(defun is-element-arr (char-list)
 (cond ((eql (car char-list) double-quote)
        (toggle-quote (cdr (is-string char-list))))
        ((eql (car char-list) {) (is-object char-list))
        ((or (eql (car char-list) minus) (member (car char-list) digits))
         (read-from-string (coerce (is-number char-list) 'string))
         ;(print char-list)
         )))


(defun recursive-array (char-list)
  (let* ((element (is-element (is-whitespace char-list)))
         (rest-str (get-rest (is-whitespace char-list) element))
         (element (if (eql (car element) double-quote)
                      (toggle-quote (cdr element))
                      (append element)))
         (rest-str (is-whitespace rest-str)))


        (if (eql (car rest-str) comma)
          (cond ((or (eql (car element) '#\t) (eql (car element) '#\f)
                     (eql (car element) '#\n) (eql (car element) minus)
                     (member (car element) digits))
                 (cons (read-from-string (coerce element 'string))
                       (recursive-array (cdr rest-str))))
                ((or (eql (car element) 'jsonobj)
                     (eql (car element) 'jsonarray))
                 (cons element (recursive-array (cdr rest-str))))
                ((not (null element))
                 (cons (coerce element 'string)
                                (recursive-array (cdr rest-str))))
                (T (error "ERROR: syntax error")))
              (cond ((or (eql (car element) '#\t)(eql (car element) '#\f)
                         (eql (car element) '#\n) (eql (car element) minus)
                         (member (car element) digits))
                 (list (read-from-string (coerce element 'string))))
                ((or (eql (car element) 'jsonobj)
                     (eql (car element) 'jsonarray))
                 (cons element nil))
                ((not (null element)) (cons (coerce element 'string) nil))
                (T (error "ERROR: syntax error")))
 )

          )

    )


(defun is-array (char-list)
  (if (eql (get-char char-list 1) ])
      (if (eql (car (is-whitespace char-list)) ])
          (cons 'jsonarray nil)
          (cons 'jsonarray (recursive-array (is-whitespace char-list)))
          )
      (error "ERROR: syntax error")
      )
  )

(defun is-json (char-list)
  (cond ((eql (car char-list) {) (is-object (cdr char-list)))
        ((eql (car char-list) [) (is-array (cdr char-list)))
        (T (error "ERROR: syntax error")))
  );)

(defun jsonparse(Input)
  (is-json (coerce Input 'list)) 
  )



; JSONACCESS

(defun value (parsed)
  (cadr parsed)
  )

(defun identifier (parsed)
   (car parsed)
  )

(defun get-element (parsed search)
   (cond ((null parsed)
          (error "ERROR: syntax error"))
          ((equal (identifier (car parsed)) (car search))
           (value (car parsed)))
          (T (get-element (cdr parsed) search))
          )

  )

(defun search-array (parsed pos)
  (cond ((= pos 0)
         (car parsed))
         (T (search-array (cdr parsed) (- pos 1)))))

(defun get-element-array (parsed search)

  (cond ((and (>= (car search) 0) (< (car search) (length parsed)))
         (nth (car search) parsed))
        (T (error "ERROR: syntax error")))
  )

(defun get-json-obj (parsed search)

  (cond ((null parsed)
         (error "ERROR: syntax error"))
        ((null search)
         (error "ERROR: syntax error"))
        ((null (cdr search))
         (get-element parsed search))
        (T (let ((element (get-element parsed search)))
             (if (listp element)
                 (cond ((equal 'jsonobj (car element))
                        (get-json-obj (cdr element) (cdr search)))
                       ((equal 'jsonarray (car element))
                        (get-json-arr (cdr element) (cdr search)))
                       (T (error "ERROR: syntax error")))
                 (append element)
                 )
             )))

  )

(defun get-json-arr (parsed search)

  (cond ((null parsed)
         (error "ERROR: syntax error"))
        ((null search)
         (error "ERROR: syntax error"))
        ((null (cdr search))
         (get-element-array parsed search))
        (T (let ((element (get-element-array parsed search)))
             (if (listp element)
                 (cond ((equal 'jsonobj (car element))
                        (get-json-obj (cdr element) (cdr search)))
                       ((equal 'jsonarray (car element))
                        (get-json-arr (cdr element) (cdr search)))
                       (T (error "ERROR: syntax error")))
                 (if (> (length search) 1)
                     (error "ERROR: syntax error")
                     (append element)
                     )

                 )
             )))


  )

(defun jsonaccess (parsed &rest search)
  (cond ((null parsed)
         (error "ERROR: syntax error"))
        ((null (first search))
         (error "ERROR: syntax error"))
        (T (cond ((eql (car parsed) 'jsonobj)
                  (get-json-obj (cdr parsed) search))
                 ((eql (car parsed) 'jsonarray)
                  (get-json-arr (cdr parsed) search))))

        )


  )


(defun jsonread (filename)
  (with-open-file (stream filename)
    (let ((contents (make-string (file-length stream))))
      (read-sequence contents stream)
      ;(print contents)
      (jsonparse contents)


      )))




;JSONDUMP

(defun take-rest (obj)
  (cdr obj)
  )

(defun get-pair (obj)
  (car obj)
  )

(defun elementbuilder (obj)

  (cond ((stringp obj)
         (concatenate 'string
                      (string double-quote) obj (string double-quote)))
        ((numberp obj)
         (concatenate 'string (princ-to-string obj)))
        ((listp obj)
         (cond ((eql (car obj) 'jsonobj)
                (jsonbuild obj))
               ((eql (car obj) 'jsonarray)
                (jsonbuild obj)))
         )
        ((or (eql obj 'TRUE)
             (eql obj 'FALSE)
             (eql obj 'NULL))
         (concatenate 'string (string obj)))
        )

  )

(defun jsonpair (obj)
  (let ((pair (get-pair obj))
        (rest (take-rest obj)))

    (cond ((null rest)
      (cond ((null pair)
           ())

          (T (concatenate 'string (elementbuilder (first pair))
                          (string '#\:) (elementbuilder (second pair))))

          ))
           (T (concatenate 'string
                           (elementbuilder (first pair))
                           (string '#\:) (elementbuilder (second pair))
                           (string comma) (jsonpair rest))))
    )
  )

(defun jsonarr (obj)
    (let ((element (get-pair obj))
          (rest (take-rest obj)))

      (cond ((not (null rest))
        (cond ((null element)
             ())
            (T (concatenate 'string
                            (elementbuilder element)
                            (string comma) (jsonarr rest)))))


            (T (concatenate 'string (elementbuilder element))))))

(defun jsonbuild (obj)
    (cond ((eql (car obj) 'jsonobj)
           (concatenate 'string (string '#\{) (jsonpair (cdr obj))
                        (string '#\})))
          ((eql (car obj) 'jsonarray)
           (concatenate 'string (string [)
                        (jsonarr (cdr obj)) (string ])))

          )
  )



(defun jsondump (obj file)
  (let ((result (jsonbuild obj)))

        (if (not (equal obj (jsonparse result)))
           (error "ERROR: Syntax error"))
        (with-open-file
            (out file
                 :direction
                 :output
                 :if-exists
                 :supersede
                 :if-does-not-exist
                 :create)
          (format out result))
        (append file)
    )

  )
