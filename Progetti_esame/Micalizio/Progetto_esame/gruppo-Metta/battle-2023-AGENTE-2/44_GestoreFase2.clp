; Importa dai moduli MAIN e ENV tutto ciò che è importabile.
(defmodule GESTORE_FASE_2 (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (export ?ALL))

;; I VINCOLI RIGIDI che ogni cella dovrà rispettare prima di poter essere asserita come cella_ammissibile sono i seguenti:
;; 1) Non è stata già posizionata la bandierina nella cella
;; 2) Deve essere possibile posizionare una bandierina nella cella

(deftemplate cella_griglia
    (slot x)
    (slot y)
    (slot considerata (allowed-values false true))
)

(deftemplate cella_ammissibile
    (slot x)
    (slot y)
    (slot score)
    (slot aggiunta (allowed-values false true))
)

;;(deftemplate lista_ordinata
;;    (multislot weight_cells) ;; conterrà le celle di tipo "cella_ammissibile" che poi saranno ordinate in base al campo score
;;)
;;(deftemplate ordinamento
;;    (slot start (allowed-values false completato))
;;)

(deftemplate celle_ammissibili_completate
    (slot completate (allowed-values false true)) ;; sarà true solo quando la regola chiamata "start_inserimento_celle_ammissibili"
    ;; non avrà altre celle ammissibili da aggiungere in weight_cells
)


; serve per sapere quando bisogna asserire la nuova cella_max_fase_2 dalla testa di "weight_cells":
(deftemplate next_cella_max_fase_2
    (slot next_max (allowed-values false true))
)


(deffacts fatti_iniziali_fase_2

    ;;(lista_ordinata (weight_cells)) ;; setto il multislot vuoto
    (celle_ammissibili_completate (completate false))
    ;;(ordinamento (start false))
    (next_cella_max_fase_2 (next_max true))


    (cella_griglia (x 0) (y 0) (considerata false))
    (cella_griglia (x 0) (y 1) (considerata false))
    (cella_griglia (x 0) (y 2) (considerata false))
    (cella_griglia (x 0) (y 3) (considerata false))
    (cella_griglia (x 0) (y 4) (considerata false))
    (cella_griglia (x 0) (y 5) (considerata false))
    (cella_griglia (x 0) (y 6) (considerata false))
    (cella_griglia (x 0) (y 7) (considerata false))
    (cella_griglia (x 0) (y 8) (considerata false))
    (cella_griglia (x 0) (y 9) (considerata false))
    (cella_griglia (x 1) (y 0) (considerata false))
    (cella_griglia (x 1) (y 1) (considerata false))
    (cella_griglia (x 1) (y 2) (considerata false))
    (cella_griglia (x 1) (y 3) (considerata false))
    (cella_griglia (x 1) (y 4) (considerata false))
    (cella_griglia (x 1) (y 5) (considerata false))
    (cella_griglia (x 1) (y 6) (considerata false))
    (cella_griglia (x 1) (y 7) (considerata false))
    (cella_griglia (x 1) (y 8) (considerata false))
    (cella_griglia (x 1) (y 9) (considerata false))
    (cella_griglia (x 2) (y 0) (considerata false))
    (cella_griglia (x 2) (y 1) (considerata false))
    (cella_griglia (x 2) (y 2) (considerata false))
    (cella_griglia (x 2) (y 3) (considerata false))
    (cella_griglia (x 2) (y 4) (considerata false))
    (cella_griglia (x 2) (y 5) (considerata false))
    (cella_griglia (x 2) (y 6) (considerata false))
    (cella_griglia (x 2) (y 7) (considerata false))
    (cella_griglia (x 2) (y 8) (considerata false))
    (cella_griglia (x 2) (y 9) (considerata false))
    (cella_griglia (x 3) (y 0) (considerata false))
    (cella_griglia (x 3) (y 1) (considerata false))
    (cella_griglia (x 3) (y 2) (considerata false))
    (cella_griglia (x 3) (y 3) (considerata false))
    (cella_griglia (x 3) (y 4) (considerata false))
    (cella_griglia (x 3) (y 5) (considerata false))
    (cella_griglia (x 3) (y 6) (considerata false))
    (cella_griglia (x 3) (y 7) (considerata false))
    (cella_griglia (x 3) (y 8) (considerata false))
    (cella_griglia (x 3) (y 9) (considerata false))
    (cella_griglia (x 4) (y 0) (considerata false))
    (cella_griglia (x 4) (y 1) (considerata false))
    (cella_griglia (x 4) (y 2) (considerata false))
    (cella_griglia (x 4) (y 3) (considerata false))
    (cella_griglia (x 4) (y 4) (considerata false))
    (cella_griglia (x 4) (y 5) (considerata false))
    (cella_griglia (x 4) (y 6) (considerata false))
    (cella_griglia (x 4) (y 7) (considerata false))
    (cella_griglia (x 4) (y 8) (considerata false))
    (cella_griglia (x 4) (y 9) (considerata false))
    (cella_griglia (x 5) (y 0) (considerata false))
    (cella_griglia (x 5) (y 1) (considerata false))
    (cella_griglia (x 5) (y 2) (considerata false))
    (cella_griglia (x 5) (y 3) (considerata false))
    (cella_griglia (x 5) (y 4) (considerata false))
    (cella_griglia (x 5) (y 5) (considerata false))
    (cella_griglia (x 5) (y 6) (considerata false))
    (cella_griglia (x 5) (y 7) (considerata false))
    (cella_griglia (x 5) (y 8) (considerata false))
    (cella_griglia (x 5) (y 9) (considerata false))
    (cella_griglia (x 6) (y 0) (considerata false))
    (cella_griglia (x 6) (y 1) (considerata false))
    (cella_griglia (x 6) (y 2) (considerata false))
    (cella_griglia (x 6) (y 3) (considerata false))
    (cella_griglia (x 6) (y 4) (considerata false))
    (cella_griglia (x 6) (y 5) (considerata false))
    (cella_griglia (x 6) (y 6) (considerata false))
    (cella_griglia (x 6) (y 7) (considerata false))
    (cella_griglia (x 6) (y 8) (considerata false))
    (cella_griglia (x 6) (y 9) (considerata false))
    (cella_griglia (x 7) (y 0) (considerata false))
    (cella_griglia (x 7) (y 1) (considerata false))
    (cella_griglia (x 7) (y 2) (considerata false))
    (cella_griglia (x 7) (y 3) (considerata false))
    (cella_griglia (x 7) (y 4) (considerata false))
    (cella_griglia (x 7) (y 5) (considerata false))
    (cella_griglia (x 7) (y 6) (considerata false))
    (cella_griglia (x 7) (y 7) (considerata false))
    (cella_griglia (x 7) (y 8) (considerata false))
    (cella_griglia (x 7) (y 9) (considerata false))
    (cella_griglia (x 8) (y 0) (considerata false))
    (cella_griglia (x 8) (y 1) (considerata false))
    (cella_griglia (x 8) (y 2) (considerata false))
    (cella_griglia (x 8) (y 3) (considerata false))
    (cella_griglia (x 8) (y 4) (considerata false))
    (cella_griglia (x 8) (y 5) (considerata false))
    (cella_griglia (x 8) (y 6) (considerata false))
    (cella_griglia (x 8) (y 7) (considerata false))
    (cella_griglia (x 8) (y 8) (considerata false))
    (cella_griglia (x 8) (y 9) (considerata false))
    (cella_griglia (x 9) (y 0) (considerata false))
    (cella_griglia (x 9) (y 1) (considerata false))
    (cella_griglia (x 9) (y 2) (considerata false))
    (cella_griglia (x 9) (y 3) (considerata false))
    (cella_griglia (x 9) (y 4) (considerata false))
    (cella_griglia (x 9) (y 5) (considerata false))
    (cella_griglia (x 9) (y 6) (considerata false))
    (cella_griglia (x 9) (y 7) (considerata false))
    (cella_griglia (x 9) (y 8) (considerata false))
    (cella_griglia (x 9) (y 9) (considerata false))
)

; questa regola serve per poter far capire alla regola "start_ordinamento" quando si può far partire l'ordinamento della "weight_cells"
; perchè la regola "start_inserimento_celle_ammissibili" ha completato il ritrovamento di tutte le celle ammissibili.
;;(defrule settaggio_a_true_di_celle_ammissibili_completate (declare (salience 501))
;;    ?celle_ammissibili_completate <- (celle_ammissibili_completate (completate false))
;;=>
;;    (modify ?celle_ammissibili_completate (completate true))
;;)


;; Quando tornerò in questo modulo dopo aver eseguito un'unguess, 
;; potrebbe succedere che la regola qui sotto si accorga che una cella
;; che prima non era ammissibile adesso lo è diventata, ma poichè l'ordinamento
;; della lista "weight_cells" non viene rifatto allora queste celle comunque non
;; verranno mai più considerate. (Questo è sicuramente un limite che ha l'agente)
(defrule nuova_cella_ammissibile (declare (salience 500))

    ?celle_ammissibili_completate <- (celle_ammissibili_completate (completate ?val)) ; non dipende dal valore di completate

    ;; prendo la cella_griglia non ancora considerata
    ?cella_griglia <- (cella_griglia (x ?x) (y ?y) (considerata false))

    ;; 1) Verifico di non aver posizionato ancora una bandierina in questa cella:
    ;; (potresti aver messo una guess ma poi successivamente hai fatto l'unguess.. Questo caso è gestito dalla regola di sotto..)
    (not (exec  (action guess) (x ?x) (y ?y)))


    ;; 2) Deve essere possibile posizionare una bandierina in questa cella,
    ;;    questo controllo si suddivide nei due controlli qui sotto:

    ;; 2.1) verifico che nella riga posso posizionare almeno 1 bandierina:
    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 1))
    ;; 2.2) verifico che nella colonna posso posizionare almeno 1 bandierina:
    (k-per-col (col ?y) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 1))

=>  

    (modify ?celle_ammissibili_completate (completate false)) ; lo setto sempre a false in modo tale che la regola più sotto che fa partire
    ; l'ordinamento non venga ancora attivata.

    ;; setto a true il campo considerata di questa cella_griglia
    (modify ?cella_griglia (considerata true))

    ;; calcolo lo score di questa cella_griglia secondo la seguente formula:
    ;; -	Score( cella[riga,colonna] ) =  
    ;;		(?max_pezzi_row + ?max_pezzi_col)
    ;;			          -
    ;;		[?num_b_row + ?num_b_col]

    (bind ?sum_1 (+ ?max_pezzi_row ?max_pezzi_col))
    (bind ?sum_2 (+ ?num_b_row ?num_b_col))
    (bind ?score_cella (- ?sum_1 ?sum_2))

    ;; assert della nuova cella_ammissibile appena trovata con il suo score appena calcolato:
    (assert (cella_ammissibile (x ?x) (y ?y) (score ?score_cella) (aggiunta false)))
)


;; Questa regola serve per coprire il caso in cui l'agente aveva posizionato un'unguess in una 
;; certa cella ma poichè ha fatto l'unguess su di essa, allora questa deve poter essere riconsiderata
;; eventualmente come cella ammissibile:
(defrule nuova_cella_ammissibile_2 (declare (salience 500))

    ?celle_ammissibili_completate <- (celle_ammissibili_completate (completate ?val)) ; non dipende dal valore di completate

    ;; prendo la cella_griglia non ancora considerata
    ?cella_griglia <- (cella_griglia (x ?x) (y ?y) (considerata false))

    ;; 1) Verifico di aver eseguito un unguess su questa cella:
    (unguess_eseguita_su_cella (x ?x) (y ?y))


    ;; 2) Deve essere possibile posizionare una bandierina in questa cella,
    ;;    questo controllo si suddivide nei due controlli qui sotto:

    ;; 2.1) verifico che nella riga posso posizionare almeno 1 bandierina:
    (k-per-row (row ?x) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 1))
    ;; 2.2) verifico che nella colonna posso posizionare almeno 1 bandierina:
    (k-per-col (col ?y) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 1))

=>  

    (modify ?celle_ammissibili_completate (completate false)) ; lo setto sempre a false in modo tale che la regola più sotto che fa partire
    ; l'ordinamento non venga ancora attivata.

    ;; setto a true il campo considerata di questa cella_griglia
    (modify ?cella_griglia (considerata true))

    ;; calcolo lo score di questa cella_griglia secondo la seguente formula:
    ;; -	Score( cella[riga,colonna] ) =  
    ;;		(?max_pezzi_row + ?max_pezzi_col)
    ;;			          -
    ;;		[?num_b_row + ?num_b_col]

    (bind ?sum_1 (+ ?max_pezzi_row ?max_pezzi_col))
    (bind ?sum_2 (+ ?num_b_row ?num_b_col))
    (bind ?score_cella (- ?sum_1 ?sum_2))

    ;; assert della nuova cella_ammissibile appena trovata con il suo score appena calcolato:
    (assert (cella_ammissibile (x ?x) (y ?y) (score ?score_cella) (aggiunta false)))
)


(defrule asserisco_cella_max_fase_2 (declare (salience 498))
    
    ; verifico che possa prendere la cella_max_fase_2 successiva:
    ?next_cella_max_fase_2 <- (next_cella_max_fase_2 (next_max true))

    ;; 1) Verifico che ci sia una cella_ammissibile che potenzialmente sarà quella max:
    ?cella_ammissibile_max <- (cella_ammissibile (x ?x_max) (y ?y_max) (score ?score_max) (aggiunta false))

    ;; 2) Tra tutte le celle ammissibili correnti la "?cella_ammissibile_max" 
    ;; DEVE ESSERE QUELLA CON LO SCORE MAGGIORE (in caso di conflitti verrà scelta l'ultima presente in WM):
    (not (cella_ammissibile (x ?x_other) (y ?y_other) (score ?score_other &:(> ?score_other ?score_max)) (aggiunta false)))

=>
    
    ; asserisco la cella_max_fase_2 corrente:
    (assert (cella_max_fase_2 (x ?x_max) (y ?y_max) (considerata false)))

    ; lo riporto a false per non far riscattare di nuovo la regola:
    (modify ?next_cella_max_fase_2 (next_max false))

    ;; ritratto la cella_ammissibile_max che ho asserito come "cella_max_fase_2" in modo tale che non venga 
    ;; più considerata successivamente:
    (retract ?cella_ammissibile_max)
)


(defrule non_ho_posizionato_gia_una_bandierina_in_cella_max_fase_2 (declare (salience 497))

    ; prendo la cella_max_fase_2 sulla quale richiederò la fire:
    ?cella_max_fase_2 <- (cella_max_fase_2 (x ?x_max) (y ?y_max) (considerata false))

    ; verifico di non aver già posizionato una bandierina in questa posizione altrimenti sarebbe inutile fare la fire
    ; su di essa:
    (not (exec (action guess) (x ?x_max) (y ?y_max)))
=>

    (modify ?cella_max_fase_2 (considerata fireRichiedibile)) ; in modo tale che possa scattare la regola di sotto
)


(defrule scopro_di_aver_posizionato_gia_una_bandierina_in_cella_max_fase_2 (declare (salience 497))

    ; prendo la cella_max_fase_2 sulla quale richiederò la fire:
    ?cella_max_fase_2 <- (cella_max_fase_2 (x ?x_max) (y ?y_max) (considerata false))

    ; verifico di non aver già posizionato una bandierina in questa posizione altrimenti sarebbe inutile fare la fire
    ; su di essa:
    (exec (action guess) (x ?x_max) (y ?y_max))

    ; verifico che possa prendere la cella_max_fase_2 successiva:
    ?next_cella_max_fase_2 <- (next_cella_max_fase_2 (next_max false))
=>

    (retract ?cella_max_fase_2) ; perchè ho già posizionato una bandierina su di essa e quindi è inutile spendere una fire
    ; su di essa

    ; questa modify farà riscattare la regola "asserisco_cella_max_fase_2_dopo_ordinamento" che prenderà la nuova cella_max_fase_2
    (modify ?next_cella_max_fase_2 (next_max true))
)

;; aggiunta
(defrule fatto_iniziale_gia_conosciuto_in_cella_max_fase_2 (declare (salience 497))

    ; prendo la cella_max_fase_2 sulla quale richiederò la fire:
    ?cella_max_fase_2 <- (cella_max_fase_2 (x ?x_max) (y ?y_max) (considerata false))

    ; verifico che la cella corrente fosse già nota all'inizio:
    (k-cell (x ?x_max) (y ?y_max) (content ?c))

    ; verifico che possa prendere la cella_max_fase_2 successiva:
    ?next_cella_max_fase_2 <- (next_cella_max_fase_2 (next_max false))
=>

    (retract ?cella_max_fase_2) ; perchè ho già posizionato una bandierina su di essa e quindi è inutile spendere una fire
    ; su di essa

    ; questa modify farà riscattare la regola "asserisco_cella_max_fase_2_dopo_ordinamento" che prenderà la nuova cella_max_fase_2:
    (modify ?next_cella_max_fase_2 (next_max true))
)



;; Questa regola verrà eseguita quando le fires a disposizione sono terminate, in questo caso
;; l'agente continuerà a posizionare tutte le bandierine rimanenti nelle celle_max che verranno
;; asserite mano mano perchè sono quelle che con maggiore probabilità potranno contenere dei pezzi di 
;; una qualche nave:
(defrule fires_terminate_ma_guess_ancora_no (declare (salience 496))

    ; prendo la cella_max_fase_2 sulla quale richiederò la fire:
    ?cella_max_fase_2 <- (cella_max_fase_2 (x ?x_max) (y ?y_max) (considerata fireRichiedibile))
    (status (step ?s)(currently running)) ; mi serve per asserire correttamente l'exec nel conseguente

    ?next_cella_max_fase_2 <- (next_cella_max_fase_2 (next_max false))

    ; verifico che il numero di fires disponibili siano 0:
    (moves (fires 0) (guesses ?num_guess_rimanenti))

    ; verifico che il numero di guesses disponibili siano maggiore di 0:
    (test (> ?num_guess_rimanenti 0))


=>

    (modify ?cella_max_fase_2 (considerata FiresTerminate)) ; in modo tale che AGENT possa capire che le fires sono terminate
    ; e quindi l'unica cosa che potrà fare sarà inserire una bandierina nella K_cell_agent asserita qui sotto!

    (modify ?next_cella_max_fase_2 (next_max true)) ;; in questo modo permetto alla regola "asserisco_cella_max_fase_2_dopo_ordinamento"
    ; di poter riscattare nel momento in cui AGENT restituirà il controllo al modulo corrente.

    ; faccio il pop del modulo corrente in modo tale che il controllo torni ad AGENT
    (pop-focus)
)


(defrule fires_e_guesses_terminate (declare (salience 496))

    ; prendo la cella_max_fase_2 sulla quale richiederò la fire:
    ?cella_max_fase_2 <- (cella_max_fase_2 (x ?x_max) (y ?y_max) (considerata fireRichiedibile))
    (status (step ?s)(currently running)) ; mi serve per asserire correttamente l'exec nel conseguente

    ?next_cella_max_fase_2 <- (next_cella_max_fase_2 (next_max false))

    ; verifico che il numero di fires e di guesses ancora disponibili siano 0:
    (moves (fires 0) (guesses 0))

    ?termina_partita <- (termina_partita (termina_game false))

=>

    (retract ?cella_max_fase_2)
    (retract ?next_cella_max_fase_2) 

    (modify ?termina_partita (termina_game true)) ; per far capire ad AGENT che l'agente richiede la terminazione
    ; del game.


    ; faccio il pop del modulo corrente in modo tale che il controllo torni ad AGENT
    (pop-focus)
)





(defrule richiedo_la_fire_a_AGENT (declare (salience 496))

    ; prendo la cella_max_fase_2 sulla quale richiederò la fire:
    ?cella_max_fase_2 <- (cella_max_fase_2 (x ?x_max) (y ?y_max) (considerata fireRichiedibile))
    (status (step ?s)(currently running)) ; mi serve per asserire correttamente l'exec nel conseguente

    ?next_cella_max_fase_2 <- (next_cella_max_fase_2 (next_max false))

    ; verifico che il numero di fires sia maggiore di 0:
    (moves (fires ?num_fires_rimanenti) (guesses ?num_guess_rimanenti))
    (test (> ?num_fires_rimanenti 0))
=>

    (modify ?cella_max_fase_2 (considerata eseguiFire)) ; in modo tale che AGENT possa capire che deve eseguire la fire su questa
    ; cella e subito dopo dovrà restituire il controllo al modulo GESTORE_fase_2 !!

    (modify ?next_cella_max_fase_2 (next_max true)) ;; in questo modo permetto alla regola "asserisco_cella_max_fase_2_dopo_ordinamento"
    ; di poter riscattare nel momento in cui AGENT restituirà il controllo al modulo corrente.

    ; faccio il pop del modulo corrente in modo tale che il controllo torni ad AGENT
    (pop-focus)
)

