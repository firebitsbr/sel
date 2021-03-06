;;;; csurf-asm.lisp --- CSURF-ASM representation.
(defpackage :software-evolution-library/test/csurf-asm
  (:nicknames :sel/test/csurf-asm)
  (:use
   :gt/full
   #+gt :testbot
   :software-evolution-library/test/util
   :stefil+
   :software-evolution-library
   :software-evolution-library/software/asm-heap
   :software-evolution-library/software/csurf-asm)
  (:export :test-csurf-asm))
(in-package :software-evolution-library/test/csurf-asm)
(in-readtable :curry-compose-reader-macros)
(defsuite test-csurf-asm "CSURF-ASM representation."
  (zerop (nth-value 2 (shell "which ~a" *elf-edit-symtab-path*))))

(deftest dynamic-linker-path-has-been-set ()
  (is *dynamic-linker-path* "Ensure `*dynamic-linker-path*' has been set."))

(defixture csurf-asm-calc
  (:setup (setf *soft*
                (from-file
                 (make-instance 'csurf-asm)
                 (asm-test-dir "calc.s.intel"))))
  (:teardown
   (setf *soft* nil)))

;; simple test to see if the whole file parsed correctly
(deftest parser-test-1 ()
  (with-fixture csurf-asm-calc
    (is (= (length (genome *soft*)) 828))))

(deftest parser-test-2 ()
  (with-fixture csurf-asm-calc
    (is (eq (asm-line-info-type (elt (genome *soft*) 0)) :empty))))

(deftest parser-test-3 ()
  (with-fixture csurf-asm-calc
    (is (eq (asm-line-info-type (elt (genome *soft*) 1)) :decl))))

(deftest parser-test-4 ()
  (with-fixture csurf-asm-calc
    (let ((op-line (find :op (genome *soft*) :key 'asm-line-info-type)))
      (is (and (equalp (asm-line-info-opcode op-line) "sub")
               (equalp (asm-line-info-operands op-line)
                       '(("rsp" "comma" 8))))))))

(deftest parser-test-5 ()
  (with-fixture csurf-asm-calc
    (is (= (iter (for x in-vector (genome *soft*))
                 (counting (eq (asm-line-info-type x) :op))) 283))))

(deftest csurf-asm-configures ()
  (with-fixture csurf-asm-calc
    (apply-config *soft* (asm-test-dir "calc.log"))
    (is (= 5 (length (weak-symbols *soft*))))
    (iter (for str in '("_Jv_RegisterClasses" "_ITM_registerTMCloneTable"
                        "_ITM_deregisterTMCloneTable" "__imp___gmon_start__"
                        "__gmon_start__"))
          (is (member str (weak-symbols *soft*) :test #'equal)))
    (is (= 1 (length (linked-files *soft*))))
    (is (equal "/lib/x86_64-linux-gnu/libc.so.6"
               (first (linked-files *soft*))))))

(defun csurf-tools-available-p ()
  (zerop (nth-value 2 (shell "which ~a" *elf-edit-symtab-path*))))

(deftest csurf-asm-can-compile ()
  (with-fixture csurf-asm-calc
    (apply-config *soft* (asm-test-dir "calc.log"))
    (with-temporary-file (:pathname bin)
      (multiple-value-bind (bin errno)
          (with-current-directory (+asm-test-dir+)
            (phenome *soft* :bin bin))
        (is (zerop errno) "Calc compilation successful.")
        (is (= 4 (parse-number (shell "~a + 2 2" bin)))
            "Calc executable is executable and functional.")))))
