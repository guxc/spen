
; Extending QF_S:
; constant emptybag, 
; the function bag, 
; the multiset comparison operator bag-lt, bag-le, bag-gt, bag-ge
; bagunion, bag-diff, bag-sub

(set-logic QF_SLRDI)

;; declare sorts
(declare-sort Avl_t 0)

;; declare fields
(declare-fun left () (Field Avl_t Avl_t))
(declare-fun right () (Field Avl_t Avl_t))
(declare-fun data () (Field Avl_t Int))
(declare-fun balance () (Field Avl_t Int))

;; declare predicates

;; avl(E,M, H)::= E = nil & emp & M = emptyset & H = 0 | 
;; exists X,Y,M1,M2,H1,H2. !E=nil & E |-> ((left,X), (right,Y)) * avl(X,M1,H1) * avl(Y,M2,H2) & M = {E.data} cup M1 cup M2 & 
;; M1 < E.data < M2 & ite(H2 > H1, H = H2+1 , H = H1+1) & E.balance = H2 - H1 & -1 <= E.balance <= 1

(define-fun avl ((?E Avl_t) (?M BagInt) (?H Int)) Space (tospace 
	(or 
	(and 	(= ?E nil) 
		(tobool emp
		)
		(= ?M emptybag)
		(= ?H 0)
	)
 
	(exists ( (?X Avl_t) (?Y Avl_t) (?M1 BagInt) (?M2 BagInt) (?H1 Int) (?H2 Int) (?d Int) (?b Int) ) 
	(and 
		(distinct ?E nil) 
		(tobool 
		(ssep 
			(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
			(avl ?X ?M1 ?H1)
			(avl ?Y ?M2 ?H2)
		)
		)
		(= ?M (bagunion (bag ?d) ?M1  ?M2) )
		(< ?M1 (bag ?d))
		(< (bag ?d) ?M2)
		(= ?H (ite (> ?H2 ?H1) (+ ?H2 1 ) (+ ?H1 1 ) ) )
		(= ?b (- ?H2 ?H1) )
		(<= (- 0 1) ?b) (<= ?b 1 )
	)
	)
	)
))

;; avlhole(E,F, M1, H1, M2, H2)::= E = F & emp & M1 = M2 & H1 = H2 | 
;; exists X,Y,M3,M4,H3,H4. E |-> ((left,X), (right,Y)) * avl(X,M3,H3) * avlhole(Y,F,M4,H4,M2,H2) & M1 = {E.data} cup M3 cup M4 & 
;; M3 < E.data < M4 & ite(H4 > H3, H1 = H4+1 , H = H3+1) & E.balance = H4 - H3 & -1 <= E.balance <= 1 |
;; exists X,Y,M3,M4,H3,H4. E |-> ((left,X), (right,Y)) * avlhole(X,F,M3,H3,M2,H2) * avl(Y,M4,H4) & M1 = {E.data} cup M3 cup M4 & 
;; M3 < E.data < M4 & ite(H4 > H3, H1 = H4+1 , H1 = H3+1) & E.balance = H4 - H3 & -1 <= E.balance <= 1

(define-fun avlhole ((?E Avl_t) (?F Avl_t) (?M1 BagInt) (?H1 Int) (?M2 BagInt) (?H2 Int)) Space (tospace 
	(or 
	(and (= ?E ?F) 
		(tobool emp
		)
		(= ?M1 ?M2)
		(= ?H1 ?H2)
	)
 
	(exists ( (?X Avl_t) (?Y Avl_t) (?M3 BagInt) (?M4 BagInt) (?H3 Int) (?H4 Int) (?d Int) (?b Int) ) 
	(and 
		(distinct ?E ?F) 
		(tobool 
		(ssep 
			(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
			(avlhole ?X ?F ?M3 ?H3 ?M2 ?H2)
			(avl ?Y ?M4 ?H4)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4) )
		(< ?M3 (bag ?d))
		(< (bag ?d) ?M4)
		(= ?H1 (ite (> ?H4 ?H3) (+ ?H4 1 ) (+ ?H3 1 ) ) )
		(= ?b (- ?H4 ?H3))
		(<= (- 0 1)  ?b) (<= ?b 1 )
	)
	)

	(exists ( (?X Avl_t) (?Y Avl_t) (?M3 BagInt) (?M4 BagInt) (?H3 Int) (?H4 Int) (?d Int) (?b Int) ) 
	(and 
		(distinct ?E ?F) 
		(tobool (ssep 
			(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
			(avl ?X ?M3 ?H3)
			(avlhole ?Y ?F ?M4 ?H4 ?M2 ?H2)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4 ) )
		(< ?M3 (bag ?d))
		(< (bag ?d) ?M4)
		(= ?H1 (ite (> ?H4 ?H3) (+ ?H4 1 ) (+ ?H3 1 ) ) )
		(= ?b (- ?H4 ?H3) )
		(<= (- 0 1)  ?b) (<= ?b 1 )
	)
	)
	)
))



;; avlhole with the property that each node on the path from E to F is balanced

;; bavlhole(E,F, M1, H1, M2, H2)::= E = F & emp & M1 = M2 & H1 = H2 | 
;; exists X,Y,M3,M4,H3,H4. E |-> ((left,X), (right,Y)) * avl(X,M3,H3) * bavlhole(Y,F,M4,H4,M2,H2) & M1 = {E.data} cup M3 cup M4 & M3 < E.data < M4 
;; & H3 = H4 & H1 = H3+1 & E.balance = 0 |
;; exists X,Y,M3,M4,H3,H4. E |-> ((left,X), (right,Y)) * bavlhole(X,F,M3,H3,M2,H2) * avl(Y,M4,H4) & M1 = {E.data} cup M3 cup M4 & M3 < E.data < M4 
;; & H3 = H4 & H1 = H3+1 & E.balance = 0

(define-fun bavlhole ((?E Avl_t) (?F Avl_t) (?M1 BagInt) (?H1 Int) (?M2 BagInt) (?H2 Int)) Space (tospace 
	(or 
	(and (= ?E ?F) 
		(tobool emp
		)
		(= ?M1 ?M2)
		(= ?H1 ?H2)
	)
 
	(exists ( (?X Avl_t) (?Y Avl_t) (?M3 BagInt) (?M4 BagInt) (?H3 Int) (?H4 Int) (?d Int) (?b Int) ) 
	(and (distinct ?E ?F) 
		(tobool 
		(ssep 
			(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
			(bavlhole ?X ?F ?M3 ?H3 ?M2 ?H2)
			(avl ?Y ?M4 ?H4)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4) )
		(< ?M3 (bag ?d))
		(< (bag ?d) ?M4)
		(= ?H1 (ite (> ?H4 ?H3) (+ ?H4 1 ) (+ ?H3 1 )) )
		(= ?b (- ?H4 ?H3))
		(= ?b 0)
	)
	)

	(exists ( (?X Avl_t) (?Y Avl_t) (?M3 BagInt) (?M4 BagInt) (?H3 Int) (?H4 Int) (?d Int) (?b Int) ) 
	(and (distinct ?E ?F) 
		(tobool (ssep 
			(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
			(avl ?X ?M3 ?H3)
			(bavlhole ?Y ?F ?M4 ?H4 ?M2 ?H2)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4) )
		(< ?M3 (bag ?d) )
		(< (bag ?d) ?M4 )
		(= ?H4 (ite (> ?H4 ?H3) (+ ?H4 1 ) (+ ?H3 1 )) )
		(= ?b (- ?H4 ?H3) )
		(= ?b 0)
	)
	)

	)
))

;; avlhole with the property that each node on the path from E to F is unbalanced

;; ubavlhole(E,F, M1, H1, M2, H2)::= E = F & emp & M1 = M2 & H1 = H2 | 
;; exists X,Y,M3,M4,H3,H4. E |-> ((left,X), (right,Y)) * avl(X,M3,H3) * ubavlhole(Y,F,M4,H4,M2,H2) & M1 = {E.data} cup M3 cup M4 & 
;; M3 < E.data < M4 & H3 = H4 & H1 = H3+1 & -1 <= E.balance <=1 & ! E.balance = 0 |
;; exists X,Y,M3,M4,H3,H4. E |-> ((left,X), (right,Y)) * ubavlhole(X,F,M3,H3,M2,H2) * avl(Y,M4,H4) & M1 = {E.data} cup M3 cup M4 & 
;; M3 < E.data < M4 & H3 = H4 & H1 = H3+1 & -1 <= E.balance <=1 & ! E.balance = 0

(define-fun ubavlhole ((?E Avl_t) (?F Avl_t) (?M1 BagInt) (?H1 Int) (?M2 BagInt) (?H2 Int)) Space (tospace 
	(or 
	(and (= ?E ?F) 
		(tobool emp
		)
		(= ?M1 ?M2)
		(= ?H1 ?H2)
	)
 
	(exists ( (?X Avl_t) (?Y Avl_t) (?M3 BagInt) (?M4 BagInt) (?H3 Int) (?H4 Int) (?d Int) (?b Int) ) 
	(and (distinct ?E ?F) 
		(tobool (ssep 
			(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
			(ubavlhole ?X ?F ?M3 ?H3 ?M2 ?H2)
			(avl ?Y ?M4 ?H4)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4 ) )
		(< ?M3 (bag ?d))
		(< (bag ?d) ?M4)
		(= ?H1 (ite (> ?H4 ?H3) (+ ?H4 1 ) (+ ?H3 1 ) ) )
		(= ?b (- ?H4 ?H3) )
		(<= (-  0 1 ) ?b) (<= ?b 1 )
		(distinct ?b 0)
	)
	)

	(exists ( (?X Avl_t) (?Y Avl_t) (?M3 BagInt) (?M4 BagInt) (?H3 Int) (?H4 Int) (?d Int) (?b Int) ) 
	(and (distinct ?E ?F) 
		(tobool (ssep 
			(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
			(avl ?X ?M3 ?H3)
			(ubavlhole ?Y ?F ?M4 ?H4 ?M2 ?H2)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4 ) )
		(< ?M3 (bag ?d))
		(< (bag ?d) ?M4)
		(= ?H1 (ite (> ?H4 ?H3) (+ ?H4 1 ) (+ ?H3 1 )) )
		(= ?b (- ?H4 ?H3))
		(<= (-  0 1 ) ?b) (<= ?b 1 )
		(distinct ?b 0)
	)
	)

	)
))


;; declare variables
(declare-fun root () Avl_t)
(declare-fun cur () Avl_t)
(declare-fun parent () Avl_t)
(declare-fun unbalance () Avl_t)
(declare-fun unbparent () Avl_t)
(declare-fun x () Avl_t)
(declare-fun X () Avl_t)
(declare-fun Y () Avl_t)
(declare-fun Z () Avl_t)
(declare-fun U () Avl_t)

(declare-fun M0 () BagInt)
(declare-fun M1 () BagInt)
(declare-fun M2 () BagInt)
(declare-fun M3 () BagInt)
(declare-fun M4 () BagInt)
(declare-fun M5 () BagInt)
(declare-fun M6 () BagInt)
(declare-fun M7 () BagInt)
(declare-fun M8 () BagInt)

(declare-fun H1 () Int)
(declare-fun H2 () Int)
(declare-fun H3 () Int)
(declare-fun H4 () Int)
(declare-fun H5 () Int)
(declare-fun H6 () Int)
(declare-fun H7 () Int)
(declare-fun H8 () Int)
(declare-fun h () Int)

(declare-fun d1 () Int)
(declare-fun d2 () Int)
(declare-fun d3 () Int)
(declare-fun d4 () Int)
(declare-fun b1 () Int)
(declare-fun b2 () Int)
(declare-fun b3 () Int)
(declare-fun b4 () Int)
(declare-fun key () Int)

;; declare set of locations

(declare-fun alpha1 () SetLoc)
(declare-fun alpha2 () SetLoc)
(declare-fun alpha3 () SetLoc)
(declare-fun alpha4 () SetLoc)
(declare-fun alpha5 () SetLoc)
(declare-fun alpha6 () SetLoc)
(declare-fun alpha7 () SetLoc)
(declare-fun alpha8 () SetLoc)
(declare-fun alpha9 () SetLoc)
(declare-fun alpha10 () SetLoc)


;; VC12: avlhole(root, unbparent, M1,H1,M2,H2) * unbparent |-> ((left,unbalance),(right,X),(data,d1),(balance,b1)) * 
;; unbalance |-> ((left,Y),(right,Z),(data,d2),(balance,b2)) * bavlhole(Y,parent,M4,H4,M6,H6) * parent |-> 
;; ((left,x),(right,U),(data,d3),(balance,b3)) * avl(cur, M7, H7) * avl(U,M8,H8) * avl(Z, M5,H5) * avl(X, M3, H3) * x |-> 
;; ((left,nil),(right,nil),(data,key), (balance,0)) & M7 < d3 < M8 & b3 = H8 - H7 & -1 <= b3 <= 1 & ite(key in M7, M6 = 
;; {d3} cup M7 cup M8, M6 = {d3} cup M7 cup M8 cup {key}) & ite(H8>H7, H6 = H8+1, H6 = H7+1) & M4 < d2 < M5 & b2 = H5 - H4 & 
;; -1 <= b2 <=1  & M2 = {d1} cup {d2} cup M4 cup M5 cup M3 & {d2} cup M4 cup M5 < d1 < M3 & ite(H5>H4, h = H5 +1, h= H4 +1) & 
;; b1 = H3 - h  & -1<= b1 <= 1  & ite(key in M0, M1 = M0, M1 = M0 cup {key}) & key in M0 <=> key in M7 & ! parent = nil & 
;; ! unbparent = nil & d1> key & d2 > key & d3 > key & ! b2 = 0 & b3 = 0 & cur = nil |-
;; avlhole(root, unbparent, M1,H1,M2,H2) * unbparent |-> ((left,unbalance),(right,X),(data,d1),(balance,b1)) * 
;; unbalance |-> ((left,Y),(right,Z),(data,d2),(balance,b2)) * bavlhole(Y,parent,M4,H4,M6,H6) * parent |-> 
;; ((left,x),(right,nil),(data,d3),(balance,b3)) * x |-> ((left,nil),(right,nil),(data,key), (balance,0)) * avl(Z, M5,H5) * 
;; avl(X, M3, H3) &  M6 = {d3} cup {key} & H6 = 1 & M4 < d2 < M5 & b2 = H5 - H4 & -1 <= b2 <=1 & M2 = {d1} cup {d2} cup M4 
;; cup M5 cup M3 & {d2} cup M4 cup M5 < d1 < M3 & ite(H5>H4, h = H5 +1, h= H4 +1) & b1 = H3 - h  & -1<= b1 <= 1 &  M1 = 
;; M0 cup {key} & !key in M0 & ! parent = nil & ! unbparent = nil & d1> key & d2 > key & d3 > key & ! b2 = 0 & b3 = 0
 
(assert 
	(and
	(tobool 
	(ssep 
		(index alpha1 (avlhole root unbparent M1 H1 M2 H2) ) 
		(pto unbparent (sref (ref left unbalance) (ref right X) (ref data d1) (ref balance b1)))
		(pto unbalance (sref (ref left Y) (ref right Z) (ref data d2) (ref balance b2)))
		(index alpha2 (bavlhole Y parent M4 H4 M6 H6))
		(pto parent (sref (ref left x) (ref right U) (ref data d3) (ref balance b3))) 
		(index alpha3 (avl cur M7 H7)) 
		(index alpha4 (avl U M8 H8)) 
		(index alpha5 (avl Z M5 H5))
		(index alpha6 (avl X M3 H3))
		(pto x  (sref (ref left nil) (ref right nil) (ref data key) (ref balance b4)))
	))
	(< M7 (bag d3)) (< (bag d3) M8) (= b3 (- H8 H7))
	(<= (- 0 1) b3) (<= b3 1) (= M6 (ite (subset (bag key) M7) (bagunion (bag d3) M7 M8) (bagunion (bag d3) M7 M8 (bag key)) ) )
	(= H6 (ite (> H8 H7) (+ H8 1) (+ H7 1)) ) (< M4 (bag d2)) (< (bag d2) M5) (= b2 (- H5 H4))
	(<= (- 0 1) b2) (<= b2 1)
	(= M2 (bagunion (bag d1) (bag d2) M4  M5 M3) ) (< (bagunion (bag d2) M4 M5) (bag d1)) (< (bag d1) M3) 
	(= h (ite (> H5 H4) (+ H5 1) (+ H4 1) ) )  (= b1 (- H3 h)) (<= (- 0 1) b1) (<= b1 1) 
	(= M1 (ite (subset (bag key) M0) M0 (bagunion M0 (bag key)) ) ) 
	(=> (subset (bag key) M0) (subset (bag key) M7) ) (=> (subset (bag key) M7) (subset (bag key) M0) ) 
	(distinct parent nil) (distinct unbparent nil) (> d1 key) (> d2 key) (> d3 key) (distinct b2 0) (= b3 0) (= cur nil) (= b4 0) (= U nil)
	)
)

;; avlhole(root, unbparent, M1,H1,M2,H2) * unbparent |-> ((left,unbalance),(right,X),(data,d1),(balance,b1)) * 
;; unbalance |-> ((left,Y),(right,Z),(data,d2),(balance,b2)) * bavlhole(Y,parent,M4,H4,M6,H6) * parent |-> 
;; ((left,x),(right,nil),(data,d3),(balance,b3)) * x |-> ((left,nil),(right,nil),(data,key), (balance,0)) * avl(Z, M5,H5) * 
;; avl(X, M3, H3) &  M6 = {d3} cup {key} & H6 = 1 & M4 < d2 < M5 & b2 = H5 - H4 & -1 <= b2 <=1 & M2 = {d1} cup {d2} cup M4 
;; cup M5 cup M3 & {d2} cup M4 cup M5 < d1 < M3 & ite(H5>H4, h = H5 +1, h= H4 +1) & b1 = H3 - h  & -1<= b1 <= 1 &  M1 = 
;; M0 cup {key} & !key in M0 & ! parent = nil & ! unbparent = nil & d1> key & d2 > key & d3 > key & ! b2 = 0 & b3 = 0

(assert (not 
	(and 
	(tobool 
	(ssep 
		(index alpha7 (avlhole root unbparent M1 H1 M2 H2))
		(pto unbparent (sref (ref left unbalance) (ref right X) (ref data d1) (ref balance b1)))
		(pto unbalance (sref (ref left Y) (ref right Z) (ref data d2) (ref balance b2)) )
		(index alpha8 (bavlhole Y parent M4 H4 M6 H6))
		(pto parent (sref (ref left x) (ref right nil) (ref data d3) (ref balance b3)))
		(pto x (sref (ref left nil) (ref right nil) (ref data key) (ref balance b4)))
		(index alpha9 (avl Z M5 H5)) 
		(index alpha10 (avl X M3 H3))
	))
	(= M6 (bagunion (bag d3) (bag key)) ) (= H6  1)  (< M4 (bag d2)) (< (bag d2) M5) (= b2 (- H5 H4)) (<= (- 0 1) b2)  (<= b2 1)
	(= M2 (bagunion (bag d1) (bag d2) M4 M5 M3) ) (< (bagunion (bag d2) M4 M5) (bag d1)) (< (bag d1) M3) 
	(= h (ite (> H5 H4) (+ H5 1) (+ H4 1) ) )  (= b1  (- H3 h)) (<= (- 0 1) b1) (<= b1 1)
	(= M1 (bagunion M0 (bag key)) ) (= M0 (bagminus M0 (bag key)) ) 
	(distinct parent nil) (distinct unbparent nil) 
	(> d1 key) (> d2 key) (> d3 key) (distinct b2 0) (= b3 0) (= b4 0)
	)
))

(check-sat)
