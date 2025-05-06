

(defmodule PIAZZAMENTO_INCROCIATORE_TOP (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (import GESTORE_TOP ?ALL) (export ?ALL))

; Questo modulo prova a piazzare una incrociatore solo in verticale partendo dalla cella "top" conosciuta e 
; se ci riesce allora setterà il flag di GESTORE_TOP a TRUE.
; in WM ci sarà sicuramente la cella middle fatta così: (cella_top (x ?x) (y ?y) (considerata false))


; DEFTEMPLATES:
(deftemplate piazzamento_incrociatore_verticale
    (slot x)
    (slot y)
)
;;(deftemplate celle_sotto_a_top
;;    (slot x_row_sotto_1) ; riga subito sotto al top
;;    (slot x_row_sotto_2) ; riga -2 sotto al top
;;)




; PRATICAMENTE LA REGOLA QUI SOTTO SARA' LA PRIMA CHE VERRA' ESEGUITA E si preoccuperà di settare
; tutti i valori che servono alle regole di posizionamento per scoprire se è possibile piazzare l'incrociatore 
; d'interesse o meno.
;;(defrule aggiunta_fatti_per_reg_successive (declare (salience 50))
;;    (cella_top (x ?x) (y ?y) (considerata ?c))
;;=>
;;   (assert (celle_sotto_a_top_in_gestore_top (x_row_sotto_1 (+ ?x 1)) (x_row_sotto_2 (+ ?x 2)) (x_row_sotto_3 (+ ?x 3))))
;;)



;; DA QUI PARTE IL CONTROLLO SULLA DIREZIONE VERTICALE.

(defrule posizionamento_incrociatore_in_verticale_conoscendo_top (declare (salience 26))

    ; 1) deve essere vero che posso piazzare ancora un incrociatore
    (incrociatori (celle_con_bandierina $?lista) (mancanti ?m))    
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella colonna “y” possa posizionare ALMENO 3 bandierine e quindi deve essere vero che:
    (cella_top (x ?x) (y ?y) (considerata ?c))
    (k-per-col (col ?y) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 3)) ; controllo se la differenza è maggiore o uguale a 3

    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle sotto alla cella top:
    (celle_sotto_a_top_in_gestore_top (x_row_sotto_1 ?x_row_sotto_1) (x_row_sotto_2 ?x_row_sotto_2) (x_row_sotto_3 ?x_row_sotto_3))


    ; 3) E inoltre mi devo assicurare che nella riga subito sotto al top possa mettere 
    ;    la bandierina che supporremo corrisponda al "middle" partendo dall'alto e quindi deve essere vero che:
    (k-per-row (row ?x_row_sotto_1) (num ?max_pezzi_row_sotto_1))
    (k-per-row-bandierine-posizionate (row ?x_row_sotto_1) (num ?num_b_row_row_sotto_1))
    (test (>= (- ?max_pezzi_row_sotto_1 ?num_b_row_row_sotto_1) 1))


    ; 4) E inoltre mi devo assicurare che due righe subito sotto possa mettere 
    ;    la bandierina che supporremo corrisponda il “bot” partendo dall'alto e quindi deve essere vero che:
    (k-per-row (row ?x_row_sotto_2) (num ?max_pezzi_row_sotto_2))
    (k-per-row-bandierine-posizionate (row ?x_row_sotto_2) (num ?num_b_row_sotto_2))
    (test (>= (- ?max_pezzi_row_sotto_2 ?num_b_row_sotto_2) 1))

    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?x_row_sotto_1) (y ?y) (content water)))
    (not (k-cell (x ?x_row_sotto_2) (y ?y) (content water)))

    ; verifico che nelle celle d'interesse non sia stata già posizionata una bandierina:
    (not(k_cell_agent (x ?x_row_sotto_1) (y ?y) (content sconosciuto) (considerato true) (current no)))
    (not(k_cell_agent (x ?x_row_sotto_2) (y ?y) (content sconosciuto) (considerato true) (current no)))

    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))
=>

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UN INCROCIATORE nelle seguenti posizioni
    ; (x+2,y)(bot) - (x+1,y) (primo middle) – (x,y)(dove sappiamo esserci il top) 
    ; e quindi faccio questa assert:
    (assert (piazzamento_incrociatore_verticale (x ?x_row_sotto_2) (y ?y))) ; per semplicità qui setto solamente la cella da dove partirà l'incrociatore (dal basso)
)


(defrule gestione_caso_solo_verticale_conoscendo_top (declare (salience 10))

    ?f_piazzamento_verticale <- (piazzamento_incrociatore_verticale (x ?row_bot) (y ?y))
	(status (step ?s)(currently running))
    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_piazzamento_verticale) ; non serve più
    
    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?row_bot) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x+3,y)
    (assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x+2,y)
    ;(assert (k_cell_agent (x (- ?row_bot 2)) (y ?y) (content sconosciuto) (considerato false))) ; QUI E' DOVE C'E' IL TOP (cella(x,y) E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
    
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
    ?new_cella <- (k_cell_agent (x ?x) (y ?y) (content top) (considerato false) (current yes)) ; il "(content top)" lo metto in qui e non sopra perchè in questo modo sono certo di entrare nella reg di memorizzazione_2 solamente dopo che sono entrato nella prima (cioè quella di sopra)
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
 


