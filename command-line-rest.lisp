(defpackage :software-evolution-library/command-line-rest
  (:nicknames :sel/command-line-rest)
  (:use
   :named-readtables
   :curry-compose-reader-macros
   :common-lisp
   :software-evolution-library/utility
   :software-evolution-library/command-line
   :software-evolution-library/rest-define-command-endpoint
   :software-evolution-library/rest-async-jobs
   :software-evolution-library/rest)
  (:import-from :uiop/utility :nest)
  (:export :define-command-rest))
(in-package :software-evolution-library/command-line-rest)
(in-readtable :curry-compose-reader-macros)

(defun find-ampersand-el (el) (and (not (listp el)) (equal #\& (aref (symbol-name el) 0))))

(defvar *default-environment*
  '(*fitness-predicate*
    *max-evals* *max-time* *orig* *population*
    *target-fitness-p* *test-suite* *threads*))

(defmacro define-command-rest
    (name args pre-help post-help &rest body)
  "Define a function, executable, and a REST server function and executable.

   Invokes `define-command' on NAME ARGS PRE-HELP POST-HELP and BODY to
   define the NAME function and the RUN-NAME command-line executable
   entry point.  See the definition of `define-command' for more
   information on these arguments.

   Use the above arguments and the additional ENVIRONMENT and STATUS
   keywords to define an asynchronous REST entry point which runs the
   function NAME asynchronously returning a job ID and another entry
   point which may be used to retrieve the status of the async job.  A
   new RUN-NAME-REST-SERVER command-line executable entry point is
   defined.

   ENVIRONMENT
   :   List of variables which should be let-bound around the execution
   of the REST end-point.

   STATUS
   :   A function which will be invoked in the dynamic environment of the
   running job to return the status of the job or, when finished, to
   return the result."
  ;; Split the args to pull out types and pass names to `define-command'.
  ;; There isn't much we can do here about rest args, due to types. We leave
  ;; the binding unused for now.
  ;; Based on the parsing code for `define-command` in `fare/parse.lisp`.
  (let* ((package (package-name *package*))
         ;; I would prefer not to need route-name, but would need to change to
         ;; a rest library that does not use CLOS generics to represent routes
         ;; (to prevent the name collision between defining the entry function
         ;; and the endpoint).
         (route-name (intern (concatenate 'string "rest-"
                                          (string-upcase (string name)))
                             package))
         (status-symbol (intern "STATUS" package))
         (status-symbol (intern "STATUS" package))
         (env-symbol (intern "ENVIRONMENT" package))
         (spec-symbol (intern "&SPEC" package))
         (rest-symbol (intern "&REST" package))
         (environment (or (plist-get env-symbol body)
                          *default-environment*))
         (status-fn (or (plist-get status-symbol body)
                        'sel/rest-async-jobs::lookup-session-job-status))
         (body (plist-drop env-symbol (plist-drop status-symbol body)))
         (command-line-specification (plist-get spec-symbol args))
         (rest-arg (let ((rest-arg (plist-get rest-symbol args)))
                     (when rest-arg (list rest-symbol rest-arg))))
         (typed-positional-args (take-until
                                 #'find-ampersand-el
                                 (plist-drop rest-symbol args)))
         (positional-args (mapcar #'car typed-positional-args))
         (aux-args (plist-drop
                    rest-symbol
                    (plist-drop
                     spec-symbol
                     (drop-until #'find-ampersand-el args)))))
    ;; NOTE: Results just status or "finished/path."
    `(progn
       ;; 1. Define the command.
       (define-command ,name (,@positional-args
                              ,spec-symbol ,command-line-specification)
         ,pre-help ,post-help ,@body)
       ;; 2. Set up REST endpoint.
       (define-endpoint-route ,route-name #',name
         ,typed-positional-args
         ,command-line-specification
         ,environment ,status-fn))))


#|
(define-command-rest four-types-2
((a integer) (b string) (c float) (d boolean)
&spec +common-command-line-options+)
"Test that the four supported types can be passed via REST."
nil
(format nil "~A: ~D, ~A: ~S, ~A: ~F, ~A: ~A"
(type-of a) a
(type-of b) b
(type-of c) c
(type-of d) d))

(macroexpand-1 '(define-command-rest fact-entry
((n integer) &spec +common-command-line-options+)
"Test that canonical REST endpoints work. Computes factorial."
#.(format nil
"~%Built from SEL ~a, and ~a ~a.~%"
+software-evolution-library-version+
(lisp-implementation-type) (lisp-implementation-version))
(declare (ignorable interactive manual quiet verbose))
(when help (show-help-for-fact-entry))
(factorial n)))
|#