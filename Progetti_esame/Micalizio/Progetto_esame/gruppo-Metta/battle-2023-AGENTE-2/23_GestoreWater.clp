; Importa dai moduli MAIN e ENV tutto ciò che è importabile.
(defmodule GESTORE_WATER (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (export ?ALL))


; Questo modulo seguirà questi controlli:

; vede in WM il fatto: (cella_water (x ?x) (y ?y) (considerata true))

; 1) Per ogni cella presente subito -> sopra(?x-1,?y), sotto(?x+1,?y), sinistra(?x,?y-1), destra(?x,?y+1)
;    rispetto alla cella_water vede se è possibile piazzare una bandierina
; 2) Quando in una certa cella è possibile piazzare una bandierina, allora calcolerà lo score di questa
;    cella e salverà la cella nel multislot chiamato "lista_spostamento_celle_con_score"
; 3) Qualora la "lista_spostamento_celle_con_score" contenesse una sola cella, allora l'agente
;    si sposterà in essa e cercherà di piazzare una qualche nave (partendo sempre dalla cella in cui si è spostato) 
;    seguendo l'ordine di importanza classico CON L'AGGIUNTA DEL SOTTOMARINO 
;    (cioè 1-corazzata, 2-incrociatore, 3-cacciatorpediniere e 4-sottomarino).
; 4) Qualora la "lista_spostamento_celle_con_score" contenesse PIU' DI UNA cella, allora l'agente
;    si sposterà quella con lo score maggiore di nuovo e cercherà di piazzare una qualche nave 
;    (partendo sempre dalla cella in cui si è spostato) seguendo l'ordine di importanza classico CON L'AGGIUNTA 
;    DEL SOTTOMARINO (cioè 1-corazzata, 2-incrociatore, 3-cacciatorpediniere e 4-sottomarino).
; 5) Qualora la "lista_spostamento_celle_con_score" fosse vuota allora il "GESTORE_WATER" terminerà subito e il controllo
;    tornerà come al solito al modulo AGENT che riprenderà la propria esecuzione da dove si era interrotto.

; Il template qui sotto mi serve per memorizzarmi le celle 
; intorno alla cella water nelle quali l'agente potrebbe spostarsi
(deftemplate cella_spostamento_con_score
    (slot x)
    (slot y)
    (slot score)
    (slot posizione_rispetto_a_water (allowed-values su giu sinistra destra))
    (slot aggiunta (allowed-values false true))
)
(deftemplate coord_celle_intorno_alla_cella_water
    (slot x_su)
    (slot y_su)
    (slot x_giu)
    (slot y_giu)
    (slot x_sinistra)
    (slot y_sinistra)
    (slot x_destra)
    (slot y_destra)
)
(deftemplate cella_max
    (slot x)
    (slot y)
    (slot direzione) ; la direzione che ha vinto
)




; PRATICAMENTE LA REGOLA QUI SOTTO SARA' LA PRIMA CHE VERRA' ESEGUITA E si preoccuperà di settare
; tutte le coordinare delle celle che fanno parte del contorno della "cella_water (x ?x) (y ?y)""
(defrule aggiunta_fatti_per_reg_successive_water (declare (salience 300))

    (cella_water (x ?x) (y ?y) (considerata true))
=>

    (assert (coord_celle_intorno_alla_cella_water (x_su (- ?x 1)) (y_su ?y) 
                                                  (x_giu (+ ?x 1)) (y_giu ?y) 
                                                  (x_sinistra ?x) (y_sinistra (- ?y 1)) 
                                                  (x_destra ?x) (y_destra (+ ?y 1))))

    ;;(assert (lista (lista_spostamento_celle_con_score))) ; asserisco la lista vuota

)


(defrule posso_spostarmi_a_destra (declare (salience 299))

    (coord_celle_intorno_alla_cella_water (x_su ?x_su) (y_su ?y_su) 
                                          (x_giu ?x_giu) (y_giu ?y_giu) 
                                          (x_sinistra ?x_sinistra) (y_sinistra ?y_sinistra) 
                                          (x_destra ?x_destra) (y_destra ?y_destra))

    ; 1) Verifico di non aver già posizionato una bandierina nella cella subito a destra rispetto alla cella water
    (not (exec  (action guess) (x ?x_destra) (y ?y_destra)))

    ; 2) Controllo di poter posizionare ancora una bandierina nella cella a destra rispetto a quella water:
    (k-per-row (row ?x_destra) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x_destra) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 1))
    ; 3)
    (k-per-col (col ?y_destra) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y_destra) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 1))

=>
    
    ; 4) CALCOLO LO SCORE DELLA cella a destra rispetto alla water:
    (bind ?score_cella_destra (+ (- ?max_pezzi_row ?num_b_row) (- ?max_pezzi_col ?num_b_col)))

    ; Asserisco la cella_destra di tipo "cella_spostamento_con_score" in WM in modo che la regola successiva possa inserirla nella lista:
    (assert (cella_spostamento_con_score (x ?x_destra) (y ?y_destra) (score ?score_cella_destra) (posizione_rispetto_a_water destra) (aggiunta false)))
)



(defrule posso_spostarmi_a_sinistra (declare (salience 298))

    (coord_celle_intorno_alla_cella_water (x_su ?x_su) (y_su ?y_su) 
                                          (x_giu ?x_giu) (y_giu ?y_giu) 
                                          (x_sinistra ?x_sinistra) (y_sinistra ?y_sinistra) 
                                          (x_destra ?x_destra) (y_destra ?y_destra))

    ; 1) Verifico di non aver già posizionato una bandierina nella cella subito a sinistra rispetto alla cella water
    (not (exec  (action guess) (x ?x_sinistra) (y ?y_sinistra)))

    ; 2) Controllo di poter posizionare ancora una bandierina nella cella a sinistra rispetto a quella water:
    (k-per-row (row ?x_sinistra) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x_sinistra) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 1))
    ; 3)
    (k-per-col (col ?y_sinistra) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y_sinistra) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 1))

=>
    
    ; 4) CALCOLO LO SCORE DELLA cella a sinistra rispetto alla water:
    (bind ?score_cella_sinistra (+ (- ?max_pezzi_row ?num_b_row) (- ?max_pezzi_col ?num_b_col)))

    ; Asserisco la cella_sinistra di tipo "cella_spostamento_con_score" in WM in modo che la regola successiva possa inserirla nella lista:
    (assert (cella_spostamento_con_score (x ?x_sinistra) (y ?y_sinistra) (score ?score_cella_sinistra) (posizione_rispetto_a_water sinistra) (aggiunta false)))
)




(defrule posso_spostarmi_su (declare (salience 297))

    (coord_celle_intorno_alla_cella_water (x_su ?x_su) (y_su ?y_su) 
                                          (x_giu ?x_giu) (y_giu ?y_giu) 
                                          (x_sinistra ?x_sinistra) (y_sinistra ?y_sinistra) 
                                          (x_destra ?x_destra) (y_destra ?y_destra))

    ; 1) Verifico di non aver già posizionato una bandierina nella cella subito sopra rispetto alla cella water
    (not (exec  (action guess) (x ?x_su) (y ?y_su)))

    ; 2) Controllo di poter posizionare ancora una bandierina nella cella sopra rispetto a quella water:
    (k-per-row (row ?x_su) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x_su) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 1))
    ; 3)
    (k-per-col (col ?y_su) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y_su) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 1))

=>
    
    ; 4) CALCOLO LO SCORE DELLA cella subito sopra rispetto alla water:
    (bind ?score_cella_su (+ (- ?max_pezzi_row ?num_b_row) (- ?max_pezzi_col ?num_b_col)))

    ; Asserisco la cella_sinistra di tipo "cella_spostamento_con_score" in WM in modo che la regola successiva possa inserirla nella lista:
    (assert (cella_spostamento_con_score (x ?x_su) (y ?y_su) (score ?score_cella_su) (posizione_rispetto_a_water su) (aggiunta false)))
)





(defrule posso_spostarmi_giu (declare (salience 296))

    (coord_celle_intorno_alla_cella_water (x_su ?x_su) (y_su ?y_su) 
                                          (x_giu ?x_giu) (y_giu ?y_giu) 
                                          (x_sinistra ?x_sinistra) (y_sinistra ?y_sinistra) 
                                          (x_destra ?x_destra) (y_destra ?y_destra))

    ; 1) Verifico di non aver già posizionato una bandierina nella cella subito sotto rispetto alla cella water
    (not (exec  (action guess) (x ?x_giu) (y ?y_giu)))

    ; 2) Controllo di poter posizionare ancora una bandierina nella cella sotto rispetto a quella water:
    (k-per-row (row ?x_giu) (num ?max_pezzi_row))
    (k-per-row-bandierine-posizionate (row ?x_giu) (num ?num_b_row))
    (test (>= (- ?max_pezzi_row ?num_b_row) 1))
    ; 3)
    (k-per-col (col ?y_giu) (num ?max_pezzi_col))
    (k-per-col-bandierine-posizionate (col ?y_giu) (num ?num_b_col))
    (test (>= (- ?max_pezzi_col ?num_b_col) 1))

=>
    
    ; 4) CALCOLO LO SCORE DELLA cella subito sopra rispetto alla water:
    (bind ?score_cella_giu (+ (- ?max_pezzi_row ?num_b_row) (- ?max_pezzi_col ?num_b_col)))

    ; Asserisco la cella_sinistra di tipo "cella_spostamento_con_score" in WM in modo che la regola successiva possa inserirla nella lista:
    (assert (cella_spostamento_con_score (x ?x_giu) (y ?y_giu) (score ?score_cella_giu) (posizione_rispetto_a_water giu) (aggiunta false)))
)


(defrule asserisco_cella_max_in_gestore_water (declare (salience 294))
    
    ;; 1) Verifico che ci sia una cella_spostamento_con_score che potenzialmente sarà quella max:
    ?cella_spostamento_con_score_max <- (cella_spostamento_con_score (x ?x_max) (y ?y_max) (score ?score_max) (posizione_rispetto_a_water ?direzione_max) (aggiunta false))

    ;; 2) Tra tutte le celle ammissibili correnti la "?cella_ammissibile_max" 
    ;; DEVE ESSERE QUELLA CON LO SCORE MAGGIORE (in caso di conflitti verrà scelta l'ultima presente in WM):
    (not (cella_spostamento_con_score (x ?x_other) (y ?y_other) (score ?score_other &:(> ?score_other ?score_max)) (posizione_rispetto_a_water ?direzione_other) (aggiunta false)))

=>
    
    ; asserisco la cella_max
    (assert (cella_max (x ?x_max) (y ?y_max) (direzione ?direzione_max)))

)


;; La regola di sotto mi serve per cancellare tutte le "coord_celle_intorno_alla_cella_water" dalla WM 
;; perchè ormai sono inutili:
(defrule cancello_coord_celle_intorno_alla_cella_water_ormai_inutili (declare (salience 293))

    ?cella_da_cancellare <- (coord_celle_intorno_alla_cella_water (x_su ?x_su) (y_su ?y_su) 
                                                                  (x_giu ?x_giu) (y_giu ?y_giu) 
                                                                  (x_sinistra ?x_sinistra) (y_sinistra ?y_sinistra) 
                                                                  (x_destra ?x_destra) (y_destra ?y_destra))
=>  
    (retract ?cella_da_cancellare)
)
;; La regola di sotto mi serve per cancellare tutte le "coord_celle_intorno_alla_cella_water" dalla WM 
;; perchè ormai sono inutili:
(defrule cancello_cella_spostamento_con_score_water_ormai_inutili (declare (salience 293))

    ?cella_da_cancellare <- (cella_spostamento_con_score (x ?x) (y ?y) (score ?score_cella) (posizione_rispetto_a_water ?pos) (aggiunta true))
=>  
    (retract ?cella_da_cancellare)
)



;;;; DA QUI IN POI PARTONO I CONTROLLI SULLE NAVI DA PIAZZARE NELLA CELLA MAX rispettando il solito  ;;;;;;
;;;; ordine CON L'AGGIUNTA DEL SOTTOMARINO:                                                          ;;;;;;
;;;; 1-corazzata - 2-incrociatore - 3-cacciatorpediniere - 4-sottomarino                                     ;;;;;;

;; QUESTE REGOLE QUI SOTTO SONO MUTAMENTE ESCLUSIVE TRA LORO, QUINDI, QUANDO UN SOTTO-MODULO INVOCATO DA UNA DI QUESTE REGOLE
;; TERMINERA' LA PROPRIA ESECUZIONE, INDIPENDENTEMENTE DALL'ESITO DEL PIAZZAMENTO delle navi, IL CONTROLLO TORNERA' SUBITO
;; AL MODULO AGENT.

; SE HA VINTO la direzione destra allora questa regola qui sotto si preoccuperà di invocare il "GESTORE_DESTRA_WATER"
(defrule chiamata_modulo_destra_water (declare (salience 292))
    
    (cella_max (x ?x_max) (y ?y_max) (direzione destra))
=>
    (focus GESTORE_DESTRA_WATER) ; quando terminerà, il controllo tornerà al modulo GESTORE_WATER
)


; SE HA VINTO la direzione sinistra allora questa regola qui sotto si preoccuperà di invocare il "GESTORE_SINISTRA_WATER"
(defrule chiamata_modulo_sinistra_water (declare (salience 292))
    
    (cella_max (x ?x_max) (y ?y_max) (direzione sinistra))
=>
    (focus GESTORE_SINISTRA_WATER) ; quando terminerà, il controllo tornerà al modulo GESTORE_WATER
)



; SE HA VINTO la direzione su allora questa regola qui sotto si preoccuperà di invocare il "GESTORE_SU_WATER"
(defrule chiamata_modulo_su_water (declare (salience 292))
    
    (cella_max (x ?x_max) (y ?y_max) (direzione su))
=>
    (focus GESTORE_SU_WATER) ; quando terminerà, il controllo tornerà al modulo GESTORE_WATER
)


; SE HA VINTO la direzione giu allora questa regola qui sotto si preoccuperà di invocare il "GESTORE_GIU_WATER"
(defrule chiamata_modulo_giu_water (declare (salience 292))
    
    (cella_max (x ?x_max) (y ?y_max) (direzione giu))
=>
    (focus GESTORE_GIU_WATER) ; quando terminerà, il controllo tornerà al modulo GESTORE_WATER
)

