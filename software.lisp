;;; software.lisp --- general representation of an instance of software

;; Copyright (C) 2011  Eric Schulte

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;;; Code:
(in-package :software-evolution)


;;; Genome Object
(defgeneric inds (genome)
  (:documentation "Return a list of the indexes of GENOME."))

(defgeneric ind (genome ind)
  (:documentation "Return the element located at IND in GENOME."))

(defgeneric (setf ind) (new genome ind)
  (:documentation "Set the element located at IND in GENOME to NEW."))

(defgeneric location (software &optional key)
  (:documentation
   "Return a location in the genome of SOFTWARE optionally weighted by KEY."))

(defun weighted-ind (weights &aux (counter 0))
  "Weighted select of an index into a list of weights."
  (let* ((cumulative (reverse (reduce (lambda (acc el)
                                        (incf counter el)
                                        (cons counter acc))
                                      weights :initial-value nil)))
         (point (random (float counter))))
    (loop for weight in cumulative as i from 0
       if (> weight point) do (return i))))

(defmethod location (genome &optional key)
  (let ((inds (inds genome)))
    (nth
     (if key
         (weighted-ind (mapcar (lambda (i) (cdr (assoc key (ind genome i)))) inds))
         (random (length inds)))
     inds)))


;;; Vector Genomes
(defmethod inds ((genome vector))
  (loop :for i :from 0 :to (1- (length genome)) collect i))

(defmethod ind ((genome vector) ind)
  (aref genome ind))

(defmethod (setf ind) (new (genome vector) ind)
  (setf (aref genome ind) new))


;;; Tree Genomes
(defstruct (tree (:copier tree-copier))
  (data nil)
  (branches nil))

(defun to-tree (item)
  (if (consp item)
      (make-tree
       :data (car item)
       :branches (mapcar #'to-tree (cdr item)))
      (make-tree :data item)))

(defun to-list (tree)
  (if (tree-branches tree)
      (cons (tree-data tree)
            (mapcar #'to-list (tree-branches tree)))
      (tree-data tree)))

(defun map-tree (type fun tree)
  (let ((first (funcall fun tree))
        (rest (mapcar (lambda (branch) (map-tree type fun branch))
                      (tree-branches tree))))
    (case type
      (tree (make-tree :data first :branches rest))
      (list (if rest (cons first rest) first)))))

(defun accessors (tree &aux (ind -1))
  "Return a list of accessors to subtrees in BFS order."
  (cons 'it
        (mapcan (lambda (branch)
                  (incf ind)
                  (mapcar (lambda (ac) `(nth ,ind (tree-branches ,ac)))
                          (accessors branch)))
                (tree-branches tree))))

(defmethod inds ((genome tree) &aux (counter -1) inds)
  (map-tree 'list (lambda (_) (declare (ignorable _))
                     (push (incf counter) inds))
            genome)
  (reverse inds))

(defmethod ind ((genome tree) index &aux (counter -1) result)
  (map-tree 'tree (lambda (current)
                    (when (= (incf counter) index)
                      (setq result current))) genome)
  result)

(defmethod (setf ind) (new (genome tree) index)
  (if (= index 0)
      (progn
        (setf (tree-data genome) (tree-data new))
        (setf (tree-branches genome) (tree-branches new)))
      (let ((ac (nth index (accessors genome))))
        (eval `((lambda (it) (setf ,ac ,new)) ,genome)))))


;;; Cons-cell Genomes
(defmethod inds ((genome cons))
  (unless (null genome)
    (flet ((follow (dir list)
             (mapcar (lambda (el) (cons dir el))
                     (if (consp list) (inds list) '(())))))
      (append '(()) (follow :a (car genome)) (follow :d (cdr genome))))))

(defmethod ind ((genome list) index)
  (flet ((get-at (list dir) (case dir (:a (car list)) (:d (cdr list)))))
    (if (cdr index)
        (ind (get-at genome (car index)) (cdr index))
        (get-at genome (car index)))))

(defmethod (setf ind) (new (genome list) index)
  (if (cdr index)
      (setf
       (ind (case (car index) (:a (car genome)) (:d (cdr genome))) (cdr index))
       new)
      (case (car index) (:a (rplaca genome new)) (:d (rplacd genome new)))))

(defun del-ind (genome index)
  (if (cddr index)
      (del-ind (case (car index) (:a (car genome)) (:d (cdr genome)))
               (cdr index))
      (case (car index)
        (:a (if (cdr index)
                (rplaca genome
                        (case (cadr index)
                          (:a (cdar genome))
                          (:d (caar genome))))
                (progn (rplaca genome (cadr genome))
                       (rplacd genome (cddr genome)))))
        (:d (rplacd genome
                    (case (cadr index)
                      (:a (cddr genome))
                      (:d (cadr genome))))))))


;;; Software Object
(defclass software ()
  ((genome  :initarg :genome  :accessor genome      :initform nil)
   (fitness :initarg :fitness :accessor raw-fitness :initform nil)
   (history :initarg :history :accessor history     :initform nil)))

(defgeneric copy (software)
  (:documentation "Return a copy of the software."))

(defgeneric evaluate (software)
  (:documentation "Evaluate SOFTWARE setting the fitness."))

(defgeneric fitness (software)
  (:documentation "Return the fitness of the software. (caching)"))

(defmethod (setf fitness) (new (software software))
  (setf (raw-fitness software) new))

(defmethod fitness :around ((software software))
  (or (raw-fitness software) (setf (fitness software) (call-next-method))))

(defgeneric insert (software &key good-key bad-key)
  (:documentation "Duplicate and insert an element of the genome of SOFT"))

(defgeneric cut (software &key good-key bad-key)
  (:documentation "Delete an element of the genome of SOFT."))

(defgeneric swap (software &key good-key bad-key)
  (:documentation "Swap two elements of the genome of SOFT."))

(defgeneric crossover (software-a software-b)
  (:documentation "Crossover between the genomes of SOFT-A and SOFT-B."))

(defvar *genome-averaging-keys* nil
  "Keys whose value should be averaged with neighbors after genome operations.")

(defgeneric genome-average-keys (genome place)
  (:documentation "Average the keys in *GENOME-AVERAGING-KEYS* around PLACE."))


;;; Software Object with an executable
(defclass software-exe (software)
  ((exe :initarg :exe :accessor raw-exe :initform nil)))

(defgeneric exe (software &optional place)
  (:documentation
   "Return the path to an executable of the software. (caching)"))

(defmethod (setf exe) (new (software software-exe))
  (setf (raw-exe software) new))

(defmethod exe :around ((software software-exe) &optional place)
  (declare (ignorable place))
  (or (raw-exe software) (setf (exe software) (or (call-next-method) :failed))))

(defgeneric delete-exe (software)
  (:documentation
   "Delete any external executables associated with the software."))

(defmethod delete-exe ((software software-exe))
  (when (raw-exe software)
    (when (and (not (eq :failed (raw-exe software)))
               (probe-file (exe software)))
      (delete-file (exe software)))
    (setf (exe software) nil)))

(defgeneric from-bytes (bytes)
  (:documentation "Read a software object from a byte array."))

(defgeneric to-bytes (software)
  (:documentation "Write a software object to a byte array."))

(defun evaluate-with-script (software script pos-num neg-num)
  "Evaluate SOFTWARE with SCRIPT.
POS-NUM is the number of positive tests defined in SCRIPT NEG-NUM is
the number of negative tests.  SCRIPT will be called with the
following arguments.

  $ SCRIPT SOFTWARE-EXECUTABLE pN ∀ N upto POS-NUM
  $ SCRIPT SOFTWARE-EXECUTABLE nN ∀ N upto NEG-NUM

SCRIPT should return 0 on success and 1 on failure."
  (let ((pos 0) (neg 0))
    (if (eq (exe software) :failed)
        0
        (progn
          (loop for i from 1 to pos-num
             do (multiple-value-bind (output err-output exit)
                    (shell "~a ~a p~d" script (exe software) i)
                  (declare (ignorable output err-output))
                  (when (= exit 0) (incf pos))))
          (loop for i from 1 to neg-num
             do (multiple-value-bind (output err-output exit)
                    (shell "~a ~a n~d" script (exe software) i)
                  (declare (ignorable output err-output))
                  (when (= exit 0) (incf neg))))
          (incf *fitness-evals*)
          (delete-exe software)
          (+ pos neg)))))


;;; Software Methods
(defmethod copy ((software software))
  (make-instance (type-of software)
    :genome (genome software)
    :history (history software)
    :fitness (raw-fitness software)))

(defmethod fitness ((software software))
  (evaluate software))

(defmethod insert ((software software) &key (good-key nil) (bad-key nil))
  (multiple-value-bind (genome place)
      (insert (genome software) :good-key good-key :bad-key bad-key)
    (setf (genome software) (genome-average-keys genome place))
    place))

(defmethod insert :around ((software software)
                           &key (good-key nil) (bad-key nil))
  (declare (ignorable good-key bad-key))
  (let ((place (call-next-method)))
    (push (cons :insert place) (history software))
    (setf (fitness software) nil)
    software))

(defmethod cut ((software software) &key (good-key nil) (bad-key nil))
  (multiple-value-bind (genome place)
      (cut (genome software) :good-key good-key :bad-key bad-key)
    (setf (genome software) genome)
    place))

(defmethod cut :around ((software software) &key (good-key nil) (bad-key nil))
  (declare (ignorable good-key bad-key))
  (let ((place (call-next-method)))
    (push (cons :cut place) (history software))
    (setf (fitness software) nil)
    software))

(defmethod swap ((software software) &key (good-key nil) (bad-key nil))
  (multiple-value-bind (genome places)
      (swap (genome software) :good-key good-key :bad-key bad-key)
    (setf (genome software)
          (reduce (lambda (g p) (genome-average-keys g p))
                  places :initial-value genome))
    places))

(defmethod swap :around ((software software) &key (good-key nil) (bad-key nil))
  (declare (ignorable good-key bad-key))
  (let ((places (call-next-method)))
    (push (cons :swap places) (history software))
    (setf (fitness software) nil)
    software))

(defmethod crossover ((a software) (b software))
  (let ((new (make-instance (type-of a))))
    (multiple-value-bind (genome place)
        (crossover (genome a) (genome b))
      (setf (genome new) genome)
      (values new place))))

(defmethod crossover :around ((a software) (b software))
  (multiple-value-bind (new place) (call-next-method)
    (setf (fitness new) nil)
    (setf (history new) (list (cons :crossover place)
                              (cons (history a) (history b))))
    new))


;;; Vector Methods
(defmethod genome-average-keys ((genome vector) place)
  (let ((above (unless (= place (- (length genome) 1))
                 (aref genome (+ place 1))))
        (below (unless (= place 0)
                 (aref genome (- place 1))))
        (middle (aref genome place)))
    (dolist (key *genome-averaging-keys*)
      (let ((new (/ (apply #'+ (mapcar (lambda (el) (or (cdr (assoc key el)) 0))
                                       (list above below middle)))
                    3)))
        (if (assoc key (aref genome place))
            (setf (cdr (assoc key (aref genome place))) new)
            (push (cons key new) (aref genome place)))))
    genome))

(defmethod insert ((genome vector) &key (good-key nil) (bad-key nil))
  (let ((dup (location genome good-key))
        (ins (location genome bad-key)))
    (values (cond
              ((> dup ins)
               (concatenate 'vector
                 (subseq genome 0 ins)
                 (vector (aref genome dup))
                 (subseq genome ins dup)
                 (subseq genome dup)))
              ((> ins dup)
               (concatenate 'vector
                 (subseq genome 0 dup)
                 (subseq genome dup ins)
                 (vector (aref genome dup))
                 (subseq genome ins)))
              (:otherwise
               (concatenate 'vector
                 (subseq genome 0 dup)
                 (vector (aref genome dup))
                 (subseq genome dup))))
            (list dup ins))))

(defmethod cut ((genome vector) &key (good-key nil) (bad-key nil))
  (declare (ignorable good-key))
  (let ((ind (location genome bad-key)))
    (values (concatenate 'vector
              (subseq genome 0 ind)
              (subseq genome (+ 1 ind)))
            ind)))

(defmethod swap ((genome vector) &key (good-key nil) (bad-key nil))
  (let* ((a (location genome good-key))
         (b (location genome bad-key))
         (temp (aref genome a)))
    (setf (aref genome a) (aref genome b))
    (setf (aref genome b) temp)
    (values genome (list a b))))

(defmethod crossover ((a vector) (b vector))
  (let ((point (random (min (length a) (length b)))))
    (values (concatenate 'vector (subseq a 0 point) (subseq b point))
            point)))


;;; Cons-cell Methods
(defmethod genome-average-keys ((genome list) place)
  (let ((inds (list (butlast place) place
                    (append place '(:a)) (append place '(:d)))))
    (dolist (key *genome-averaging-keys*)
      (let ((new (/ (apply #'+ (mapcar (lambda (el)
                                         (or (cdr (assoc key (ind genome el)))
                                             0))
                                       inds))
                    4)))
        (if (assoc key (ind genome place))
            (setf (cdr (assoc key (ind genome place))) new)
            (push (cons key new) (ind genome place)))))
    genome))

(defmethod insert ((genome list) &key (good-key nil) (bad-key nil))
  (declare (ignorable bad-key))
  (let ((dup (location genome good-key))
        (ins (location genome good-key)))
    (setf (ind genome ins)
          (cons (ind genome ins)
                (ind genome dup)))
    (values genome (list ins dup))))

(defmethod cut ((genome list) &key (good-key nil) (bad-key nil))
  (declare (ignorable good-key))
  (let ((del (location genome bad-key)))
    (del-ind genome del)
    (values genome del)))

(defmethod swap ((genome list) &key (good-key nil) (bad-key nil))
  (let* ((a (location genome good-key))
         (b (location genome bad-key))
         (ordered (sort (list a b) #'< :key #'length))
         (tmp (ind genome (second ordered))))
    (setf (ind genome (second ordered)) (ind genome (first ordered)))
    (setf (ind genome (first ordered)) tmp)
    (values genome ordered)))

(defmethod crossover ((a list) (b list))
  (let* ((inds-a (inds a))
         (inds-b (inds b))
         (points-in-common (remove-if-not (lambda (it) (member it inds-a)) inds-b))
         (point (random-elt points-in-common))
         (new (copy-seq a)))
    (setf (ind new point) (ind b point))
    (values new point)))
