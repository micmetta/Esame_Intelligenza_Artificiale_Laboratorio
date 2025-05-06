
;; IL MODULO MAIN CONTIENE ALCUNI FATTI CHE SONO UTILI SIA ALL'AMBIENTE E SIA ALL'AGENTE.
(defmodule MAIN (export ?ALL)) ;; Il main esporta TUTTO ALL'ESTERNO.

;; template che rappresenta la mossa eseguita al passo ?step
;; Quindi praticamente "exec" rappresenta proprio l'operazione che vogliamo fare ovvero una delle 4 
;; possibili (cioè: "fire", "guess", "unguess", "solve").
(deftemplate exec
   (slot step) ;; quando il valore di step arriverà a 100 ALLORA IL PROGRAMMA TERMINERA' AUTOMATICAMENTE.
   (slot action (allowed-values fire guess unguess solve)) ;; specifichiamo i 4 valori possibili del campo action.
   (slot x) ;;non usato nel caso del comando solve
   (slot y) ;;non usato nel caso del comando solve
)

;; stato corrente dell'esecuzione
;; - Il template "status" (puoi usarlo anche tu quando creerai l'agente) è utilizzato internamente dall'ambiente 
;;   perchè permette di tener traccia di quale sia lo stato corrente "in esecuzione" oppure "in stop". 
(deftemplate status (slot step) (slot currently (allowed-values running stopped)) )



;; numero di mosse ancora disponibili (tra fire e guess)
;; - Il template "moves" ti sarà sicuramente utile quando creerai l'agente perchè contiene il numero di fires
;;   e di guess che sono ancora a nostra disposizione.  
(deftemplate moves (slot fires) (slot guesses) )


;; - Il template "statistics" tiene traccia a posteriori di quante volte di quante volte le fires e le guess
;;   del nostro agente sono andate a segno e quindi tiene traccia anche di quante volte siamo riusciti ad 
;;   affondare una nave. 
(deftemplate statistics
	(slot num_fire_ok)
	(slot num_fire_ko)
	(slot num_guess_ok)
	(slot num_guess_ko)
	(slot num_safe)
	(slot num_sink) ;; conterrà il numero di navi totalmente affondate
)




;; - Il Main praticamente gestirà in maniera sequenziale il passaggio da un modulo ad un altro.
;; - Con la regola di sotto, il Main PASSERA' IL CONTROLLO (inserendolo in cima al focus) AL MODULO ENV
;;   che sarà il primo modulo ad essere eseguito. 
(defrule go-on-env-first (declare (salience 30)) ;; SALIENCE IMPORTANTE
  ?f <- (first-pass-to-env) ;; Se il fatto "first-pass-to_env" è vero allora esso verrà memorizzato nella variabile
			    ;; f 
=>

  (retract ?f) ;; f verrà ritrattato
  (focus ENV) ;; il main inserisce in cima al focus il modulo ENV
)



;; - Con la regola di sotto, quando il modulo ENV avrà terminato, rientrerà in gioco il Main che a questo punto
;;   PASSERA' IL CONTROLLO (inserendolo in cima al focus) AL MODULO AGENT.
(defrule go-on-agent  (declare (salience 20))
   (maxduration ?d)
   (status (step ?s&:(< ?s ?d)) (currently running))

 =>

    ;(printout t crlf crlf)
    ;(printout t "vado ad agent  step" ?s)
    (focus AGENT) ;; il main inserisce in cima al focus il modulo AGENT
)




; SI PASSA AL MODULO ENV DOPO CHE AGENTE HA DECISO AZIONE DA FARE
;; - Con la regola di sotto, quando il modulo AGENT avrà terminato perchè ha deciso l'azione da fare, rientrerà in 
;;   gioco il Main che a questo punto PASSERA' IL CONTROLLO (inserendolo in cima al focus) di nuovo AL MODULO ENV.
(defrule go-on-env  (declare (salience 30)) ;; SALIENCE IMPORTANTE
  ?f1<-	(status (step ?s))
  (exec (step ?s)) 	;// azione da eseguire al passo s, viene simulata dall'environment

=>

  ; (printout t crlf crlf)
  ; (printout t "vado ad ENV  step" ?s)
  (focus ENV) ;; il main inserisce in cima al focus il modulo ENV

)


;; Questa regola serve solo per imporre la terminazione del programma nel momento in cui si raggiungerà 
;; il numero di passi massimo (100).
(defrule game-over
	(maxduration ?d)
	(status (step ?s&:(>= ?s ?d)) (currently running))
=>
	(assert (exec (step ?s) (action solve)))
	(focus ENV)
)

;; QUESTI SONO I FATTI INIZIALI: (questi fatti essendo interni al main non verrano esportati)
(deffacts initial-facts
	(maxduration 100) ;; è un fatto ordinato che viene fissato a 100
	(status (step 0) (currently running)) ;; stato iniziale sarà quello di "running"
        (statistics (num_fire_ok 0) (num_fire_ko 0) (num_guess_ok 0) (num_guess_ko 0) (num_safe 0) (num_sink 0))
	(first-pass-to-env) ;; SERVIRA' AL MAIN PER FAR PARTIRE IL MODULO "ENV" !!
	(moves (fires 5) (guesses 20) ) ;; viene impostato il num max di fires e guess da rispettare
)

