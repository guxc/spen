
; Extending QF_S:
; constant emptybag, 
; the function singleton, 
; the multiset comparison operator bag-lt, bag-le, bag-gt, bag-ge
; bag-union, bag-diff, bag-sub

(set-logic QF_S)

;; declare sorts
(declare-sort Bst_t 0)

;; declare fields
(declare-fun left () (Field Bst_t Bst_t))
(declare-fun right () (Field Bst_t Bst_t))
(declare-fun data () (Field Bst_t Int))

;; declare predicates

;; bst(E,M)::= E = nil & emp & M = emptybag | 
;; exists X,Y,M1,M2. E |-> ((left,X), (right,Y)) * bst(X,M1) * bst(Y,M2) & M = {E.data} cup M1 cup M2 & M1 < E.data < M2


(define-fun bst ((?E Bst_t) (?M BagInt)) Space (tospace 
	(or 
	(and (= ?E nil) 
		(tobool emp
		)
		(= ?M emptybag)
	)
 
	(exists ( (?X Bst_t) (?Y Bst_t) (?M1 BagInt) (?M2 BagInt) (?d Int) ) 
	(and (distinct ?E nil) 
		(tobool (ssep 
		(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d)) ) 
		(bst ?X ?M1)
		(bst ?Y ?M2)
		)
		)
		(= ?M (bag-union (singleton ?d) (bag-union ?M1 ?M2) ) )
		(bag-lt ?M1 (singleton ?d))
		(bag-lt (singleton ?d) ?M2)
	)
	)
	)
))

;; bsthole(E,F,M1,M2)::= E = F & emp & M1 = M2 | 
;; exists X,Y,M3,M4. E |-> ((left,X), (right,Y)) * bst(X,M3) * bsthole(Y,F,M4,M2) & M1={E.data} cup M3 cup M4 & M3 < E.data < M4 |
;; exists X,Y,M3,M4. E |-> ((left,X), (right,Y)) * bsthole(X,F,M3,M2) * bst(Y,M4) & M1={E.data} cup M3 cup M4 & M3 < E.data < M4

(define-fun bsthole ((?E Bst_t) (?F Bst_t) (?M1 BagInt) (?M2 BagInt)) Space (tospace 
	(or 
	(and (= ?E ?F) 
		(tobool emp
		)
		(= ?M1 ?M2)
	)
 
	(exists ((?X Bst_t) (?Y Bst_t) (?M3 BagInt) (?M4 BagInt) (?d Int)) 
	(and (distinct ?E ?F) 
		(tobool (ssep 
		(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d)) ) 
		(bst ?X ?M3)
		(bsthole ?Y ?F ?M4 ?M2)
		)
		)
		(= ?M1  (bag-union (singleton ?d) (bag-union ?M3 ?M4) ) )
		(bag-lt ?M3 (singleton ?d) )
		(bag-lt (singleton ?d) ?M4 )
	) 
	)

	(exists ((?X Bst_t) (?Y Bst_t) (?M3 BagInt) (?M4 BagInt) (?d Int)) 
	(and (distinct ?E ?F) 
		(tobool (ssep 
		(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d)) ) 
		(bsthole ?X ?F ?M3 ?M2)
		(bst ?Y ?M4)
		)
		)
		(= ?M1 (bag-union (singleton ?d) (bag-union ?M3 ?M4) ) )
		(bag-lt ?M3 (singleton ?d) )
		(bag-lt (singleton ?d) ?M4 )
	) 
	)
	)
))

;; declare variables
(declare-fun root () Bst_t)
(declare-fun cur1 () Bst_t)
(declare-fun cur2 () Bst_t)
(declare-fun parent1 () Bst_t)
(declare-fun parent2 () Bst_t)
(declare-fun Y () Bst_t)
(declare-fun Z () Bst_t)
(declare-fun M0 () BagInt)
(declare-fun M1 () BagInt)
(declare-fun M2 () BagInt)
(declare-fun M3 () BagInt)
(declare-fun M4 () BagInt)
(declare-fun M5 () BagInt)
(declare-fun M6 () BagInt)
(declare-fun M22 () BagInt)
(declare-fun key () Int)
(declare-fun d1 () Int)
(declare-fun d2 () Int)

;; declare set of locations

(declare-fun alpha1 () SetLoc)
(declare-fun alpha2 () SetLoc)
(declare-fun alpha3 () SetLoc)
(declare-fun alpha4 () SetLoc)
(declare-fun alpha5 () SetLoc)
(declare-fun alpha6 () SetLoc)
(declare-fun alpha7 () SetLoc)

;; VC1: bsthole(root, parent1, M1, M2) * parent1 |-> ((left,cur1), (right,Y)) * cur1 |-> ((left,Z), (right,cur2)) * bst(Z,M5) * 
;; bst(cur2, M6) * bst(Y,M4) & M1 = M0 \ {key} & M2 = ({parent1.data} cup M3 cup M4) \ {key} & M3 < parent1.data < M4 & 
;; M3 = {cur1.data} cup M5 cup M6 & M5 < cur1.data < M6 & parent1.data > key & cur1.data < key & parent2 = cur1 & 
;; (key in M0 <=> key in M3) & M22 = M3 \ {key} |-
;; bsthole(root,parent2, M1, M22) * parent2 |-> ((left,Z), (right,cur2)) * bst(Z, M5) * bst(cur2, M6) & M1 = M0 \ {key} & 
;; M22 = ({parent2.data} cup M5 cup M6) \ {key}  & M5 < parent2.data < M6  & key in M0 <=> key in M6 & parent2.data < key

(assert 
	(and
	(tobool 
	(ssep 
		(index alpha1 (bsthole root parent1 M1 M2) )
		(pto parent1 (sref (ref left cur1) (ref right Y) (data d1) ) )
		(pto cur1 (sref (ref left Z) (ref right cur2) (data d2) ) ) 
		(index alpha2 (bst Z M5)) 
		(index alpha3 (bst cur2 M6) )
		(index alpha4 (bst Y M4) )
	))
	(= M1 (bag-diff M0 (singleton key)) )
	(= M2 (bag-diff (bag-union (singleton d1) (bag-union M3 M4)) (singleton key)) )
	(bag-lt M3 (singleton d1) )
	(bag-lt (singleton d1) M4)
	(= M3 (bag-union (singleton d2) (bag-union M5 M6)) )
	(bag-lt M5 (singleton d2) )
	(bag-lt (singleton d2) M6)
	(> d1 key)
	(< d2 key)
	(= parent2 cur1)
	(or (not (bag-sub (singleton key) M0)) (bag-sub (singleton key) M3))
	(or (not (bag-sub (singleton key) M3)) (bag-sub (singleton key) M0))
	(= M22 (bag-diff M3 (singleton key)))
	)
)

;; bsthole(root,parent2, M1, M22) * parent2 |-> ((left,Z), (right,cur2)) * bst(Z, M5) * bst(cur2, M6) & M1 = M0 \ {key} & 
;; M22 = ({parent2.data} cup M5 cup M6) \ {key}  & M5 < parent2.data < M6  & key in M0 <=> key in M6 & parent2.data < key

(assert (not 
	(and
	(tobool 
	(ssep 
		(index alpha5 (bsthole root parent2 M1 M22) )
		(pto parent2 (sref (ref left Z) (ref right cur2) (data d2) ) ) 
		(index alpha6 (bst Z M5) )
		(index alpha7 (bst cur2 M6) )
	))
	(= M1 (bag-diff M0 (singleton key)) )
	(= M22 (bag-diff (bag-union (singleton d2) (bag-union M5 M6)) (singleton key)) )
	(bag-lt M5 (singleton d2) )
	(bag-lt (singleton d) M6)
	(or (not (bag-sub (singleton key) M0)) (bag-sub (singleton key) M6))
	(or (not (bag-sub (singleton key) M6)) (bag-sub (singleton key) M0))
	(< d2 key)
	)
))

(check-sat)
