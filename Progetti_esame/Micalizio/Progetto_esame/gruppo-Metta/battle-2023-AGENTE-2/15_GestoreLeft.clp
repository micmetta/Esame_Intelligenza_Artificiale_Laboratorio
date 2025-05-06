
; Importa dai moduli MAIN e ENV tutto ciò che è importabile.
(defmodule GESTORE_LEFT (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (export ?ALL))

; Questo modulo si preoccuperà di chiamare prima il modulo "PIAZZAMENTO_CORAZZATA" e se questo non riesce in nessun
; modo a piazzare una corazzata (conoscendo che in cella(x,y) c'è un left) allora richiamerà il modulo
; "PIAZZAMENTO_INCROCIATORE" e se anche questa nave non può essere piazzata allora verrà richiamato il modulo 
; "PIAZZAMENTO_CACCIATORPEDINIERE" al termine anche di quest'ultimo modulo, indipendentemente dal fatto che questo
; sia riuscito a piazzare un cacciatorpediniere o meno comunque anche il gestore corrente terminerà la propria
; esecuzione e quindi il controllo tornerà subito ad AGENT.


(deftemplate decremento_corazzate
    ; solo se tutti questi cambi saranno a true allora verrà eseguita la regola che si occuperà di decrementare il numero tot di incrociatori ancora da piazzare
    (slot cella_corazzata_1 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il primo pezzo della corazzaza (true) o meno (false)
    (slot cella_corazzata_2 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il secondo pezzo della corazzaza (true) o meno (false)
    (slot cella_corazzata_3 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il terzo pezzo della corazzaza (true) o meno (false)
    (slot cella_corazzata_4 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il quarto pezzo della corazzaza (true) o meno (false)
)
(deftemplate decremento_incrociatori
    ; solo se tutti questi cambi saranno a true allora verrà eseguita la regola che si occuperà di decrementare il numero tot di incrociatori ancora da piazzare
    (slot cella_incrociatore_1 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il primo pezzo dell'incrociatore (true) o meno (false)
    (slot cella_incrociatore_2 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il secondo pezzo dell'incrociatore (true) o meno (false)
    (slot cella_incrociatore_3 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il terzo pezzo dell'incrociatore (true) o meno (false)
)
(deftemplate decremento_cacciatorpedinieri
    ; solo se tutti questi cambi saranno a true allora verrà eseguita la regola che si occuperà di decrementare il numero tot di incrociatori ancora da piazzare
    (slot cella_cacciatorpediniere_1 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il primo pezzo del cacciatorpediniere (true) o meno (false)
    (slot cella_cacciatorpediniere_2 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il secondo pezzo del cacciatorpediniere (true) o meno (false)
)

(deftemplate nessuna_nave_posizionata
    (slot posizionamento (allowed-values in_test nessuno))
)


(deftemplate fai_unguess
    (slot unguess (allowed-values false true))
)
; se ho un left allora posso cercare di posizionare qualcosa solamente sulla destra partendo ovviamente dalla cella left
(deftemplate celle_destra_a_left_in_gestore_left
    (slot y_col_destra_1) ; riga subito a destra rispetto al left
    (slot y_col_destra_2) ; riga +2 a destra rispetto al left
    (slot y_col_destra_3) ; riga +3 a destra rispetto al left
)


(deftemplate unguess_corazzata
    (slot unguess (allowed-values false true))
)
(deftemplate unguess_incrociatori
    (slot unguess (allowed-values false true))
)
(deftemplate unguess_cacciatorpedinieri
    (slot unguess (allowed-values false true))
)
(deftemplate unguess_sottomarini
    (slot unguess (allowed-values false true))
)


(deftemplate corazzata_incrementata
    (slot x) ; coord x della cella dove ho fatto l'unguess
    (slot y) ; coord y della cella dove ho fatto l'unguess
    (slot incrementata (allowed-values false true))
)
(deftemplate incrociatori_incrementati
    (slot x)
    (slot y)
    (slot incrementata (allowed-values false true))
)
(deftemplate cacciatorpedinieri_incrementati
    (slot x)
    (slot y)
    (slot incrementata (allowed-values false true))
)
(deftemplate sottomarini_incrementati
    (slot x)
    (slot y)
    (slot incrementata (allowed-values false true))
)


; La regola di sotto serve nel momento in cui uno dei sotto-moduli di piazzamento delle navi
; sono riusciti a piazzare una nave perchè con la regola di sotto il modulo GESTORE_LEFT
; notifica al modulo AGENT che una nave è stata piazzata, in questo modo AGENT potrà richiamare
; il MAIN che a sua volta invocherà ENV per piazzare le bandierine che faranno riferimento alla nave piazzata:
(defrule controllo_piazzamento_nave_gestore_left (declare (salience 170))
    (nave_piazzata_gestore (piazzamento true)) ; controllo se sono riuscito a piazzare una nave
    ?f_piazzamento_agent <- (nave_piazzata_agent (piazzamento ?true_o_false)) ; la var ?true_o_false serve per rendere indipendente questa regola dal valore del campo "piazzamento"
    ?add_bandierina_cella <- (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato true) (current yes))

=>
    (modify ?f_piazzamento_agent (piazzamento true)) ; avverto AGENT che deve fare il pop (se il campo è già a "true", comunque verrà rieseguita la modify ma non fa niente altrimenti avrei dovuto aggiungere un ulteriore regola..)
    (modify ?add_bandierina_cella (considerato setBandierina)) ; fa capire ad AGENT che nella cella memorizzata in "?add_bandierina_cella" deve far aggiungere una bandierina da ENV
)

;; Quando la reg di sopra ha fatto completare tutte le exec guess ad AGENT, allora scatterà questa 
;; regola qui sotto per ritrattare la cella_left ormai risolta:
(defrule cancellazione_cella_left_risolta (declare (salience 169))
    
    (nave_piazzata_gestore (piazzamento true)) ; controllo se sono riuscito a piazzare una nave
    
    ; Aggancio la cella_left_corrente che il modulo AGENT mi ha detto di considerare
    ; e per la quale l'agente è riscito a piazzare una nave:
    ?cella_left_corrente <- (cella_left (x ?x) (y ?y) (considerata true))

    ; aggiunta..
    ?celle_destra_a_left_in_gestore_left <- (celle_destra_a_left_in_gestore_left (y_col_destra_1 ?y_col_destra_1) (y_col_destra_2 ?y_col_destra_2) (y_col_destra_3 ?y_col_destra_3))


=>
    (retract ?cella_left_corrente) ;; ormai l'ho completata quindi la tolgo in modo tale che l'agente non la rivaluti

    ; aggiunta..
    (retract ?celle_destra_a_left_in_gestore_left) ;; ormai non mi serve più

)

;; LA REGOLA QUI SOTTO VERRA' ESEGUITA SOLAMENTE SE L'AGENTE NON E' RIUSCITO A PIAZZARE NULLA E 
;; si trova nella fase 3:
;;(defrule controllo_nessun_piazzamento_nave_gestore_left (declare (salience 168))
    
;;    (fase_3_iniziata (start true)) ;; mi assicuro di trovarmi nella fase 3

;;    (nave_piazzata_gestore (piazzamento false)) ; controllo se non sono riuscito a piazzare una nave
;;    (nessuna_nave_posizionata (posizionamento nessuno))

    ; Aggancio la cella_left che il modulo AGENT mi ha detto di considerare
    ; e per la quale l'agente è riscito a piazzare una nave
;;    ?cella_left_corrente <- (cella_left (x ?x) (y ?y) (considerata false))
;;    ?new_cella <- (k_cell_agent (x ?x) (y ?y) (content left) (considerato false) (current yes))

;;=>
;;    (retract ?cella_left_corrente) ;; ormai ci ho provato quindi la tolgo in modo tale che l'agente non la rivaluti

    ;;;; QUI AGGIORNO IL CAMPO current di "?new_cella" inserendo il valore "no" al campo "current" per far capire che questa k_cell_agent è stata considerata completamente:
;;	(modify ?new_cella (current no)) ;; se l'antecedente è verificato allora setto anche per questa cella il valore del campo current a "no"
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;)




(defrule controllo_piazzamento_cacciatorpediniere (declare (salience 150))

    (cella_left (x ?x) (y ?y) (considerata true)) ; controllo che ci sia una cella_left che il modulo AGENT mi ha detto di considerare

    ; ASSUNZIONE: se è già stato trovato un modo per posizionare la corazzata allora l'agente non proverà neanche a piazzare l'incrociatore
    (nave_piazzata_gestore (piazzamento false))
=>  
    ; questa assert qui sotto servirà al modulo 10, qualora dovesse scoprire che si può posizionare
    ; un cacciatorpediniere, per memorizzare dove ha posizionato i cacciatorpedinieri e fare il decremento 
    ; sul num tot di incrociatori ancora da trovare:
    (assert (decremento_cacciatorpedinieri (cella_cacciatorpediniere_1 false) (cella_cacciatorpediniere_2 false))) ; lo setto a false

    ; richiamo il sotto-modulo che si preoccuperà di posizionare l'incrociatore
    (focus PIAZZAMENTO_CACCIATORPEDINIERE_LEFT)
)

(defrule controllo_piazzamento_incrociatore (declare (salience 150))

    (cella_left (x ?x) (y ?y) (considerata true)) ; controllo che ci sia una cella_left che il modulo AGENT mi ha detto di considerare

    ; ASSUNZIONE: se è già stato trovato un modo per posizionare la corazzata allora l'agente non proverà neanche a piazzare l'incrociatore
    (nave_piazzata_gestore (piazzamento false))
=>  
    ; questa assert qui sotto servirà al modulo 9, qualora dovesse scoprire che si può posizionare
    ; un incrociatore, per memorizzare dove ha posizionato gli incrociatori e fare il decremento 
    ; sul num tot di incrociatori ancora da trovare:
    (assert (decremento_incrociatori (cella_incrociatore_1 false) (cella_incrociatore_2 false) (cella_incrociatore_3 false))) ; lo setto a false

    ; richiamo il sotto-modulo che si preoccuperà di posizionare l'incrociatore
    (focus PIAZZAMENTO_INCROCIATORE_LEFT)
)

(defrule controllo_piazzamento_corazzata (declare (salience 150))

	(cella_left (x ?x) (y ?y) (considerata true)) ; controllo che ci sia una cella_left che il modulo AGENT mi ha detto di considerare
    (nave_piazzata_gestore (piazzamento false))
=>  

    ; questa assert qui sotto servirà al modulo 8, qualora dovesse scoprire che si può posizionare
    ; una corazzata, per memorizzare dove ha posizionato la corazzata e fare il decremento 
    ; sul num tot di corazzate ancora da trovare:
    (assert (decremento_corazzate (cella_corazzata_1 false) (cella_corazzata_2 false) (cella_corazzata_3 false) (cella_corazzata_4 false))) ; lo setto a false
    
    ; richiamo il sotto-modulo che si preoccuperà di posizionare la corazzata
    (focus PIAZZAMENTO_CORAZZATA_LEFT)
)





;; LA REGOLA DI SOTTO (E QUINDI IN GENERALE LA GESTIONE DELLE UNGUESS) NON VERRA' ESEGUITA 
;; SE L'AGENTE SI TROVA GIA' NELLA FASE 3:
(defrule controllo_se_non_sono_riuscito_a_piazzare_nessuna_nave_precedente (declare (salience 100))

    ;;(not (fase_3_iniziata (start true))) ;; mi assicuro di non trovarmi nella fase 3


    ; controllo che ci sia una cella_left che il modulo AGENT mi ha detto di considerare:
    ?cella_left_corrente <- (cella_left (x ?x) (y ?y) (considerata true))

    ; verifico che l'agente non sia riuscito a piazzare nè una corazzata nè un incrociatore e neanche un cacciatorpediniere
    (nave_piazzata_gestore (piazzamento false))

=>
    ;; A questo punto l'agente è certo di aver commesso un errore in precedenza poichè non è riuscito a piazzare nessuna nave
    ;; partendo da una cella nella quale è certo che ci sia il "left" di una nave.
    ;; Quindi quello che farà adesso sarà quello di togliere una bandierina per volta dalla riga "x" corrente
    ;; fino a quando non riuscirà a piazzare una qualche nave lungo questa colonna:
    ;; Per fare quello appena detto, verrà asserito qui sotto un fatto che farà attivare la regola
    ;; chiamata "eseguo_unguess":
    (assert (fai_unguess (unguess true)))

    ; Con l'assert qui sotto, mi preoccupo di settare
    ; tutti i valori che servono alle regole di posizionamento per cercare di scoprire con le regole successive
    ; in quale riga o colonna bisogna togliere una bandierina già inserita che si suppone essere sbagliata:
    (assert (celle_destra_a_left_in_gestore_left (y_col_destra_1 (+ ?y 1)) (y_col_destra_2 (+ ?y 2)) (y_col_destra_3 (+ ?y 3))))

)






;; la colonna "x" rimane fissa e controllo se lungo questa riga devo fare l'unguess (perchè stiamo trattando un left)
(defrule eseguo_unguess_lungo_la_stessa_riga_di_cella_left (declare (salience 99))

    ?cella_left_corrente <- (cella_left (x ?x) (y ?y) (considerata true)) ; prendo le info della cella che mi ha 
    ; portato a capire che bisogna fare l'unguess

    ?fai_unguess <- (fai_unguess (unguess true))

    ; prendo tutte le info delle colonne nelle quali potenzialmente dovrei fare le unguess:
    ?celle_destra_a_left_in_gestore_left <- (celle_destra_a_left_in_gestore_left (y_col_destra_1 ?y_col_destra_1) (y_col_destra_2 ?y_col_destra_2) (y_col_destra_3 ?y_col_destra_3))

    ; verifico di NON riuscire a piazzare una bandierina nella riga in cui si trova la cella left:
    ; (questo controllo mi permette di sapere con certezza che la bandierina da togliere sarà una
    ;  di quelle presente proprio in questa riga!)
    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (< (- ?max_pezzi_row ?num_b_row) 1))


    ; mi assicuro che sulla cella sulla quale farò l'unguess l'agente abbia già posizionato una bandierina:
    ; (aggiunta)
    (exec (step ?s) (action guess) (x ?x) (y ?y_var))

    ; A questo punto sono certo che devo togliere una bandierina nella riga "x" dove però
    ; la colonna potrà essere una qualsiasiasi e quindi
    ; prendo la posizione di una delle bandierine che l'agente ha posizionato lungo
    ; una qualsiasi colonna "y_var" ma lungo la stessa riga "x":
    ?k_cell_agent <- (k_cell_agent (x ?x) (y ?y_var) (content ?val_content) (considerato ?val_considerato) (current ?val_current))

    ; mi assicuro che la bandierina che andrò a togliere non faccia riferimento ad un fatto iniziale che 
    ; mi assicura che in quella posizione ci sia un qualche pezzo di una nave:
    (not (k-cell (x ?x) (y ?y_var) (content top)))
    (not (k-cell (x ?x) (y ?y_var) (content bot)))
    (not (k-cell (x ?x) (y ?y_var) (content left)))
    (not (k-cell (x ?x) (y ?y_var) (content right)))
    (not (k-cell (x ?x) (y ?y_var) (content middle)))
    (not (k-cell (x ?x) (y ?y_var) (content sub)))

    ?posizione_bandierina_da_togliere <- (k-per-row-bandierine-posizionate (row ?x) (num ?n1)) 
    ?posizione_colonna_bandierina_da_togliere <- (k-per-col-bandierine-posizionate (col ?y_var) (num ?n2)) 

=>

    ; asserisco la cella da cancellare (in questo caso sarà quella presente nella riga subito sopra alla cella_left
    ; per questo motivo c'è "?row_sopra_1"):
    (assert (bandierina_da_cancellare (x ?x) (y ?y_var) (content sconosciuto) (considerato true) (current yes)))

    ; aggiorno la nostra struttura dell'agente in modo tale da togliere 1 bandierina nella riga "?x" e nella colonna "?y_var":
    (modify ?posizione_bandierina_da_togliere (num (- ?n1 1)))
    (modify ?posizione_colonna_bandierina_da_togliere (num (- ?n2 1)))

    (retract ?fai_unguess) ; così la regola di sotto non scatta ma scatterà eventualemente solamente quando AGENT ridarà il controllo
    ; a GestoreLeft

    (assert (unguess_agent (esegui_unguess true))) ; faccio capire ad AGENT che dovrà eseguire una unguess
)




;; la riga "x" adesso può variare rispetto a quella di cella_left e considero come colonna "y" 
;; quella subito a destra rispetto a dove si trova cella_left (perchè stiamo trattando un left) per cercare di capire se in questa
;; colonna "y_col_destra_1" devo fare l'unguess:
(defrule eseguo_unguess_su_colonna_destra_rispetto_a_cella_left (declare (salience 99))

    ?cella_left_corrente <- (cella_left (x ?x) (y ?y) (considerata true))

    ?fai_unguess <- (fai_unguess (unguess true))

    ; prendo tutte le info delle colonne nelle quali potenzialmente dovrei fare le unguess:
    ?celle_destra_a_left_in_gestore_left <- (celle_destra_a_left_in_gestore_left (y_col_destra_1 ?y_col_destra_1) (y_col_destra_2 ?y_col_destra_2) (y_col_destra_3 ?y_col_destra_3))

    ; verifico di riuscire a piazzare una bandierina nella riga in cui si trova la cella left:
    ; (questo controllo mi permette di sapere con certezza che la bandierina da togliere non sarà una
    ;  di quelle presente proprio in questa riga!)
    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 1))


    ; verifico di non riuscire a piazzare una bandierina nella colonna subito a destra rispetto alla cella left:
    ; (questo controllo mi permette di sapere con certezza che la bandierina da togliere deve essere una
    ;  di quelle presente proprio in questa colonna!)
    (k-per-col (col ?y_col_destra_1) (num ?max_pezzi_col_destra_1))
    (k-per-col-bandierine-posizionate (col ?y_col_destra_1) (num ?num_b_col_destra_1))
    (test (< (- ?max_pezzi_col_destra_1 ?num_b_col_destra_1) 1))


    ; mi assicuro che sulla cella sulla quale farò l'unguess l'agente abbia già posizionato una bandierina:
    ; (aggiunta)
    (exec (step ?s) (action guess) (x ?x_var) (y ?y_col_destra_1))


    ; A questo punto sono certo che devo togliere una bandierina dalla "y_col_destra_1" dove però
    ; la riga non dovrà essere uguale ad "x" e quindi
    ; prendo la posizione di una delle bandierine che l'agente ha posizionato lungo
    ; la colonna "y_col_destra_1" (la "x" invece sarà diversa da quella della cella left)
    ?k_cell_agent <- (k_cell_agent (x ?x_var) (y ?y_col_destra_1) (content ?val_content) (considerato ?val_considerato) (current ?val_current))

    ; mi accerto che la ?x sia diversa dalla ?x_var:
    (test (neq ?x ?x_var)) ; Controlla se sono diversi

    ; mi assicuro che la bandierina che andrò a togliere non faccia riferimento ad un fatto iniziale che 
    ; mi assicura che in quella posizione ci sia un qualche pezzo di una nave:
    (not (k-cell (x ?x_var) (y ?y_col_destra_1) (content top)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_1) (content bot)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_1) (content left)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_1) (content right)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_1) (content middle)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_1) (content sub)))

    ?posizione_bandierina_da_togliere <- (k-per-row-bandierine-posizionate (row ?x_var) (num ?n1)) 
    ?posizione_colonna_bandierina_da_togliere <- (k-per-col-bandierine-posizionate (col ?y_col_destra_1) (num ?n2)) 

=>

    ; asserisco la cella da cancellare (in questo caso sarà quella presente nella colonna subito a destra rispetto alla cella left
    ; per questo motivo c'è "?y_col_destra_1"):
    (assert (bandierina_da_cancellare (x ?x_var) (y ?y_col_destra_1) (content sconosciuto) (considerato true) (current yes)))

    ; aggiorno la nostra struttura dell'agente in modo tale da togliere 1 bandierina nella riga "?x_row_sopra_1":
    (modify ?posizione_bandierina_da_togliere (num (- ?n1 1)))
    (modify ?posizione_colonna_bandierina_da_togliere (num (- ?n2 1)))


    (retract ?fai_unguess) ; così la regola di sotto non scatta ma scatterà eventualemente solamente quando AGENT ridarà il controllo
    ; a Gestoreleft

    (assert (unguess_agent (esegui_unguess true))) ; faccio capire ad AGENT che dovrà eseguire una unguess
)


; la riga "x" varia rispetto a quella di cella_left e la colonna che consideriamo adesso è la "y_col_destra_2" perchè stiamo trattando un left:
(defrule eseguo_unguess_su_due_colonne_a_destra_rispetto_a_cella_left (declare (salience 99))

    ?cella_left_corrente <- (cella_left (x ?x) (y ?y) (considerata true))

    ?fai_unguess <- (fai_unguess (unguess true))

    ; prendo tutte le info delle colonne nelle quali potenzialmente dovrei fare le unguess:
    ?celle_destra_a_left_in_gestore_left <- (celle_destra_a_left_in_gestore_left (y_col_destra_1 ?y_col_destra_1) (y_col_destra_2 ?y_col_destra_2) (y_col_destra_3 ?y_col_destra_3))

    ; verifico di riuscire a piazzare una bandierina nella riga in cui si trova la cella left:
    ; (questo controllo mi permette di sapere con certezza che la bandierina da togliere non sarà una
    ;  di quelle presente proprio in questa riga!)
    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 1))


    ; verifico di non riuscire a piazzare una bandierina nella colonna due volte a destra rispetto alla cella left:
    ; (questo controllo mi permette di sapere con certezza che la bandierina da togliere deve essere una
    ;  di quelle presente proprio in questa colonna!)
    (k-per-col (col ?y_col_destra_2) (num ?max_pezzi_col_destra_1))
    (k-per-col-bandierine-posizionate (col ?y_col_destra_2) (num ?num_b_col_destra_1))
    (test (< (- ?max_pezzi_col_destra_1 ?num_b_col_destra_1) 1))


    ; mi assicuro che sulla cella sulla quale farò l'unguess l'agente abbia già posizionato una bandierina:
    ; (aggiunta)
    (exec (step ?s) (action guess) (x ?x_var) (y ?y_col_destra_2))


    ; A questo punto sono certo che devo togliere una bandierina dalla "y_col_destra_2" dove però
    ; la riga non dovrà essere uguale ad "x" e quindi
    ; prendo la posizione di una delle bandierine che l'agente ha posizionato lungo
    ; la colonna "y_col_destra_2" (la "x" invece sarà diversa da quella della cella left)
    ?k_cell_agent <- (k_cell_agent (x ?x_var) (y ?y_col_destra_2) (content ?val_content) (considerato ?val_considerato) (current ?val_current))

    ; mi accerto che la ?x sia diversa dalla ?x_var:
    (test (neq ?x ?x_var)) ; Controlla se sono diversi

    ; mi assicuro che la bandierina che andrò a togliere non faccia riferimento ad un fatto iniziale che 
    ; mi assicura che in quella posizione ci sia un qualche pezzo di una nave:
    (not (k-cell (x ?x_var) (y ?y_col_destra_2) (content top)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_2) (content bot)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_2) (content left)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_2) (content right)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_2) (content middle)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_2) (content sub)))


    ?posizione_bandierina_da_togliere <- (k-per-row-bandierine-posizionate (row ?x_var) (num ?n1)) 
    ?posizione_colonna_bandierina_da_togliere <- (k-per-col-bandierine-posizionate (col ?y_col_destra_2) (num ?n2)) 

=>

    ; asserisco la cella da cancellare (in questo caso sarà quella presente nella colonna subito a destra rispetto alla cella left
    ; per questo motivo c'è "?y_col_destra_2"):
    (assert (bandierina_da_cancellare (x ?x_var) (y ?y_col_destra_2) (content sconosciuto) (considerato true) (current yes)))

    ; aggiorno la nostra struttura dell'agente in modo tale da togliere 1 bandierina nella riga "?x_row_sopra_1":
    (modify ?posizione_bandierina_da_togliere (num (- ?n1 1)))
    (modify ?posizione_colonna_bandierina_da_togliere (num (- ?n2 1)))


    (retract ?fai_unguess) ; così la regola di sotto non scatta ma scatterà eventualemente solamente quando AGENT ridarà il controllo
    ; a Gestoreleft

    (assert (unguess_agent (esegui_unguess true))) ; faccio capire ad AGENT che dovrà eseguire una unguess
)


; la riga "x" varia rispetto a quella di cella left e la colonna che consideriamo adesso è la "y_col_destra_2" perchè stiamo trattando un left:
(defrule eseguo_unguess_su_tre_colonne_a_destra_rispetto_a_cella_left (declare (salience 99))

    ?cella_left_corrente <- (cella_left (x ?x) (y ?y) (considerata true))

    ?fai_unguess <- (fai_unguess (unguess true))

    ; prendo tutte le info delle colonne nelle quali potenzialmente dovrei fare le unguess:
    ?celle_destra_a_left_in_gestore_left <- (celle_destra_a_left_in_gestore_left (y_col_destra_1 ?y_col_destra_1) (y_col_destra_2 ?y_col_destra_2) (y_col_destra_3 ?y_col_destra_3))

    ; verifico di riuscire a piazzare una bandierina nella riga in cui si trova la cella left:
    ; (questo controllo mi permette di sapere con certezza che la bandierina da togliere non sarà una
    ;  di quelle presente proprio in questa riga!)
    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 1))


    ; verifico di non riuscire a piazzare una bandierina nella colonna tre volte a destra rispetto alla cella left:
    ; (questo controllo mi permette di sapere con certezza che la bandierina da togliere deve essere una
    ;  di quelle presente proprio in questa colonna!)
    (k-per-col (col ?y_col_destra_3) (num ?max_pezzi_col_destra_1))
    (k-per-col-bandierine-posizionate (col ?y_col_destra_3) (num ?num_b_col_destra_1))
    (test (< (- ?max_pezzi_col_destra_1 ?num_b_col_destra_1) 1))


    ; mi assicuro che sulla cella sulla quale farò l'unguess l'agente abbia già posizionato una bandierina:
    ; (aggiunta)
    (exec (step ?s) (action guess) (x ?x_var) (y ?y_col_destra_3))


    ; A questo punto sono certo che devo togliere una bandierina dalla "y_col_destra_3" dove però
    ; la riga non dovrà essere uguale ad "x" e quindi
    ; prendo la posizione di una delle bandierine che l'agente ha posizionato lungo
    ; la colonna "y_col_destra_3" (la "x" invece sarà diversa da quella della cella left)
    ?k_cell_agent <- (k_cell_agent (x ?x_var) (y ?y_col_destra_3) (content ?val_content) (considerato ?val_considerato) (current ?val_current))

    ; mi accerto che la ?x sia diversa dalla ?x_var:
    (test (neq ?x ?x_var)) ; Controlla se sono diversi

    ; mi assicuro che la bandierina che andrò a togliere non faccia riferimento ad un fatto iniziale che 
    ; mi assicura che in quella posizione ci sia un qualche pezzo di una nave:
    (not (k-cell (x ?x_var) (y ?y_col_destra_3) (content top)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_3) (content bot)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_3) (content left)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_3) (content right)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_3) (content middle)))
    (not (k-cell (x ?x_var) (y ?y_col_destra_3) (content sub)))

    ?posizione_bandierina_da_togliere <- (k-per-row-bandierine-posizionate (row ?x_var) (num ?n1)) 
    ?posizione_colonna_bandierina_da_togliere <- (k-per-col-bandierine-posizionate (col ?y_col_destra_3) (num ?n2)) 

=>

    ; asserisco la cella da cancellare (in questo caso sarà quella presente nella colonna subito a destra rispetto alla cella left
    ; per questo motivo c'è "?y_col_destra_3"):
    (assert (bandierina_da_cancellare (x ?x_var) (y ?y_col_destra_3) (content sconosciuto) (considerato true) (current yes)))

    ; aggiorno la nostra struttura dell'agente in modo tale da togliere 1 bandierina nella riga "?x_row_sopra_1":
    (modify ?posizione_bandierina_da_togliere (num (- ?n1 1)))
    (modify ?posizione_colonna_bandierina_da_togliere (num (- ?n2 1)))


    (retract ?fai_unguess) ; così la regola di sotto non scatta ma scatterà eventualemente solamente quando AGENT ridarà il controllo
    ; a Gestoreleft

    (assert (unguess_agent (esegui_unguess true))) ; faccio capire ad AGENT che dovrà eseguire una unguess
)





;; SE LA BANDIERINA CHE AGENT TOGLIERA' NON APPENA RIAVRA' IL CONTROLLO, APPARTENEVA AD UNA CORAZZATA, allora
;; la k_cell_agent corrispondente verrà tolta dal multislot della corazzata questo perchè l'agente supporrà
;; che questa cella in realtà non dovrebbe contenere una bandierina e quindi farà su di essa l'unguess.
;; Inoltre, il contantore ?m verrà incrementato di 1 perchè la corazzata precedente era sbagliata e quindi bisognerà ancora
;; trovare dove pizzarla.
;; TUTTE LE ALTRE BANDIERINE CHE ERANO STATE INSERITE NEL MULTISLOT DELLA CORAZZATA ma che in realtà non rappresentano la corazzata, 
;; VERRANNO LASCIATE NELLA STESSA POSIZIONE (e quindi anche all'interno del multislot della corazzata), questo perchè
;; magari, seppur vero che la nave trovata con queste bandierine non era la corazzata, è comunque abbastanza probabile che 
;; esse ricoprano pezzi di altre navi come ad esempio un incrociatore o un cacciatorpediniere. 

;; - LE STESSE IDENTICHE COSE APPENA DETTE sopra VARRANNO ANCHE PER L'INCROCIATORE E PER IL CACCIATORPEDINIERE.
(defrule rimuovo_bandierina_da_corazzata (declare (salience 98))

    (bandierina_da_cancellare (x ?x) (y ?y) (content ?val_content) (considerato ?val_considerato) (current ?val_current))
    ?k_cell_agent <- (k_cell_agent (x ?x) (y ?y) (content ?val_content) (considerato true) (current no))
    ?corazzata <- (corazzata (celle_con_bandierina $?facts) (mancanti ?m))
    (test (member$ ?k_cell_agent $?facts))
=>
  ; con l'istruzione qui sotto, cancello la ?k_cell_agent dal multislot di corazzata (perchè l'agente sta supponendo
  ; che questa cella in realrà non dovrebbe contenere una bandierina e quindi farà su di essa l'unguess) 
  (modify ?corazzata (celle_con_bandierina (delete-member$ $?facts ?k_cell_agent))) 
  ;(modify ?corazzata (celle_con_bandierina)) ; svuoto tutto il multislot che contiene i fatti della corazzata
  ; perchè assumo di non essere riuscito ancora a trovarla. Questa cosa non la faccio per gli incrociatori e per il 
  ; cacciatorpediniere per questioni di semplicità.
  ;(modify ?corazzata (mancanti (+ ?m 1))) ; incremento nuovamente il numero di corazzate ancora da trovare.
  
  ; ritratto la ?k_cell_agent perchè ormai l'agente ha tolto la bandierina su di essa:
  (retract ?k_cell_agent)

  (assert (unguess_corazzata (unguess true)))
)

;; Questa regola si assicura di poter incrementare di 1 il numero di corazzate da trovare:
(defrule controllo_incremento_corazzate_da_trovare (declare (salience 98))

    ?cella_left_corrente <- (cella_left (x ?x) (y ?y) (considerata true))
    (unguess_corazzata (unguess true))
    (not (corazzata_incrementata (x ?x) (y ?y) (incrementata true))) ; in questo modo sono certo che non faccio due volte l'incremento
    ; per la stessa cella left di partenza

    ?corazzata <- (corazzata (celle_con_bandierina $?facts) (mancanti ?m))
    (test (< ?m 1)) ; mi assicuro di poter incrementare la corazzata di 1
=>  

    (assert (corazzata_incrementata (x ?x) (y ?y) (incrementata true)))
    (modify ?corazzata (mancanti (+ ?m 1))) ; incremento di 1 il numero di corazzate ancora da trovare.
)





;; stessa cosa di sopra ma questa volta verrà fatto per l'incrociatore
(defrule rimuovo_bandierina_da_incrociatore (declare (salience 98))

    (bandierina_da_cancellare (x ?x) (y ?y) (content ?val_content) (considerato ?val_considerato) (current ?val_current))
    ?k_cell_agent <- (k_cell_agent (x ?x) (y ?y) (content ?val_content) (considerato true) (current no))
    ?incrociatori <- (incrociatori (celle_con_bandierina $?facts) (mancanti ?m))
    (test (member$ ?k_cell_agent $?facts))
=>
  ; con l'istruzione qui sotto, cancello la ?k_cell_agent dal multislot degli incrociatori (perchè l'agente sta supponendo
  ; che questa cella in realtà non dovrebbe contenere una bandierina e quindi farà su di essa l'unguess) 
  (modify ?incrociatori (celle_con_bandierina (delete-member$ $?facts ?k_cell_agent))) 
  ;(modify ?incrociatori (mancanti (+ ?m 1))) ; incremento nuovamente il numero di incrociatori ancora da trovare.

  ; ritratto la ?k_cell_agent perchè ormai l'agente ha tolto la bandierina su di essa:
  (retract ?k_cell_agent)

  (assert (incrociatori_incrementati (x ?x) (y ?y) (incrementata true)))
  (assert (unguess_incrociatori (unguess true)))
)

;; Questa regola si assicura di poter incrementare di 1 il numero di incrociatori da trovare:
(defrule controllo_incremento_incrociatori_da_trovare (declare (salience 98))

    ?cella_left_corrente <- (cella_left (x ?x) (y ?y) (considerata true))
    (unguess_incrociatori (unguess true))
    (not (incrociatori_incrementati (x ?x) (y ?y) (incrementata true))) ; in questo modo sono certo che non faccio due volte l'incremento
    ; per la stessa cella left di partenza

    ?incrociatori <- (incrociatori (celle_con_bandierina $?facts) (mancanti ?m))
    (test (< ?m 2)) ; mi assicuro di poter incrementare gli incrociatori di 1
=>  

    (assert (incrociatori_incrementati (x ?x) (y ?y) (incrementata true)))
    (modify ?incrociatori (mancanti (+ ?m 1))) ; incremento di 1 il numero di incrociatori ancora da trovare.
)




;; stessa cosa di sopra ma questa volta verrà fatto per il cacciatorpediniere
(defrule rimuovo_bandierina_da_cacciatorpediniere (declare (salience 98))

    (bandierina_da_cancellare (x ?x) (y ?y) (content ?val_content) (considerato ?val_considerato) (current ?val_current))
    ?k_cell_agent <- (k_cell_agent (x ?x) (y ?y) (content ?val_content) (considerato true) (current no))
    ?cacciatorpedinieri <- (cacciatorpedinieri (celle_con_bandierina $?facts) (mancanti ?m))
    (test (member$ ?k_cell_agent $?facts))

=>
  ; con l'istruzione qui sotto, cancello la ?k_cell_agent dal multislot dei cacciatorpedinieri (perchè l'agente sta supponendo
  ; che questa cella in realtà non dovrebbe contenere una bandierina e quindi farà su di essa l'unguess) 
  (modify ?cacciatorpedinieri (celle_con_bandierina (delete-member$ $?facts ?k_cell_agent))) 

  ; ritratto la ?k_cell_agent perchè ormai l'agente ha tolto la bandierina su di essa:
  (retract ?k_cell_agent)


  (assert (cacciatorpedinieri_incrementati (x ?x) (y ?y) (incrementata true)))
  (assert (unguess_cacciatorpedinieri (unguess true)))
)

;; Questa regola si assicura di poter incrementare di 1 il numero di cacciatorpedinieri da trovare:
(defrule controllo_incremento_cacciatorperdinieri_da_trovare (declare (salience 98))

    ?cella_left_corrente <- (cella_left (x ?x) (y ?y) (considerata true))
    (unguess_cacciatorpedinieri (unguess true))
    (not (cacciatorpedinieri_incrementati (x ?x) (y ?y) (incrementata true))) ; in questo modo sono certo che non faccio due volte l'incremento
    ; per la stessa cella left di partenza

    ?cacciatorpedinieri <- (cacciatorpedinieri (celle_con_bandierina $?facts) (mancanti ?m))
    (test (< ?m 3)) ; mi assicuro di poter incrementare i cacciatorpedinieri di 1
=>  

    (assert (cacciatorpedinieri_incrementati (x ?x) (y ?y) (incrementata true)))
    (modify ?cacciatorpedinieri (mancanti (+ ?m 1))) ; incremento di 1 il numero di cacciatorpedinieri ancora da trovare.
)


;; DEVI COPIARE QUESTI CONTROLLI ANCHE NEGLI ALTRI GESTORI PERCHE' LA RETRACT (retract ?k_cell_agent)   
;; NON STA FUNZIONANDO..

;; stessa cosa di sopra ma questa volta verrà fatto per il sottomarino
(defrule rimuovo_bandierina_da_sottomarino (declare (salience 98))

    (bandierina_da_cancellare (x ?x) (y ?y) (content ?val_content) (considerato ?val_considerato) (current ?val_current))
    ?k_cell_agent <- (k_cell_agent (x ?x) (y ?y) (content ?val_content) (considerato true) (current no))
    ?sottomarini <- (sottomarini (celle_con_bandierina $?facts) (mancanti ?m))
    (test (member$ ?k_cell_agent $?facts))

=>
  ; con l'istruzione qui sotto, cancello la ?k_cell_agent dal multislot dei sottomarini (perchè l'agente sta supponendo
  ; che questa cella in realtà non dovrebbe contenere una bandierina e quindi farà su di essa l'unguess) 
  (modify ?sottomarini (celle_con_bandierina (delete-member$ $?facts ?k_cell_agent))) 
  
  ; ritratto la ?k_cell_agent perchè ormai l'agente ha tolto la bandierina su di essa:
  (retract ?k_cell_agent)

  (assert (sottomarini_incrementati (x ?x) (y ?y) (incrementata true)))
  (assert (unguess_sottomarini (unguess true)))
)

;; Questa regola si assicura di poter incrementare di 1 il numero di sottomarini da trovare:
(defrule controllo_incremento_sottomarini_da_trovare (declare (salience 98))

    ?cella_left_corrente <- (cella_left (x ?x) (y ?y) (considerata true))
    (unguess_sottomarini (unguess true))
    (not (sottomarini_incrementati (x ?x) (y ?y) (incrementata true))) ; in questo modo sono certo che non faccio due volte l'incremento
    ; per la stessa cella left di partenza

    ?sottomarini <- (sottomarini (celle_con_bandierina $?facts) (mancanti ?m))
    (test (< ?m 4)) ; mi assicuro di poter incrementare gli incrociatori di 1
=>  

    (assert (sottomarini_incrementati (x ?x) (y ?y) (incrementata true)))
    (modify ?sottomarini (mancanti (+ ?m 1))) ; incremento di 1 il numero di sottomarini ancora da trovare.
)


;; Questa regola scatterà solamente se non è stato possibile piazzare nessuna nava e no si è 
;; entrati in nessuna regola di unguess:
(defrule aggiorno_struttura_k_per_row_per_col_bandierine_posizionate (declare (salience 97))

    ; mi assicuro di non aver richiesto nessuna unguess:
    (not (bandierina_da_cancellare (x ?x_unguess) (y ?y_unguess) (content ?content) (considerato true) (current yes)))
    
    ; dovrò ritrattarlo:
    ?fai_unguess <- (fai_unguess (unguess true))

    ?cella_left <- (cella_left (x ?x) (y ?y) (considerata true))
    ?k_per_row_bandierine_posizionate <- (k-per-row-bandierine-posizionate (row ?x) (num ?nb_row))
    ?k_per_col_bandierine_posizionate <- (k-per-col-bandierine-posizionate (col ?y) (num ?nb_col))
=>

    (modify ?k_per_row_bandierine_posizionate (num (+ ?nb_row 1))) ;; perchè ho eseguito la guess sul left
    (modify ?k_per_col_bandierine_posizionate (num (+ ?nb_col 1))) ;; perchè ho eseguito la guess sul left
    (retract ?cella_left) ;; non serve più
    (retract ?fai_unguess)
)