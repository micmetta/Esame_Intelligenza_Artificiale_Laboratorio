
(defmodule PIAZZAMENTO_CORAZZATA_MIDDLE (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (import GESTORE_MIDDLE ?ALL) (export ?ALL))

; Questo modulo prova a piazzare una corazzata in qualsiasi direzione e 
; se ci riesce allora setterà il flag di GESTORE_MIDDLE a TRUE.
; in WM ci sarà sicuramente la cella middle fatta così: (cella_middle (x ?x) (y ?y) (considerata false))


; DEFTEMPLATES:
(deftemplate piazzamento_corazzata_orizzontale_left_subito_a_sinistra
    (slot x)
    (slot y)
)
(deftemplate piazzamento_corazzata_orizzontale_right_subito_a_destra
    (slot x)
    (slot y)
)
(deftemplate piazzamento_corazzata_orizzontale ; mi serve per capire chi ha vinto tra i due di sopra (qualora ci fosse un conflitto in orizzontale)
    (slot x)
    (slot y)
)
(deftemplate piazzamento_corazzata_verticale_bot_subito_sotto
    (slot x)
    (slot y)
)
(deftemplate piazzamento_corazzata_verticale_top_subito_sopra
    (slot x)
    (slot y)
)
(deftemplate piazzamento_corazzata_verticale
    (slot x)
    (slot y)
)
(deftemplate scores_conflitto_orizzontale
    (slot orizzontale_caso1)
    (slot orizzontale_caso2)
)
(deftemplate scores_conflitto_verticale
    (slot verticale_caso1)
    (slot verticale_caso2)
)
(deftemplate scores
    (slot orizzontale)
    (slot verticale)
)
(deftemplate celle_adiacenti_a_middle 
    (slot x_row_sopra_1) ; riga subito sopra al middle
    (slot x_row_sopra_2) ; riga -2 sopra al middle
    (slot x_row_sotto_1) ; riga subito sotto al middle
    (slot x_row_sotto_2) ; riga +2 sotto al middle
    (slot y_col_sinistra_1) ; colonna subito a sinistra del middle
    (slot y_col_sinistra_2) ; colonna -2 a sinistra del middle
    (slot y_col_destra_1) ; colonna subito a destra del middle
    (slot y_col_destra_2) ; colonna +2 a destra del middle
)
(deftemplate celle_corazzata_caso1_orizzontale
    (slot y_col_left) 
    (slot y_col_middle_1) 
    (slot y_col_middle_2) 
    (slot y_col_right)
)
(deftemplate celle_corazzata_caso2_orizzontale
    (slot y_col_left) 
    (slot y_col_middle_1) 
    (slot y_col_middle_2) 
    (slot y_col_right) 
)
(deftemplate celle_corazzata_caso1_verticale
    (slot x_row_bot) 
    (slot x_row_middle_1) 
    (slot x_row_middle_2) 
    (slot x_row_top) 
)
(deftemplate celle_corazzata_caso2_verticale
    (slot x_row_bot) 
    (slot x_row_middle_1) 
    (slot x_row_middle_2) 
    (slot x_row_top) 
)
(deftemplate celle_corazzata_orizzontale
    (slot y_col_left) 
    (slot y_col_middle_1) 
    (slot y_col_middle_2)
    (slot y_col_right)
)
(deftemplate celle_corazzata_verticale
    (slot x_row_bot) 
    (slot x_row_middle_1) 
    (slot x_row_middle_2) 
    (slot x_row_top) 
)

; QUESTI SONO I FATTI INIZIALI:
;(deffacts fatti_iniziali
;	(nave_piazzata (piazzamento false)) ; settato a false all'inizio
;)

; PRATICAMENTE LA REGOLA QUI SOTTO SARA' LA PRIMA CHE VERRA' ESEGUITA E si preoccuperà di settare
; tutti i valori che servono alle regole di posizionamento per scoprire se è possibile piazzare la corazzata 
; d'interesse o meno.
(defrule aggiunta_fatti_per_reg_successive (declare (salience 50))
    (cella_middle (x ?x) (y ?y) (considerata true))
=>
    (assert (celle_adiacenti_a_middle (x_row_sopra_1 (- ?x 1)) (x_row_sopra_2 (- ?x 2)) (x_row_sotto_1 (+ ?x 1)) (x_row_sotto_2 (+ ?x 2)) (y_col_sinistra_1 (- ?y 1)) (y_col_sinistra_2 (- ?y 2)) (y_col_destra_1 (+ ?y 1)) (y_col_destra_2 (+ ?y 2))))
)


;; DA QUI PARTE IL CONTROLLO SULLA DIREZIONE ORIZZONTALE.

(defrule posizionamento_corazzata_in_orizzontale_left_subito_a_sinistra (declare (salience 30))

    ; 1) deve essere vero che posso piazzare ancora una corazzata
    (corazzata (celle_con_bandierina) (mancanti ?m))    
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella riga “x” possa posizionare ALMENO 4 bandierine e quindi deve essere vero che:
    (cella_middle (x ?x) (y ?y) (considerata ?c))
    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 4)) ; controllo se la differenza è maggiore o uguale a 4


    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle adiacenti alla cella middle:
    (celle_adiacenti_a_middle (x_row_sopra_1 ?row_sopra) (x_row_sopra_2 ?row_sopra_2) 
                              (x_row_sotto_1 ?row_sotto) (x_row_sotto_2 ?row_sotto_2) 
                              (y_col_sinistra_1 ?col_sinistra) (y_col_sinistra_2 ?col_sinistra_2) 
                              (y_col_destra_1 ?col_destra) (y_col_destra_2 ?col_destra_2))


    ; 3) E inoltre mi devo assicurare che nella colonna subito a sinistra possa mettere 
    ;    la bandierina che supporremo corrisponda al "left" e quindi deve essere vero che:
    (k-per-col (col ?col_sinistra) (num ?max_pezzi_col_sx))
    (k-per-col-bandierine-posizionate (col ?col_sinistra) (num ?num_b_col_sx))
    (test (>= (- ?max_pezzi_col_sx ?num_b_col_sx) 1))

    ; 4) E inoltre mi devo assicurare che nella colonna subito a destra possa mettere 
    ;    la bandierina che supporremo corrisponda al secondo “middle” e quindi deve essere vero che:
    (k-per-col (col ?col_destra) (num ?max_pezzi_col_dx))
    (k-per-col-bandierine-posizionate (col ?col_destra) (num ?num_b_col_dx))
    (test (>= (- ?max_pezzi_col_dx ?num_b_col_dx) 1))

    ; 5) E inoltre mi devo assicurare che anche due colonne subito a destra possa mettere 
    ;    la bandierina che supporremo corrisponda il “right” e quindi deve essere vero che:
    (k-per-col (col ?col_destra_2) (num ?max_pezzi_col_dx_2))
    (k-per-col-bandierine-posizionate (col ?col_destra_2) (num ?num_b_col_dx_2))
    (test (>= (- ?max_pezzi_col_dx_2 ?num_b_col_dx_2) 1))

    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?x) (y ?col_sinistra) (content water)))
    (not (k-cell (x ?x) (y ?col_destra) (content water)))
    (not (k-cell (x ?x) (y ?col_destra_2) (content water)))

    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))
=>

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UNA CORAZZATA nelle seguenti posizioni
    ; (x,y-1)(left) - (x,y) (dove sappiamo esserci il middle) – (x,y+1)(altro middle) – (x,y+2)(right) 
    ; e quindi faccio questa assert:
    (assert (piazzamento_corazzata_orizzontale_left_subito_a_sinistra (x ?x) (y ?col_sinistra))) ; per semplicità qui setto solamente la cella da dove partirà la corazzata (da sinistra)
)


(defrule posizionamento_corazzata_in_orizzontale_right_subito_a_destra (declare (salience 30))

    ; 1) deve essere vero che posso piazzare ancora una corazzata
    (corazzata (celle_con_bandierina) (mancanti ?m))    
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella riga “x” possa posizionare ALMENO 4 bandierine e quindi deve essere vero che:
    (cella_middle (x ?x) (y ?y) (considerata ?c))
    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 4)) ; controllo se la differenza è maggiore o uguale a 4

    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle adiacenti alla cella middle:
    (celle_adiacenti_a_middle (x_row_sopra_1 ?row_sopra) (x_row_sopra_2 ?row_sopra_2) 
                              (x_row_sotto_1 ?row_sotto) (x_row_sotto_2 ?row_sotto_2) 
                              (y_col_sinistra_1 ?col_sinistra) (y_col_sinistra_2 ?col_sinistra_2) 
                              (y_col_destra_1 ?col_destra) (y_col_destra_2 ?col_destra_2))


    ; 3) E inoltre mi devo assicurare che nella colonna subito a destra possa mettere 
    ;    la bandierina che supporremo corrisponda al "right" e quindi deve essere vero che:
    (k-per-col (col ?col_destra) (num ?max_pezzi_col_dx))
    (k-per-col-bandierine-posizionate (col ?col_destra) (num ?num_b_col_dx))
    (test (>= (- ?max_pezzi_col_dx ?num_b_col_dx) 1))


    ; 4) E inoltre mi devo assicurare che nella colonna subito a sinistra possa mettere 
    ;    la bandierina che supporremo corrisponda al secondo “middle” e quindi deve essere vero che:
    (k-per-col (col ?col_sinistra) (num ?max_pezzi_col_sx))
    (k-per-col-bandierine-posizionate (col ?col_sinistra) (num ?num_b_col_sx))
    (test (>= (- ?max_pezzi_col_sx ?num_b_col_sx) 1))

    ; 5) E inoltre mi devo assicurare che anche due colonne subito a sinistra possa mettere 
    ;    la bandierina che supporremo corrisponda il left e quindi deve essere vero che:
    (k-per-col (col ?col_sinistra_2) (num ?max_pezzi_col_sx_2))
    (k-per-col-bandierine-posizionate (col ?col_sinistra_2) (num ?num_b_col_sx_2))
    (test (>= (- ?max_pezzi_col_sx_2 ?num_b_col_sx_2) 1))


    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?x) (y ?col_destra) (content water)))
    (not (k-cell (x ?x) (y ?col_sinistra) (content water)))
    (not (k-cell (x ?x) (y ?col_sinistra_2) (content water)))

    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))
=>

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UNA CORAZZATA nelle seguenti posizioni
    ; (x,y-2)(left) - (x,y-1)(altro middle)  – (x,y)(dove sappiamo esserci il middle) – (x,y+1)(right) 
    ; e quindi faccio questa assert:
    (assert (piazzamento_corazzata_orizzontale_right_subito_a_destra (x ?x) (y ?col_sinistra_2))) ; per semplicità qui setto solamente la cella da dove partirà la corazzata (da sinistra)
)


;; QUI PARTONO LE REGOLE CHE GESTISCONO UN POSSIBILE CONFLITTO SOLO PER LA DIREZIONE ORIZZONTALE

;; GESTISCO UN EVENTUALE CONFLITTO LUNGO LA DIREZIONE ORIZZONTALE, un conflitto di questo tipo
;; lo avremo quando saranno presenti in WM questi due fatti:
;; fact1 -> (piazzamento_corazzata_orizzontale (cella(x,y-1))
;; fact2 -> (piazzamento_corazzata_orizzontale (cella(x,y-2))
;; E QUINDI IN BASE ALLO SCORE MI CONSERVERO’ IN WM SOLAMENTE UNO DEI DUE FATTI 
;; - IN QUESTO CASO LA FIRE NON PUO’ ESSERE FATTA PERCHE’ LE DUE CELLE NON SONO IDENTICHE !

(defrule aggiunta_fatti_per_gestione_conflitti_solo_orizzontale_1 (declare (salience 29))

    (piazzamento_corazzata_orizzontale_left_subito_a_sinistra (x ?x) (y ?col_left_caso1))
    (piazzamento_corazzata_orizzontale_right_subito_a_destra (x ?x) (y ?col_left_caso2))
    (test (neq ?col_left_caso1 ?col_left_caso2)) ; verifico che che ?col_left_caso1 e ?col_left_caso2 sono diversi (sicuramente saranno diversi il controllo lo lascio per maggiore leggibilità)
=>  

    (assert (celle_corazzata_caso1_orizzontale (y_col_left ?col_left_caso1) (y_col_middle_1 (+ ?col_left_caso1 1)) (y_col_middle_2 (+ ?col_left_caso1 2)) (y_col_right (+ ?col_left_caso1 3))))
    (assert (celle_corazzata_caso2_orizzontale (y_col_left ?col_left_caso2) (y_col_middle_1 (+ ?col_left_caso2 1)) (y_col_middle_2 (+ ?col_left_caso2 2)) (y_col_right (+ ?col_left_caso2 3))))
)


(defrule gestione_conflitto_solo_orizzontale (declare (salience 28))

    ; 1) devono essere veri questi fatti in WM
    (piazzamento_corazzata_orizzontale_left_subito_a_sinistra (x ?x) (y ?col_left_caso1))
    (piazzamento_corazzata_orizzontale_right_subito_a_destra (x ?x) (y ?col_left_caso2))

    ; 2) Devo verificare che che ?col_sinistra_caso1 e ?col_sinistra_caso2 sono diversi
    (test (neq ?col_left_caso1 ?col_left_caso2))

    ; 3) Calcolo lo score delle due direzioni in base alla loro cella di partenza:

    ; Calcolo score direzione caso 1:
    ?celle_corazzata_caso1 <- (celle_corazzata_caso1_orizzontale (y_col_left ?col_left_caso1) (y_col_middle_1 ?col_middle1_caso1) (y_col_middle_2 ?col_middle2_caso1) (y_col_right ?col_right_caso1))

    ?v1_col_left_caso1 <- (k-per-col (col ?col_left_caso1) (num ?max_pezzi_col_left_caso1)) ; va bene nell'antecedente
    ?v2_col_left_caso1 <- (k-per-col-bandierine-posizionate (col ?col_left_caso1) (num ?num_b_col_left_caso1)) ; va bene nell'antecedente

    ?v1_col_middle1_caso1 <- (k-per-col (col ?col_middle1_caso1) (num ?max_pezzi_col_middle1_caso1))
    ?v2_col_middle1_caso1 <- (k-per-col-bandierine-posizionate (col ?col_middle1_caso1) (num ?num_b_col_middle1_caso1))

    ?v1_col_middle2_caso1 <- (k-per-col (col ?col_middle2_caso1) (num ?max_pezzi_col_middle2_caso1))
    ?v2_col_middle2_caso1 <- (k-per-col-bandierine-posizionate (col ?col_middle2_caso1) (num ?num_b_col_middle2_caso1))

    ?v1_col_right_caso1 <- (k-per-col (col ?col_right_caso1) (num ?max_pezzi_col_right_caso1))
    ?v2_col_right_caso1 <- (k-per-col-bandierine-posizionate (col ?col_right_caso1) (num ?num_b_col_right_caso1))

    ; Calcolo score direzione caso 2:
    ?celle_corazzata_caso2 <- (celle_corazzata_caso2_orizzontale (y_col_left ?col_left_caso2) (y_col_middle_1 ?col_middle1_caso2) (y_col_middle_2 ?col_middle2_caso2) (y_col_right ?col_right_caso2))

    ?v1_col_left_caso2 <- (k-per-col (col ?col_left_caso2) (num ?max_pezzi_col_left_caso2))
    ?v2_col_left_caso2 <- (k-per-col-bandierine-posizionate (col ?col_left_caso2) (num ?num_b_col_left_caso2))

    ?v1_col_middle1_caso2 <- (k-per-col (col ?col_middle1_caso2) (num ?max_pezzi_col_middle1_caso2))
    ?v2_col_middle1_caso2 <- (k-per-col-bandierine-posizionate (col ?col_middle1_caso2) (num ?num_b_col_middle1_caso2))

    ?v1_col_middle2_caso2 <- (k-per-col (col ?col_middle2_caso2) (num ?max_pezzi_col_middle2_caso2))
    ?v2_col_middle2_caso2 <- (k-per-col-bandierine-posizionate (col ?col_middle2_caso2) (num ?num_b_col_middle2_caso2))

    ?v1_col_right_caso2 <- (k-per-col (col ?col_right_caso2) (num ?max_pezzi_col_right_caso2))
    ?v2_col_right_caso2 <- (k-per-col-bandierine-posizionate (col ?col_right_caso2) (num ?num_b_col_right_caso2))

=>  
    (bind ?diff_col_left_caso1 (- ?max_pezzi_col_left_caso1 ?num_b_col_left_caso1))
    (bind ?diff_col_middle1_caso1 (- ?max_pezzi_col_middle1_caso1 ?num_b_col_middle1_caso1))
    (bind ?diff_col_middle2_caso1 (- ?max_pezzi_col_middle2_caso1 ?num_b_col_middle2_caso1))
    (bind ?diff_col_right_caso1 (- ?max_pezzi_col_right_caso1 ?num_b_col_right_caso1))
    (bind ?score_orizzontale_caso1 (+ ?diff_col_left_caso1 ?diff_col_middle1_caso1 ?diff_col_middle2_caso1 ?diff_col_right_caso1)) ; questo sarà lo score orizzontale del caso 1)

    (bind ?diff_col_left_caso2 (- ?max_pezzi_col_left_caso2 ?num_b_col_left_caso2))
    (bind ?diff_col_middle1_caso2 (- ?max_pezzi_col_middle1_caso2 ?num_b_col_middle1_caso2))
    (bind ?diff_col_middle2_caso2 (- ?max_pezzi_col_middle2_caso2 ?num_b_col_middle2_caso2))
    (bind ?diff_col_right_caso2 (- ?max_pezzi_col_right_caso2 ?num_b_col_right_caso2))
    (bind ?score_orizzontale_caso2 (+ ?diff_col_left_caso2 ?diff_col_middle1_caso2 ?diff_col_middle2_caso2 ?diff_col_right_caso2)) ; questo sarà lo score orizzontale del caso 2

    ; Asserisco i due scores orizzontali (in modo tale che una delle due regole qui sotto scatterà in base a chi ha vinto):
    (assert (scores_conflitto_orizzontale (orizzontale_caso1 ?score_orizzontale_caso1) (orizzontale_caso2 ?score_orizzontale_caso2)))
)

(defrule vince_orizzontale_caso1 (declare (salience 27))

    ; 1) devono essere veri questi fatti in WM
    ?piazzamento_caso1 <- (piazzamento_corazzata_orizzontale_left_subito_a_sinistra (x ?x) (y ?col_left_caso1))
    ?piazzamento_caso2 <- (piazzamento_corazzata_orizzontale_right_subito_a_destra (x ?x) (y ?col_left_caso2))

    ; 2) Devo verificare che che ?col_sinistra_caso1 e ?col_sinistra_caso2 sono diversi
    (test (neq ?col_left_caso1 ?col_left_caso2))
    
    ; 3) controllo che il caso 1 sia maggiore o uguale al secondo
    ?f_scores <- (scores_conflitto_orizzontale (orizzontale_caso1 ?score_orizzontale_caso1) (orizzontale_caso2 ?score_orizzontale_caso2))
    (test (>= ?score_orizzontale_caso1 ?score_orizzontale_caso2))
    
=>  

    (assert (piazzamento_corazzata_orizzontale(x ?x) (y ?col_left_caso1))) ; faccio capire quale direzione orizzontale ha vinto ed è quindi quella che rimarrà
    ;(retract ?piazzamento_caso1) ; lo userò per ricordarmi più giù dove si trova il middle
    (retract ?piazzamento_caso2) ; non serve più

)  
(defrule vince_orizzontale_caso2 (declare (salience 27))

    ; 1) devono essere veri questi fatti in WM
    ?piazzamento_caso1 <- (piazzamento_corazzata_orizzontale_left_subito_a_sinistra (x ?x) (y ?col_left_caso1))
    ?piazzamento_caso2 <- (piazzamento_corazzata_orizzontale_right_subito_a_destra (x ?x) (y ?col_left_caso2))

    ; 2) Devo verificare che che ?col_sinistra_caso1 e ?col_sinistra_caso2 sono diversi
    (test (neq ?col_left_caso1 ?col_left_caso2))
    
    ; 3) controllo che il caso 1 minore del secondo
    ?f_scores <- (scores_conflitto_orizzontale (orizzontale_caso1 ?score_orizzontale_caso1) (orizzontale_caso2 ?score_orizzontale_caso2))
    (test (< ?score_orizzontale_caso1 ?score_orizzontale_caso2))
    
=>
    (assert (piazzamento_corazzata_orizzontale(x ?x) (y ?col_left_caso2))) ; faccio capire quale direzione orizzontale ha vinto ed è quindi quella che rimarrà
    (retract ?piazzamento_caso1) ; non serve più
    ;(retract ?piazzamento_caso2) ; lo userò per ricordarmi più giù dove si trova il middle
)  




;; DA QUI PARTE IL CONTROLLO SULLA DIREZIONE VERTICALE.

;; LA SALIENCE DI TUTTE LE REGOLE QUI SOTTO SARA' PIU' BASSA RISPETTO A QUELLE PRECEDENTI.. IN MODO TALE CHE, PRIMA DI PASSARE
;; A VALUTARE LA DIREZIONE VERTICALE, POSSO ESSERE CERTO CHE IL CASO ORIZZONTALE SIA STATO COMPLETAMENTE GESTITO e quindi
;; ANCHE eventuali conflitti lungo quest'ultima direzione.


(defrule posizionamento_corazzata_in_verticale_bot_subito_sotto (declare (salience 26))

    ; 1) deve essere vero che posso piazzare ancora una corazzata
    (corazzata (celle_con_bandierina) (mancanti ?m))    
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella colonna “y” possa posizionare ALMENO 4 bandierine e quindi deve essere vero che:
    (cella_middle (x ?x) (y ?y) (considerata ?c))
    (k-per-col (col ?y) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 4)) ; controllo se la differenza è maggiore o uguale a 4

    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle adiacenti alla cella middle:
    (celle_adiacenti_a_middle (x_row_sopra_1 ?row_sopra) (x_row_sopra_2 ?row_sopra_2) 
                              (x_row_sotto_1 ?row_sotto) (x_row_sotto_2 ?row_sotto_2) 
                              (y_col_sinistra_1 ?col_sinistra) (y_col_sinistra_2 ?col_sinistra_2) 
                              (y_col_destra_1 ?col_destra) (y_col_destra_2 ?col_destra_2))


    ; 3) E inoltre mi devo assicurare che nella riga subito sotto possa mettere 
    ;    la bandierina che supporremo corrisponda al "bot" e quindi deve essere vero che:
    (k-per-row (row ?row_sotto) (num ?max_pezzi_row_sotto))
    (k-per-row-bandierine-posizionate (row ?row_sotto) (num ?num_b_row_sotto))
    (test (>= (- ?max_pezzi_row_sotto ?num_b_row_sotto) 1))


    ; 4) E inoltre mi devo assicurare che nella riga subito sopra possa mettere 
    ;    la bandierina che supporremo corrisponda al secondo “middle” e quindi deve essere vero che:
    (k-per-row (row ?row_sopra) (num ?max_pezzi_row_sopra))
    (k-per-row-bandierine-posizionate (row ?row_sopra) (num ?num_b_row_sopra))
    (test (>= (- ?max_pezzi_row_sopra ?num_b_row_sopra) 1))

    ; 5) E inoltre mi devo assicurare che anche due righe subito sopra possa mettere 
    ;    la bandierina che supporremo corrisponda il “top” e quindi deve essere vero che:
    (k-per-row (row ?row_sopra_2) (num ?max_pezzi_row_sopra_2))
    (k-per-row-bandierine-posizionate (row ?row_sopra_2) (num ?num_b_row_sopra_2))
    (test (>= (- ?max_pezzi_row_sopra_2 ?num_b_row_sopra_2) 1))


    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?row_sotto) (y ?y) (content water)))
    (not (k-cell (x ?row_sopra) (y ?y) (content water)))
    (not (k-cell (x ?row_sopra_2) (y ?y) (content water)))

    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))

=>  

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UNA CORAZZATA nelle seguenti posizioni
    ; (x-1,y)(bot) - (x,y) (dove sappiamo esserci il middle) – (x+1,y)(altro middle) – (x+2,y)(bot) 
    ; e quindi faccio questa assert:
    (assert (piazzamento_corazzata_verticale_bot_subito_sotto (x ?row_sotto) (y ?y))) ; per semplicità qui setto solamente la cella da dove partirà la corazzata (dal basso)
)



(defrule posizionamento_corazzata_in_verticale_top_subito_sopra (declare (salience 26))

    ; 1) deve essere vero che posso piazzare ancora una corazzata
    (corazzata (celle_con_bandierina) (mancanti ?m))    
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella colonna “y” possa posizionare ALMENO 4 bandierine e quindi deve essere vero che:
    (cella_middle (x ?x) (y ?y) (considerata ?c))
    (k-per-col (col ?y) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 4)) ; controllo se la differenza è maggiore o uguale a 4

    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle adiacenti alla cella middle:
    (celle_adiacenti_a_middle (x_row_sopra_1 ?row_sopra) (x_row_sopra_2 ?row_sopra_2) 
                              (x_row_sotto_1 ?row_sotto) (x_row_sotto_2 ?row_sotto_2) 
                              (y_col_sinistra_1 ?col_sinistra) (y_col_sinistra_2 ?col_sinistra_2) 
                              (y_col_destra_1 ?col_destra) (y_col_destra_2 ?col_destra_2))


    ; 3) E inoltre mi devo assicurare che nella riga subito sopra possa mettere 
    ;    la bandierina che supporremo corrisponda al secondo “middle” e quindi deve essere vero che:
    (k-per-row (row ?row_sopra) (num ?max_pezzi_row_sopra))
    (k-per-row-bandierine-posizionate (row ?row_sopra) (num ?num_b_row_sopra))
    (test (>= (- ?max_pezzi_row_sopra ?num_b_row_sopra) 1))

    ; 4) E inoltre mi devo assicurare che nella riga subito sotto possa mettere 
    ;    la bandierina che supporremo corrisponda al "bot" e quindi deve essere vero che:
    (k-per-row (row ?row_sotto) (num ?max_pezzi_row_sotto))
    (k-per-row-bandierine-posizionate (row ?row_sotto) (num ?num_b_row_sotto))
    (test (>= (- ?max_pezzi_row_sotto ?num_b_row_sotto) 1))

    ; 5) E inoltre mi devo assicurare che anche due righe subito sotto possa mettere 
    ;    la bandierina che supporremo corrisponda il “top” e quindi deve essere vero che:
    (k-per-row (row ?row_sotto_2) (num ?max_pezzi_row_sotto_2))
    (k-per-row-bandierine-posizionate (row ?row_sotto_2) (num ?num_b_row_sotto_2))
    (test (>= (- ?max_pezzi_row_sotto_2 ?num_b_row_sotto_2) 1))


    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?row_sopra) (y ?y) (content water)))
    (not (k-cell (x ?row_sotto) (y ?y) (content water)))
    (not (k-cell (x ?row_sotto_2) (y ?y) (content water)))

    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))

=>

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UNA CORAZZATA nelle seguenti posizioni
    ; (x-2,y)(bot) - (x-1,y) (altro middle) – (x,y)(dove sappiamo esserci il middle) – (x+1,y)(top) 
    ; e quindi faccio questa assert:
    (assert (piazzamento_corazzata_verticale_top_subito_sopra (x ?row_sotto_2) (y ?y))) ; per semplicità qui setto solamente la cella da dove partirà la corazzata (dal basso)
)




;; QUI PARTONO LE REGOLE CHE GESTISCONO UN POSSIBILE CONFLITTO SOLO PER LA DIREZIONE VERTICALE

;; GESTISCO UN EVENTUALE CONFLITTO LUNGO LA DIREZIONE VERTICALE, un conflitto di questo tipo
;; lo avremo quando saranno presenti in WM questi due fatti:
;; fact1 -> (piazzamento_corazzata_verticale (cella(x,y-1))
;; fact2 -> (piazzamento_corazzata_verticale (cella(x,y-2))
;; E QUINDI IN BASE ALLO SCORE MI CONSERVERO’ IN WM SOLAMENTE UNO DEI DUE FATTI 
;; - IN QUESTO CASO LA FIRE NON PUO’ ESSERE FATTA PERCHE’ LE DUE CELLE NON SONO IDENTICHE !

(defrule aggiunta_fatti_per_gestione_conflitti_solo_verticale (declare (salience 25))
    (piazzamento_corazzata_verticale_bot_subito_sotto (x ?row_bot_caso1) (y ?y))
    (piazzamento_corazzata_verticale_top_subito_sopra (x ?row_bot_caso2) (y ?y))
    (test (neq ?row_bot_caso1 ?row_bot_caso2)) ; verifico che che ?row_bot_caso1 e ?row_bot_caso2 sono diversi (sicuramente saranno diversi il controllo lo lascio per maggiore leggibilità)
=>  

    (assert (celle_corazzata_caso1_verticale (x_row_bot ?row_bot_caso1) (x_row_middle_1 (+ ?row_bot_caso1 1)) (x_row_middle_2 (+ ?row_bot_caso1 2)) (x_row_top (+ ?row_bot_caso1 3))))
    (assert (celle_corazzata_caso2_verticale (x_row_bot ?row_bot_caso2) (x_row_middle_1 (+ ?row_bot_caso2 1)) (x_row_middle_2 (+ ?row_bot_caso2 2)) (x_row_top (+ ?row_bot_caso2 3))))
)


(defrule gestione_conflitto_solo_verticale (declare (salience 24))

    ; 1) devono essere veri questi fatti in WM
    (piazzamento_corazzata_verticale_bot_subito_sotto (x ?row_bot_caso1) (y ?y))
    (piazzamento_corazzata_verticale_top_subito_sopra (x ?row_bot_caso2) (y ?y))

    ; 2) Devo verificare che che ?row_bot_caso1 e ?row_bot_caso2 sono diversi
    (test (neq ?row_bot_caso1 ?row_bot_caso2))

    ; 3) Calcolo lo score delle due direzioni in base alla loro cella di partenza:

    ; Calcolo score direzione caso 1:
    ?celle_corazzata_caso1 <- (celle_corazzata_caso1_verticale (x_row_bot ?row_bot_caso1) (x_row_middle_1 ?row_middle1_caso1) (x_row_middle_2 ?row_middle2_caso1) (x_row_top ?row_right_caso1))

    ?v1_row_bot_caso1 <- (k-per-row (row ?row_bot_caso1) (num ?max_pezzi_row_bot_caso1))
    ?v2_row_bot_caso1 <- (k-per-row-bandierine-posizionate (row ?row_bot_caso1) (num ?num_b_row_bot_caso1))

    ?v1_row_middle1_caso1 <- (k-per-row (row ?row_middle1_caso1) (num ?max_pezzi_row_middle1_caso1))
    ?v2_row_middle1_caso1 <- (k-per-row-bandierine-posizionate (row ?row_middle1_caso1) (num ?num_b_row_middle1_caso1))

    ?v1_row_middle2_caso1 <- (k-per-row (row ?row_middle2_caso1) (num ?max_pezzi_row_middle2_caso1))
    ?v2_row_middle2_caso1 <- (k-per-row-bandierine-posizionate (row ?row_middle2_caso1) (num ?num_b_row_middle2_caso1))

    ?v1_row_right_caso1 <- (k-per-row (row ?row_right_caso1) (num ?max_pezzi_row_right_caso1))
    ?v2_row_right_caso1 <- (k-per-row-bandierine-posizionate (row ?row_right_caso1) (num ?num_b_row_right_caso1))


    ; Calcolo score direzione caso 2:
    ?celle_corazzata_caso2 <- (celle_corazzata_caso2_verticale (x_row_bot ?row_bot_caso2) (x_row_middle_1 ?row_middle1_caso2) (x_row_middle_2 ?row_middle2_caso2) (x_row_top ?row_right_caso2))

    ?v1_row_bot_caso2 <- (k-per-row (row ?row_bot_caso2) (num ?max_pezzi_row_bot_caso2))
    ?v2_row_bot_caso2 <- (k-per-row-bandierine-posizionate (row ?row_bot_caso2) (num ?num_b_row_bot_caso2))

    ?v1_row_middle1_caso2 <- (k-per-row (row ?row_middle1_caso2) (num ?max_pezzi_row_middle1_caso2))
    ?v2_row_middle1_caso2 <- (k-per-row-bandierine-posizionate (row ?row_middle1_caso2) (num ?num_b_row_middle1_caso2))

    ?v1_row_middle2_caso2 <- (k-per-row (row ?row_middle2_caso2) (num ?max_pezzi_row_middle2_caso2))
    ?v2_row_middle2_caso2 <- (k-per-row-bandierine-posizionate (row ?row_middle2_caso2) (num ?num_b_row_middle2_caso2))

    ?v1_row_right_caso2 <- (k-per-row (row ?row_right_caso2) (num ?max_pezzi_row_right_caso2))
    ?v2_row_right_caso2 <- (k-per-row-bandierine-posizionate (row ?row_right_caso2) (num ?num_b_row_right_caso2))

=>  

    (bind ?diff_row_bot_caso1 (- ?max_pezzi_row_bot_caso1 ?num_b_row_bot_caso1))
    (bind ?diff_row_middle1_caso1 (- ?max_pezzi_row_middle1_caso1 ?num_b_row_middle1_caso1))
    (bind ?diff_row_middle2_caso1 (- ?max_pezzi_row_middle2_caso1 ?num_b_row_middle2_caso1))
    (bind ?diff_row_right_caso1 (- ?max_pezzi_row_right_caso1 ?num_b_row_right_caso1))
    (bind ?score_verticale_caso1 (+ ?diff_row_bot_caso1 ?diff_row_middle1_caso1 ?diff_row_middle2_caso1 ?diff_row_right_caso1)) ; questo sarà lo score verticale del caso 1

    (bind ?diff_row_bot_caso2 (- ?max_pezzi_row_bot_caso2 ?num_b_row_bot_caso2))
    (bind ?diff_row_middle1_caso2 (- ?max_pezzi_row_middle1_caso2 ?num_b_row_middle1_caso2))
    (bind ?diff_row_middle2_caso2 (- ?max_pezzi_row_middle2_caso2 ?num_b_row_middle2_caso2))
    (bind ?diff_row_right_caso2 (- ?max_pezzi_row_right_caso2 ?num_b_row_right_caso2))
    (bind ?score_verticale_caso2 (+ ?diff_row_bot_caso2 ?diff_row_middle1_caso2 ?diff_row_middle2_caso2 ?diff_row_right_caso2)) ; questo sarà lo score verticale del caso 2

    ; Asserisco i due scores orizzontali (in modo tale che una delle due regole qui sotto scatterà in base a chi ha vinto):
    (assert (scores_conflitto_verticale (verticale_caso1 ?score_verticale_caso1) (verticale_caso2 ?score_verticale_caso2)))
)

(defrule vince_verticale_caso1 (declare (salience 23))

    ; 1) devono essere veri questi fatti in WM
    ?piazzamento_caso1 <- (piazzamento_corazzata_verticale_bot_subito_sotto (x ?row_bot_caso1) (y ?y))
    ?piazzamento_caso2 <- (piazzamento_corazzata_verticale_top_subito_sopra (x ?row_bot_caso2) (y ?y))

    ; 2) Devo verificare che che ?row_bot_caso1 e ?row_bot_caso2 sono diversi
    (test (neq ?row_bot_caso1 ?row_bot_caso2))
    
    ; 3) controllo che il caso 1 sia maggiore o uguale al secondo
    ?f_scores <- (scores_conflitto_verticale (verticale_caso1 ?score_verticale_caso1) (verticale_caso2 ?score_verticale_caso2))
    (test (>= ?score_verticale_caso1 ?score_verticale_caso2))
    
=>
    (assert (piazzamento_corazzata_verticale(x ?row_bot_caso1) (y ?y))) ; faccio capire quale direzione verticale ha vinto ed è quindi quella che rimarrà
    ;(retract ?piazzamento_caso1) ; lo userò per ricordarmi più giù dove si trova il middle e quindi non lo elimino
    (retract ?piazzamento_caso2) ; non serve più
)  
(defrule vince_verticale_caso2 (declare (salience 23))

    ; 1) devono essere veri questi fatti in WM
    ?piazzamento_caso1 <- (piazzamento_corazzata_verticale_bot_subito_sotto (x ?row_bot_caso1) (y ?y))
    ?piazzamento_caso2 <- (piazzamento_corazzata_verticale_top_subito_sopra (x ?row_bot_caso2) (y ?y))

    ; 2) Devo verificare che che ?row_bot_caso1 e ?row_bot_caso2 sono diversi
    (test (neq ?row_bot_caso1 ?row_bot_caso2))
    
    ; 3) controllo che il caso 1 sia minore del secondo
    ?f_scores <- (scores_conflitto_verticale (verticale_caso1 ?score_verticale_caso1) (verticale_caso2 ?score_verticale_caso2))
    (test (< ?score_verticale_caso1 ?score_verticale_caso2))
    
=>
    (assert (piazzamento_corazzata_verticale(x ?row_bot_caso2) (y ?y))) ; faccio capire quale direzione verticale ha vinto ed è quindi quella che rimarrà
    (retract ?piazzamento_caso1) ; non serve più
    ;(retract ?piazzamento_caso2) ; lo userò per ricordarmi più giù dove si trova il middle e quindi non lo elimino
)  



;; QUI SOTTO PARTONO LE REGOLE CHE GESTISCONO UN POSSIBILE CONFLITTO TRA LA DIREZIONE VERTICALE E ORIZZONTALE

; Qui sotto ci sono le regole che si preoccupano di gestire eventuali conflitti.
; -	Le regole di sotto gestiranno UN CONFLITTO CHE SI VERIFICA QUANDO POSSIAMO PIAZZARE UNA corazzata 
;   SIA IN ORIZZONTALE CHE IN VERTICALE E QUINDI VUOL DIRE CHE ABBIAMO IN WM QUESTI DUE FATTI:
;   -	(piazzamento_corazzata_verticale (cella(x,y))”  
;   -   (piazzamento_corazzata_verticale (cella(x,y))”
;   dove però le due celle saranno sicuramente differenti per costruzione.
; - Per eliminare questa ambiguità, questo agente non esegue la fire ma procede con il calcolo dello score lungo le due direzioni,
;   in questo modo, quella che avrà lo score maggiore sarà la direzione lungo la quale verrà davvero
;   posizionato l'incrociatore (Questo agente PREFERSCE CONSERVARE TUTTE LE FIREs per la fase 3)


(defrule aggiunta_fatti_per_gestione_conflitti_verticale_e_orizzontale (declare (salience 22))
    (piazzamento_corazzata_orizzontale (x ?x) (y ?col_left))
    (piazzamento_corazzata_verticale (x ?row_bot) (y ?y))
=>  

    (assert (celle_corazzata_orizzontale (y_col_left ?col_left) (y_col_middle_1 (+ ?col_left 1)) (y_col_middle_2 (+ ?col_left 2)) (y_col_right (+ ?col_left 3))))
    (assert (celle_corazzata_verticale (x_row_bot ?row_bot) (x_row_middle_1 (+ ?row_bot 1)) (x_row_middle_2 (+ ?row_bot 2)) (x_row_top (+ ?row_bot 3))))
)


(defrule calcolo_score (declare (salience 21))
    ; la presenza di questi due fatti in WM mi garantiscono che c'è il conflitto da risolvere:
    (piazzamento_corazzata_orizzontale (x ?x) (y ?col_left))
    (piazzamento_corazzata_verticale (x ?row_bot) (y ?y))

    ; calcolo tutti i termini che mi permetteranno di calcolare lo score finale per la direzione ORIZZONTALE:
    ; (k-per-row (row 0) (num 2))
    ; (k-per-row-bandierine-posizionate (row 0) (num 0))
    ?celle_corazzata_orizzontale <- (celle_corazzata_orizzontale (y_col_left ?col_left) (y_col_middle_1 ?col_middle1) (y_col_middle_2 ?col_middle2) (y_col_right ?col_right))

    ?v1_col_left <- (k-per-col (col ?col_left) (num ?max_pezzi_col_left))
    ?v2_col_left <- (k-per-col-bandierine-posizionate (col ?col_left) (num ?num_b_col_left))

    ?v1_col_middle1 <- (k-per-col (col ?col_middle1) (num ?max_pezzi_col_middle1))
    ?v2_col_middle1 <- (k-per-col-bandierine-posizionate (col ?col_middle1) (num ?num_b_col_middle1))

    ?v1_col_middle2 <- (k-per-col (col ?col_middle2) (num ?max_pezzi_col_middle2))
    ?v2_col_middle2 <- (k-per-col-bandierine-posizionate (col ?col_middle2) (num ?num_b_col_middle2))

    ?v1_col_right <- (k-per-col (col ?col_right) (num ?max_pezzi_col_right))
    ?v2_col_right <- (k-per-col-bandierine-posizionate (col ?col_right) (num ?num_b_col_right))


    ; calcolo tutti i termini che mi permetteranno di calcolare lo score finale per la direzione VERTICALE:
    ?celle_corazzata_verticale <- (celle_corazzata_verticale (x_row_bot ?row_bot) (x_row_middle_1 ?row_middle1) (x_row_middle_2 ?row_middle2) (x_row_top ?row_right))

    ?v1_row_bot <- (k-per-row (row ?row_bot) (num ?max_pezzi_row_bot))
    ?v2_row_bot <- (k-per-row-bandierine-posizionate (row ?row_bot) (num ?num_b_row_bot))

    ?v1_row_middle1 <- (k-per-row (row ?row_middle1) (num ?max_pezzi_row_middle1))
    ?v2_row_middle1 <- (k-per-row-bandierine-posizionate (row ?row_middle1) (num ?num_b_row_middle1))

    ?v1_row_middle2 <- (k-per-row (row ?row_middle2) (num ?max_pezzi_row_middle2))
    ?v2_row_middle2 <- (k-per-row-bandierine-posizionate (row ?row_middle2) (num ?num_b_row_middle2))

    ?v1_row_right <- (k-per-row (row ?row_right) (num ?max_pezzi_row_right))
    ?v2_row_right <- (k-per-row-bandierine-posizionate (row ?row_right) (num ?num_b_row_right))

=>
    (bind ?diff_col_left (- ?max_pezzi_col_left ?num_b_col_left))
    (bind ?diff_col_middle1 (- ?max_pezzi_col_middle1 ?num_b_col_middle1))
    (bind ?diff_col_middle2 (- ?max_pezzi_col_middle2 ?num_b_col_middle2))
    (bind ?diff_col_right (- ?max_pezzi_col_right ?num_b_col_right))
    (bind ?score_orizzontale (+ ?diff_col_left ?diff_col_middle1 ?diff_col_middle2 ?diff_col_right)) ; questo sarà lo score orizzontale

    (bind ?diff_row_bot (- ?max_pezzi_row_bot ?num_b_row_bot))
    (bind ?diff_row_middle1 (- ?max_pezzi_row_middle1 ?num_b_row_middle1))
    (bind ?diff_row_middle2 (- ?max_pezzi_row_middle2 ?num_b_row_middle2))
    (bind ?diff_row_right (- ?max_pezzi_row_right ?num_b_row_right))
    (bind ?score_verticale (+ ?diff_row_bot ?diff_row_middle1 ?diff_row_middle2 ?diff_row_right)) ; questo sarà lo score verticale

    ; Asserisco i due scores (in modo tale che una delle due regole qui sotto scatterà in base a chi ha vinto):
    (assert (scores (orizzontale ?score_orizzontale) (verticale ?score_verticale)))
)



(defrule vince_orizzontale_left_subito_a_sinistra (declare (salience 20)) ; è mutuamente esclusiva con quella di sotto

    ?f_scores <- (scores (orizzontale ?score_orizzontale) (verticale ?score_verticale))
    (test (>= ?score_orizzontale ?score_verticale))
    
    ?f_piazzamento_orizzontale <- (piazzamento_corazzata_orizzontale (x ?x) (y ?col_left))
    ?f_piazzamento_verticale <- (piazzamento_corazzata_verticale (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?x) (y ?col_left))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

    ; mi assicuro che il middle di partenza sia proprio quello più a sinistra tra i due middle della corazzata, in modo tale da sapere con certezza (nel conseguente) in quale cella posizionare l'altro middle
    (piazzamento_corazzata_orizzontale_left_subito_a_sinistra (x ?x) (y ?col_left_caso1)) ; punto di mutua esclusione

=>

    (retract ?f_scores) ; in questo modo la regola di sotto non scatterà
    (retract ?f_piazzamento_orizzontale) ; non serve più
    (retract ?f_piazzamento_verticale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?x) (y ?col_left) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y-2)
    ;(assert (k_cell_agent (x ?x) (y (+ ?col_sinistra 1)) (content middle) (considerato false))) ; QUI E' DOVE C'E' IL MIDDLE (cella(x,y-1) E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
    (assert (k_cell_agent (x ?x) (y (+ ?col_left 2)) (content middle) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y)
    (assert (k_cell_agent (x ?x) (y (+ ?col_left 3)) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y+1)
	
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)   
(defrule vince_orizzontale_right_subito_a_destra (declare (salience 20)) ; è mutuamente esclusiva con quella di sopra

    ?f_scores <- (scores (orizzontale ?score_orizzontale) (verticale ?score_verticale))
    (test (>= ?score_orizzontale ?score_verticale))
    
    ?f_piazzamento_orizzontale <- (piazzamento_corazzata_orizzontale (x ?x) (y ?col_left))
    ?f_piazzamento_verticale <- (piazzamento_corazzata_verticale (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?x) (y ?col_left))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

    ; mi assicuro che il middle di partenza sia quello più a destra tra i due middle della corazzata, in modo tale da sapere con certezza (nel conseguente) in quale cella posizionare l'altro middle
    (piazzamento_corazzata_orizzontale_right_subito_a_destra (x ?x) (y ?col_left_caso2)) ; punto di mutua esclusione

=>

    (retract ?f_scores) ; in questo modo la regola di sotto non scatterà
    (retract ?f_piazzamento_orizzontale) ; non serve più
    (retract ?f_piazzamento_verticale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?x) (y ?col_left) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y-2)
    (assert (k_cell_agent (x ?x) (y (+ ?col_left 1)) (content middle) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y-1)
    ;(assert (k_cell_agent (x ?x) (y (+ ?col_left 2)) (content middle) (considerato false) (current yes))) ; QUI E' DOVE C'E' IL MIDDLE (cella(x,y) E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
    (assert (k_cell_agent (x ?x) (y (+ ?col_left 3)) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y+1)
	
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

) 



(defrule vince_verticale_bot_subito_sotto (declare (salience 20))

    ?f_scores <-(scores (orizzontale ?score_orizzontale) (verticale ?score_verticale))

    (test (< ?score_orizzontale ?score_verticale))

    ?f_piazzamento_orizzontale <- (piazzamento_corazzata_orizzontale (x ?x) (y ?col_sinistra))
    ?f_piazzamento_verticale <- (piazzamento_corazzata_verticale (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?row_bot) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))


    ; mi assicuro che il middle di partenza sia quello più sotto tra i due middle della corazzata, in modo tale da sapere con certezza (nel conseguente) in quale cella posizionare l'altro middle
    (piazzamento_corazzata_verticale_bot_subito_sotto (x ?row_bot) (y ?y)) ; punto di mutua esclusione

=>
    (retract ?f_scores) ; non serve più
    (retract ?f_piazzamento_orizzontale) ; non serve più
    (retract ?f_piazzamento_verticale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?row_bot) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y)
    ;(assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content middle) (considerato false) (current yes))) ; QUI E' DOVE C'E' IL MIDDLE (cella(x-1,y) E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
    (assert (k_cell_agent (x (- ?row_bot 2)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x-2,y)
    (assert (k_cell_agent (x (- ?row_bot 3)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x-3,y)


    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)
(defrule vince_verticale_top_subito_sopra (declare (salience 20))

    ?f_scores <-(scores (orizzontale ?score_orizzontale) (verticale ?score_verticale))

    (test (< ?score_orizzontale ?score_verticale))

    ?f_piazzamento_orizzontale <- (piazzamento_corazzata_orizzontale (x ?x) (y ?col_sinistra))
    ?f_piazzamento_verticale <- (piazzamento_corazzata_verticale (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?row_bot) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))


    ; mi assicuro che il middle di partenza sia quello più sotto tra i due middle della corazzata, in modo tale da sapere con certezza (nel conseguente) in quale cella posizionare l'altro middle
    (piazzamento_corazzata_verticale_top_subito_sopra (x ?row_bot) (y ?y)) ; punto di mutua esclusione

=>
    (retract ?f_scores) ; non serve più
    (retract ?f_piazzamento_orizzontale) ; non serve più
    (retract ?f_piazzamento_verticale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?row_bot) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y)
    (assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content middle) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x-1,y)
    ;(assert (k_cell_agent (x (- ?row_bot 2)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; QUI E' DOVE C'E' IL MIDDLE (cella(x-2,y) E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
    (assert (k_cell_agent (x (- ?row_bot 3)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x-3,y)


    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)


;; QUI SOTTO CI SONO LE ULTIME REGOLE PER GESTIRE I 2 CASI PIU' SEMPLICI NEI QUALI ABBIAMO SOLO UN POSIZIONAMENTO ORIZZONTALE O SOLO
;; QUELLO VERTICALE senza NESSUN CONFLITTO:

(defrule gestione_caso_solo_orizzontale_left_subito_a_sinistra (declare (salience 10)) ; è mutuamente esclusiva con quella di sotto

    ; mi assicuro che il middle di partenza sia proprio quello più a sinistra tra i due middle della corazzata, 
    ; in modo tale da sapere con certezza (nel conseguente) in quale cella posizionare l'altro middle
    ?f_piazzamento_orizzontale <- (piazzamento_corazzata_orizzontale_left_subito_a_sinistra (x ?x) (y ?col_left))
    
	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?x) (y ?col_left))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_piazzamento_orizzontale) ; non serve più
    
    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?x) (y ?col_left) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y-2)
    ;(assert (k_cell_agent (x ?x) (y (+ ?col_sinistra 1)) (content middle) (considerato false))) ; QUI E' DOVE C'E' IL MIDDLE (cella(x,y-1) E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
    (assert (k_cell_agent (x ?x) (y (+ ?col_left 2)) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y)
    (assert (k_cell_agent (x ?x) (y (+ ?col_left 3)) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y+1)
	
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)   
(defrule gestione_caso_solo_orizzontale_right_subito_a_destra (declare (salience 10)) ; è mutuamente esclusiva con quella di sotto

    ; mi assicuro che il middle di partenza sia proprio quello più a sinistra tra i due middle della corazzata, 
    ; in modo tale da sapere con certezza (nel conseguente) in quale cella posizionare l'altro middle
    ?f_piazzamento_orizzontale <- (piazzamento_corazzata_orizzontale_right_subito_a_destra (x ?x) (y ?col_left))
    
	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?x) (y ?col_left))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_piazzamento_orizzontale) ; non serve più
    
    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?x) (y ?col_left) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y-2)
    (assert (k_cell_agent (x ?x) (y (+ ?col_left 1)) (content sconosciuto) (considerato false) (current yes))) ;  mi ricordo che devo posizionare una bandierina in cella(x,y-1)
    ;(assert (k_cell_agent (x ?x) (y (+ ?col_left 2)) (content middle) (considerato false))) ; QUI E' DOVE C'E' IL MIDDLE (cella(x,y) E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
    (assert (k_cell_agent (x ?x) (y (+ ?col_left 3)) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y+1)
	
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)  


(defrule gestione_caso_solo_verticale_bot_subito_sotto (declare (salience 10)) ; è mutuamente esclusiva con quella di sotto

    ; mi assicuro che il middle di partenza sia proprio quello più a sinistra tra i due middle della corazzata, 
    ; in modo tale da sapere con certezza (nel conseguente) in quale cella posizionare l'altro middle
    ?f_piazzamento_orizzontale <- (piazzamento_corazzata_verticale_bot_subito_sotto (x ?row_bot) (y ?y))
    
	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?row_bot) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_piazzamento_orizzontale) ; non serve più
    
    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?row_bot) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y)
    ;(assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content middle) (considerato false) (current yes))) ; QUI E' DOVE C'E' IL MIDDLE (cella(x-1,y) E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
    (assert (k_cell_agent (x (- ?row_bot 2)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x-2,y)
    (assert (k_cell_agent (x (- ?row_bot 3)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x-3,y)
	
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)
(defrule gestione_caso_solo_verticale_top_subito_sopra (declare (salience 10)) ; è mutuamente esclusiva con quella di sotto

    ; mi assicuro che il middle di partenza sia proprio quello più a sinistra tra i due middle della corazzata, 
    ; in modo tale da sapere con certezza (nel conseguente) in quale cella posizionare l'altro middle
    ?f_piazzamento_orizzontale <- (piazzamento_corazzata_verticale_top_subito_sopra (x ?row_bot) (y ?y))
    
	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?row_bot) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_piazzamento_orizzontale) ; non serve più
    
    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?row_bot) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y)
    (assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content middle) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x-1,y)
    ;(assert (k_cell_agent (x (- ?row_bot 2)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; QUI E' DOVE C'E' IL MIDDLE (cella(x-2,y) E QUINDI QUESTA ASSERT NON SERVE (perchè già è presente in WM la k_cell_agent corrispondente)
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
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content middle) (considerato false) (current yes))
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