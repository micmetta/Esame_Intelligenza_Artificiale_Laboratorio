;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
; Questo è il modulo AGENT per l'agente RANDOM.

; Importa dai moduli MAIN e ENV tutto ciò che è importabile.
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

; TEMPLATES DI AGENT:
(deftemplate cella_guess_richiesta
	(slot x)
	(slot y)
)
(deftemplate cella_guess ; serve all'agente per ricordarsi in quali celle ha già inserito le bandierine
	(slot x)
	(slot y)
)
(deftemplate start_guess ; serve all'agente per sapere quando deve generare una nuova cella sulla quale posizionare 
; una bandierina e quando invece deve restituire il controllo al modulo MAIN per permettere all'ambiente di poter
; posizionare una bandierina
	(slot start (allowed-values false true))
)

; FATTI INIZIALI:
(deffacts fatti_iniziali
	(start_guess (start true))
)




(defrule agent_richiede_la_terminazione_della_partita (declare (salience 500))

	(moves (fires ?num_fires) (guesses ?num_guesses))
	(test(eq ?num_guesses 0))

	(status (step ?s)(currently running))
=> 

	(assert (exec (step ?s) (action solve))) ; richiedo ad ENV la terminazione della partita
	(pop-focus) ; eseguo il pop dal focus in modo tale che ENV possa eseguire la terminazione del game.
)


(defrule genera_guess_cella (declare (salience 499))

	?start_guess <- (start_guess (start true))
	(moves (fires ?num_fires) (guesses ?num_guesses))
	(test(> ?num_guesses 0))
=>
	(bind ?x_gen (random 0 9))
	(bind ?y_gen (random 0 9))
	(assert (cella_guess_richiesta (x ?x_gen) (y ?y_gen)))
	(modify ?start_guess (start false))
)


;; La regola di sotto si attiverà nel momento in cui è già stata posizionata una bandierina in (cella_guess_richiesta (x ?x_gen) (y ?y_gen))
;; asserita dalla regola precedente: 
(defrule guess_non_eseguibile (declare (salience 498))

	?start_guess <- (start_guess (start false))
	(moves (fires ?num_fires) (guesses ?num_guesses))
	(test(> ?num_guesses 0))
	?cella_guess_richiesta <- (cella_guess_richiesta (x ?x_gen) (y ?y_gen))
	(cella_guess (x ?x_gen) (y ?y_gen))
=>

	(retract ?cella_guess_richiesta)
	(modify ?start_guess (start true))
)


(defrule eseguo_guess (declare (salience 497))

	?start_guess <- (start_guess (start false))
	(moves (fires ?num_fires) (guesses ?num_guesses))
	(test(> ?num_guesses 0))
	?cella_guess_richiesta <- (cella_guess_richiesta (x ?x_gen) (y ?y_gen))
	(not (cella_guess (x ?x_gen) (y ?y_gen)))
	(status (step ?s)(currently running))
=>
	
	; specifico che voglio posizionare la bandierina in cella(?x_gen,?y_gen):
	(assert (exec (step ?s) (action guess) (x ?x_gen) (y ?y_gen)))
	; mi ricordo di aver già posizionato la bandierina in cella(?x_gen,?y_gen):
	(assert (cella_guess (x ?x_gen) (y ?y_gen)))
	
	;ritratto ?cella_guess_richiesta tanto non serve più:
	(retract ?cella_guess_richiesta)

	(modify ?start_guess (start true))

	(printout t "Coordinate della cella sulla quale faro' la guess: ("?x_gen","?y_gen")" crlf)
	(pop-focus)
)
