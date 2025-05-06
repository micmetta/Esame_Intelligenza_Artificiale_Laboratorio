
(defmodule PIAZZAMENTO_INCROCIATORE_LEFT (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (import GESTORE_LEFT ?ALL) (export ?ALL))

; Questo modulo prova a piazzare una incrociatore solo in verticale partendo dalla cella "left" conosciuta e 
; se ci riesce allora setterà il flag di GESTORE_LEFT a TRUE.
; in WM ci sarà sicuramente la cella middle fatta così: (cella_left (x ?x) (y ?y) (considerata false))


; DEFTEMPLATES:
(deftemplate piazzamento_incrociatore_orizzontale
    (slot x)
    (slot y)
)

; se ho un left allora posso cercare di posizionare qualcosa solamente sulla destra partendo ovviamente dalla cella left
;;(deftemplate celle_destra_a_left
;;    (slot y_col_destra_1) ; riga subito a destra rispetto al left
;;    (slot y_col_destra_2) ; riga +2 a destra rispetto al left
;;)




; PRATICAMENTE LA REGOLA QUI SOTTO SARA' LA PRIMA CHE VERRA' ESEGUITA E si preoccuperà di settare
; tutti i valori che servono alle regole di posizionamento per scoprire se è possibile piazzare la incrociatore 
; d'interesse o meno.
;;(defrule aggiunta_fatti_per_reg_successive (declare (salience 50))
;;    (cella_left (x ?x) (y ?y) (considerata ?c))
;;=>
;;    (assert (celle_destra_a_left_in_gestore_left (y_col_destra_1 (+ ?y 1)) (y_col_destra_2 (+ ?y 2)) (y_col_destra_3 (+ ?y 3))))
;;)



;; DA QUI PARTE IL CONTROLLO SULLA DIREZIONE ORIZZONTALE.

(defrule posizionamento_incrociatore_in_orizzontale_conoscendo_left (declare (salience 26))

    ; 1) deve essere vero che posso piazzare ancora una incrociatore
    (incrociatori (celle_con_bandierina $?lista) (mancanti ?m))   
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella riga “x” possa posizionare ALMENO 3 bandierine e quindi deve essere vero che:
    (cella_left (x ?x) (y ?y) (considerata ?c))
    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 3)) ; controllo se la differenza è maggiore o uguale a 3

    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle a destra rispetto alla cella left:
    (celle_destra_a_left_in_gestore_left (y_col_destra_1 ?y_col_destra_1) (y_col_destra_2 ?y_col_destra_2) (y_col_destra_3 ?y_col_destra_3))


    ; 3) E inoltre mi devo assicurare che nella colonna subito a destra del left possa mettere 
    ;    la bandierina che supporremo corrisponda al "middle" partendo da sinistra e quindi deve essere vero che:
    (k-per-col (col ?y_col_destra_1) (num ?max_pezzi_col_destra_1))
    (k-per-col-bandierine-posizionate (col ?y_col_destra_1) (num ?num_b_col_destra_1))
    (test (>= (- ?max_pezzi_col_destra_1 ?num_b_col_destra_1) 1))


    ; 4) E inoltre mi devo assicurare che due colonne subito a destra possa mettere 
    ;    la bandierina che supporremo corrisponda al "right" partendo da sinistra e quindi deve essere vero che:
    (k-per-col (col ?y_col_destra_2) (num ?max_pezzi_col_destra_2))
    (k-per-col-bandierine-posizionate (col ?y_col_destra_2) (num ?num_b_col_destra_2))
    (test (>= (- ?max_pezzi_col_destra_2 ?num_b_col_destra_2) 1))

    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?x) (y ?y_col_destra_1) (content water)))
    (not (k-cell (x ?x) (y ?y_col_destra_2) (content water)))

    ; verifico che nelle celle d'interesse non sia stata già posizionata una bandierina:
    (not(k_cell_agent (x ?x) (y ?y_col_destra_1) (content sconosciuto) (considerato true) (current no)))
    (not(k_cell_agent (x ?x) (y ?y_col_destra_2) (content sconosciuto) (considerato true) (current no)))

    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))
=>

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UN INCROCIATORE nelle seguenti posizioni
    ; (x,y)(dove sappiamo esserci il left) - (x,y+1) (middle) – (x,y+2)(right) 
    ; e quindi faccio questa assert:
    (assert (piazzamento_incrociatore_orizzontale (x ?x) (y ?y))) ; per semplicità qui setto solamente la cella da dove partirà l'incrociatore (da sinistra)
)


(defrule gestione_caso_solo_orizzontale_conoscendo_left (declare (salience 10))

    ?f_piazzamento_orizzontale <- (piazzamento_incrociatore_orizzontale (x ?x) (y ?y_col_left))
	(status (step ?s)(currently running))
    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_piazzamento_orizzontale) ; non serve più
    
    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	;(assert (k_cell_agent (x ?x) (y ?y_col_left) (content left) (considerato false) (current yes))) ; QUI E' DOVE C'E' IL LEFT (cella(x,y) E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
    (assert (k_cell_agent (x ?x) (y (+ ?y_col_left 1)) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y+1)
    (assert (k_cell_agent (x ?x) (y (+ ?y_col_left 2)) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x,y+2)
	
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)




;; Qui sotto ci sono le regole che si preoccupano di aggiornare la struttura dati che avrà l'agente per sapere dove ha 
;; posizionato le bandierine e decrementa il numero di incrociatori da trovare rimanenti.

; Con la regola di sotto l'agente si memorizza nella sua struttura "incrociatori" sia le celle nelle quali 
; ha deciso di posizionare l'incrociatore e sia il fatto che adesso gli manca ancora da cercare "?m - 1" incrociatori. 
(defrule memorizzo_incrociatore_1 (declare (salience 3))
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato false) (current yes))
	?incrociatori <- (incrociatori (celle_con_bandierina $?lista) (mancanti ?m))
	?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    ?decremento_incrociatori <- (decremento_incrociatori (cella_incrociatore_1 false) (cella_incrociatore_2 false) (cella_incrociatore_3 false))
=>
	(modify ?incrociatori (celle_con_bandierina (insert$ $?lista (+ (length$ $?lista) 1) ?new_cella)))
	(modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
    (modify ?decremento_incrociatori (cella_incrociatore_1 true)) ; attivo la regola "decremento_incrociatori" qui sotto
    (modify ?new_cella (considerato true)) 
)
(defrule memorizzo_incrociatore_2 (declare (salience 3))
    ?new_cella <- (k_cell_agent (x ?x) (y ?y) (content left) (considerato false) (current yes)) ; il "(content left)" lo metto in qui e non sopra perchè in questo modo sono certo di entrare nella reg di memorizzazione_2 solamente dopo che sono entrato nella prima (cioè quella di sopra)
	?incrociatori <- (incrociatori (celle_con_bandierina $?lista) (mancanti ?m))
    ?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    ?decremento_incrociatori <- (decremento_incrociatori (cella_incrociatore_1 true) (cella_incrociatore_2 false) (cella_incrociatore_3 false))
=>
	(modify ?incrociatori (celle_con_bandierina (insert$ $?lista (+ (length$ $?lista) 1) ?new_cella)))
	(modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
    (modify ?decremento_incrociatori (cella_incrociatore_2 true)) ; attivo la regola "decremento_incrociatori" qui sotto
    (modify ?new_cella (considerato true)) 
)
(defrule memorizzo_incrociatore_3 (declare (salience 3))
    ?new_cella <- (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato false) (current yes))
	?incrociatori <- (incrociatori (celle_con_bandierina $?lista) (mancanti ?m))
    ?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    ?decremento_incrociatori <- (decremento_incrociatori (cella_incrociatore_1 true) (cella_incrociatore_2 true) (cella_incrociatore_3 false))
=>
	(modify ?incrociatori (celle_con_bandierina (insert$ $?lista (+ (length$ $?lista) 1) ?new_cella)))
	(modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
    (modify ?decremento_incrociatori (cella_incrociatore_3 true)) ; attivo la regola "decremento_incrociatori" qui sotto
    (modify ?new_cella (considerato true)) 
)



(defrule decremento_incrociatori (declare (salience 2))
	?decremento_incrociatori <- (decremento_incrociatori (cella_incrociatore_1 true) (cella_incrociatore_2 true) (cella_incrociatore_3 true)) ; tutti e 3 gli slot devono essere a true
    ?incrociatori <- (incrociatori (celle_con_bandierina $?lista) (mancanti ?m))
=>
	(modify ?incrociatori (mancanti (- ?m 1)))
    (retract ?decremento_incrociatori)
)