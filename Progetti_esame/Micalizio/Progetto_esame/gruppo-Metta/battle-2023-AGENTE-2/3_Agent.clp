;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------

; Questo è il modulo AGENT da implementare.

; Importa dai moduli MAIN e ENV tutto ciò che è importabile.
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

; TEMPLATES DI AGENT:

; Il multislot qui sotto non può essere utilizzato altrimenti avrei problemi nel momento in cui faccio la 
; retract e comunque su Clips non posso fare il bind su una variabile che contiene gli stessi valori 
; sugli slot di un'altra variabile già presente in WM.
;(deftemplate conoscenza_iniziale
;	(multislot lista_conoscenza_ordinata)
;)

; i due template qui sotto mi serviranno per poter sapere in ogni riga e in ogni colonna quante
; bandierine ho posizionato
(deftemplate k-per-row-bandierine-posizionate
	(slot row)
	(slot num)
)
(deftemplate k-per-col-bandierine-posizionate
	(slot col)
	(slot num)
)
(deftemplate k_cell_agent ; mi permette di ricordarmi in quali celle ho già posizionato le bandierine
	(slot x)
	(slot y)
	(slot content (allowed-values water left right middle top bot sub sconosciuto))
	;; I POSSIBILI VALORI del campo "content" sono i seguenti:
	;; 1) water
	;; 2) left (è stato colpito il fianco sinistro di una nave)
	;; 3) right (è stato colpito il fianco destro di una nave)
	;; 4) middle (è stato colpito il centro di una nave)
	;; 5) top (è stato colpito il fianco superiore di una nave
	;; 6) bot (è stato colpito il fianco inferiore di una nave	
	;; 7) sub (la nave è stata affondata perchè era un sottomarino e quindi occupava una sola cella)
	;; 8) sconosciuto (non so se c'è un pezzo di nave in questa cella e qualora ci fosse non so quale sia)
	
	(slot considerato (allowed-values false true setBandierina)) ;; questo campo mi serve per capire se:
	;; 1) Ho già considerato questo fatto iniziale (true)
	;; 2) NON ho ancora considerato questo fatto iniziale (false)
	;; 3) L'ENV deve ancora settare la bandierina in questa cella (setBandierina)

	(slot current (allowed-values no yes)) ; mi permette di esprimere se una k_cell_agent in un certo momento ancora non è stata considerata del tutto o meno

)
(deftemplate corazzata
	;; il multislot conterrà i fatti di tipo "k_cell_agent"
	;; che permetteranno all'agente di ricordarsi in quali celle ha posizionato
	;; una bandierina pensando che essa appartenga alla corazzata
	(multislot celle_con_bandierina)
	;; mi dirà quante corazzate mi mancano da piazzare (all'inizio 1)
	(slot mancanti)
)
(deftemplate incrociatori
	;(multislot posizioni_3_celle_1) ; conterrà le 3 celle di tipo k_cell_bandierina
	;(multislot posizioni_3_celle_2) ; conterrà le 3 celle di tipo k_cell_bandierina

	(multislot celle_con_bandierina)
	(slot mancanti) ; inizio == 2
)

(deftemplate cacciatorpedinieri
	;(multislot posizioni_2_celle_1) ; conterrà le 2 celle di tipo k_cell_bandierina
	;(multislot posizioni_2_celle_2) ; conterrà le 2 celle di tipo k_cell_bandierina
	;(multislot posizioni_2_celle_3) ; conterrà le 2 celle di tipo k_cell_bandierina

	(multislot celle_con_bandierina)
	(slot mancanti) ; inizio == 3
)

(deftemplate sottomarini
	;(slot posizione_1_cella_1) ; conterrà le 1 cella di tipo k_cell_bandierina
	;(slot posizione_1_cella_2) ; conterrà le 1 cella di tipo k_cell_bandierina
	;(slot posizione_1_cella_3) ; conterrà le 1 cella di tipo k_cell_bandierina
	;(slot posizione_1_cella_4) ; conterrà le 1 cella di tipo k_cell_bandierina

	(multislot celle_con_bandierina) ; conterrà al massimo 4 celle di tipo k_cell_bandierina che saranno proprio quelle nelle quali 
									 ; l'agente ha deciso di posizionare la bandierina rappresentante un sottomarino.
									 ; L'aggiunta di una nuova bandierina potrà essere fatta ad esempio sempre in coda (ovviamente solo se mancanti > 0)
	(slot mancanti) ; inizio == 4 
)

;; DEVI SCRIVERE COME GESTIRE QUESTO TEMPLATE QUI SOTTO IN MODO TALE DA FARE UNA EXEC ALLA VOLTA.... !!!!!!!!!!!!!
(deftemplate nave_piazzata_agent
    (slot piazzamento (allowed-values false true)) ; se è TRUE allora vuol dire che una nave è stata piazzata
	;(multislot celle_nave_piazzata) ; conterrà le celle di tipo k_cell_agent sempre con il campo "content == sconosciuto"
)
;(deftemplate nave_piazzata_gestore_middle
;    (slot piazzamento (allowed-values false true)) ; se è TRUE allora vuol dire che una nave è stata piazzata
;)
;(deftemplate nave_piazzata_gestore_bot
;    (slot piazzamento (allowed-values false true)) ; se è TRUE allora vuol dire che una nave è stata piazzata
;)
(deftemplate nave_piazzata_gestore
    (slot piazzamento (allowed-values false true)) ; se è TRUE allora vuol dire che una nave è stata piazzata
)


; Il campo "considerata" del template qui sotto 
; mi dice se l'agente ha già considerato questa cella middle cercando di sfruttare 
; questa informazione per piazzare una qualche nave
(deftemplate cella_middle
    (slot x)
    (slot y)
    (slot considerata (allowed-values false true))
)
; Il campo "considerata" del template qui sotto 
; mi dice se l'agente ha già considerato questa cella bot cercando di sfruttare 
; questa informazione per piazzare una qualche nave
(deftemplate cella_bot
    (slot x)
    (slot y)
    (slot considerata (allowed-values false true))
)
; Il campo "considerata" del template qui sotto 
; mi dice se l'agente ha già considerato questa cella top cercando di sfruttare 
; questa informazione per piazzare una qualche nave
(deftemplate cella_top
    (slot x)
    (slot y)
    (slot considerata (allowed-values false true))
)
; Il campo "considerata" del template qui sotto 
; mi dice se l'agente ha già considerato questa cella left cercando di sfruttare 
; questa informazione per piazzare una qualche nave
(deftemplate cella_left
    (slot x)
    (slot y)
    (slot considerata (allowed-values false true))
)
; Il campo "considerata" del template qui sotto 
; mi dice se l'agente ha già considerato questa cella right cercando di sfruttare 
; questa informazione per piazzare una qualche nave
(deftemplate cella_right
    (slot x)
    (slot y)
    (slot considerata (allowed-values false true))
)
; Il campo "considerata" del template qui sotto 
; mi dice se l'agente ha già considerato questa cella right cercando di sfruttare 
; questa informazione per piazzare una qualche nave
(deftemplate cella_water
    (slot x)
    (slot y)
    (slot considerata (allowed-values false true))
)


(deftemplate unguess_agent
	(slot esegui_unguess (allowed-values false true))
)
(deftemplate bandierina_da_cancellare
    (slot x)
    (slot y)
    (slot content)
    (slot considerato)
    (slot current)
)

(deftemplate unguess_eseguita_su_cella
	(slot x)
	(slot y)
)


(deftemplate fase_2_iniziata
	(slot start (allowed-values false true))
)



;; servirà al modulo GESTORE_FASE_2 per far capire ad Agent in quale cella dovrà eseguire la fire o posizionare una bandierina:
(deftemplate cella_max_fase_2
    (slot x)
    (slot y)
    (slot considerata (allowed-values false fireRichiedibile eseguiFire FireEseguita completata FiresTerminate BandierinaSenzaFireInserita completataSenzaFire))
)

; quando il valore di "termina_game" sarà "true" allora vuol dire che AGENT potrà eseguire l'azione
; "solve" per far capire al modulo ENV che l'agente pensa di aver risolto il gioco:
(deftemplate termina_partita
	(slot termina_game (allowed-values false true))
)



;; QUESTI SONO I FATTI INIZIALI DI AGENT: (questi fatti essendo interni ad AGENT non verrano esportati)
(deffacts fatti_iniziali_agent
	
	(k-per-row-bandierine-posizionate (row 0) (num 0))
	(k-per-row-bandierine-posizionate (row 1) (num 0))
	(k-per-row-bandierine-posizionate (row 2) (num 0))
	(k-per-row-bandierine-posizionate (row 3) (num 0))
	(k-per-row-bandierine-posizionate (row 4) (num 0))
	(k-per-row-bandierine-posizionate (row 5) (num 0))
	(k-per-row-bandierine-posizionate (row 6) (num 0))
	(k-per-row-bandierine-posizionate (row 7) (num 0))
	(k-per-row-bandierine-posizionate (row 8) (num 0))
	(k-per-row-bandierine-posizionate (row 9) (num 0))
	(k-per-col-bandierine-posizionate (col 0) (num 0))
	(k-per-col-bandierine-posizionate (col 1) (num 0))
	(k-per-col-bandierine-posizionate (col 2) (num 0))
	(k-per-col-bandierine-posizionate (col 3) (num 0))
	(k-per-col-bandierine-posizionate (col 4) (num 0))
	(k-per-col-bandierine-posizionate (col 5) (num 0))
	(k-per-col-bandierine-posizionate (col 6) (num 0))
	(k-per-col-bandierine-posizionate (col 7) (num 0))
	(k-per-col-bandierine-posizionate (col 8) (num 0))
	(k-per-col-bandierine-posizionate (col 9) (num 0))

	; i 4 FATTI INIZIALI SETTATI QUI SOTTO CORRISPONDERANNO ALLE "GUESS-FATTE" perchè verranno utilizzati dall'agente per poter
	; tener traccia sia di ciò che ha già posizionato, in particolare potrà ricordarsi delle celle nelle quali ha 
	; già posizionato una bandierina, e sia di ciò che gli manca ancora da posizionare:
	(corazzata (celle_con_bandierina) (mancanti 1))
	(incrociatori (celle_con_bandierina) (mancanti 2))
	(cacciatorpedinieri (celle_con_bandierina) (mancanti 3))
	(sottomarini (celle_con_bandierina) (mancanti 4))

	(nave_piazzata_agent (piazzamento false))
	(nave_piazzata_gestore (piazzamento false))

	(fase_2_iniziata (start false))
	(termina_partita (termina_game false))
)


;; RICORDA: 
;; Ogni volta che l'agente asserisce un "exec" DOBBIAMO GARANTIRE CHE venga eseguito il 
;; (pop-focus), in altre parole questo vuol dire che quando l'agente delibererà l'azione che vuole fare,
;; IL CONTROLLO DELLE TORNARE AL MAIN perchè sarà esso a cedere il controllo di nuovo al modulo "ENV" perchè
;; l'ambiente dovrà considerare l'azione che l'agente vuole eseguire; in questo modo l'agente eseguirà veramente
;; l'azione. Questo sempre per il fatto che l'ambiente permette l'esecuzione di un'azione per volta. 


(defrule agent_richiede_la_terminazione_della_partita (declare (salience 512))

	(termina_partita (termina_game true))
	(status (step ?s)(currently running))
=> 

	(assert (exec (step ?s) (action solve))) ; richiedo ad ENV la terminazione della partita
	(pop-focus) ; eseguo il pop dal focus in modo tale che ENV possa eseguire la terminazaione del game.
)




; regola che dopo aver ricevuto la richiesta di una fire dal modulo GESTORE_FASE_2, si preoccupa di richiederla al modulo ENV:
(defrule eseguo_fire_in_agent (declare (salience 511))
	?cella_max_fase_2 <- (cella_max_fase_2 (x ?x_max) (y ?y_max) (considerata eseguiFire))
	(status (step ?s)(currently running))
=>

	(assert (exec (step ?s) (action fire) (x ?x_max) (y ?y_max))) ; specifico che voglio eseguire la fire in queste coordinate x,y
	(modify ?cella_max_fase_2 (considerata FireEseguita)) ; in modo tale che la cella_max_fase_2 non verrà più riconsiderata e possa scattare
	; la penultima regola di AGENT quando il controllo passerà da ENV ad AGENT subito dopo l'esecuzione della
	; fire.

	; faccio il pop in modo tale che il "MAIN" mandi in esecuzione "ENV" 
	; che eseguirà la fire proprio nelle coordinate x,y presenti in "?cella_max_fase_2" 
	(pop-focus)

)

;; Questa regola verrà attivata solamente se l'agente si trova nella fase e solamente se le fires sono terminate:
(defrule posiziono_direttamente_bandierina_in_agent (declare (salience 511))

	(fase_2_iniziata (start true)) ; mi assicuro di trovarmi nella fase 3

	; prendo la cella_max_fase_2 sulla quale non posso eseguire la fire ma sulla quale l'agente piazzerà 
	; una bandierina (quando il controllo ritornerà ad AGENT sarà attivabile l'ultima regola di agent che è 
	; chiamata "restituisco_il_controllo_a_GestoreFase3_2"):
    ?cella_max_fase_2 <- (cella_max_fase_2 (x ?x_max) (y ?y_max) (considerata FiresTerminate))

	(status (step ?s)(currently running))
=>

	(assert (exec (step ?s) (action guess) (x ?x_max) (y ?y_max))) ; specifico che voglio piazzare una bandierina in queste coordinate x,y
	
	(modify ?cella_max_fase_2 (considerata BandierinaSenzaFireInserita)) ; in modo tale che quando il controllo tornerà ad 
	; AGENT verrà eseguita l'ultima regola chiamata "restituisco_il_controllo_a_GestoreFase3_2".


	; faccio il pop in modo tale che il "MAIN" mandi in esecuzione "ENV" 
	; che eseguirà la fire proprio nelle coordinate x,y presenti in "?cella_max_fase_2" 
	(pop-focus)

)





(defrule elimino_dalla_WM_unguess_completata (declare (salience 511))
	?unguess_completata <- (exec (step ?s) (action unguess) (x ?x) (y ?y))
	?bandierina_da_cancellare <- (bandierina_da_cancellare (x ?x) (y ?y) (content sconosciuto) (considerato true) (current yes))
=>
	(retract ?unguess_completata)
	(retract ?bandierina_da_cancellare)
)

(defrule controllo_piazzamento_nave_agent (declare (salience 511))
    ; Quando sarà vero il fatto qui sotto, allora il modulo AGENT capirà che uno dei sotto-moduli invocati dalle
	; regole qui sotto è riuscito a piazzare una nave e quindi bisogna immediatamente restituire il controllo 
	; al MAIN in modo tale che possa a sua volta invocare l'ENV e piazzare le bandierine richieste:
    ?f_piazzamento_gestore <-(nave_piazzata_gestore (piazzamento ?val_1)) ; con "?val_1" mi rendo indipendente dal suo valore.. Così questa regola potrà scattare sia se è true e sia se è false
    ?f_piazzamento_agent <- (nave_piazzata_agent (piazzamento ?val_2)) ; con "?val_1" mi rendo indipendente dal suo valore.. Così questa regola potrà scattare sia se è true e sia se è false
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content sconosciuto) (considerato setBandierina) (current yes)) ;; questa è la cella nella quale ENV deve inserire la bandierina
	
	(not (exec  (action guess) (x ?x) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione
	(status (step ?s)(currently running)) ; mi serve per asserire correttamente l'exec nel conseguente
=>	
	(modify ?f_piazzamento_gestore (piazzamento false)) ; lo setto a false in modo tale che quando rientreò in GESTORE_MIDDLE si potrà ripartire di nuovo con i controlli di piazzamento delle navi
	(modify ?f_piazzamento_agent (piazzamento false)) ; lo setto a false in modo tale che la regola corrente non riscatti all'infinito
    
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y))) ; specifico che voglio piazzare la bandierina in queste coordinate x,y
	(modify ?new_cella (considerato true)) ; serve per far capire che questo fatto "?new_cella" è stato completamente considerato
	
	;;;; QUI AGGIORNO IL CAMPO current di "?new_cella" inserendo il valore "no" al campo "current" per far capire che questa k_cell_agent è stata considerata completamente:
	(modify ?new_cella (current no))
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	(pop-focus) ; faccio il pop in modo tale che il "MAIN" mandi in esecuzione "ENV" che piazzerà la bandierina proprio nelle coordinate x,y presenti in "?new_cella"
)
(defrule set_current_no_per_fatto_iniziale_conosciuto (declare (salience 511))
    
	?f_piazzamento_gestore <-(nave_piazzata_gestore (piazzamento false)) ; mi serve per assicurarmi che un gestore sia riuscito a piazzare una nave
    ?f_piazzamento_agent <- (nave_piazzata_agent (piazzamento false))
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content ?val_content) (considerato true) (current yes))
	
	;; con il test di sotto controllo se in WM ci sia una new_cella che come campo content ha uno di quelli descritti qui sotto 
	;; e inoltre ha ancora il campo "current" a "yes":
	(test (or (eq ?val_content top) (eq ?val_content bot) (eq ?val_content left) (eq ?val_content right) (eq ?val_content middle) (eq ?val_content water)))

=>	
	
	;;;; QUI AGGIORNO IL CAMPO current di "?new_cella" inserendo il valore "no" al campo "current" per far capire che questa k_cell_agent è stata considerata completamente:
	(modify ?new_cella (current no)) ;; se l'antecedente è verificato allora setto anche per questa cella il valore del campo current a "no"
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
)



; Qui sotto gestisco il caso "sub" che sarà il primo ad essere gestito proprio perchè adremo a posizionare
; subito la bandierina nella posizione in cui c'è il sottomarino invocando l'ENV:
(defrule posiziono_sottomarino (declare (salience 510))
	(k-cell (x ?x) (y ?y) (content sub) ) ; verifico che in WM ci sia come fatto iniziale la posizione di un sottomarino
	(status (step ?s)(currently running)) ; il fatto status BISOGNA CONSIDERARLO PERCHE' CI PERMETTE DI 
	;; AVERE L'INFORMAZIONE SU QUELLO CHE E' LO STEP CORRENTE perchè esso sarà sempre un marcatore 
	;; dell'exec (basta che vedi il conseguente).
	(not (exec  (action guess) (x ?x) (y ?y))) ; verifico di non aver già posizionato una bandierina in questa posizione

	;?sottomarini <- (sottomarini (celle_con_bandierina $?lista) (mancanti ?m))
	;(> ?m 0) ; verifico che mi manca ancora un sottomarino da posizionare (bisogna fixarlo..)
=>
	; asserisco di voler piazzare una bandierina in cella(?x,?y)
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y))) ;; ogni exec ha sempre lo step s corrente
							     						   ;; e quindi ogni exec è sempre associato ad un 
							     						   ;; particolare istante di tempo.


	; creo la k_cell_agent e setto il suo campo considerato a false in modo tale che la regola di memorizzazione
	; posso aggiornare la nostra struttura dove manteniamo aggiornate le posizioni nelle quali
	; l'agente posiziona le sue bandierine:
	(assert (k_cell_agent (x ?x) (y ?y) (content sub) (considerato false) (current yes)))
	
	; faccio il pop dal focus per permettere subito all'ENV di eseguire veramente il posizionamento della bandierina in (?x,?y):
	(pop-focus)
)


; PROBABILMENTE DEVE TOGLIERE L'(exec (step ?s) (action guess) (x ?x) (y ?y)) CHE HA RICHIESTO LA REGOLA DI SOPRA...
(defrule memorizzo_sottomarino (declare (salience 509))
	?new_cella <- (k_cell_agent (x ?x) (y ?y) (content sub) (considerato false) (current yes))
	?sottomarini <- (sottomarini (celle_con_bandierina $?lista) (mancanti ?m))
	?k_row_bandierine <- (k-per-row-bandierine-posizionate (row ?x) (num ?num_b_row))
	?k_col_bandierine <- (k-per-col-bandierine-posizionate (col ?y) (num ?num_b_col))
=>
	(modify ?sottomarini (celle_con_bandierina (insert$ $?lista (+ (length$ $?lista) 1) ?new_cella)))
	(modify ?new_cella (considerato true) (current no))
	(modify ?sottomarini (mancanti (- ?m 1)))
	(modify ?k_row_bandierine (num (+ ?num_b_row 1))) ; aggiungo una bandierina in riga ?x
	(modify ?k_col_bandierine (num (+ ?num_b_col 1))) ; aggiungo una bandierina in colonna ?y
)


; La regola di sotto si preoccupa di prendere un fatto iniziale "top" e di asserire (cella_top (x ?x) (y ?y) (considerata false)) in modo tale
; che la regola "start_gestione_top" possa scattare e una volta eseguita potrà richiamare il modulo "11_GESTORE_TOP":
(defrule creo_nuovo_fatto_iniziale_top (declare (salience 508))
	
	(k-cell (x ?x) (y ?y) (content top) )
	(status (step ?s)(currently running)) 
	(not (exec  (action guess) (x ?x) (y ?y)))

	; Il not qui sotto mi assicura il fatto che non vengano gestiti 2 o più "top" iniziali, altrimenti
	; ci sarebbero dei conflitti e le cose non funzionerebbero correttamente:
	(not (k_cell_agent (x ?x_esistente) (y ?y_esistente) (content top) (considerato false) (current yes)))

=>	
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
	(assert (k_cell_agent (x ?x) (y ?y) (content top) (considerato false) (current yes))) ; asserisco la cella nella quale l'agente posizionerà la bandierina
	; in modo tale che l'agente possa ricordarsi di questo posizionamento
	
	; asserisco che questa cella top dovrà essere considerata per piazzare una qualche nave:
	(assert (cella_top (x ?x) (y ?y) (considerata false)))
	
	(pop-focus) ;; in modo tale che l'ENV possa posizionare la bandierina in cella(x ?x) (y ?y) dove siamo certi esserci un "top" 
)

; Adesso, la regola di sotto fa questo:
; Se c'è un top non ancora considerato
; Allora, chiamo semplicemente il modulo "gestore_caso_top" inserendolo in cima allo stack
(defrule start_gestione_top (declare (salience 508))

	; controllo che ci sia ancora una qualche cella_top in WM che non è stata ancora considerata
	?cella_top <- (cella_top (x ?x) (y ?y) (considerata false))

=>
	; dico che adesso questa cella_top è stata considerata perchè subito sotto
	; il modulo "GESTORE_TOP" la prenderà in cosiderazione per piazzare una nave:
	(modify ?cella_top(considerata true))

	; Invoco il modulo qui sotto che si occuperà di cercare di piazzare una qualche nave 
	; sfruttando l'informazione sulla cella top trovata nell'antecedente:
	(focus GESTORE_TOP) ; quando terminerà, il controllo tornerà al MODULO AGENT
)


;; Quando il GESTORE_TOP terminerà potrebbe attivarsi subito la regola qui sotto qualora il GESTORE_TOP
;; appena completato richiedesse l'esecuzione di una unguess:
(defrule esecuzione_unguess_da_parte_di_AGENT_richiesta_da_gestore_top (declare (salience 508))

	; controllo che ci sia ancora una qualche cella_bot in WM che è stata considerata ma per la quale 
	; il suo gestore ha richiesto l'esecuzione di una unguess:
	?cella_top <- (cella_top (x ?x) (y ?y) (considerata true))
	?unguess_agent <- (unguess_agent (esegui_unguess true))
	(status (step ?s)(currently running)) ; mi serve per asserire correttamente l'exec nel conseguente

	; vedo in quale posizione bisogna togliere la bandierina:
	?bandierina_da_cancellare <- (bandierina_da_cancellare (x ?x_b) (y ?y_b) (content ?val_content) (considerato ?val_considerato) (current ?val_current))

=>	
	; specifico che voglio togliere la bandierina in queste coordinate ?x_b,?y_b
	(assert (exec (step ?s) (action unguess) (x ?x_b) (y ?y_b)))

	; mi conservo in WM il ricordo su quali sono le celle sulle quali l'agente ha fatto l'unguess
	; (per maggiore leggibilità delle azioni eseguite da parte dell'agente)
	(assert (unguess_eseguita_su_cella (x ?x_b) (y ?y_b)))


	; al termine di questa regola il controllo tornerà ad AGENT che rieseguirà la 
	; regola chiamata "start_gestione_bot" grazie al fatto che resetto qui sotto il 
	; campo "considerata" a false della cella_top che ha righiesto l'unguess:
	; questo ciclo dovrebbe ripetersi fino a quando partendo dalla "?cella_top" il GestoreBot
	; non riesce ad inserire una qualsiasi nave !!
	(modify ?cella_top (considerata false))

	(retract ?unguess_agent) ; non serve più

	; faccio il pop in modo tale che il "MAIN" mandi in esecuzione "ENV" 
	; che toglierà la bandierina proprio nelle coordinate (x_b,y_b)
	(pop-focus)
)



; La regola di sotto si preoccupa di prendere un fatto iniziale "bot" e di metterlo in coda a "conoscenza_ordinata":
(defrule creo_nuovo_fatto_iniziale_bot (declare (salience 507))

	(k-cell (x ?x) (y ?y) (content bot) )
	(status (step ?s)(currently running)) 
	(not (exec  (action guess) (x ?x) (y ?y)))

	; Il not qui sotto mi assicura il fatto che non vengano gestiti 2 o più "bot" iniziali, altrimenti
	; ci sarebbero dei conflitti e le cose non funzionerebbero correttamente:
	(not (k_cell_agent (x ?x_esistente) (y ?y_esistente) (content bot) (considerato false) (current yes)))
=>	
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
	(assert (k_cell_agent (x ?x) (y ?y) (content bot) (considerato false) (current yes)))

	; asserisco che questa cella bot dovrà essere considerata per piazzare una qualche nave:
	(assert (cella_bot (x ?x) (y ?y) (considerata false)))

	; faccio il pop dal focus per permettere subito all'ENV di eseguire veramente il posizionamento della bandierina in (?x,?y):
	(pop-focus)
)
; Adesso, la regola di sotto fa questo:
; Se c'è un bot non ancora considerato
; Allora, chiamo semplicemente il modulo "gestore_caso_bot" inserendolo in cima allo stack
(defrule start_gestione_bot (declare (salience 507))

	; controllo che ci sia ancora una qualche cella_bot in WM che non è stata ancora considerata
	?cella_bot <- (cella_bot (x ?x) (y ?y) (considerata false))

=>
	; dico che adesso questa cella_bot è stata considerata perchè subito sotto
	; il modulo "GESTORE_BOT" la prenderà in cosiderazione per piazzare una nave:
	(modify ?cella_bot(considerata true))

	; Invoco il modulo qui sotto che si occuperà di cercare di piazzare una qualche nave 
	; sfruttando l'informazione sulla cella middle trovata nell'antecedente:
	(focus GESTORE_BOT) ; quando terminerà il controllo tornerà al MODULO AGENT
)
;; Quando il GESTORE_BOT terminerà potrebbe attivarsi subito la regola qui sotto qualora il GESTORE_BOT
;; appena completato richiedesse l'esecuzione di una unguess:
(defrule esecuzione_unguess_da_parte_di_AGENT_richiesta_da_gestore_bot (declare (salience 507))

	; controllo che ci sia ancora una qualche cella_bot in WM che p stata considerata ma per la quale 
	; il suo gestore ha richiesto l'esecuzione di una unguess:
	?cella_bot <- (cella_bot (x ?x) (y ?y) (considerata true))
	?unguess_agent <- (unguess_agent (esegui_unguess true))
	(status (step ?s)(currently running)) ; mi serve per asserire correttamente l'exec nel conseguente

	; vedo in quale posizione bisogna togliere la bandierina:
	?bandierina_da_cancellare <- (bandierina_da_cancellare (x ?x_b) (y ?y_b) (content ?val_content) (considerato ?val_considerato) (current ?val_current))

=>	
	; specifico che voglio togliere la bandierina in queste coordinate ?x_b,?y_b
	(assert (exec (step ?s) (action unguess) (x ?x_b) (y ?y_b)))

	; mi conservo in WM il ricordo su quali sono le celle sulle quali l'agente ha fatto l'unguess
	; (per maggiore leggibilità delle azioni eseguite da parte dell'agente)
	(assert (unguess_eseguita_su_cella (x ?x_b) (y ?y_b)))


	; al termine di questa regola il controllo tornerà ad AGENT che rieseguirà la 
	; regola chiamata "start_gestione_bot" grazie al fatto che resetto qui sotto il 
	; campo "considerata" a false della cella_bot che ha righiesto l'unguess:
	; questo ciclo dovrebbe ripetersi fino a quando partendo dalla "?cella_bot" il GestoreBot
	; non riesce ad inserire una qualsiasi nave !!
	(modify ?cella_bot (considerata false))

	(retract ?unguess_agent) ; non serve più

	; faccio il pop in modo tale che il "MAIN" mandi in esecuzione "ENV" 
	; che toglierà la bandierina proprio nelle coordinate x_b,y_b
	(pop-focus)
)




; La regola di sotto si preoccupa di prendere un fatto iniziale "left" e di metterlo in coda a "conoscenza_ordinata":
(defrule creo_nuovo_fatto_iniziale_left (declare (salience 506))

	(k-cell (x ?x) (y ?y) (content left) )
	(status (step ?s)(currently running)) 
	(not (exec  (action guess) (x ?x) (y ?y)))

	; Il not qui sotto mi assicura il fatto che non vengano gestiti 2 o più "left" iniziali, altrimenti
	; ci sarebbero dei conflitti e le cose non funzionerebbero correttamente:
	(not (k_cell_agent (x ?x_esistente) (y ?y_esistente) (content left) (considerato false) (current yes)))

=>
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y))) ; asserisco di voler piazzare una bandierina in cella(?x,?y) in modo che venga richiamato l'ENV
	(assert (k_cell_agent (x ?x) (y ?y) (content left) (considerato false) (current yes)))

	; asserisco che questa cella left dovrà essere considerata per piazzare una qualche nave:
	(assert (cella_left (x ?x) (y ?y) (considerata false)))

	(pop-focus)
)
; Adesso, la regola di sotto fa questo:
; Se c'è un left non ancora considerato
; Allora, chiamo semplicemente il modulo "gestore_caso_left" inserendolo in cima allo stack
(defrule start_gestione_left (declare (salience 506))

	; controllo che ci sia ancora una qualche cella_left in WM che non è stata ancora considerata
	?cella_left <- (cella_left (x ?x) (y ?y) (considerata false))

=>
	; dico che adesso questa cella_left è stata considerata perchè subito sotto
	; il modulo "GESTORE_LEFT" la prenderà in cosiderazione per piazzare una nave:
	(modify ?cella_left(considerata true))

	; Invoco il modulo qui sotto che si occuperà di cercare di piazzare una qualche nave 
	; sfruttando l'informazione sulla cella middle trovata nell'antecedente:
	(focus GESTORE_LEFT) ; quando terminerà il controllo tornerà al MODULO AGENT
)
;; Quando il GESTORE_LEFT terminerà potrebbe attivarsi subito la regola qui sotto qualora il GESTORE_LEFT
;; appena completato richiedesse l'esecuzione di una unguess:
(defrule esecuzione_unguess_da_parte_di_AGENT_richiesta_da_gestore_left (declare (salience 506))

	; controllo che ci sia ancora una qualche cella_bot in WM che è stata considerata ma per la quale 
	; il suo gestore ha richiesto l'esecuzione di una unguess:
	?cella_left <- (cella_left (x ?x) (y ?y) (considerata true))
	?unguess_agent <- (unguess_agent (esegui_unguess true))
	(status (step ?s)(currently running)) ; mi serve per asserire correttamente l'exec nel conseguente

	; vedo in quale posizione bisogna togliere la bandierina:
	?bandierina_da_cancellare <- (bandierina_da_cancellare (x ?x_b) (y ?y_b) (content ?val_content) (considerato ?val_considerato) (current ?val_current))

=>	
	; specifico che voglio togliere la bandierina in queste coordinate ?x_b,?y_b
	(assert (exec (step ?s) (action unguess) (x ?x_b) (y ?y_b)))

	; mi conservo in WM il ricordo su quali sono le celle sulle quali l'agente ha fatto l'unguess
	; (per maggiore leggibilità delle azioni eseguite da parte dell'agente)
	(assert (unguess_eseguita_su_cella (x ?x_b) (y ?y_b)))


	; al termine di questa regola il controllo tornerà ad AGENT che rieseguirà la 
	; regola chiamata "start_gestione_bot" grazie al fatto che resetto qui sotto il 
	; campo "considerata" a false della cella_left che ha righiesto l'unguess:
	; questo ciclo dovrebbe ripetersi fino a quando partendo dalla "?cella_left" il GestoreBot
	; non riesce ad inserire una qualsiasi nave !!
	(modify ?cella_left (considerata false))

	(retract ?unguess_agent) ; non serve più

	; faccio il pop in modo tale che il "MAIN" mandi in esecuzione "ENV" 
	; che toglierà la bandierina proprio nelle coordinate x_b,y_b
	(pop-focus)
)



; La regola di sotto si preoccupa di prendere un fatto iniziale "right" e di metterlo in coda a "conoscenza_ordinata":
(defrule creo_nuovo_fatto_iniziale_right (declare (salience 505))
	(k-cell (x ?x) (y ?y) (content right) )
	(status (step ?s)(currently running)) 
	(not (exec  (action guess) (x ?x) (y ?y)))

	; Il not qui sotto mi assicura il fatto che non vengano gestiti 2 o più "right" iniziali, altrimenti
	; ci sarebbero dei conflitti e le cose non funzionerebbero correttamente:
	(not (k_cell_agent (x ?x_esistente) (y ?y_esistente) (content right) (considerato false) (current yes)))

=>	
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y))) ; asserisco di voler piazzare una bandierina in cella(?x,?y) in modo che venga richiamato l'ENV
	(assert (k_cell_agent (x ?x) (y ?y) (content right) (considerato false) (current yes)))

	; asserisco che questa cella right dovrà essere considerata per piazzare una qualche nave:
	(assert (cella_right (x ?x) (y ?y) (considerata false)))

	(pop-focus)
)
; Adesso, la regola di sotto fa questo:
; Se c'è un right non ancora considerato
; Allora, chiamo semplicemente il modulo "gestore_caso_right" inserendolo in cima allo stack
(defrule start_gestione_right (declare (salience 505))

	; controllo che ci sia ancora una qualche cella_right in WM che non è stata ancora considerata
	?cella_right <- (cella_right (x ?x) (y ?y) (considerata false))

=>
	; dico che adesso questa cella_right è stata considerata perchè subito sotto
	; il modulo "GESTORE_RIGHT" la prenderà in cosiderazione per piazzare una nave:
	(modify ?cella_right(considerata true))

	; Invoco il modulo qui sotto che si occuperà di cercare di piazzare una qualche nave 
	; sfruttando l'informazione sulla cella right trovata nell'antecedente:
	(focus GESTORE_RIGHT) ; quando terminerà il controllo tornerà al MODULO AGENT
)
;; Quando il GESTORE_RIGHT terminerà potrebbe attivarsi subito la regola qui sotto qualora il GESTORE_RIGHT
;; appena completato richiedesse l'esecuzione di una unguess:
(defrule esecuzione_unguess_da_parte_di_AGENT_richiesta_da_gestore_right (declare (salience 505))

	; controllo che ci sia ancora una qualche cella_right in WM che è stata considerata ma per la quale 
	; il suo gestore ha richiesto l'esecuzione di una unguess:
	?cella_right <- (cella_right (x ?x) (y ?y) (considerata true))
	?unguess_agent <- (unguess_agent (esegui_unguess true))
	(status (step ?s)(currently running)) ; mi serve per asserire correttamente l'exec nel conseguente

	; vedo in quale posizione bisogna togliere la bandierina:
	?bandierina_da_cancellare <- (bandierina_da_cancellare (x ?x_b) (y ?y_b) (content ?val_content) (considerato ?val_considerato) (current ?val_current))

=>	
	; specifico che voglio togliere la bandierina in queste coordinate ?x_b,?y_b
	(assert (exec (step ?s) (action unguess) (x ?x_b) (y ?y_b)))

	; mi conservo in WM il ricordo su quali sono le celle sulle quali l'agente ha fatto l'unguess
	; (per maggiore leggibilità delle azioni eseguite da parte dell'agente)
	(assert (unguess_eseguita_su_cella (x ?x_b) (y ?y_b)))


	; al termine di questa regola il controllo tornerà ad AGENT che rieseguirà la 
	; regola chiamata "start_gestione_bot" grazie al fatto che resetto qui sotto il 
	; campo "considerata" a false della cella_right che ha righiesto l'unguess:
	; questo ciclo dovrebbe ripetersi fino a quando partendo dalla "?cella_right" il GestoreBot
	; non riesce ad inserire una qualsiasi nave !!
	(modify ?cella_right (considerata false))

	(retract ?unguess_agent) ; non serve più

	; faccio il pop in modo tale che il "MAIN" mandi in esecuzione "ENV" 
	; che toglierà la bandierina proprio nelle coordinate x_b,y_b
	(pop-focus)
)



; La regola di sotto si preoccupa di prendere un fatto iniziale "middle" e di metterlo in coda a "conoscenza_ordinata":
(defrule creo_nuovo_fatto_iniziale_middle (declare (salience 504))

	(k-cell (x ?x) (y ?y) (content middle)) ; deve essere presente in WM
	(status (step ?s)(currently running)) 
	(not (exec  (action guess) (x ?x) (y ?y)))

	; Il not qui sotto mi assicura il fatto che non vengano gestiti 2 o più "middle" iniziali, altrimenti
	; ci sarebbero dei conflitti e le cose non funzionerebbero correttamente:
	(not (k_cell_agent (x ?x_esistente) (y ?y_esistente) (content middle) (considerato false) (current yes)))

=>	

	; asserisco di voler piazzare una bandierina in cella(?x,?y) in modo che venga richiamato l'ENV
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))


	; QUI SOTTO ASSERISCO UNA VARIABILE CHE SARA' DI TIPO k_cell_agent e che conterrà al suo 
	; interno gli stessi identici valori di "?fatto_middle".
	; Non ci sarà bisogno di aggiungere questa nuova variabile asserita in una lista perchè tanto 
	; la differenza sostanziale tra il tipo "k-cell" e il tipo "k_cell_agent" è sia che in quest'ultimo
	; c'è il campo "considerato" e sia il fatto che un fatto di tipo "k_cell_agent" verrà cancellato non 
	; appena sarà risolto mentre tutti i fatti di tipo "k-cell" rimarranno fino al termine del programma
	; in WM perchè potranno servire per evitare in un futuro di fare le "unguess" su posizioni sulle quali siamo
	; certi grazie ai fatti iniziali che deve essere piazzata una bandierina. 
	
	; creo una nuova variabile "?fatto_middle_new" che conterrà gli stessi valori di ?fatto_middle
	(assert (k_cell_agent (x ?x) (y ?y) (content middle) (considerato false) (current yes)))

	; asserisco che questa cella middle dovrà essere considerata per piazzare una qualche nave:
	(assert (cella_middle (x ?x) (y ?y) (considerata false)))

	; faccio il pop dal focus per permettere subito all'ENV di eseguire veramente il posizionamento della bandierina in (?x,?y):
	(pop-focus)
)
; Adesso, la regola di sotto fa questo:
; Se c'è un middle non ancora considerato
; Allora, chiamo semplicemente il modulo "gestore_caso_middle" inserendolo in cima allo stack
(defrule start_gestione_middle (declare (salience 504))

	; controllo che ci sia ancora una qualche cella_middle in WM che non è stata ancora considerata
	?cella_middle <- (cella_middle (x ?x) (y ?y) (considerata false))

=>
	; dico che adesso questa cella_middle è stata considerata perchè subito sotto
	; il modulo "GESTORE_MIDDLE" la prenderà in cosiderazione per piazzare una nave:
	(modify ?cella_middle(considerata true))

	; Invoco il modulo qui sotto che si occuperà di cercare di piazzare una qualche nave 
	; sfruttando l'informazione sulla cella middle trovata nell'antecedente:
	(focus GESTORE_MIDDLE) ; quando terminerà il controllo tornerà al MODULO AGENT
)





; La regola di sotto si preoccupa di prendere un fatto iniziale "water" e di metterlo in coda a "conoscenza_ordinata":
(defrule creo_nuovo_fatto_iniziale_water (declare (salience 503))

	(k-cell (x ?x) (y ?y) (content water)) ; deve essere presente in WM
	(status (step ?s)(currently running)) 
	(not (cella_water (x ?x) (y ?y) (considerata true))) ; verifico di non aver già considerato questo fatto iniziale

=>
	(assert (k_cell_agent (x ?x) (y ?y) (content water) (considerato false) (current yes)))

	; asserisco che questa cella water dovrà essere considerata per piazzare una qualche nave:
	(assert (cella_water (x ?x) (y ?y) (considerata false)))
)
; Adesso, la regola di sotto fa questo:
; Se c'è un water non ancora considerato
; Allora, chiamo semplicemente il modulo "gestore_caso_water" inserendolo in cima allo stack
(defrule start_gestione_water (declare (salience 503))

	; controllo che ci sia ancora una qualche cella_water in WM che non è stata ancora considerata
	?cella_water <- (cella_water (x ?x) (y ?y) (considerata false))

=>
	; dico che adesso questa cella_middle è stata considerata perchè subito sotto
	; il modulo "GESTORE_MIDDLE" la prenderà in cosiderazione per piazzare una nave:
	(modify ?cella_water(considerata true))

	; Invoco il modulo qui sotto che si occuperà di cercare di piazzare una qualche nave 
	; sfruttando l'informazione sulla cella middle trovata nell'antecedente:
	(focus GESTORE_WATER) ; quando terminerà il controllo tornerà al MODULO AGENT
)




;;;;; CON LA REGOLA DI SOTTO VIENE FATTA PARTIRE LA FASE 2 ;;;;;
(defrule start_fase_2 (declare (salience 502))

	?fase_2_iniziata <- (fase_2_iniziata (start false)) ; perchè altrimenti vuol dire che la fase 3 è già iniziata

	;; mi assicuro che non ci siano più fatti iniziali non ancora esplorati:
	(not (cella_top (x ?x_top) (y ?y_top) (considerata false)))
	(not (cella_bot (x ?x_bot) (y ?y_bot) (considerata false)))
	(not (cella_left (x ?x_left) (y ?y_left) (considerata false)))
	(not (cella_right (x ?x_right) (y ?y_right) (considerata false)))
	(not (cella_middle (x ?x_middle) (y ?y_middle) (considerata false)))
	(not (cella_water (x ?x_water) (y ?y_water) (considerata false)))

=>

	(modify ?fase_2_iniziata (start true)) ; parte la fase 3

	;; chiamo il modulo che si preoccuperà di gestire la fase 3 (tranne le fires che verranno eseguite sempre
	;; dal modulo AGENT una volta che il modulo 3 avrà selezionato ogni volta la cella sulla quale eseguirla):
	(focus GESTORE_FASE_2)

)



(defrule restituisco_il_controllo_a_GestoreFase3_1 (declare (salience 502))

	(fase_2_iniziata (start true)) ; mi assicuro che la fase 3 sia già partita
	?cella_max_fase_2_appena_completata <- (cella_max_fase_2 (x ?x_max) (y ?y_max) (considerata FireEseguita))
=>	

	(modify ?cella_max_fase_2_appena_completata (considerata completata))
	;; chiamo il modulo che si preoccuperà di gestire la fase 3 (tranne le fires che verranno eseguite sempre
	;; dal modulo AGENT una volta che il modulo 3 avrà selezionato ogni volta la cella sulla quale eseguirla):
	(focus GESTORE_FASE_2)
)
(defrule restituisco_il_controllo_a_GestoreFase3_2 (declare (salience 502))

	(fase_2_iniziata (start true)) ; mi assicuro che la fase 3 sia già partita
	?cella_max_fase_2_appena_completata <- (cella_max_fase_2 (x ?x_max) (y ?y_max) (considerata BandierinaSenzaFireInserita))
=>	

	(modify ?cella_max_fase_2_appena_completata (considerata completataSenzaFire))
	(focus GESTORE_FASE_2)
)



