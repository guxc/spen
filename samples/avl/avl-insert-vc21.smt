
; Extending QF_S:
; constant emptybag, 
; the function bag, 
; the multiset comparison operator bag-lt, bag-le, bag-gt, bag-ge
; bagunion, bag-diff, bag-sub

(set-logic QF_S)

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
	(and (= ?E nil) 
		(tobool emp
		)
		(= ?M emptybag)
		(= ?H 0)
	)
 
	(exists ( (?X Avl_t) (?Y Avl_t) (?M1 BagInt) (?M2 BagInt) (?H1 Int) (?H2 Int) (?d Int) (?b Int) ) 
	(and (distinct ?E nil) 
		(tobool (ssep 
		(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
		(avl ?X ?M1 ?H1)
		(avl ?Y ?M2 ?H2)
		)
		)
		(= ?M (bagunion (bag ?d) ?M1  ?M2) )
		(< ?M1 (bag ?d))
		(< (bag ?d) ?M2)
		ite((> ?H2 ?H1) (= ?H ?H2+1) (= ?H ?H1+1))
		(= ?b (- ?H2 ?H1))
		(<= -1 ?b) (<= ?b 1)
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
	(and (distinct ?E ?F) 
		(tobool (ssep 
		(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
		(avlhole ?X ?M3 ?H3 ?M2 ?H2)
		(avl ?Y ?M4 ?H4)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4) )
		(< ?M3 (bag ?d))
		(< (bag ?d) ?M4)
		ite((> ?H4 ?H3) (= ?H1 ?H4+1) (= ?H1 ?H3+1))
		(= ?b (- ?H4 ?H3))
		(<= -1 ?b) (<= ?b 1)
	)
	)

	(exists ( (?X Avl_t) (?Y Avl_t) (?M3 BagInt) (?M4 BagInt) (?H3 Int) (?H4 Int) (?d Int) (?b Int) ) 
	(and (distinct ?E ?F) 
		(tobool (ssep 
		(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
		(avl ?Y ?M3 ?H3)
		(avlhole ?X ?M4 ?H4 ?M2 ?H2)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4 ) )
		(< ?M3 (bag ?d))
		(< (bag ?d) ?M4)
		ite((> ?H4 ?H3) (= ?H1 ?H4+1) (= ?H1 ?H3+1))
		(= ?b (- ?H4 ?H3))
		(<= -1 ?b) (<= ?b 1)
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
		(tobool (ssep 
		(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
		(bavlhole ?X ?M3 ?H3 ?M2 ?H2)
		(avl ?Y ?M4 ?H4)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4) )
		(< ?M3 (bag ?d))
		(< (bag ?d) ?M4)
		ite((> ?H4 ?H3) (= ?H1 ?H4+1) (= ?H1 ?H3+1))
		(= ?b (- ?H4 ?H3))
		(= ?b 0)
	)
	)

	(exists ( (?X Avl_t) (?Y Avl_t) (?M3 BagInt) (?M4 BagInt) (?H3 Int) (?H4 Int) (?d Int) (?b Int) ) 
	(and (distinct ?E ?F) 
		(tobool (ssep 
		(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
		(avl ?Y ?M3 ?H3)
		(bavlhole ?X ?M4 ?H4 ?M2 ?H2)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4) )
		(< ?M3 (bag ?d))
		(< (bag ?d) ?M4)
		ite((> ?H4 ?H3) (= ?H1 ?H4+1) (= ?H1 ?H3+1))
		(= ?b (- ?H4 ?H3))
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
		(ubavlhole ?X ?M3 ?H3 ?M2 ?H2)
		(avl ?Y ?M4 ?H4)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4 ) )
		(< ?M3 (bag ?d))
		(< (bag ?d) ?M4)
		ite((> ?H4 ?H3) (= ?H1 ?H4+1) (= ?H1 ?H3+1))
		(= ?b (- ?H4 ?H3))
		(<= -1 ?b) (<= ?b 1)
		(distinct ?b 0)
	)
	)

	(exists ( (?X Avl_t) (?Y Avl_t) (?M3 BagInt) (?M4 BagInt) (?H3 Int) (?H4 Int) (?d Int) (?b Int) ) 
	(and (distinct ?E ?F) 
		(tobool (ssep 
		(pto ?E (sref (ref left ?X) (ref right ?Y) (ref data ?d) (ref balance ?b)) ) 
		(avl ?Y ?M3 ?H3)
		(ubavlhole ?X ?M4 ?H4 ?M2 ?H2)
		)
		)
		(= ?M1 (bagunion (bag ?d) ?M3 ?M4 ) )
		(< ?M3 (bag ?d))
		(< (bag ?d) ?M4)
		ite((> ?H4 ?H3) (= ?H1 ?H4+1) (= ?H1 ?H3+1))
		(= ?b (- ?H4 ?H3))
		(= ?b 0)
	)
	)

	)
))

;; declare variables
(declare-fun root0 () Avl_t)
(declare-fun root () Avl_t)
(declare-fun root1 () Avl_t)
(declare-fun cur () Avl_t)
(declare-fun cur1 () Avl_t)
(declare-fun cur2 () Avl_t)
(declare-fun parent () Avl_t)
(declare-fun parent1 () Avl_t)
(declare-fun parent2 () Avl_t)
(declare-fun unbalance () Avl_t)
(declare-fun unbalance1 () Avl_t)
(declare-fun unbalance2 () Avl_t)
(declare-fun unbparent () Avl_t)
(declare-fun unbparent1 () Avl_t)
(declare-fun unbparent2 () Avl_t)
(declare-fun lft () Avl_t)
(declare-fun lftright () Avl_t)
(declare-fun x () Avl_t)
(declare-fun X () Avl_t)
(declare-fun Y () Avl_t)
(declare-fun Z () Avl_t)
(declare-fun U () Avl_t)
(declare-fun V () Avl_t)
(declare-fun U1 () Avl_t)
(declare-fun V1 () Avl_t)


(declare-fun M0 () BagInt)
(declare-fun M1 () BagInt)
(declare-fun M2 () BagInt)
(declare-fun M3 () BagInt)
(declare-fun M4 () BagInt)
(declare-fun M5 () BagInt)
(declare-fun M6 () BagInt)
(declare-fun M7 () BagInt)
(declare-fun M9 () BagInt)
(declare-fun M10 () BagInt)
(declare-fun M11 () BagInt)
(declare-fun M12 () BagInt)
(declare-fun M13 () BagInt)

(declare-fun H1 () Int)
(declare-fun H2 () Int)
(declare-fun H3 () Int)
(declare-fun H4 () Int)
(declare-fun H5 () Int)
(declare-fun H6 () Int)
(declare-fun H7 () Int)
(declare-fun H8 () Int)
(declare-fun H9 () Int)
(declare-fun H10 () Int)
(declare-fun H11 () Int)
(declare-fun H12 () Int)
(declare-fun H13 () Int)
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
(declare-fun alpha11 () SetLoc)
(declare-fun alpha12 () SetLoc)
(declare-fun alpha13 () SetLoc)
(declare-fun alpha14 () SetLoc)

;; VC21: avlhole(root, unbparent, M1,H1,M2,H2) * unbparent |-> ((left,lftright),(right,X),(data,d1),(balance,b1)) * 
;; unbalance |-> ((left,V1),(right,Z),(data,d2),(balance,0)) * Y |-> ((left,U),(right,U1),(data,d4),(balance,-1)) * 
;; ubavlhole(U,parent,M9,H9,M7,H8) * V |-> ((left,lft),(right,unbalance),(data,d5),(balance,0)) * avl(U1,M11,H11) * 
;; avl(V1,M12,H12) * parent |-> ((left,x),(right,nil),(data,d3),(balance,b3)) * x |-> ((left,nil),(right,nil),(data,key), (balance,0)) 
;; * avl(Z, M5,H5) * avl(X, M3, H3) & M10 = {d5} cup M11 cup M12 & M11 < d5 < M12 & ite(H12 > H11, H10 = H12+1, H10 = H11 +1) & 
;; b5 = H12 - H11 & b5 = 1 & M4 = {d4} cup M9 cup M10 & M9 < d4 < M10 & ite(H10 > H9, H4 = H10 +1, H4 = H9 +1) & b4 = H10 - H9 & 
;; -1 <= b4 <=1 & !b4=0 & !b4 = -1 & M7 = {d3} cup {key} & H8 = 2 & M4 < d2 < M5 & b2 = H5 - H4 & b2=-2 & 
;; M2 = {d1} cup {d2} cup M4 cup M5 cup M3 & {d2} cup M4 cup M5 < d1 < M3 & ite(H5+1>H4, h = H5 +1, h= H4) & b1 = H3 - h  & 
;; -1<= b1 <= 1 &  M1 = M0 cup {key} & ! key in M0 & ! parent = nil & ! unbparent = nil & d1> key & d2 > key & d3 > key & ! b2 = 0 & 
;; b3 = -1 & cur = x & lft = Y & lftright = V & ret = root |-
;; avl(ret,M1,H1) & M1 = M0 cup {key} & ! key in M0

 
(assert 
	(and
	(tobool 
	(ssep 
		(index alpha1 (avlhole root unbparent M1 H1 M2 H2)) 
		(pto unbparent (sref (ref left lftright) (ref right X) (ref data d1) (ref balance b1)))
		(pto unbalance (sref (ref left V1) (ref right Z) (ref data d2) (ref balance 0)))
		(pto Y (sref (ref left U) (ref right U1) (ref data d4) (ref balance -1)))
		(index alpha2 (ubavlhole U parent M9 H9 M7 H8))
		(pto V (sref (ref left lft) (ref right unbalance) (ref data d5) (ref balance 0)))
		(index alpha3 (avl U1 M11 H11))
		(index alpha4 (avl V1 M12 H12))
		(pto (parent (sref (ref left x) (ref right nil) (ref data d3) (ref balance b3)))
		(pto x (sref (ref left nil) (ref right nil) (ref data key) (ref balance 0)))
		(index alpha5 (avl Z M5 H5))
		(index alpha6 (avl X M3 H3))
	))
	(= M10 (bagunion (bag d5) M11 M12)) (< M11 (bag d5)) (< (bag d5) M12)
	(ite (> H12 H11) (= H10  (+ H12 1)) (= H10 (+ H11 1)) )  
	(= b5 (- H12  H11)) (= b5 1)
	(= M4 (bagunion (bag d4) M9 M10)) (< M9 (bag d4)) (< (bag d4) M10) 
	(ite (> H10 H9) (= H4 (+ H10 1)) (= H4 (+ H9 1)) )  
	(= b4 (- H10 H9)) (<= -1 b4) (<= b4 1)(distinct b4 0)  (distinct b4 -1) (= M7 (bagunion (bag d3) (bag key)))
	(= H8 2) (< M4 (bag d2)) (< (bag d2) M5) (= b2 (- H5 H4)) (= b2 -2) (= M2 (bagunion (bag d1) (bag d2)  M4  M5 M3)) 
	(< (bagunion (bag d2)  M4  M5) (bag d1)) (< (bag d1) M3) (ite (> (+ H5 1) H4) (= h (+ H5 1)) (= h H4)) 
	(= b1  (- H3  h)) (<= -1 b1) (<= b1 1) (= M1 (bagunion M0 (bag key))) (not (subset (bag key) M0)) (distinct parent nil)
	(distinct unbparent nil) (> d1 key) (> d2 key) (> d3 key) (distinct b2 0) (= b3 -1) (= cur x) (= lft Y) 
	(= lftright V) (= ret root)
)

;; avl(ret,M1,H1) & M1 = M0 cup {key} & ! key in M0

(assert (not 
	(and 
	(tobool 
		(index alpha7 (avl ret M1 H1))
	)
	(= M1 (bagunion M0 (bag key))) (not (subset (bag key) M0))
	)
))

(check-sat)
