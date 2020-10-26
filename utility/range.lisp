(defpackage software-evolution-library/utility/range
  (:nicknames :sel/utility/range)
  (:use :gt)
  (:export
   :source-location
   :line
   :column
   :source-range
   :range
   :begin
   :end
   :source-<
   :source-<=
   :source->
   :source->=
   :contains
   :intersects
   :source-location->position
   :position->source-location
   :source-range-subseq))
(in-package :software-evolution-library/utility/range)


;;;; Source and binary locations and ranges.
;;;
;;; Classes for representing locations and ranges in sequences
;;; (typically text source code files or binary executable bytes).
;;; Functions for comparing locations and ranges, as well as
;;; determining "contains" and "intersects" relationships between
;;; locations and ranges.
;;;
;;; @texi{locations-and-ranges}
(defclass source-location ()
  ((line :initarg :line :accessor line :type fixnum)
   (column :initarg :column :accessor column :type fixnum)))

(defclass source-range ()
  ((begin :initarg :begin :accessor begin :type source-location)
   (end   :initarg :end   :accessor end   :type source-location)))

(defclass range ()
  ((begin :initarg :begin :accessor begin :type fixnum)
   (end   :initarg :end   :accessor end   :type fixnum)))

(defmethod print-object ((obj source-location) stream)
  (print-unreadable-object (obj stream :type t)
    (prin1 (line obj) stream)
    (format stream ":")
    (prin1 (column obj) stream)))

(defmethod print-object ((obj source-range) stream)
  (flet ((p1-range (range)
           (prin1 (line range) stream)
           (format stream ":")
           (prin1 (column range) stream)))
    (print-unreadable-object (obj stream :type t)
      (p1-range (begin obj))
      (format stream " to ")
      (p1-range (end obj)))))

(defmethod print-object ((obj range) stream)
  (print-unreadable-object (obj stream :type t)
    (prin1 (begin obj) stream)
    (format stream " to ")
    (prin1 (end obj) stream)))

(defgeneric source-< (a b)
  (:documentation "Return true if source location A comes strictly before B.")
  (:method ((a source-location) (b source-location))
    (or (< (line a) (line b))
        (and (= (line a) (line b))
             (< (column a) (column b))))))

(defgeneric source-<= (a b)
  (:documentation "Return true if source location A is equal to or comes
before B.")
  (:method ((a source-location) (b source-location))
    (or (< (line a) (line b))
        (and (= (line a) (line b))
             (<= (column a) (column b))))))

(defgeneric source-> (a b)
  (:documentation "Return true if source location A comes strictly after B.")
  (:method ((a source-location) (b source-location))
    (or (> (line a) (line b))
        (and (= (line a) (line b))
             (> (column a) (column b))))))

(defgeneric source->= (a b)
  (:documentation "Return true if source location A is equal to or comes
after B.")
  (:method ((a source-location) (b source-location))
    (or (> (line a) (line b))
        (and (= (line a) (line b))
             (>= (column a) (column b))))))

(defgeneric contains (range location)
  (:documentation "Return true if RANGE fully subsumes LOCATION.")
  (:method ((range source-range) (location source-location))
    (and (source-<= (begin range) location)
         (source->= (end range) location)))
  (:method ((a-range source-range) (b-range source-range))
    (and (source-<= (begin a-range) (begin b-range))
         (source->= (end a-range) (end b-range))))
  (:method ((range range) point)
    (and (<= (begin range) point) (>= (end range) point)))
  (:method ((a-range range) (b-range range))
    (and (<= (begin a-range) (begin b-range))
         (>= (end a-range) (end b-range)))))

(defgeneric intersects (a-range b-range)
  (:documentation "Return true if A-RANGE and B-RANGE intersect.")
  (:method ((a-range source-range) (b-range source-range))
    (and (source-< (begin a-range) (end b-range))
         (source-> (end a-range) (begin b-range))))
  (:method ((a-range range) (b-range range))
    (and (< (begin a-range) (end b-range))
         (> (end a-range) (begin b-range)))))

(defun position->source-location (text pos)
  (declare (array-index pos)
           (optimize speed)
           (inline cl:count))
  (with-string-dispatch () text
    ;; We pretend there is a newline at "position" -1.
    (let* ((lines (1+ (cl:count #\Newline text :end pos)))
           (columns (- pos
                       (or (cl:position #\Newline text
                                        :end pos
                                        :from-end t)
                           -1))))
      (make 'source-location
            :line lines
            :column columns))))

;;; TODO Maybe this should be a utility?
(defun nth-position (n item seq
                     &rest args
                     &key (start 0)
                     &allow-other-keys)
  "Return the position of the Nth occurrence of ITEM in SEQ.
If there are fewer than N+1 occurrences, return the difference as a second value."
  (nlet rec ((n n)
             (start start)
             (last-pos nil))
    (if (minusp n) (values last-pos 0)
        (let ((next-pos (apply #'position item seq :start start args)))
          (if (null next-pos) (values last-pos (1+ n))
              (rec (1- n)
                   (1+ next-pos)
                   next-pos))))))

(defun source-location->position (text location)
  (mvlet* ((line (line location))
           (column (column location))
           ;; When translating from a source location to a position, we treat
           ;; excess newlines as extending beyond the end of the string.
           (line-start-pos remaining
            (if (= line 1) (values -1 0)
                (multiple-value-bind (pos rem)
                    (nth-position (- line 2) #\Newline text)
                  (if (null pos) (values -1 0)
                      (values pos rem))))))
    ;; Note that we don't have to adjust the column as the extra
    ;; offset is "absorbed" by the newline.
    (+ line-start-pos column remaining)))

(defun source-range-subseq (text range)
  (slice text
         (source-location->position text (begin range))
         (source-location->position text (end range))))

;;; TODO Make a test
(defun test-source-location-position-conversion ()
  (macrolet ((is (&rest args) `(assert ,@args)))
    (flet ((loc (line col) (make 'source-location :line line :column col))
           (pos= (s loc pos)
             (is (equal? loc (position->source-location s pos)))
             (is (equal? pos (source-location->position s loc)))
             t))
      (is (equal? (loc 1 1)
                  (position->source-location "" 0)))
      (let ((s (fmt "~%")))
        (is (pos= s (loc 1 1) 0))
        (is (pos= s (loc 2 1) 1)))
      (let ((s (fmt "~%~%")))
        (is (pos= s (loc 1 1) 0))
        (is (pos= s (loc 2 1) 1))
        (is (pos= s (loc 3 1) 2)))
      (let ((s (fmt "~%a~%b")))
        (is (pos= s (loc 1 1) 0))
        (is (pos= s (loc 2 1) 1))
        (is (pos= s (loc 2 2) 2))
        (is (pos= s (loc 3 1) 3))
        (is (pos= s (loc 3 2) 4))))))
