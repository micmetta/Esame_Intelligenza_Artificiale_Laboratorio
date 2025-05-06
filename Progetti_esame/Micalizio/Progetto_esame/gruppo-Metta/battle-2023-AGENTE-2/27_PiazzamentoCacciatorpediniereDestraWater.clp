

; Importa dai moduli MAIN e ENV tutto ciò che è importabile.
(defmodule PIAZZAMENTO_CACCIATORPEDINIERE_DESTRA_WATER (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (import GESTORE_DESTRA_WATER ?ALL) (export ?ALL))



;; Sappiamo che nella cella subito a sinistra rispetto alla cella_max c'è water e quindi l'unico modo per cercare
;; di piazzare un cacciatorpediniere partendo dalla cella_max (DOVE SONO CERTO DI POTER POSIZIONARE UNA BANDIERINA ma NON SO NULLA SU cosa ci sia al suo 
;; interno) è quella di metterla in una delle seguenti posizioni:

;; 1-in orizzontale (ovviamente VERSO DESTRA)
;; 2-in verticale (assumento che la cella_max sia il bot) 
;; 3-in verticale (assumento che la cella_max sia il top)

;; Qualora dovessero esserci conflitti, come al solito verrà scelto il posizionamento con lo score maggiore.

;; mi serve per conoscere le coordinate di tutte le celle nelle quali posso provare a pizzare qualcosa partendo da cella_max(x,y)
(deftemplate celle_adiacenti_a_cella_max  
    (slot x_row_sopra_1) ; riga subito sopra a cella_max
    (slot x_row_sotto_1) ; riga subito sotto cella_max
    (slot y_col_destra_1) ; colonna subito a destra della cella_max
)

(deftemplate celle_cacciatorpediniere_orizzontale
    (slot y_col_left)  
    (slot y_col_right)
)
(deftemplate celle_cacciatorpediniere_caso1_verticale
    (slot x_row_bot) 
    (slot x_row_top) 
)
(deftemplate celle_cacciatorpediniere_caso2_verticale
    (slot x_row_bot) 
    (slot x_row_top) 
)
(deftemplate celle_cacciatorpediniere_verticale
    (slot x_row_bot) 
    (slot x_row_top) 
)


(deftemplate piazzamento_cacciatorpediniere_orizzontale
    (slot x)
    (slot y)
)
(deftemplate piazzamento_cacciatorpediniere_verticale_cella_max_bot
    (slot x)
    (slot y)
)
(deftemplate piazzamento_cacciatorpediniere_verticale_cella_max_top
    (slot x)
    (slot y)
)
(deftemplate piazzamento_cacciatorpediniere_verticale ;; in caso di conflitti sulla dir verticale, conterrà comunque il punto di partenda della cacciatorpediniere che ha vinto lungo la dir verticale
    (slot x)
    (slot y)
)


(deftemplate scores_conflitto_verticale ; mi permette di calcolare lo score per le due direzioni verticali qualora ci fossero conflitti
    (slot verticale_caso1)
    (slot verticale_caso2)
)
(deftemplate scores ; mi permette di calcolare lo score per la direzione verticale e orizzontale qualora ci fossero conflitti
    (slot orizzontale)
    (slot verticale)
)



; PRATICAMENTE LA REGOLA QUI SOTTO SARA' LA PRIMA CHE VERRA' ESEGUITA E si preoccuperà di settare
; tutti i valori che servono alle regole di posizionamento per scoprire se è possibile piazzare la cacciatorpediniere 
; d'interesse o meno.
(defrule aggiunta_fatti_per_reg_successive (declare (salience 50))
    (cella_max (x ?x) (y ?y) (direzione destra))
=>
    (assert (celle_adiacenti_a_cella_max (x_row_sopra_1 (- ?x 1))
                                         (x_row_sotto_1 (+ ?x 1)) 
                                         (y_col_destra_1 (+ ?y 1))))
)

;; DA QUI PARTE IL CONTROLLO SULLA DIREZIONE ORIZZONTALE.

(defrule posizionamento_cacciatorpediniere_in_orizzontale_supponendo_cella_max_left (declare (salience 26))

    ; 1) deve essere vero che posso piazzare ancora una cacciatorpediniere
    (cacciatorpedinieri (celle_con_bandierina $?lista) (mancanti ?m))
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella riga “x” possa posizionare ALMENO 2 bandierine e quindi deve essere vero che:
    (cella_max (x ?x) (y ?y) (direzione destra))

    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 2)) ; controllo se la differenza è maggiore o uguale a 2 (perchè devo considerare anche la bandierina per la cella_max che ancora non ho messo)

    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle_adiacenti_a_cella_max:
    (celle_adiacenti_a_cella_max (x_row_sopra_1 ?x_row_sopra_1)
                                 (x_row_sotto_1 ?x_row_sotto_1)
                                 (y_col_destra_1 ?y_col_destra_1))



    ; 3) E inoltre mi devo assicurare che nella colonna subito a destra di cella_max possa mettere 
    ;    la bandierina che supporremo corrisponda al "right" partendo da sinistra e quindi deve essere vero che:
    (k-per-col (col ?y_col_destra_1) (num ?max_pezzi_col_destra_1))
    (k-per-col-bandierine-posizionate (col ?y_col_destra_1) (num ?num_b_col_destra_1))
    (test (>= (- ?max_pezzi_col_destra_1 ?num_b_col_destra_1) 1))


    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?x) (y ?y_col_destra_1) (content water)))

    ; verifico che in tutte le celle dove posizionerò la nave l'agente non abbia già posizionato
    ; una bandierina:
    (not (k_cell_agent (x ?x) (y ?y) (content ?content) (considerato true) (current no)))
    (not (k_cell_agent (x ?x) (y ?y_col_destra_1) (content ?content) (considerato true) (current no)))

    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))
=>

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UNA cacciatorpediniere nelle seguenti posizioni
    ; (x,y)(dove sappiamo esserci cella_max) - (x,y+1) (right)
    ; e quindi faccio questa assert:
    (assert (piazzamento_cacciatorpediniere_orizzontale (x ?x) (y ?y))) ; per semplicità qui setto solamente la cella da dove partirà la cacciatorpediniere (da sinistra)
)



;; DA QUI PARTONO I CONTROLLI SULLE DIREZIONI VERTICALI.

(defrule posizionamento_cacciatorpediniere_in_verticale_supponendo_cella_max_bot (declare (salience 26))

    ; 1) deve essere vero che posso piazzare ancora una cacciatorpediniere
    (cacciatorpedinieri (celle_con_bandierina $?lista) (mancanti ?m))    
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella colonna “y” possa posizionare ALMENO 2 bandierine e quindi deve essere vero che:
    (cella_max (x ?x) (y ?y) (direzione destra))


    (k-per-col (col ?y) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 2)) ; controllo se la differenza è maggiore o uguale a 2 (perchè devo considerare anche la bandierina per la cella_max che ancora non ho messo)

    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle_adiacenti_a_cella_max:
    (celle_adiacenti_a_cella_max (x_row_sopra_1 ?x_row_sopra_1)
                                 (x_row_sotto_1 ?x_row_sotto_1)
                                 (y_col_destra_1 ?y_col_destra_1))



    ; 3) E inoltre mi devo assicurare che nella riga subito sopra al bot possa mettere 
    ;    la bandierina che supporremo corrisponda al "top" partendo dal basso e quindi deve essere vero che:
    (k-per-row (row ?x_row_sopra_1) (num ?max_pezzi_row_sopra_1))
    (k-per-row-bandierine-posizionate (row ?x_row_sopra_1) (num ?num_b_row_sopra_1))
    (test (>= (- ?max_pezzi_row_sopra_1 ?num_b_row_sopra_1) 1))


    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?x_row_sopra_1) (y ?y) (content water)))

    ; verifico che in tutte le celle dove posizionerò la nave l'agente non abbia già posizionato
    ; una bandierina:
    (not (k_cell_agent (x ?x) (y ?y) (content ?content) (considerato true) (current no)))
    (not (k_cell_agent (x ?x_row_sopra_1) (y ?y) (content ?content) (considerato true) (current no)))


    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))

=>

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UNA cacciatorpediniere nelle seguenti posizioni
    ; (x,y)(dove sappiamo esserci cella_max) – (x-1,y)(top) 
    ; e quindi faccio questa assert:
    (assert (piazzamento_cacciatorpediniere_verticale_cella_max_bot (x ?x) (y ?y))) ; per semplicità qui setto solamente la cella da dove partirà la cacciatorpediniere (dal basso)
)



(defrule posizionamento_cacciatorpediniere_in_verticale_supponendo_cella_max_top (declare (salience 26))

    ; 1) deve essere vero che posso piazzare ancora una cacciatorpediniere
    (cacciatorpedinieri (celle_con_bandierina $?lista) (mancanti ?m))    
    (test (> ?m 0))
    
    ; 2) E inoltre mi devo assicurare che nella colonna “y” possa posizionare ALMENO 2 bandierine e quindi deve essere vero che:
    (cella_max (x ?x) (y ?y) (direzione destra))


    (k-per-col (col ?y) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 2)) ; controllo se la differenza è maggiore o uguale a 2 (perchè devo considerare anche la bandierina per la cella_max che ancora non ho messo)

    ; con il fatto qui sotto mi prendo tutte le coordinate di tutte le celle_adiacenti_a_cella_max:
    (celle_adiacenti_a_cella_max (x_row_sopra_1 ?x_row_sopra_1)
                                 (x_row_sotto_1 ?x_row_sotto_1)
                                 (y_col_destra_1 ?y_col_destra_1))



    ; 3) E inoltre mi devo assicurare che nella riga subito sotto possa mettere 
    ;    la bandierina che supporremo corrisponda al "bot" partendo dal basso e quindi deve essere vero che:
    (k-per-row (row ?x_row_sotto_1) (num ?max_pezzi_row_sotto_1))
    (k-per-row-bandierine-posizionate (row ?x_row_sotto_1) (num ?num_b_row_sotto_1))
    (test (>= (- ?max_pezzi_row_sotto_1 ?num_b_row_sotto_1) 1))



    ; VERIFICO CHE IN TUTTE LE CELLE IN CUI STO CERCANDO DI PIAZZARE la nave corrente
    ; io non sappia già che ci sia "water", perchè se così fosse, non avrebbe senso piazzare una bandierina
    ; in questa cella e quindi tutto il posizionamento della nave che sto cercando di inserire in questo momento
    ; non avrebbe senso farlo:
    (not (k-cell (x ?x_row_sotto_1) (y ?y) (content water)))

    ; verifico che in tutte le celle dove posizionerò la nave l'agente non abbia già posizionato
    ; una bandierina:
    (not (k_cell_agent (x ?x) (y ?y) (content ?content) (considerato true) (current no)))
    (not (k_cell_agent (x ?x_row_sotto_1) (y ?y) (content ?content) (considerato true) (current no)))

    ; evita che la regola corrente riscatti quando il fatto qui sotto è presente in WM:
    (nave_piazzata_gestore (piazzamento false))

=>

    ; A QUESTO PUNTO SONO CERTO DI POTER PIAZZARE UNA cacciatorpediniere nelle seguenti posizioni
    ; (x,y)(dove sappiamo esserci cella_max) – (x+1,y)(bot) 
    ; e quindi faccio questa assert:
    (assert (piazzamento_cacciatorpediniere_verticale_cella_max_top (x ?x_row_sotto_1) (y ?y))) ; per semplicità qui setto solamente la cella da dove partirà la cacciatorpediniere (dal basso)
)



;; QUI PARTONO LE REGOLE CHE GESTISCONO UN POSSIBILE CONFLITTO SOLO PER LA DIREZIONE VERTICALE

;; GESTISCO UN EVENTUALE CONFLITTO LUNGO LA DIREZIONE VERTICALE, un conflitto di questo tipo
;; lo avremo quando saranno presenti in WM questi due fatti:
;; fact1 -> (piazzamento_cacciatorpediniere_verticale (cella(x,y-1))
;; fact2 -> (piazzamento_cacciatorpediniere_verticale (cella(x,y-2))
;; E QUINDI IN BASE ALLO SCORE MI CONSERVERO’ IN WM SOLAMENTE UNO DEI DUE FATTI 
;; - IN QUESTO CASO LA FIRE NON PUO’ ESSERE FATTA PERCHE’ LE DUE CELLE NON SONO IDENTICHE !

(defrule aggiunta_fatti_per_gestione_conflitti_solo_verticale (declare (salience 25))

    (piazzamento_cacciatorpediniere_verticale_cella_max_bot (x ?row_bot_caso1) (y ?y))
    (piazzamento_cacciatorpediniere_verticale_cella_max_top (x ?row_bot_caso2) (y ?y))
    (test (neq ?row_bot_caso1 ?row_bot_caso2)) ; verifico che che ?row_bot_caso1 e ?row_bot_caso2 sono diversi (sicuramente saranno diversi il controllo lo lascio per maggiore leggibilità)
=>  

    (assert (celle_cacciatorpediniere_caso1_verticale (x_row_bot ?row_bot_caso1) (x_row_top (- ?row_bot_caso1 1))))
    (assert (celle_cacciatorpediniere_caso2_verticale (x_row_bot ?row_bot_caso2) (x_row_top (- ?row_bot_caso2 1))))
)


(defrule gestione_conflitto_solo_verticale (declare (salience 24))

    ; 1) devono essere veri questi fatti in WM
    (piazzamento_cacciatorpediniere_verticale_cella_max_bot (x ?row_bot_caso1) (y ?y))
    (piazzamento_cacciatorpediniere_verticale_cella_max_top (x ?row_bot_caso2) (y ?y))

    ; 2) Devo verificare che che ?row_bot_caso1 e ?row_bot_caso2 sono diversi
    (test (neq ?row_bot_caso1 ?row_bot_caso2))

    ; 3) Calcolo lo score delle due direzioni in base alla loro cella di partenza:

    ; Calcolo score direzione caso 1:
    ?celle_cacciatorpediniere_caso1 <- (celle_cacciatorpediniere_caso1_verticale (x_row_bot ?row_bot_caso1) (x_row_top ?row_right_caso1))

    ?v1_row_bot_caso1 <- (k-per-row (row ?row_bot_caso1) (num ?max_pezzi_row_bot_caso1))
    ?v2_row_bot_caso1 <- (k-per-row-bandierine-posizionate (row ?row_bot_caso1) (num ?num_b_row_bot_caso1))

    ?v1_row_right_caso1 <- (k-per-row (row ?row_right_caso1) (num ?max_pezzi_row_right_caso1))
    ?v2_row_right_caso1 <- (k-per-row-bandierine-posizionate (row ?row_right_caso1) (num ?num_b_row_right_caso1))


    ; Calcolo score direzione caso 2:
    ?celle_cacciatorpediniere_caso2 <- (celle_cacciatorpediniere_caso2_verticale (x_row_bot ?row_bot_caso2) (x_row_top ?row_right_caso2))

    ?v1_row_bot_caso2 <- (k-per-row (row ?row_bot_caso2) (num ?max_pezzi_row_bot_caso2))
    ?v2_row_bot_caso2 <- (k-per-row-bandierine-posizionate (row ?row_bot_caso2) (num ?num_b_row_bot_caso2))

    ?v1_row_right_caso2 <- (k-per-row (row ?row_right_caso2) (num ?max_pezzi_row_right_caso2))
    ?v2_row_right_caso2 <- (k-per-row-bandierine-posizionate (row ?row_right_caso2) (num ?num_b_row_right_caso2))

=>  

    (bind ?diff_row_bot_caso1 (- ?max_pezzi_row_bot_caso1 ?num_b_row_bot_caso1))
    (bind ?diff_row_right_caso1 (- ?max_pezzi_row_right_caso1 ?num_b_row_right_caso1))
    (bind ?score_verticale_caso1 (+ ?diff_row_bot_caso1 ?diff_row_right_caso1)) ; questo sarà lo score verticale del caso 1

    (bind ?diff_row_bot_caso2 (- ?max_pezzi_row_bot_caso2 ?num_b_row_bot_caso2))
    (bind ?diff_row_right_caso2 (- ?max_pezzi_row_right_caso2 ?num_b_row_right_caso2))
    (bind ?score_verticale_caso2 (+ ?diff_row_bot_caso2 ?diff_row_right_caso2)) ; questo sarà lo score verticale del caso 2

    ; Asserisco i due scores orizzontali (in modo tale che una delle due regole qui sotto scatterà in base a chi ha vinto):
    (assert (scores_conflitto_verticale (verticale_caso1 ?score_verticale_caso1) (verticale_caso2 ?score_verticale_caso2)))
)

(defrule vince_verticale_caso1 (declare (salience 23))

    ; 1) devono essere veri questi fatti in WM
    ?piazzamento_caso1 <- (piazzamento_cacciatorpediniere_verticale_cella_max_bot (x ?row_bot_caso1) (y ?y))
    ?piazzamento_caso2 <- (piazzamento_cacciatorpediniere_verticale_cella_max_top (x ?row_bot_caso2) (y ?y))

    ; 2) Devo verificare che che ?row_bot_caso1 e ?row_bot_caso2 sono diversi
    (test (neq ?row_bot_caso1 ?row_bot_caso2))
    
    ; 3) controllo che il caso 1 sia maggiore o uguale al secondo
    ?f_scores <- (scores_conflitto_verticale (verticale_caso1 ?score_verticale_caso1) (verticale_caso2 ?score_verticale_caso2))
    (test (>= ?score_verticale_caso1 ?score_verticale_caso2))
    
=>
    (assert (piazzamento_cacciatorpediniere_verticale(x ?row_bot_caso1) (y ?y))) ; faccio capire quale direzione verticale ha vinto ed è quindi quella che rimarrà
    (retract ?piazzamento_caso2) ; non serve più
)  
(defrule vince_verticale_caso2 (declare (salience 23))

    ; 1) devono essere veri questi fatti in WM
    ?piazzamento_caso1 <- (piazzamento_cacciatorpediniere_verticale_cella_max_bot (x ?row_bot_caso1) (y ?y))
    ?piazzamento_caso2 <- (piazzamento_cacciatorpediniere_verticale_cella_max_top (x ?row_bot_caso2) (y ?y))

    ; 2) Devo verificare che che ?row_bot_caso1 e ?row_bot_caso2 sono diversi
    (test (neq ?row_bot_caso1 ?row_bot_caso2))
    
    ; 3) controllo che il caso 1 sia minore del secondo
    ?f_scores <- (scores_conflitto_verticale (verticale_caso1 ?score_verticale_caso1) (verticale_caso2 ?score_verticale_caso2))
    (test (< ?score_verticale_caso1 ?score_verticale_caso2))
    
=>
    (assert (piazzamento_cacciatorpediniere_verticale(x ?row_bot_caso2) (y ?y))) ; faccio capire quale direzione verticale ha vinto ed è quindi quella che rimarrà
    (retract ?piazzamento_caso1) ; non serve più
)  




;; REGOLE CHE SARANNO ESEGUITE SOLAMENTE SE C'E' UN POSSIBILE PIAZZAMENTO VERSO UNA SOLA DELLE DUE DIREZIONI ORIZZONTALI:
;; (sono mutuamente esclusive tra loro):
;; aggiunto 
(defrule aggiunta_fatti_per_gestire_solo_il_caso_verticale_cella_max_bot (declare (salience 22))

    (piazzamento_cacciatorpediniere_verticale_cella_max_bot (x ?x_row_bot_caso1) (y ?y_caso1))
    (not (piazzamento_cacciatorpediniere_verticale_cella_max_top (x ?x_row_bot_caso2) (y ?y_caso2)))

=>  

    (assert (piazzamento_cacciatorpediniere_verticale(x ?x_row_bot_caso1) (y ?y_caso1)))
)
(defrule aggiunta_fatti_per_gestire_solo_il_caso_verticale_cella_max_top (declare (salience 22))

    (piazzamento_cacciatorpediniere_verticale_cella_max_top (x ?x_row_bot_caso2) (y ?y_caso2))
    (not (piazzamento_cacciatorpediniere_verticale_cella_max_bot (x ?x_row_bot_caso1) (y ?y_caso1)))

=>  
    (assert (piazzamento_cacciatorpediniere_verticale(x ?x_row_bot_caso2) (y ?y_caso2)))
)






;; QUI SOTTO PARTONO LE REGOLE CHE GESTISCONO UN POSSIBILE CONFLITTO TRA LA DIREZIONE VERTICALE E ORIZZONTALE

; Qui sotto ci sono le regole che si preoccupano di gestire eventuali conflitti.
; -	Le regole di sotto gestiranno UN CONFLITTO CHE SI VERIFICA QUANDO POSSIAMO PIAZZARE UNA cacciatorpediniere 
;   SIA IN ORIZZONTALE CHE IN VERTICALE E QUINDI VUOL DIRE CHE ABBIAMO IN WM QUESTI DUE FATTI:
;   -	(piazzamento_cacciatorpediniere_orizzontale (cella(x,y))”  
;   -   (piazzamento_cacciatorpediniere_verticale (cella(x,y))”
;   dove però le due celle saranno sicuramente differenti per costruzione.
; - Per eliminare questa ambiguità, questo agente non esegue la fire ma procede con il calcolo dello score lungo le due direzioni,
;   in questo modo, quella che avrà lo score maggiore sarà la direzione lungo la quale verrà davvero
;   posizionato l'cacciatorpediniere (Questo agente PREFERSCE CONSERVARE TUTTE LE FIREs per la fase 3)


(defrule aggiunta_fatti_per_gestione_conflitti_verticale_e_orizzontale (declare (salience 22))
    (piazzamento_cacciatorpediniere_orizzontale (x ?x) (y ?col_left))
    (piazzamento_cacciatorpediniere_verticale (x ?row_bot) (y ?y))
=>  

    (assert (celle_cacciatorpediniere_orizzontale (y_col_left ?col_left)(y_col_right (+ ?col_left 1))))
    (assert (celle_cacciatorpediniere_verticale (x_row_bot ?row_bot) (x_row_top (- ?row_bot 1))))
)


(defrule calcolo_score (declare (salience 21))
    ; la presenza di questi due fatti in WM mi garantiscono che c'è il conflitto da risolvere:
    (piazzamento_cacciatorpediniere_orizzontale (x ?x) (y ?col_left))
    (piazzamento_cacciatorpediniere_verticale (x ?row_bot) (y ?y))

    ; calcolo tutti i termini che mi permetteranno di calcolare lo score finale per la direzione ORIZZONTALE:
    ; (k-per-row (row 0) (num 2))
    ; (k-per-row-bandierine-posizionate (row 0) (num 0))
    ?celle_cacciatorpediniere_orizzontale <- (celle_cacciatorpediniere_orizzontale (y_col_left ?col_left) (y_col_right ?col_right))

    ?v1_col_left <- (k-per-col (col ?col_left) (num ?max_pezzi_col_left))
    ?v2_col_left <- (k-per-col-bandierine-posizionate (col ?col_left) (num ?num_b_col_left))

    ?v1_col_right <- (k-per-col (col ?col_right) (num ?max_pezzi_col_right))
    ?v2_col_right <- (k-per-col-bandierine-posizionate (col ?col_right) (num ?num_b_col_right))


    ; calcolo tutti i termini che mi permetteranno di calcolare lo score finale per la direzione VERTICALE:
    ?celle_cacciatorpediniere_verticale <- (celle_cacciatorpediniere_verticale (x_row_bot ?row_bot) (x_row_top ?row_right))

    ?v1_row_bot <- (k-per-row (row ?row_bot) (num ?max_pezzi_row_bot))
    ?v2_row_bot <- (k-per-row-bandierine-posizionate (row ?row_bot) (num ?num_b_row_bot))

    ?v1_row_right <- (k-per-row (row ?row_right) (num ?max_pezzi_row_right))
    ?v2_row_right <- (k-per-row-bandierine-posizionate (row ?row_right) (num ?num_b_row_right))

=>
    (bind ?diff_col_left (- ?max_pezzi_col_left ?num_b_col_left))
    (bind ?diff_col_right (- ?max_pezzi_col_right ?num_b_col_right))
    (bind ?score_orizzontale (+ ?diff_col_left ?diff_col_right)) ; questo sarà lo score orizzontale

    (bind ?diff_row_bot (- ?max_pezzi_row_bot ?num_b_row_bot))
    (bind ?diff_row_right (- ?max_pezzi_row_right ?num_b_row_right))
    (bind ?score_verticale (+ ?diff_row_bot ?diff_row_right)) ; questo sarà lo score verticale

    ; Asserisco i due scores (in modo tale che una delle due regole qui sotto scatterà in base a chi ha vinto):
    (assert (scores (orizzontale ?score_orizzontale) (verticale ?score_verticale)))
)


(defrule vince_orizzontale (declare (salience 20)) ; è mutuamente esclusiva con quella di sotto

    ?f_scores <- (scores (orizzontale ?score_orizzontale) (verticale ?score_verticale))
    (test (>= ?score_orizzontale ?score_verticale))
    
    ?f_piazzamento_orizzontale <- (piazzamento_cacciatorpediniere_orizzontale (x ?x) (y ?col_left))
    ?f_piazzamento_verticale <- (piazzamento_cacciatorpediniere_verticale (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?x) (y ?col_left))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_scores) ; in questo modo la regola di sotto non scatterà
    (retract ?f_piazzamento_orizzontale) ; non serve più
    (retract ?f_piazzamento_verticale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?x) (y ?col_left) (content sconosciuto) (considerato false) (current yes))) ; questa è la cella_max nella quale sto assumendo che ci sia il left in cella(x,y)
    (assert (k_cell_agent (x ?x) (y (+ ?col_left 1)) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y+1)

    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)
(defrule vince_verticale_supponendo_cella_max_bot (declare (salience 20))

    ?f_scores <-(scores (orizzontale ?score_orizzontale) (verticale ?score_verticale))

    (test (< ?score_orizzontale ?score_verticale))

    ?f_piazzamento_orizzontale <- (piazzamento_cacciatorpediniere_orizzontale (x ?x) (y ?col_sinistra))
    ?f_piazzamento_verticale <- (piazzamento_cacciatorpediniere_verticale (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?row_bot) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))


    ; mi assicuro che la direzione verticale vincente fosse quella che supponeva che cella_max fosse il bot
    (piazzamento_cacciatorpediniere_verticale_cella_max_bot (x ?x) (y ?y)) ; punto di mutua esclusione

=>
    (retract ?f_scores) ; non serve più
    (retract ?f_piazzamento_orizzontale) ; non serve più
    (retract ?f_piazzamento_verticale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?row_bot) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; questa è la cella_max nella quale sto assumendo che ci sia il bot in cella(x,y)
    (assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x-1,y)
    
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)
(defrule vince_verticale_supponendo_cella_max_top (declare (salience 20))

    ?f_scores <-(scores (orizzontale ?score_orizzontale) (verticale ?score_verticale))

    (test (< ?score_orizzontale ?score_verticale))

    ?f_piazzamento_orizzontale <- (piazzamento_cacciatorpediniere_orizzontale (x ?x) (y ?col_sinistra))
    ?f_piazzamento_verticale <- (piazzamento_cacciatorpediniere_verticale (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?row_bot) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))


    ; mi assicuro che la direzione verticale vincente fosse quella che supponeva che cella_max fosse il top
    (piazzamento_cacciatorpediniere_verticale_cella_max_top (x ?x) (y ?y)) ; punto di mutua esclusione

=>
    (retract ?f_scores) ; non serve più
    (retract ?f_piazzamento_orizzontale) ; non serve più
    (retract ?f_piazzamento_verticale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?row_bot) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x,y)
    (assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x-1,y)

    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)





(defrule vince_orizzontale_senza_conflitto (declare (salience 10)) ; è mutuamente esclusiva con quella di sotto

    (not (piazzamento_cacciatorpediniere_verticale (x ?x_row_bot) (y ?y))) ; aggiunto
    ?f_piazzamento_orizzontale <- (piazzamento_cacciatorpediniere_orizzontale (x ?x) (y ?col_left))
    
	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?x) (y ?col_left))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_piazzamento_orizzontale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?x) (y ?col_left) (content sconosciuto) (considerato false) (current yes))) ; questa è la cella_max nella quale sto assumendo che ci sia il left in cella(x,y)
    (assert (k_cell_agent (x ?x) (y (+ ?col_left 1)) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che devo posizionare una bandierina in cella(x,y+1)
    
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)
(defrule vince_verticale_supponendo_cella_max_bot_senza_conflitto (declare (salience 10))

    (not (piazzamento_cacciatorpediniere_orizzontale (x ?x) (y ?y_col_left))) ; aggiunto
    ?f_piazzamento_verticale <- (piazzamento_cacciatorpediniere_verticale_cella_max_bot (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?row_bot) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_piazzamento_verticale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?row_bot) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; questa è la cella_max nella quale sto assumendo che ci sia il bot in cella(x,y)
    (assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x-1,y)
    
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)
(defrule vince_verticale_supponendo_cella_max_top_senza_conflitto (declare (salience 10))

    (not (piazzamento_cacciatorpediniere_orizzontale (x ?x) (y ?y_col_left))) ; aggiunto
    ?f_piazzamento_verticale <- (piazzamento_cacciatorpediniere_verticale_cella_max_top (x ?row_bot) (y ?y))

	(status (step ?s)(currently running))
	(not (exec  (action guess) (x ?row_bot) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione

    ?nave_piazzata <- (nave_piazzata_gestore (piazzamento false))

=>

    (retract ?f_piazzamento_verticale) ; non serve più

    ; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?row_bot) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x,y)
    (assert (k_cell_agent (x (- ?row_bot 1)) (y ?y) (content sconosciuto) (considerato false) (current yes))) ; mi ricordo che ho posizionato una bandierina in cella(x-1,y)
    
    (modify ?nave_piazzata (piazzamento true)) ; per far capire al chiamante che una nave è stata piazzata

)





;; Qui sotto ci sono le regole che si preoccupano di aggiornare la struttura dati che avrà l'agente per sapere dove ha 
;; posizionato le bandierine e decrementa il numero di corazzate da trovare rimanenti.

; Con la regola di sotto l'agente si memorizza nella sua struttura "cacciatorpediniere" sia le celle nelle quali 
; ha deciso di posizionare la cacciatorpediniere e sia il fatto che adesso gli manca ancora da cercare "?m - 1" cacciatorpediniere. 
(defrule memorizzo_cacciatorpediniere_1 (declare (salience 3))
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato false) (current yes))
	?cacciatorpediniere <- (cacciatorpedinieri (celle_con_bandierina $?lista) (mancanti ?m))
	?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    ?decremento_cacciatorpediniere <- (decremento_cacciatorpedinieri (cella_cacciatorpediniere_1 false) (cella_cacciatorpediniere_2 false))
=>
	(modify ?cacciatorpediniere (celle_con_bandierina (insert$ $?lista (+ (length$ $?lista) 1) ?new_cella)))
	(modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
    (modify ?decremento_cacciatorpediniere (cella_cacciatorpediniere_1 true)) ; attivo la regola "decremento_cacciatorpediniere" qui sotto
    (modify ?new_cella (considerato true)) 
)
(defrule memorizzo_cacciatorpediniere_2 (declare (salience 3))
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato false) (current yes))
	?cacciatorpediniere <- (cacciatorpedinieri (celle_con_bandierina $?lista) (mancanti ?m))
	?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    ?decremento_cacciatorpediniere <- (decremento_cacciatorpedinieri (cella_cacciatorpediniere_1 true) (cella_cacciatorpediniere_2 false))
=>
	(modify ?cacciatorpediniere (celle_con_bandierina (insert$ $?lista (+ (length$ $?lista) 1) ?new_cella)))
	(modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
    (modify ?decremento_cacciatorpediniere (cella_cacciatorpediniere_2 true)) ; attivo la regola "decremento_cacciatorpediniere" qui sotto
    (modify ?new_cella (considerato true)) 
)



(defrule decremento_cacciatorpediniere (declare (salience 2))
	?decremento_cacciatorpediniere <- (decremento_cacciatorpedinieri (cella_cacciatorpediniere_1 true) (cella_cacciatorpediniere_2 true)) ; tutti e 4 gli slot devono essere a true
    ?cacciatorpediniere <- (cacciatorpedinieri (celle_con_bandierina $?lista) (mancanti ?m))
=>
	(modify ?cacciatorpediniere (mancanti (- ?m 1)))
    (retract ?decremento_cacciatorpediniere)
)


;; FORSE LA REGOLA QUI SOTTO DOVRAI METTERLA ANCHE PER LE ALTRE NAVI..
;; CON LA REGOLA DI SOTTO ritratto il fatto di tipo "celle_adiacenti_a_cella_max"
;; perchè tanto adesso non mi serve più e se non lo tolgo avrò problemi successivamente:
(defrule cancello_celle_adiacenti_a_cella_max_ormai_inutili(declare (salience 1))

    ?cella_da_cancellare <- (celle_adiacenti_a_cella_max (x_row_sopra_1 ?x_row_sopra_1)
                                                         (x_row_sotto_1 ?x_row_sotto_1)
                                                         (y_col_destra_1 ?y_col_destra_1))

=>
    (retract ?cella_da_cancellare)
)
