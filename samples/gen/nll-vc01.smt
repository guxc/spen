
(set-logic QF_S)

;; declare sorts
(declare-sort NLL_lvl1_t 0)
(declare-sort NLL_lvl2_t 0)


;; declare fields
(declare-fun next1 () (Field NLL_lvl1_t NLL_lvl1_t))
(declare-fun next2 () (Field NLL_lvl2_t NLL_lvl2_t))
(declare-fun down () (Field NLL_lvl2_t NLL_lvl1_t))


;; declare predicates

(define-fun sll ((?in NLL_lvl1_t) (?out NLL_lvl1_t) ) Space (tospace 
	(or 
	(and (= ?in ?out) 
		(tobool emp
		)

	)
 
	(exists ((?u NLL_lvl1_t) ) 
	(and (distinct ?in ?out) 
		(tobool (ssep 
		(pto ?in (ref next1 ?u) ) 
		(sll ?u ?out )
		) )

	)
 
	)

	)
))

(define-fun nsll ((?in NLL_lvl2_t) (?out NLL_lvl2_t) (?boundary NLL_lvl1_t) ) Space (tospace 
	(or 
	(and (= ?in ?out) 
		(tobool emp
		)

	)
 
	(exists ((?u NLL_lvl2_t) (?Z1 NLL_lvl1_t) ) 
	(and (distinct ?in ?out) 
		(tobool (ssep 
		(pto ?in (sref (ref next2 ?u) (ref down ?Z1) ) ) 
		(sll ?Z1 ?boundary )
		(nsll ?u ?out ?boundary )
		) )

	)
 
	)

	)
))

;; declare variables
(declare-fun x1 () NLL_lvl2_t)
(declare-fun x1_1 () NLL_lvl1_t)
(declare-fun x1_2 () NLL_lvl1_t)
(declare-fun x1_3 () NLL_lvl1_t)
(declare-fun x2 () NLL_lvl2_t)
(declare-fun x2_1 () NLL_lvl1_t)
(declare-fun x2_2 () NLL_lvl1_t)

;; declare set of locations

(declare-fun alpha0 () SetLoc)

(assert 
	(tobool 
	(ssep 
		(pto x1 (sref (ref next2 x2) (ref down x1_1) ) ) 
		(pto x1_1 (ref next1 x1_2) ) 
		(pto x1_2 (ref next1 x1_3) ) 
		(pto x1_3 (ref next1 nil) ) 
		(pto x2 (sref (ref next2 nil) (ref down x2_1) ) ) 
		(pto x2_1 (ref next1 x2_2) ) 
		(pto x2_2 (ref next1 nil) ) 
	)

	)

)

(assert (not 
	(tobool 
		(index alpha0 (nsll x1 nil nil )) 
	)

))

(check-sat)
