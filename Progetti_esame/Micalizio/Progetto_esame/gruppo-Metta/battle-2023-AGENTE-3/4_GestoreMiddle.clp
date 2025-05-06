
; Importa dai moduli MAIN e ENV tutto ciò che è importabile.
(defmodule GESTORE_MIDDLE (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (export ?ALL))

; Questo modulo si preoccuperà di chiamare prima il modulo "PIAZZAMENTO_CORAZZATA" e se questo non riesce in nessun
; modo a piazzare una corazzata (conoscendo che in cella(x,y) c'è un middle) allora richiamerà il modulo
; "PIAZZAMENTO_INCROCIATORE" al termine anche di quest'ultimo modulo, indipendentemente dal fatto che questo
; sia riuscito a piazzare un incrociatore o meno comunque anche il gestore corrente terminerà la propria
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
(deftemplate nessuna_nave_posizionata
    (slot posizionamento (allowed-values in_test nessuno))
)







; La regola di sotto serve nel momento in cui uno dei sotto-moduli di piazzamento delle navi
; sono riusciti a piazzare una nave perchè con la regola di sotto il modulo GESTORE_MIDDLE 
; notifica al modulo AGENT che una nave è stata piazzata, in questo modo AGENT potrà richiamare
; il MAIN che a sua volta invocherà ENV per piazzare le bandierine che faranno riferimento alla nave piazzata:
(defrule controllo_piazzamento_nave_gestore_middle (declare (salience 170))
    (nave_piazzata_gestore (piazzamento true)) ; controllo se sono riuscito a piazzare una nave
    ?f_piazzamento_agent <- (nave_piazzata_agent (piazzamento ?true_o_false)) ; la var ?true_o_false serve per rendere indipendente questa regola dal valore del campo "piazzamento"
    ?add_bandierina_cella <- (k_cell_agent (x ?x) (y ?col_sinistra) (content sconosciuto) (considerato true) (current yes))

=>
    (modify ?f_piazzamento_agent (piazzamento true)) ; avverto AGENT che deve fare il pop (se il campo è già a "true", comunque verrà rieseguita la modify ma non fa niente altrimenti avrei dovuto aggiungere un ulteriore regola..)
    (modify ?add_bandierina_cella (considerato setBandierina)) ; fa capire ad AGENT che nella cella memorizzata in "?add_bandierina_cella" deve far aggiungere una bandierina da ENV

)

;; Quando la reg di sopra ha fatto completare tutte le exec guess ad AGENT, allora scatterà questa 
;; regola qui sotto per ritrattare la cella_middle ormai risolta:
(defrule cancellazione_cella_middle_risolta (declare (salience 169))
    
    (nave_piazzata_gestore (piazzamento true)) ; controllo se sono riuscito a piazzare una nave
    
    ; Aggancio la cella_middle_corrente che il modulo AGENT mi ha detto di considerare
    ; e per la quale l'agente è riscito a piazzare una nave:
    ?cella_middle_corrente <- (cella_middle (x ?x) (y ?y) (considerata true))

=>
    (retract ?cella_middle_corrente) ;; ormai l'ho completata quindi la tolgo in modo tale che l'agente non la rivaluti
)

(defrule controllo_nessun_piazzamento_nave_gestore_middle (declare (salience 168))
    
    (nave_piazzata_gestore (piazzamento false)) ; controllo se non sono riuscito a piazzare una nave
    (nessuna_nave_posizionata (posizionamento nessuno))

    ; Aggancio la cella_middle_corrente che il modulo AGENT mi ha detto di considerare
    ; e per la quale l'agente è riscito a piazzare una nave
    ?cella_middle_corrente <- (cella_middle (x ?x) (y ?y) (considerata false))

    ; qui "?val_content" sarà sicuramente middle:
    ?new_cella <- (k_cell_agent (x ?x) (y ?y) (content middle) (considerato false) (current yes))
	

=>
    (retract ?cella_middle_corrente) ;; ormai ci ho provato quindi la tolgo in modo tale che l'agente non la rivaluti
    
    ;;;; QUI AGGIORNO IL CAMPO current di "?new_cella" inserendo il valore "no" al campo "current" per far capire che questa k_cell_agent è stata considerata completamente:
	(modify ?new_cella (current no)) ;; se l'antecedente è verificato allora setto anche per questa cella il valore del campo current a "no"
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
)




(defrule controllo_piazzamento_corazzata (declare (salience 150))

	(cella_middle (x ?x) (y ?y) (considerata true)) ; controllo che ci sia una cella_middle che il modulo AGENT mi ha detto di considerare
    (nave_piazzata_gestore (piazzamento false))
=>  

    (assert (decremento_corazzate (cella_corazzata_1 false) (cella_corazzata_2 false) (cella_corazzata_3 false) (cella_corazzata_4 false))) ; lo setto a false
    
    ; richiamo il sotto-modulo che si preoccuperà di posizionare la corazzata
    (focus PIAZZAMENTO_CORAZZATA_MIDDLE)
)


(defrule controllo_piazzamento_incrociatore (declare (salience 150))

    (cella_middle (x ?x) (y ?y) (considerata true)) ; controllo che ci sia una cella_middle che il modulo AGENT mi ha detto di considerare

    ; ASSUNZIONE: se è già stato trovato un modo per posizionare la corazzata allora l'agente non proverà neanche a piazzare l'incrociatore
    (nave_piazzata_gestore (piazzamento false))
=>  
    ; questa assert qui sotto servirà al modulo 6, qualora dovesse scoprire che si può posizionare
    ; un incrociatore, per memorizzare dove ha posizionato gli incrociatori e fare il decremento 
    ; sul num tot di incrociatori ancora da trovare:
    (assert (decremento_incrociatori (cella_incrociatore_1 false) (cella_incrociatore_2 false) (cella_incrociatore_3 false))) ; lo setto a false

    ; richiamo il sotto-modulo che si preoccuperà di posizionare l'incrociatore
    (focus PIAZZAMENTO_INCROCIATORE_MIDDLE)
)


(defrule controllo_se_non_sono_riuscito_a_piazzare_nessuna_nave_precedente (declare (salience 100))

    ; controllo che ci sia una cella_middle che il modulo AGENT mi ha detto di considerare:
    ?cella_middle_corrente <- (cella_middle (x ?x) (y ?y) (considerata true))

    ; verifico che l'agente non sia riuscito a piazzare nè una corazzata e nè un incrociatore
    ; (in questo caso ho provato a piazzare solo queste due navi perchè mi trovo nel caso in cui
    ; conosco il "middle") nella cella_middle selezionata con il controllo precedente:
    (nave_piazzata_gestore (piazzamento false))

    ;; Prendo le coordinate che mi servono per posizionare la bandierina proprio nella cella_middle corrente:
    ?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))

=>
    ;; A questo punto SI POTREBBE DECIDERE DI FARE DELLE UNGUESS secondo una qualche 
    ;; strategia perchè se conoscendo il middle non sono riuscito a piazzare nessuna delle 
    ;; due navi precedenti allora vuol dire che sicuramente ho posizionato ALMENO una bandierina 
    ;; in una posizione sbagliata..
    ;; Per adesso, per questioni di semplicità, non inserisco la gestione delle unguess ma
    ;; faccio in modo che il "GESTORE_MIDDLE" INSERISCA direttamente lui la bandierina in corrispondenza
    ;; del middle corrente all'interno della struttura del nostro agente,
    ;; in modo tale comunque da non perdere questa informazione iniziale perchè lui si ricorderà
    ;; che in questa cella è stata messa comunque già una bandierina:
    (modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
    (assert (nessuna_nave_posizionata (posizionamento nessuno))) ; avverto che nessuna nave è stata posizionata e quindi
    ; nel caso più semplice una delle prime regole chiamata "controllo_nessun_piazzamento_nave_gestore_middle" 
    ; andrà in esecuzione e cancellerà solamente la cella_middle corrente perchè assume che ormai tutti i diversi 
    ; modi per poterla soddisfare con qualche nave è stato provato.
    (modify ?cella_middle_corrente (considerata false))


)
