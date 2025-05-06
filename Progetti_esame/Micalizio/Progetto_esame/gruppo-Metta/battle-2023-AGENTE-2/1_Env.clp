
;; L'ENVIRONMENT importa dal MAIN tutto ciò che è importabile ed esporta questi templates CHE COSTITUIRANNO
;; LA CONOSCENZA INIZIALE DEL NOSTRO AGENTE:
;; - k-cell ;; possiamo sapere cosa è stato trovato in una certa cella k della griglia con coordinate x e y
;; - k-per-row ;; numero di 
;; - k-per-col
(defmodule ENV (import MAIN ?ALL) (export deftemplate k-cell k-per-row  k-per-col))


;; - Il template "cell" rappresenta una cella della griglia.
(deftemplate cell
	(slot x) ;; coordinata x
	(slot y) ;; coordinata y
	(slot content (allowed-values water boat hit-boat)) ;; una cella può contenere acqua, una nave intera
							    ;; oppure un pezzo di nave che è stato colpito.
	(slot status (allowed-values none guessed fired missed)) ;; una cella ha uno stato che può essere:
;; 1) none -> se l'agente non ha ancora considerato questa cella
;; 2) guessed -> se l'agente ha messo una bandierina su questa cella
;; 3) fired -> se l'agente ha colpito questa cella e ha trovato o una nave intera o un pezzo di una nave allora
	       ;; lo stato di questa cella diventa "fired"
;; 4) missed -> se l'agente ha colpito questa cella e ha trovato dell'acqua allora lo stato di questa cella diventa
		;; "missed"
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; I DUE TEMPLATES DI TIPI DI NAVI QUI SOTTO NON SONO ESPORTATE ALL'ESTERNO

;; - Il template "boat-hor" rappresenta la struttura di una nave IN ORIZZONTALE
(deftemplate boat-hor
    (slot name) ;; nome nave
	(slot x) ;; unica coordinata x (indice di riga)
	(multislot ys) ;; multislot di coordinate y (indici di colonna)
	(slot size) ;; lunghezza orizzontale della nave
	(multislot status (allowed-values safe hit)) ;; questo multislot serve per specificare lo stato di 
						     ;; di ogni singolo pezzo della nave che potrà essere
						     ;; "safe"(non colpita) o "hit"(colpita). In questo template
						     ;; non serve sapere la cella della nave che è stata colpita
						     ;; perchè basta questo per calcolare la formula finale del 
						     ;; punteggio. Se si volesse sapere quale cella è stata colpita
						     ;; verrà usato direttamente il template "cell" di sopra.
)

;; - Il template "boat-ver" rappresenta la struttura di una nave IN VERTICALE
(deftemplate boat-ver
    (slot name)
	(multislot xs) ;; multislot di coordinate x (indici di riga)
	(slot y) ;; unica coordinata y (indice di colonna)
	(slot size)
	(multislot status (allowed-values safe hit))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; I TRE TEMPLATES DI TIPI DI NAVI QUI SOTTO SONO ESPORTATE ALL'ESTERNO e quindi il nostro agente potrà e dovrà
;; usarle.

;; - Con il template "k-cell" possiamo sapere cosa è stato trovato in una certa cella k con coordinate x e y.
;;   Queste k-cell l'agente potrà saperle perchè o sono fatti noti già dall'inizio o perchè sono il risultato
;;   di una "fire" che è stata fatta dall'agente. 
(deftemplate k-cell 
	(slot x)
	(slot y)
	(slot content (allowed-values water left right middle top bot sub)) ;; I POSSIBILI VALORI DELLA "k-cell"
	;; sono i seguenti:
	;; 1) water
	;; 2) left (è stato colpito il fianco sinistro di una nave)
	;; 3) right (è stato colpito il fianco destro di una nave)
	;; 4) middle (è stato colpito il centro di una nave)
	;; 5) top (è stato colpito il fianco superiore di una nave
	;; 6) bot (è stato colpito il fianco inferiore di una nave	
	;; 7) sub (la nave è stata affondata perchè era un sottomarino e quindi occupava una sola cella)
)


;; - Con il template "k-per-row" RAPPRESENTIAMO PER OGNI RIGA il numero di celle occupate totali 
;;   (da una o più navi)
;; - Quindi avremo 10 fatti (1 per riga) e ciascuno di essi ci dirà in una certa riga quante celle sono occupate
;;   dalle navi.  
(deftemplate k-per-row
	(slot row)
	(slot num)
)

;; - Con il template "k-per-col" RAPPRESENTIAMO PER OGNI COLONNA il numero di celle occupate totali 
;;   (da una o più navi) 
;; - Quindi avremo 10 fatti (1 per colonna) e ciascuno di essi ci dirà in una certa colonna quante celle 
;;   sono occupate dalle navi. 
(deftemplate k-per-col
	(slot col)
	(slot num)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DA QUI IN POI PARTONO TUTTE LE REGOLE CHE SERVONO PER MODELLARE LE REGOLE DEL GIOCO e che quindi NON saranno
;; disponibili all'agente perchè non gli serviranno.

;; RICORDA: SE FAI LA FIRE SU UNA CELLA E SI SCOPRE CHE LI' C'E' L'ACQUA DEVI INFERIRE DA SOLO CHE 
;; 	    DENTRO QUELLA CELLA C'ERA L'ACQUA PERCHE' LE REGOLE DI SOTTO NON TE LO DICONO.. (36m)

;; - La regola "action-fire" 
(defrule action-fire 
        ?us <- (status (step ?s) (currently running)) ;; se mi trovo nello stato di "running" dove il numero di 
						      ;; steps è s, mi salvo questo stato nella variabile "us".
	(exec (step ?s) (action fire) (x ?x) (y ?y)) ;; se l'agente vuole fare una fire su una certa cella (x,y)
	?mvs <- (moves (fires ?nf &:(> ?nf 0))) ;; e se l'agente ha effetivamente dei fires a sua disposizione
=>
	(assert (fire ?x ?y)) ;; allora asserisco il fatto fire nella cella (x,y) (farà attivare due possibili
			      ;; regole che sono "fire-ok" e "fire-ko")
        (modify ?us (step (+ ?s 1)) ) ;; modifico il numero di steps fatti (+1)
 	(modify ?mvs (fires (- ?nf 1))) ;; modifico il numero di fires possibili (-1)
)



(defrule action-guess
        ?us <- (status (step ?s) (currently running))
	(exec (step ?s) (action guess) (x ?x) (y ?y))
	?mvs <- (moves (guesses ?ng &:(> ?ng 0)))
=>
	(assert (guess ?x ?y))
        (modify ?us (step (+ ?s 1)) )
	(modify ?mvs (guesses (- ?ng 1)))
)

(defrule action-unguess
        ?us <- (status (step ?s) (currently running))
	(exec (step ?s) (action unguess) (x ?x) (y ?y))
	?gu <- (guess ?x ?y)
	?mvs <- (moves (guesses ?ng &:(< ?ng 20)))
=>	
	(retract ?gu)
        (modify ?us (step (+ ?s 1)) )
	(modify ?mvs (guesses (+ ?ng 1)))
)



(defrule action-solve
        ?us <- (status (step ?s) (currently running))
	(exec (step ?s) (action solve))
=>
	(assert (solve))
        (modify ?us (step (+ ?s 1)) (currently stopped) )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Queste qui sotto sono due regole "fire-ok" e "fire-ko" che si attiveranno quando asserirò un fatto (fire ?x ?y)
(defrule fire-ok
	(fire ?x ?y)
	?fc <- (cell (x ?x) (y ?y) (content boat) (status none)) ;; l'agente ha centrato un pezzo di nave presente
								 ;; nella cella (x,y) e mi memorizzo questa cella 
								 ;; nella variabile fc
	?st <- (statistics (num_fire_ok ?fok)) ;; mi salvo il numero di fire andati a buon fine
=>
	(modify ?fc (content hit-boat) (status fired)) ;; modifico lo stato della cella fc specificando che adesso
						       ;; il suo status è "fired" e che il suo content è "hit-boat"
        (modify ?st (num_fire_ok (+ ?fok 1))) ;; incremento il numero di fire che hanno permesso di colpire
					      ;; correttamente il bersaglio. 
)


(defrule fire-ko
	(fire ?x ?y)
	?fc <- (cell (x ?x) (y ?y) (content water) (status none))
	?st <- (statistics (num_fire_ko ?fko))
=>
	(modify ?fc (status missed))
        (modify ?st (num_fire_ko (+ ?fko 1)))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(defrule hit-boat-hor-trace

	(cell (x ?x) (y ?y) (content hit-boat))
	?b<- (boat-hor (x ?x) (ys $? ?y $?) (size ?s) (status $?prima safe $?dopo))
        (not (considered ?x ?y))

=>
	(modify ?b (status ?prima hit ?dopo))
        (assert (considered ?x ?y))
)

(defrule hit-boat-ver-trace

	(cell (x ?x) (y ?y) (content hit-boat))
        (not (considered ?x ?y))
	?b <-(boat-ver (xs $? ?x $?) (y ?y) (size ?s) (status $?prima safe $?dopo))
=>
	(modify ?b (status ?prima hit ?dopo))
        (assert (considered ?x ?y))
)

(defrule sink-boat-hor

	(cell (x ?x) (y ?y) (content hit-boat))
	(boat-hor (name ?n) (x ?x) (ys $? ?y $?) (size ?s) (status $?ss))
        
	(or 
		(and (test (eq ?s 1))
		     (test (subsetp $?ss (create$ hit)))
                )

		(and (test (eq ?s 2))
		     (test (subsetp $?ss (create$ hit hit)))
                )

		(and (test (eq ?s 3))
		     (test (subsetp $?ss (create$ hit hit hit)))
                )

		(and (test (eq ?s 4))
		     (test (subsetp $?ss (create$ hit hit hit hit)))
                )


	)
=>

	(assert (sink-boat ?n ))
)

(defrule sink-boat-ver

	(cell (x ?x) (y ?y) (content hit-boat))
	(boat-ver (name ?n) (xs $? ?x $?) (y ?y) (size ?s) (status $?ss))
        
	(or 
		(and (test (eq ?s 1))
		     (test (subsetp $?ss (create$ hit)))
                )

		(and (test (eq ?s 2))
		     (test (subsetp $?ss (create$ hit hit)))
                )

		(and (test (eq ?s 3))
		     (test (subsetp $?ss (create$ hit hit hit)))
                )

		(and (test (eq ?s 4))
		     (test (subsetp $?ss (create$ hit hit hit hit)))
                )
	)
=>
	(assert (sink-boat ?n))
)



(defrule solve-count-guessed-ok
        (solve)
        (guess ?x ?y)
        ?c <- (cell (x ?x) (y ?y) (content boat) (status none))
        ?st <- (statistics (num_guess_ok ?gok))
=>
	(modify ?st (num_guess_ok (+ 1 ?gok)))
	(modify ?c (content hit-boat) (status guessed))
)

(defrule solve-count-guessed-ko 
	(solve)
	(guess ?x ?y)
	?c <- (cell (x ?x) (y ?y) (content water) (status none))
	?st <- (statistics (num_guess_ko ?gko))
=>
	(modify ?st (num_guess_ko (+ 1 ?gko)))
	(modify ?c (status missed))
)

(defrule solve-count-safe 
	(solve)
	?c <-(cell (x ?x) (y ?y) (content boat) (status none))
	(not (guess ?x ?y))
	?st <- (statistics (num_safe ?saf))
=>
	(modify ?st (num_safe(+ 1 ?saf)))
	(modify ?c (status missed))
)

(defrule solve-sink-count
	(solve)
	?s<- (sink-boat ?n)
        (not (sink-checked ?n))
	?st <- (statistics (num_sink ?sink))
=>
	(modify ?st (num_sink (+ 1 ?sink)))
	(retract ?s)
	(assert (sink-checked ?n))
)


(deffunction scoring (?fok ?fko ?gok ?gko ?saf ?sink ?nf ?ng)

	(- (+ (* ?gok 15) (* ?sink 20) )  (+ (* ?gko 10) (* ?saf 10) (* ?nf 20) (* ?ng 20) ))
)

	

(defrule solve-scoring (declare (salience -10))
	(solve)
	(statistics (num_fire_ok ?fok) (num_fire_ko ?fko) (num_guess_ok ?gok) (num_guess_ko ?gko) (num_safe ?saf) (num_sink ?sink))
	(moves (fires ?nf) (guesses ?ng))
=>
	(printout t "Your score is " (scoring ?fok ?fko ?gok ?gko ?saf ?sink ?nf ?ng) crlf)
)
	

(defrule reset-map
	(k-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
	?st <- (statistics (num_fire_ok ?fok))
	(not (resetted ?x ?y))
=>
	(assert (fire ?x ?y))
	(modify ?st (num_fire_ok (- ?fok 1))) ;;non contiamo come fire le posizioni note inizialmente
	(assert (resetted ?x ?y))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; - TUTTE QUESTE REGOLE RIMANENTI SERVONO PER RENDERE VISIBILE LA CELLA CHE L'AGENTE HA OSSERVATO dopo aver
;;   eseguito la fire su di essa.


;; - Questa regola "make-visible-sub" serve per specificare che in una k-cell l'agente ha colpito un sottomarino.
(defrule make-visible-sub (declare (salience 10))
	(fire ?x ?y) ;; se è vero che ho fatto la fire su una cella (x,y)
	(cell (x ?x) (y ?y) (content boat)) ;; se è vero che in questa cella c'era una nave
	(boat-hor (x ?x) (ys ?y $?) (size 1)) ;; se è vero che questa nave era in orizzontale e di dimensione 1 
					      ;; (e quindi era un sottomarino)
	(not (k-cell (x ?x) (y ?y) ) ) ;; e la k-cell con le coordinate correnti non è già presente tra i fatti 
=>
	(assert (k-cell (x ?x) (y ?y) (content sub))) ;; allora asserisco questa k-cell specificando che in essa
						      ;; c'era un sottomarino
	(assert (resetted ?x ?y)) 
)



(defrule make-visible-left (declare (salience 5))
	(fire ?x ?y) ;; se è vero che ho fatto la fire su una cella (x,y)
	(cell (x ?x) (y ?y) (content boat)) ;; se è vero che in questa cella c'era una nave
	(boat-hor (x ?x) (ys ?y $?)) ;; se è vero che questa nave era in orizzontale E la y corrente è proprio 
				     ;; il valore DELLA PRIMA coordinata del multislot "boat-hor"
	(not (k-cell (x ?x) (y ?y) ))
=>
	(assert (k-cell (x ?x) (y ?y) (content left))) ;; ALLORA POSSO DIRE CHE L'AGENTE HA COLPITO IL FIANCO
						       ;; SINISTRO DELLA NAVE orizzontale 
						       ;; PRESENTE IN (x, "boat-hor") proprio perchè 
						       ;; nell'antecedente mi sono accertato che 
						       ;; y fosse il valore della prima colonna 
						       ;; del multislot "boat-hor".
	(assert (resetted ?x ?y))
)


(defrule make-visible-right (declare (salience 5))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content boat))
	(boat-hor (x ?x) (ys $? ?y)) ;; se è vero che questa nave era in orizzontale E la y corrente è proprio 
				     ;; il valore DELL'ULTIMA coordinata del multislot "boat-hor"
	(not (k-cell (x ?x) (y ?y)) )
=>
	(assert (k-cell (x ?x) (y ?y) (content right))) ;; ALLORA POSSO ASSERIRE CHE L'AGENTE HA COLPITO IL FIANCO
						        ;; DESTRO DELLA NAVE orizzontale
	(assert (resetted ?x ?y))
)

;;;;;;;;;;						;;;;;;;;;;
;; LE REGOLE QUI SOTTO SEGUONO LA SCIA DELLE PRIME DUE..
;;;;;;;;;;						;;;;;;;;;;


(defrule make-visible-top (declare (salience 5))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content boat))
	(boat-ver (y ?y) (xs ?x $?))
	(not (k-cell (x ?x) (y ?y) ) )
=>
	(assert (k-cell (x ?x) (y ?y) (content top)))
	(assert (resetted ?x ?y))
)
	

(defrule make-visible-bot (declare (salience 5))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content boat))
	(boat-ver (y ?y) (xs $? ?x))
	(not (k-cell (x ?x) (y ?y) ) )
=>
	(assert (k-cell (x ?x) (y ?y) (content bot)))
	(assert (resetted ?x ?y))
)

(defrule make-visible-middle (declare (salience 5))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content boat))
	(not (k-cell (x ?x) (y ?y) ) )
=>
	(assert (k-cell (x ?x) (y ?y) (content middle)))
	(assert (resetted ?x ?y))
)


(defrule make-visible-water (declare (salience 5))
	(fire ?x ?y)
	(cell (x ?x) (y ?y) (content water))
	(not (k-cell (x ?x) (y ?y) ) )
=>
	(assert (k-cell (x ?x) (y ?y) (content water)))
	(assert (resetted ?x ?y))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

