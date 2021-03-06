(defpackage :software-evolution-library/test/util
  (:nicknames :sel/test/util)
  (:use :gt/full
        :software-evolution-library
        :software-evolution-library/utility/debug
        :software-evolution-library/utility/range
        :stefil+
        :software-evolution-library/software/parseable)
  (:export :test
           :+etc-dir+
           :+gcd-dir+
           :+grep-prj-dir+
           :+multi-file-dir+
           :+asm-test-dir+
           :+multiple-artifact-dir+
           :+lisp-scopes-dir+
           :+javascript-dir+
           :+python-dir+
           :+python-utility-dir+
           ;; Other functions
           :acorn-available-p
           :python3.8-available-p
           :stmt-with-text
           :stmt-starting-with-text
           :fully-every
           :different-asts
           :range-to-list
           ;; Directory functions
           :gcd-dir
           :fib-dir
           :asm-test-dir
           :javascript-dir
           :python-dir
           ;; Variables referenced in tests
           :*tfos*
           :*soft*
           :*gcd*
           :*binary-search*
           :*fib*
           :*test*
           :*project*
           :*soft-mutate-errors*
           ;; Fixtures.
           :soft
           :range
           :double-range
           :gcd-elf))
(in-package :software-evolution-library/test/util)
(in-readtable :curry-compose-reader-macros)

(defvar *tfos* nil "Another software used in tests.")
(defvar *soft* nil "Software used in tests.")
(defvar *gcd* nil "Holds the gcd software object.")
(defvar *binary-search* nil "Holds the binary_search software object.")
(defvar *fib* nil "Holds the fibonacci software object.")
(defvar *test* nil "Variable to hold evaluation function for tests.")
(defvar *project* nil "Software used in project fixtures.")

(defroot test)

(define-constant +etc-dir+
    (append (pathname-directory
             #.(or *compile-file-truename*
                   *load-truename*
                   *default-pathname-defaults*))
            (list "etc"))
  :test #'equalp
  :documentation "Path to directory holding testing artifacts.")

(define-constant +gcd-dir+ (append +etc-dir+ (list "gcd"))
  :test #'equalp
  :documentation "Path to directory holding gcd.")

(define-constant +grep-prj-dir+ (append +etc-dir+ (list "grep-prj"))
  :test #'equalp
  :documentation "Path to directory holding the grep project.")

(define-constant +multi-file-dir+ (append +etc-dir+ (list "multi-file"))
  :test #'equalp
  :documentation "Path to directory holding the multi-file example.")

(define-constant +clang-format-dir+ (append +etc-dir+ (list "clang-format"))
  :test #'equalp
  :documentation "Location of the clang-format example directory")

(define-constant +fib-dir+
    (append +etc-dir+ (list "fib"))
  :test #'equalp
  :documentation "Location of the fib example dir")

(define-constant +javascript-dir+ (append +etc-dir+ (list "javascript"))
  :test #'equalp
  :documentation "Path to directory holding Javascript test programs.")

(define-constant +python-dir+ (append +etc-dir+ (list "python"))
  :test #'equalp
  :documentation "Path to directory holding python test programs.")

(define-constant +asm-test-dir+ (append +etc-dir+ (list "asm-test"))
  :test #'equalp
  :documentation "Path to asm-test examples.")

(define-constant +multiple-artifact-dir+
    (append +etc-dir+ (list "multiple-artifacts"))
  :test #'equalp
  :documentation
  "Path to directory holding a project which produces multiple artifacts.")

(define-constant +lisp-scopes-dir+
    (append +etc-dir+ (list "lisp-scopes"))
  :test #'equalp
  :documentation
  "Path to directory holding lisp code to test scopes.")

(define-constant +python-utility-dir+
    (append +etc-dir+ (list "python-utility"))
  :test #'equalp
  :documentation
  "Path to directory holding python code to test utility functions.")

(defun asm-test-dir (filename)
  (make-pathname :name (pathname-name filename)
                 :type (pathname-type filename)
                 :directory +asm-test-dir+))


;;; Functions on constants.
(defun gcd-dir (filename)
  (make-pathname :name (pathname-name filename)
                 :type (pathname-type filename)
                 :directory +gcd-dir+))

(defun clang-format-dir (filename)
  (make-pathname :name (pathname-name filename)
                 :type (pathname-type filename)
                 :directory +clang-format-dir+))

(defun fib-dir (filename)
  (make-pathname :name (pathname-name filename)
                 :type (pathname-type filename)
                 :directory +fib-dir+))

(defun javascript-dir (path)
  (merge-pathnames-as-file (make-pathname :directory +javascript-dir+)
                           path))

(defun python-dir (path)
  (merge-pathnames-as-file (make-pathname :directory +python-dir+)
                           path))


;;;; Helper functions.
(defun acorn-available-p ()
  (which "acorn"))

(defun python3.8-available-p ()
  (and (which "python3")
       (register-groups-bind (major minor)
           ("Python ([0-9]+)\.([0-9]+)" (shell "python3 --version"))
         (and (>= (parse-integer major) 3) (>= (parse-integer minor) 8)))))

(defun stmt-with-text (obj text &key no-error (trim t))
  "Return the AST in OBJ holding TEXT.
Unless optional argument NO-ERROR is non-nil an error is raised if no
AST holding STMT is found."
  (when trim
    (setf text (trim-whitespace text)))
  (or (let ((result
             (find-if [{string= text} (if trim #'trim-whitespace #'identity)
                       #'source-text]
                      (asts obj))))
        result)
      (if no-error
          nil
          (error "`stmt-with-text' failed to find ~S in ~S"
                 text
                 (mapcar #'source-text (asts obj))))))

(defun stmt-starting-with-text (obj text)
  (find-if (lambda (ast)
             (and ast (equal 0 (search text (source-text ast)))))
           (asts obj)))


;;; Software.
(define-software soft (software)
  ((genome :initarg :genome :accessor genome :initform nil)))

(defvar *soft-mutate-errors* nil
  "Control when mutations on soft objects throw errors.")


;;; Methods.
(defmethod crossover ((a soft) (b soft))
  (values (copy a)(list :fake-a) (list :fake-b)))
(defmethod mutate ((a soft))
  (setf (fitness a) nil)
  (if *soft-mutate-errors*
      (error (make-condition 'mutate
                             :text "FAKE"
                             :obj a
                             :operation '(:fake)))
      (values (copy a) (list :fake))))


;;; Fixtures
(defixture soft
  (:setup (setf *soft* (make-instance 'soft
                         :genome (coerce (loop :for i :from 0 :to 9 :collect i)
                                         'vector))))
  (:teardown (setf *soft* nil)))

(defixture gcd-elf
  (:setup
   (let ((arch (intern (string-upcase (subseq (shell "uname -m") 0 3)))))
     (setf *gcd* (from-file (make-instance (case arch
                                             (x86 'elf-x86)
                                             (mips 'elf-mips)))
                            (gcd-dir "gcd")))))
  (:teardown (setf *gcd* nil)))

(defun fully-every (fn seq &rest other-seqs)
  "A version of EVERY that also checks that all sequences are
of the same length"
  (let ((len (length seq)))
    (and (every (lambda (s) (= (length s) len)) other-seqs)
         (apply #'every fn seq other-seqs))))

;; Check if the two AST lists differ. Do a smoke test with
;; the list lengths; if they match, use the src-text
;; field as a proxy for equality. Strict equality isn't
;; useful because of nondeterministic fields like :src-file.
(defun different-asts (this that)
  (or (not (equal (length this) (length that)))
      (not (every (lambda (x y)
                    (string= (source-text x) (source-text y)))
                  this that))))

(defun range-to-list (range)
  "Convert a range object to a pair of (begin-line . begin-col)
(end-line . end-col) conses."
  (list (cons (line (begin range)) (column (begin range)))
        (cons (line (end range)) (column (end range)))))
