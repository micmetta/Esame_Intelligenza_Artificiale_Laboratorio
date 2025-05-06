

; Importa dai moduli MAIN e ENV tutto ciò che è importabile.
(defmodule PIAZZAMENTO_SOTTOMARINO_SU_WATER (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (import GESTORE_SU_WATER ?ALL) (export ?ALL))



;; Sappiamo che nella cella subito a destra rispetto alla cella_max c'è water e quindi l'unico modo per cercare
;; di piazzare un sottomarino partendo dalla cella_max (DOVE SONO CERTO DI POTER POSIZIONARE UNA BANDIERINA ma NON SO NULLA SU cosa ci sia al suo 
;; interno) è quella di metterlo solo nella seguente posizione:

;; 1-ESATTAMENTE IN cella_max(x,y)


(deftemplate piazzamento_sottomarino
    (slot x)
    (slot y)
)


;; DA QUI PARTE IL CONTROLLO SU FATTO DI POTER PIAZZARE O MENO UN SOTTOMARINO:

(defrule posizionamento_sottomarino (declare (salience 26))

    ; 1) deve essere vero che posso piazzare ancora una sottomarino
    (sottomarini (celle_con_bandierina $?lista) (mancanti ?m))
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella riga “x” possa posizionare ALMENO 1 bandierina e quindi deve essere vero che:
    (cella_max (x ?x) (y ?y) (direzione su))

    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 1)) ; controllo se la differenza è maggiore o uguale a 1 (perchè devo considerare proprio la bandierina per la cella_max che ancora non ho messo)

    
    ; VERIFICO CHE NELLA CELLA IN CUI STO CERCANDO DI PIAZZARE IL SOTTOMARINO
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?x) (y ?y) (content water)))

    ; verifico che in tutte le celle dove posizionerò la nave l'agente non abbia già posizionato
    ; una bandierina:
    (not (k_cell_agent (x ?x) (y ?y) (content ?content) (considerato true) (current no)))
    
    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))
=>

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UN SOTTOMARINO NELLA CELLA (x,y) corrente
    (assert (piazzamento_sottomarino (x ?x) (y ?y)))
)


(defrule vince_il_sottomarino (declare (salience 10))

    ?f_piazzamento_sottomarino <- (piazzamento_sottomarino (x ?x) (y ?y))
	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?x) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione
    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_piazzamento_sottomarino) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x,y)
    
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)



;; Qui sotto ci sono le regole che si preoccupano di aggiornare la struttura dati che avrà l'agente per sapere dove ha 
;; posizionato le bandierine e decrementa il numero di sottomarini da trovare rimanenti.

; Con la regola di sotto l'agente si memorizza nella sua struttura "sottomarino" sia la cella nella quale 
; ha deciso di posizionare il sottomarino e sia il fatto che adesso gli manca ancora da cercare "?m - 1" sottomarin. 
(defrule memorizzo_sottomarino_1 (declare (salience 3))
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato false) (current yes))
	?sottomarino <- (sottomarini (celle_con_bandierina $?lista) (mancanti ?m))
	?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    ?decremento_sottomarino <- (decremento_sottomarini (cella_sottomarino false))
=>
	(modify ?sottomarino (celle_con_bandierina (insert$ $?lista (+ (length$ $?lista) 1) ?new_cella)))
	(modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
    (modify ?decremento_sottomarino (cella_sottomarino true)) ; attivo la regola "decremento_sottomarino" qui sotto
    (modify ?new_cella (considerato true)) 
)


(defrule decremento_sottomarino (declare (salience 2))
	?decremento_sottomarino <- (decremento_sottomarini (cella_sottomarino true))
    ?sottomarino <- (sottomarini (celle_con_bandierina $?lista) (mancanti ?m))
=>
	(modify ?sottomarino (mancanti (- ?m 1)))
    (retract ?decremento_sottomarino)
)

