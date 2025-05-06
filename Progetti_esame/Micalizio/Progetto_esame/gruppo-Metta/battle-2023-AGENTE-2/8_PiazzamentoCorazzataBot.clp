
(defmodule PIAZZAMENTO_CORAZZATA_BOT (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (import GESTORE_BOT ?ALL) (export ?ALL))

; Questo modulo prova a piazzare una corazzata solo in verticale partendo dalla cella "bot" conosciuta e 
; se ci riesce allora setterà il flag di GESTORE_BOT a TRUE.
; in WM ci sarà sicuramente la cella middle fatta così: (cella_bot (x ?x) (y ?y) (considerata false))


; DEFTEMPLATES:
(deftemplate piazzamento_corazzata_verticale
    (slot x)
    (slot y)
)
;;(deftemplate celle_sopra_a_bot
;;    (slot x_row_sopra_1) ; riga subito sopra al bot
;;    (slot x_row_sopra_2) ; riga -2 sopra al bot
;;    (slot x_row_sopra_3) ; riga -3 sopra al bot
;;)




; PRATICAMENTE LA REGOLA QUI SOTTO SARA' LA PRIMA CHE VERRA' ESEGUITA E si preoccuperà di settare
; tutti i valori che servono alle regole di posizionamento per scoprire se è possibile piazzare la corazzata 
; d'interesse o meno.
;;(defrule aggiunta_fatti_per_reg_successive (declare (salience 50))

;;    (cella_bot (x ?x) (y ?y) (considerata ?c))
;;=>
;;    (assert (celle_sopra_a_bot_in_gestore_bot (x_row_sopra_1 (- ?x 1)) (x_row_sopra_2 (- ?x 2)) (x_row_sopra_3 (- ?x 3))))
;;)



;; DA QUI PARTE IL CONTROLLO SULLA DIREZIONE VERTICALE.

(defrule posizionamento_corazzata_in_verticale_conoscendo_bot (declare (salience 26))

    ; 1) deve essere vero che posso piazzare ancora una corazzata
    (corazzata (celle_con_bandierina $?lista) (mancanti ?m))    
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella colonna “y” possa posizionare ALMENO 4 bandierine e quindi deve essere vero che:
    (cella_bot (x ?x) (y ?y) (considerata ?c))
    (k-per-col (col ?y) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 4)) ; controllo se la differenza è maggiore o uguale a 4

    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle superiorio alla cella bot:
    (celle_sopra_a_bot_in_gestore_bot (x_row_sopra_1 ?row_sopra_1) (x_row_sopra_2 ?row_sopra_2) (x_row_sopra_3 ?row_sopra_3))


    ; 3) E inoltre mi devo assicurare che nella riga subito sopra al bot possa mettere 
    ;    la bandierina che supporremo corrisponda al primo "middle" partendo dal basso e quindi deve essere vero che:
    (k-per-row (row ?row_sopra_1) (num ?max_pezzi_row_sopra_1))
    (k-per-row-bandierine-posizionate (row ?row_sopra_1) (num ?num_b_row_sopra_1))
    (test (>= (- ?max_pezzi_row_sopra_1 ?num_b_row_sopra_1) 1))


    ; 4) E inoltre mi devo assicurare che due righe subito sopra possa mettere 
    ;    la bandierina che supporremo corrisponda al secondo “middle” partendo dal basso e quindi deve essere vero che:
    (k-per-row (row ?row_sopra_2) (num ?max_pezzi_row_sopra_2))
    (k-per-row-bandierine-posizionate (row ?row_sopra_2) (num ?num_b_row_sopra_2))
    (test (>= (- ?max_pezzi_row_sopra_2 ?num_b_row_sopra_2) 1))

    ; 5) E inoltre mi devo assicurare che anche tre righe subito sopra possa mettere 
    ;    la bandierina che supporremo corrisponda al “top” e quindi deve essere vero che:
    (k-per-row (row ?row_sopra_3) (num ?max_pezzi_row_sopra_3))
    (k-per-row-bandierine-posizionate (row ?row_sopra_3) (num ?num_b_row_sopra_3))
    (test (>= (- ?max_pezzi_row_sopra_3 ?num_b_row_sopra_3) 1))


    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?row_sopra_1) (y ?y) (content water)))
    (not (k-cell (x ?row_sopra_2) (y ?y) (content water)))
    (not (k-cell (x ?row_sopra_3) (y ?y) (content water)))

    ; verifico che nelle celle d'interesse non sia stata già posizionata una bandierina:
    (not(k_cell_agent (x ?row_sopra_1) (y ?y) (content sconosciuto) (considerato true) (current no)))
    (not(k_cell_agent (x ?row_sopra_2) (y ?y) (content sconosciuto) (considerato true) (current no)))
    (not(k_cell_agent (x ?row_sopra_3) (y ?y) (content sconosciuto) (considerato true) (current no)))

    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))

=>

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UNA CORAZZATA nelle seguenti posizioni
    ; (x,y)(dove sappiamo esserci il bot) - (x-1,y) (primo middle) – (x-2,y)(altro middle) – (x-3,y)(top) 
    ; e quindi faccio questa assert:
    (assert (piazzamento_corazzata_verticale (x ?x) (y ?y))) ; per semplicità qui setto solamente la cella da dove partirà la corazzata (dal basso)
)


(defrule gestione_caso_solo_verticale_conoscendo_bot (declare (salience 10))

    ?f_piazzamento_verticale <- (piazzamento_corazzata_verticale (x ?row_bot) (y ?y))
	(status (step ?s)(currently running))
    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_piazzamento_verticale) ; non serve più
    
    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	;(assert (k_cell_agent (x ?row_bot) (y ?y) (content bot) (considerato false))) ; QUI E' DOVE C'E' IL BOT (cella(x,y) E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
    (assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x-1,y)
    (assert (k_cell_agent (x (- ?row_bot 2)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x-2,y)
    (assert (k_cell_agent (x (- ?row_bot 3)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x-3,y)
	
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)


;; Qui sotto ci sono le regole che si preoccupano di aggiornare la struttura dati che avrà l'agente per sapere dove ha 
;; posizionato le bandierine e decrementa il numero di corazzate da trovare rimanenti.


; Con la regola di sotto l'agente si memorizza nella sua struttura "corazzata" sia le celle nelle quali 
; ha deciso di posizionare la corazzata e sia il fatto che adesso gli manca ancora da cercare "?m - 1" corazzata. 
(defrule memorizzo_corazzata_1 (declare (salience 3))
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato false) (current yes))
	?corazzata <- (corazzata (celle_con_bandierina $?lista) (mancanti ?m))
	?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    ?decremento_corazzata <- (decremento_corazzate (cella_corazzata_1 false) (cella_corazzata_2 false) (cella_corazzata_3 false) (cella_corazzata_4 false))
=>
	(modify ?corazzata (celle_con_bandierina (insert$ $?lista (+ (length$ $?lista) 1) ?new_cella)))
	(modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
    (modify ?decremento_corazzata (cella_corazzata_1 true)) ; attivo la regola "decremento_corazzata" qui sotto
    (modify ?new_cella (considerato true)) 
)
(defrule memorizzo_corazzata_2 (declare (salience 3))
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content bot) (considerato false) (current yes)) ; il "(content bot)" lo metto in qui e non sopra perchè in questo modo sono certo di entrare nella reg di memorizzazione_2 solamente dopo che sono entrato nella prima (cioè quella di sopra)
	?corazzata <- (corazzata (celle_con_bandierina $?lista) (mancanti ?m))
	?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    ?decremento_corazzata <- (decremento_corazzate (cella_corazzata_1 true) (cella_corazzata_2 false) (cella_corazzata_3 false) (cella_corazzata_4 false))
=>
	(modify ?corazzata (celle_con_bandierina (insert$ $?lista (+ (length$ $?lista) 1) ?new_cella)))
	(modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
    (modify ?decremento_corazzata (cella_corazzata_2 true)) ; attivo la regola "decremento_corazzata" qui sotto
    (modify ?new_cella (considerato true))
)
(defrule memorizzo_corazzata_3 (declare (salience 3))
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato false) (current yes))
	?corazzata <- (corazzata (celle_con_bandierina $?lista) (mancanti ?m))
	?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    ?decremento_corazzata <- (decremento_corazzate (cella_corazzata_1 true) (cella_corazzata_2 true) (cella_corazzata_3 false) (cella_corazzata_4 false))
=>
	(modify ?corazzata (celle_con_bandierina (insert$ $?lista (+ (length$ $?lista) 1) ?new_cella)))
	(modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
    (modify ?decremento_corazzata (cella_corazzata_3 true)) ; attivo la regola "decremento_corazzata" qui sotto
    (modify ?new_cella (considerato true))
)
(defrule memorizzo_corazzata_4 (declare (salience 3))
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato false) (current yes))
	?corazzata <- (corazzata (celle_con_bandierina $?lista) (mancanti ?m))
	?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    ?decremento_corazzata <- (decremento_corazzate (cella_corazzata_1 true) (cella_corazzata_2 true) (cella_corazzata_3 true) (cella_corazzata_4 false))
=>
	(modify ?corazzata (celle_con_bandierina (insert$ $?lista (+ (length$ $?lista) 1) ?new_cella)))
	(modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
    (modify ?decremento_corazzata (cella_corazzata_4 true)) ; attivo la regola "decremento_corazzata" qui sotto
    (modify ?new_cella (considerato true))
)


(defrule decremento_corazzata (declare (salience 2))
	?decremento_corazzata <- (decremento_corazzate (cella_corazzata_1 true) (cella_corazzata_2 true) (cella_corazzata_3 true) (cella_corazzata_4 true)) ; tutti e 3 gli slot devono essere a true
    ?corazzata <- (corazzata (celle_con_bandierina $?lista) (mancanti ?m))
=>
	(modify ?corazzata (mancanti (- ?m 1)))
    (retract ?decremento_corazzata)
)


;; aggiunta.. (la regola di sotto deve essere inserita nel modulo di ogni nave anche 
;; per gli altri casi)
;; CON LA REGOLA DI SOTTO ritratto il fatto di tipo "celle_sopra_a_bot"
;; perchè tanto adesso non mi serve più e se non lo tolgo avrò problemi successivamente:
;;(defrule cancello_celle_sopra_a_bot_ormai_inutili(declare (salience 1))

;;    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento true))
;;    ?celle_sopra_a_bot <- (celle_sopra_a_bot (x_row_sopra_1 ?x_row_sopra_1) 
;;                                             (x_row_sopra_2 ?x_row_sopra_2) 
;;                                             (x_row_sopra_3 ?x_row_sopra_3))

;;=>  
    ;; verrà fatta solo se è stata piazzata la nave corrente grazie a "(nave_piazzata_gestore (piazzamento true))"
    ;; richiesto nell'antecedente di questa regola!
;;    (retract ?celle_sopra_a_bot)
;;)