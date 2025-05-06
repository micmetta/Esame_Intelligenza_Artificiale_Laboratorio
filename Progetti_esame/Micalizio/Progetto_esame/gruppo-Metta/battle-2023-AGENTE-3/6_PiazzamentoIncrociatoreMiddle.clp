
(defmodule PIAZZAMENTO_INCROCIATORE_MIDDLE (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (import GESTORE_MIDDLE ?ALL) (export ?ALL))

; Questo modulo prova a piazzare una incrociatore in qualsiasi direzione e 
; se ci riesce allora setterà il flag di GESTORE_MIDDLE a TRUE.
; in WM ci sarà sicuramente la cella middle fatta così: (cella_middle (x ?x) (y ?y) (considerata false))


; DEFTEMPLATES:
(deftemplate piazzamento_incrociatore_orizzontale
    (slot x)
    (slot y)
)
(deftemplate piazzamento_incrociatore_verticale
    (slot x)
    (slot y)
)
(deftemplate scores
    (slot orizzontale)
    (slot verticale)
)
(deftemplate celle_adiacenti_a_middle 
    (slot x_row_sopra) ; riga subito sopra al middle
    (slot x_row_sotto) ; riga subito sotto al middle
    (slot y_col_sinistra) ; colonna subito a sinistra del middle
    (slot y_col_destra) ; colonna subito a destra del middle
)
(deftemplate celle_incrociatore_orizzontale
    (slot y_col_left) 
    (slot y_col_middle_1) 
    (slot y_col_right)
)
(deftemplate celle_incrociatore_verticale
    (slot x_row_bot) 
    (slot x_row_middle_1) 
    (slot x_row_top) 
)





; PRATICAMENTE LA REGOLA QUI SOTTO SARA' LA PRIMA CHE VERRA' ESEGUITA E si preoccuperà di settare
; tutti i valori che servono alle regole di posizionamento per scoprire se è possibile piazzare l'incrociatore 
; d'interesse o meno.
(defrule aggiunta_fatti_per_reg_successive (declare (salience 50))
    (cella_middle (x ?x) (y ?y) (considerata ?c))
=>
    (assert (celle_adiacenti_a_middle (x_row_sopra (- ?x 1)) (x_row_sotto (+ ?x 1)) (y_col_sinistra (- ?y 1)) (y_col_destra (+ ?y 1))))
)


; per gestire il caso orizzontale dell'incrociatore basta quest'unica regola
(defrule posizionamento_incrociatore_in_orizzontale (declare (salience 30))

    ; 1) deve essere vero che posso piazzare ancora un incrociatore
    (incrociatori (celle_con_bandierina $?lista) (mancanti ?m))    
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella riga “x” possa posizionare ALMENO 3 bandierine e quindi deve essere vero che:
    (cella_middle (x ?x) (y ?y) (considerata ?c))
    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 3)) ; controllo se la differenza è maggiore o uguale a 3

    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle adiacenti alla cella middle:
    (celle_adiacenti_a_middle (x_row_sopra ?row_sopra) (x_row_sotto ?row_sotto) (y_col_sinistra ?col_sinistra) (y_col_destra ?col_destra))

    ; 3) E inoltre mi devo assicurare che nella colonna subito a sinistra possa mettere 
    ;    la bandierina che supporremo corrisponda al "left" e quindi deve essere vero che:
    (k-per-col (col ?col_sinistra) (num ?max_pezzi_col_sx))
    (k-per-col-bandierine-posizionate (col ?col_sinistra) (num ?num_b_col_sx))
    (test (>= (- ?max_pezzi_col_sx ?num_b_col_sx) 1))

    ; 4) E inoltre mi devo assicurare che anche due colonne subito a destra possa mettere 
    ;    la bandierina che supporremo corrisponda il “right” e quindi deve essere vero che:
    (k-per-col (col ?col_destra) (num ?max_pezzi_col_dx_2))
    (k-per-col-bandierine-posizionate (col ?col_destra) (num ?num_b_col_dx_2))
    (test (>= (- ?max_pezzi_col_dx_2 ?num_b_col_dx_2) 1))


    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?x) (y ?col_sinistra) (content water)))
    (not (k-cell (x ?x) (y ?col_destra) (content water)))

    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))

=>  

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UN INCROCIATORE nelle seguenti posizioni
    ; (x,y-1)(left) - (x,y) (dove sappiamo esserci il middle) – (x,y+1)(right)
    ; e quindi faccio questa assert:
    (assert (piazzamento_incrociatore_orizzontale (x ?x) (y ?col_sinistra))) ; per semplicità qui setto solamente la cella da dove partirà l'incrociatore (da sinistra)
)




; per gestire il caso verticale dell'incrociatore basta quest'unica regola
(defrule posizionamento_incrociatore_in_verticale (declare (salience 30))

    ; 1) deve essere vero che posso piazzare ancora un incrociatore
    (incrociatori (celle_con_bandierina $?lista) (mancanti ?m))    
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella colonna “y” possa posizionare ALMENO 3 bandierine e quindi deve essere vero che:
    (cella_middle (x ?x) (y ?y) (considerata ?c))
    (k-per-col (col ?y) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 3)) ; controllo se la differenza è maggiore o uguale a 3

    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle adiacenti alla cella middle:
    (celle_adiacenti_a_middle (x_row_sopra ?row_sopra) (x_row_sotto ?row_sotto) (y_col_sinistra ?col_sinistra) (y_col_destra ?col_destra))
    
    ; 3) E inoltre mi devo assicurare che nella riga subito sotto possa mettere 
    ;    la bandierina che supporremo corrisponda al "bot" e quindi deve essere vero che:
    (k-per-row (row ?row_sotto) (num ?max_pezzi_row_sotto))
    (k-per-row-bandierine-posizionate (row ?row_sotto) (num ?num_b_row_sotto))
    (test (>= (- ?max_pezzi_row_sotto ?num_b_row_sotto) 1) )

    ; 4) E inoltre mi devo assicurare che nella riga subito sopra possa mettere 
    ;    la bandierina che supporremo corrisponda al secondo “top” e quindi deve essere vero che:
    (k-per-row (row ?row_sopra) (num ?max_pezzi_row_sopra))
    (k-per-row-bandierine-posizionate (row ?row_sopra) (num ?num_b_row_sopra))
    (test (>= (- ?max_pezzi_row_sopra ?num_b_row_sopra) 1) )


    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?row_sotto) (y ?y) (content water)))
    (not (k-cell (x ?row_sopra) (y ?y) (content water)))

    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))
=>

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UN INCROCIATORE nelle seguenti posizioni
    ; (x-1,y)(bot) - (x,y) (dove sappiamo esserci il middle) – (x+1,y)(top)
    ; e quindi faccio questa assert:
    
    (assert (piazzamento_incrociatore_verticale (x ?row_sotto) (y ?y))) ; per semplicità qui setto solamente la cella da dove partirà l'incrociatore (dal basso)
    
    ;(printout t "Il valore della variabile è m: " ?m crlf)
    ;(printout t "Questa è una semplice regola che stampa un messaggio." crlf)


)




;; QUI SOTTO PARTONO LE REGOLE CHE GESTISCONO UN POSSIBILE CONFLITTO TRA LA DIREZIONE VERTICALE E ORIZZONTALE

; Qui sotto ci sono le regole che si preoccupano di gestire eventuali conflitti.
; -	Le regole di sotto gestiranno UN CONFLITTO CHE SI VERIFICA QUANDO POSSIAMO PIAZZARE UNA incrociatore 
;   SIA IN ORIZZONTALE CHE IN VERTICALE E QUINDI VUOL DIRE CHE ABBIAMO IN WM QUESTI DUE FATTI:
;   -	(piazzamento_incrociatore_verticale (cella(x,y))”  
;   -   (piazzamento_incrociatore_verticale (cella(x,y))”
;   dove però le due celle saranno sicuramente differenti per costruzione.
; - Per eliminare questa ambiguità, questo agente non esegue la fire ma procede con il calcolo dello score lungo le due direzioni,
;   in questo modo, quella che avrà lo score maggiore sarà la direzione lungo la quale verrà davvero
;   posizionato l'incrociatore (Questo agente PREFERSCE CONSERVARE TUTTE LE FIREs per la fase 3)


(defrule aggiunta_fatti_per_gestione_conflitti_verticale_e_orizzontale (declare (salience 22))
    (piazzamento_incrociatore_orizzontale (x ?x) (y ?col_left))
    (piazzamento_incrociatore_verticale (x ?row_bot) (y ?y))
=>  

    (assert (celle_incrociatore_orizzontale (y_col_left ?col_left) (y_col_middle_1 (+ ?col_left 1)) (y_col_right (+ ?col_left 3))))
    (assert (celle_incrociatore_verticale (x_row_bot ?row_bot) (x_row_middle_1 (+ ?row_bot 1)) (x_row_top (+ ?row_bot 3))))
)


(defrule calcolo_score (declare (salience 21))
    ; la presenza di questi due fatti in WM mi garantiscono che c'è il conflitto da risolvere:
    (piazzamento_incrociatore_orizzontale (x ?x) (y ?col_left))
    (piazzamento_incrociatore_verticale (x ?row_bot) (y ?y))

    ; calcolo tutti i termini che mi permetteranno di calcolare lo score finale per la direzione ORIZZONTALE:
    ; (k-per-row (row 0) (num 2))
    ; (k-per-row-bandierine-posizionate (row 0) (num 0))
    ?celle_incrociatore_orizzontale <- (celle_incrociatore_orizzontale (y_col_left ?col_left) (y_col_middle_1 ?col_middle1) (y_col_right ?col_right))

    ?v1_col_left <- (k-per-col (col ?col_left) (num ?max_pezzi_col_left))
    ?v2_col_left <- (k-per-col-bandierine-posizionate (col ?col_left) (num ?num_b_col_left))

    ?v1_col_middle1 <- (k-per-col (col ?col_middle1) (num ?max_pezzi_col_middle1))
    ?v2_col_middle1 <- (k-per-col-bandierine-posizionate (col ?col_middle1) (num ?num_b_col_middle1))

    ?v1_col_right <- (k-per-col (col ?col_right) (num ?max_pezzi_col_right))
    ?v2_col_right <- (k-per-col-bandierine-posizionate (col ?col_right) (num ?num_b_col_right))


    ; calcolo tutti i termini che mi permetteranno di calcolare lo score finale per la direzione VERTICALE:
    ?celle_incrociatore_verticale <- (celle_incrociatore_verticale (x_row_bot ?row_bot) (x_row_middle_1 ?row_middle1) (x_row_top ?row_right))

    ?v1_row_bot <- (k-per-row (row ?row_bot) (num ?max_pezzi_row_bot))
    ?v2_row_bot <- (k-per-row-bandierine-posizionate (row ?row_bot) (num ?num_b_row_bot))

    ?v1_row_middle1 <- (k-per-row (row ?row_middle1) (num ?max_pezzi_row_middle1))
    ?v2_row_middle1 <- (k-per-row-bandierine-posizionate (row ?row_middle1) (num ?num_b_row_middle1))

    ?v1_row_right <- (k-per-row (row ?row_right) (num ?max_pezzi_row_right))
    ?v2_row_right <- (k-per-row-bandierine-posizionate (row ?row_right) (num ?num_b_row_right))

=>
    (bind ?diff_col_left (- ?max_pezzi_col_left ?num_b_col_left))
    (bind ?diff_col_middle1 (- ?max_pezzi_col_middle1 ?num_b_col_middle1))
    (bind ?diff_col_right (- ?max_pezzi_col_right ?num_b_col_right))
    (bind ?score_orizzontale (+ ?diff_col_left ?diff_col_middle1 ?diff_col_right)) ; questo sarà lo score orizzontale

    (bind ?diff_row_bot (- ?max_pezzi_row_bot ?num_b_row_bot))
    (bind ?diff_row_middle1 (- ?max_pezzi_row_middle1 ?num_b_row_middle1))
    (bind ?diff_row_right (- ?max_pezzi_row_right ?num_b_row_right))
    (bind ?score_verticale (+ ?diff_row_bot ?diff_row_middle1 ?diff_row_right)) ; questo sarà lo score verticale

    ; Asserisco i due scores (in modo tale che una delle due regole qui sotto scatterà in base a chi ha vinto):
    (assert (scores (orizzontale ?score_orizzontale) (verticale ?score_verticale)))
)


(defrule vince_orizzontale (declare (salience 10))

    ?f_scores <- (scores (orizzontale ?score_orizzontale) (verticale ?score_verticale))
    (test (>= ?score_orizzontale ?score_verticale))
    
    ?f_piazzamento_orizzontale <- (piazzamento_incrociatore_orizzontale (x ?x) (y ?col_sinistra))
    ?f_piazzamento_verticale <- (piazzamento_incrociatore_verticale (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?x) (y ?col_sinistra))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))
=>

    (retract ?f_scores) ; in questo modo la regola di sotto non scatterà
    (retract ?f_piazzamento_orizzontale) ; non serve più
    (retract ?f_piazzamento_verticale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?x) (y ?col_sinistra) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(?x,y)
    ;(assert (k_cell_agent (x ?x) (y (+ ?col_sinistra 1)) (content middle) (considerato false))) ; QUI E' DOVE C'E' IL MIDDLE E QUINDI LA BANDIERINA L'HO GIA' MESSA DURANTE LA FASE 1
    (assert (k_cell_agent (x ?x) (y (+ ?col_sinistra 2)) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(?x,y+2)
	
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)   


(defrule vince_verticale (declare (salience 10))

    ?f_scores <-(scores (orizzontale ?score_orizzontale) (verticale ?score_verticale))

    (test (< ?score_orizzontale ?score_verticale))

    ?f_piazzamento_orizzontale <- (piazzamento_incrociatore_orizzontale (x ?x) (y ?col_sinistra))
    ?f_piazzamento_verticale <- (piazzamento_incrociatore_verticale (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?row_bot) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))
=>
    (retract ?f_scores) ; non serve più
    (retract ?f_piazzamento_orizzontale) ; non serve più
    (retract ?f_piazzamento_verticale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?row_bot) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(?x,y)
    ;(assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content middle) (considerato false))) ; QUI E' DOVE C'E' IL MIDDLE E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
    (assert (k_cell_agent (x (- ?row_bot 2)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(?x+1,y)
    
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)  


(defrule vince_orizzontale_senza_conflitto (declare (salience 5))

    ?f_piazzamento_orizzontale <- (piazzamento_incrociatore_orizzontale (x ?x) (y ?col_sinistra))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?x) (y ?col_sinistra))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))
=>

    (retract ?f_piazzamento_orizzontale) ; non serve più
    
    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?x) (y ?col_sinistra) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(?x,y)
    ;(assert (k_cell_agent (x ?x) (y (+ ?col_sinistra 1)) (content middle) (considerato false))) ; QUI E' DOVE C'E' IL MIDDLE E QUINDI LA BANDIERINA L'HO GIA' MESSA DURANTE LA FASE 1
    (assert (k_cell_agent (x ?x) (y (+ ?col_sinistra 2)) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(?x,y+2)
    
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)


(defrule vince_verticale_senza_conflitto (declare (salience 5))

    ?f_piazzamento_verticale <- (piazzamento_incrociatore_verticale (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?row_bot) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))
=>

    (retract ?f_piazzamento_verticale) ; non serve più
	
    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione dell'incrociato presente sotto
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?row_bot) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(?x,y)
    ;(assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content middle) (considerato false))) ; QUI E' DOVE C'E' IL MIDDLE E QUINDI LA BANDIERINA L'HO GIA' MESSA DURANTE LA FASE 1
    (assert (k_cell_agent (x (- ?row_bot 2)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(?x+1,y)
    
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
    ?new_cella <- (k_cell_agent (x ?x) (y ?y) (content middle) (considerato false) (current yes))
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


