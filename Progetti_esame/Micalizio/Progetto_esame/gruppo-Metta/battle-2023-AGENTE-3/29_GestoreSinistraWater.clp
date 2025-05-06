
; Importa dai moduli MAIN e ENV tutto ciò che è importabile.
(defmodule GESTORE_SINISTRA_WATER (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (import GESTORE_WATER ?ALL) (export ?ALL))

; Questo modulo SA' CHE A DESTRA DELLA (cella_max (x) (y) (direzione sinistra)) c'è WATER 
; e quindi anche tutti i suoi sotto-moduli di piazzamento sapranno questa cosa e quindi questi ultimi
; cercheranno di piazzare una qualche nave partendo proprio (cella_max (x) (y) (direzione sinistra))
; SFRUTTANDO L'INFORMAZIONE CHE NELLA CELLA SUBITO A DESTRA della cella_max C'E' WATER.

; Quindi il modulo corrente si preoccuperà di chiamare prima il modulo "PIAZZAMENTO_CORAZZATA" e se questo non riesce in nessun
; modo a piazzare una corazzata allora richiamerà il modulo
; "PIAZZAMENTO_INCROCIATORE", al termine anche di quest'ultimo modulo, se anche questo non è riuscito in nessun
; modo a piazzare un incrociatore allora richiamerà il modulo "PIAZZAMENTO_CACCIATORPEDINIERE" e qualora
; anche questo non dovesse riuscire a piazzare nulla, allora verrà chiamato il modulo "PIAZZAMENTO_SOTTOMARINO"
; e se anche questo dovesse fallire allora questo modulo terminerà senza piazzare nulla e il controllo
; tornerà al modulo "GESTORE_WATER".

(deftemplate decremento_corazzate
    ; solo se tutti questi campi saranno a true allora verrà eseguita la regola che si occuperà di decrementare il numero tot di incrociatori ancora da piazzare
    (slot cella_corazzata_1 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il primo pezzo della corazzaza (true) o meno (false)
    (slot cella_corazzata_2 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il secondo pezzo della corazzaza (true) o meno (false)
    (slot cella_corazzata_3 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il terzo pezzo della corazzaza (true) o meno (false)
    (slot cella_corazzata_4 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il quarto pezzo della corazzaza (true) o meno (false)
)
(deftemplate decremento_incrociatori
    ; solo se tutti questi campi saranno a true allora verrà eseguita la regola che si occuperà di decrementare il numero tot di incrociatori ancora da piazzare
    (slot cella_incrociatore_1 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il primo pezzo dell'incrociatore (true) o meno (false)
    (slot cella_incrociatore_2 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il secondo pezzo dell'incrociatore (true) o meno (false)
    (slot cella_incrociatore_3 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il terzo pezzo dell'incrociatore (true) o meno (false)
)
(deftemplate decremento_cacciatorpedinieri
    ; solo se tutti questi campi saranno a true allora verrà eseguita la regola che si occuperà di decrementare il numero tot di incrociatori ancora da piazzare
    (slot cella_cacciatorpediniere_1 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il primo pezzo del cacciatorpediniere (true) o meno (false)
    (slot cella_cacciatorpediniere_2 (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il secondo pezzo del cacciatorpediniere (true) o meno (false)
)
(deftemplate decremento_sottomarini
    ; solo se tutti questo campo sarà a true allora verrà eseguita la regola che si occuperà di decrementare il numero tot di incrociatori ancora da piazzare
    (slot cella_sottomarino (allowed-values false true)) ; mi dice se l'agente ha memorizzato (nella nostra struttura) la cella che contiene il sottomarino
)


(deftemplate nessuna_nave_posizionata
    (slot posizionamento (allowed-values in_test nessuno))
)



(deffacts fatti_iniziali_sinistra_water
    (nessuna_nave_posizionata (posizionamento in_test))
)



; La regola di sotto serve nel momento in cui uno dei sotto-moduli di piazzamento delle navi
; sono riusciti a piazzare una nave perchè con la regola di sotto il modulo GESTORE_WATER_sinistra
; notifica al modulo AGENT che una nave è stata piazzata, in questo modo il modulo AGENT potrà capire 
; dove dovrà inserire le bandierine quando verrà richiamato il modulo ENV per piazzare le bandierine 
; che faranno riferimento alla nave piazzata:
(defrule controllo_piazzamento_nave_gestore_water_sinistra (declare (salience 170))
    (nave_piazzata_gestore (piazzamento true)) ; controllo se sono riuscito a piazzare una nave
    ?f_piazzamento_agent <- (nave_piazzata_agent (piazzamento ?true_o_false)) ; la var ?true_o_false serve per rendere indipendente questa regola dal valore del campo "piazzamento"
    ?add_bandierina_cella <- (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato true) (current yes))

=>
    (modify ?f_piazzamento_agent (piazzamento true)) ; avverto AGENT che deve fare il pop (se il campo è già a "true", comunque verrà rieseguita la modify ma non fa niente altrimenti avrei dovuto aggiungere un ulteriore regola..)
    (modify ?add_bandierina_cella (considerato setBandierina)) ; fa capire ad AGENT che nella cella memorizzata in "?add_bandierina_cella" deve far aggiungere una bandierina da ENV

)

;; Quando la reg di sopra ha fatto completare tutte le exec guess ad AGENT, allora scatterà questa 
;; regola qui sotto per ritrattare la cella_max ormai risolta:
(defrule cancellazione_cella_max_risolta (declare (salience 169))
    
    (nave_piazzata_gestore (piazzamento true)) ; controllo se sono riuscito a piazzare una nave
    
    ; Aggancio la cella_middle_corrente che il modulo AGENT mi ha detto di considerare
    ; e per la quale l'agente è riscito a piazzare una nave:
    ?cella_max_corrente <- (cella_max (x ?x) (y ?y) (direzione ?dir))

=>
    (retract ?cella_max_corrente) ;; ormai l'ho completata quindi la tolgo dalla WM
)

(defrule controllo_nessun_piazzamento_nave_gestore_water_sinistra (declare (salience 168))
    
    (nave_piazzata_gestore (piazzamento false)) ; controllo se non sono riuscito a piazzare una nave

    ?nessuna_nave_posizionata <- (nessuna_nave_posizionata (posizionamento nessuno))

    ; Aggancio la cella_max_corrente che il modulo AGENT mi ha detto di considerare
    ; e per la quale l'agente è riscito a piazzare una nave
    ?cella_max_corrente <- (cella_max (x ?x_max) (y ?y_max) (direzione ?dir))

    ; qui "?val_content" può essere qualsiasi cosa:
    ?new_cella <- (k_cell_agent  (x ?x_water) (y ?y_water) (content ?val_content) (considerato false) (current yes))
	

=>
    (retract ?cella_max_corrente) ;; ormai ci ho provato quindi la tolgo dalla WM
    
    ;;;; QUI AGGIORNO IL CAMPO current di "?new_cella" inserendo il valore "no" al campo "current" per far capire che questa k_cell_agent è stata considerata completamente:
	(modify ?new_cella (current no)) ;; se l'antecedente è verificato allora setto anche per questa cella il valore del campo current a "no"
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (modify ?nessuna_nave_posizionata (posizionamento in_test))
)




(defrule controllo_piazzamento_corazzata (declare (salience 150))

	(cella_max (x ?x) (y ?y) (direzione sinistra)) ; controllo che ci sia una cella_middle che il modulo GESTORE_WATER mi ha detto di considerare
    (nave_piazzata_gestore (piazzamento false))
=>  

    (assert (decremento_corazzate (cella_corazzata_1 false) (cella_corazzata_2 false) (cella_corazzata_3 false) (cella_corazzata_4 false))) ; lo setto a false
    
    ; richiamo il sotto-modulo che si preoccuperà di posizionare la corazzata
    (focus PIAZZAMENTO_CORAZZATA_SINISTRA_WATER)
)


(defrule controllo_piazzamento_incrociatore (declare (salience 150))

    (cella_max (x ?x) (y ?y) (direzione sinistra)) ; controllo che ci sia una cella_middle che il modulo GESTORE_WATER mi ha detto di considerare

    ; ASSUNZIONE: se è già stato trovato un modo per posizionare la corazzata allora l'agente non proverà neanche a piazzare l'incrociatore
    (nave_piazzata_gestore (piazzamento false))
=>  
    ; questa assert qui sotto servirà al modulo 6, qualora dovesse scoprire che si può posizionare
    ; un incrociatore, per memorizzare dove ha posizionato gli incrociatori e fare il decremento 
    ; sul num tot di incrociatori ancora da trovare:
    (assert (decremento_incrociatori (cella_incrociatore_1 false) (cella_incrociatore_2 false) (cella_incrociatore_3 false))) ; lo setto a false

    ; richiamo il sotto-modulo che si preoccuperà di posizionare l'incrociatore
    (focus PIAZZAMENTO_INCROCIATORE_SINISTRA_WATER)
)


(defrule controllo_piazzamento_cacciatorpediniere (declare (salience 150))

    (cella_max (x ?x) (y ?y) (direzione sinistra)) ; controllo che ci sia una cella_middle che il modulo GESTORE_WATER mi ha detto di considerare

    ; ASSUNZIONE: se è già stato trovato un modo per posizionare la corazzata allora l'agente non proverà neanche a piazzare l'incrociatore
    (nave_piazzata_gestore (piazzamento false))
=>  
    ; questa assert qui sotto servirà al modulo 6, qualora dovesse scoprire che si può posizionare
    ; un incrociatore, per memorizzare dove ha posizionato gli incrociatori e fare il decremento 
    ; sul num tot di incrociatori ancora da trovare:
    (assert (decremento_cacciatorpedinieri (cella_cacciatorpediniere_1 false) (cella_cacciatorpediniere_2 false))) ; lo setto a false

    ; richiamo il sotto-modulo che si preoccuperà di posizionare l'incrociatore
    (focus PIAZZAMENTO_CACCIATORPEDINIERE_SINISTRA_WATER)
)


;; NON provo a posizionare il sottomarino perchè la maggior parte delle volte sbaglierebbe.. E' più probabile che durante la 
;; fase 3 l'agente riesca a piazzare una bandierina esattamente nella posizione del sottomarino !!!
(defrule controllo_piazzamento_sottomarino (declare (salience 150))

    (fase_2_iniziata (start true)) ; L'AGENTE SI ASSICURA DI TROVARSI NELLA FASE 3

    (cella_max (x ?x) (y ?y) (direzione sinistra)) ; controllo che ci sia una cella_middle che il modulo GESTORE_WATER mi ha detto di considerare

    ; ASSUNZIONE: se è già stato trovato un modo per posizionare la corazzata allora l'agente non proverà neanche a piazzare l'incrociatore
    (nave_piazzata_gestore (piazzamento false))
=>  
    ; questa assert qui sotto servirà al modulo 6, qualora dovesse scoprire che si può posizionare
    ; un incrociatore, per memorizzare dove ha posizionato gli incrociatori e fare il decremento 
    ; sul num tot di incrociatori ancora da trovare:
    (assert (decremento_sottomarini (cella_sottomarino false))) ; lo setto a false

    ; richiamo il sotto-modulo che si preoccuperà di posizionare l'incrociatore
    (focus PIAZZAMENTO_SOTTOMARINO_SINISTRA_WATER)
)




(defrule controllo_se_non_sono_riuscito_a_piazzare_nessuna_nave_precedente (declare (salience 100))

    ; controllo che ci sia una cella_middle che il modulo AGENT mi ha detto di considerare:
    ?cella_max_corrente <- (cella_max (x ?x) (y ?y) (direzione sinistra))

    ; verifico che l'agente non sia riuscito a piazzare nè una corazzata, nè un incrociatore, nè un cacciatorpediniere 
    ; e neanche un sottomarino:
    (nave_piazzata_gestore (piazzamento false))

    ?nessuna_nave_posizionata <- (nessuna_nave_posizionata (posizionamento in_test))

=>
    ;; A questo punto l'unica cosa che farà l'agente sarà quella di asserire che nessuna 
    ;; nave è stata posizionata in modo tale che la regola "controllo_nessun_piazzamento_nave_gestore_water_sinistra"
    ;; che si trova più in alto in questo modulo possa andare in esecuzione e cancellare 
    ;; solamente la cella_max corrente perchè assume che ormai tutti i diversi 
    ;; modi per poterla soddisfare con qualche nave è stato provato.
    (modify ?nessuna_nave_posizionata (posizionamento nessuno))
)



