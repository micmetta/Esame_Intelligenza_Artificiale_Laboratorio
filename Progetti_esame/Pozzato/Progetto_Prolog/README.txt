Per eseguire i test sul labirinto1:

1) ['dominio1.pl'].
2) ['azioni1.pl'].
3) ['IDA_star.pl'].
4) initialize. 
5) prova(Cammino).  


Per eseguire i test sul labirinto2:

1) ['dominio2.pl'].
2) ['azioni2.pl'].
3) ['IDA_star.pl'].
4) initialize. 
5) prova(Cammino). 


- All'interno di 'azioni1.pl' e 'azioni2.pl', in particolare all'interno dei predicati "applicabile" è possibile decommentare sia la metrica di distanza (Euclidea o Manhattan) e sia l'euristica h(n) (combinazione lineare o minimo) che si vuole utilizzare per permettere all'agente di ottenere il cammino finale.


OUTPUT: 

- CamminoFinaleRicotruitoINV TROVATO: è il cammino che contiene al proprio interno tutte le azioni che l'agente ha eseguito per riuscire ad arrivare in uno degli stati finali (compreso eventuali azioni di backtracking per tornare indietro qualora l'agente si fosse bloccato).
- lunghezza CamminoFinaleRicotruitoINV TROVATO: lunghezza del cammino citato pocanzi.

- CamminoFinaleRicotruitoDirettoINV TROVATO: è il cammino che contiene al proprio interno tutte le azioni che l'agente ha eseguito per riuscire ad arrivare in uno degli stati finali (senza considerare eventuali azioni di backtracking).
- lunghezza CamminoFinaleRicotruitoDirettoINV TROVATO: lunghezza del cammino citato pocanzi.

- La lunghezza "CamminoFinaleRicotruitoDirettoINV" è il valore che è stato inserito all'interno del powerpoint in modo da poter essere confrontato con la lunghezza del cammino individuato dall'Iterative deeping implementato a lezione.
				  