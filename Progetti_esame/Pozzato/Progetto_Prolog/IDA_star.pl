
% In particolare, quello che vogliamo fare è:

% 1) Partire da uno stato iniziale
% 2) Cerchiamo un'azione applicabile nello stato in cui ci troviamo adesso
% 3) Lo stato in cui sono adesso E' FINALE?
      
%    3.1) SI, ALLORA: la computazione termina (uso il cut per tagliare tutte le altre alternative trovate) e restituire il cammino trovato con la sua lunghezza.
%    3.2) NO, ALLORA:

            % Per ogni azione applicabile trovata (partendo dallo stato corrente), calcoliamo:
            %    f(n) = h(n) + g(n)
            % ove:
            % n = stato in cui possiamo andare spostandoci dallo stato in cui troviamo adesso.
            % h(n) = distanza di Manhattan dallo stato n ad uno stato finale.
            % g(n) = costo del cammino per arrivare dallo stato iniziale fino allo stato n (da incrementare di 1 perchè assumiamo di spostarci nel nuovo stato n).

            % 3.2.1) Applichiamo una di queste azioni applicabili (scegliendo ogni volta quella che MINIMIZZA la f(n))
            % 3.2.2) Ripartitamo dallo stato in cui arrivo tramite l'azione selezionata al passo precedente per cercare di raggiungere lo stato finale
            %    ripentendo gli stessi passi dal 2) fino a quando non raggiungo lo stato finale.
            %    Inoltre, quando visitiamo uno stato, facciamo in modo che l'agente se lo ricordi in modo 
            %    tale da non cadere in un loop infinito rientrando ogni volta in stati nei quali è già stato.




% Questo predicato mi serve per settare la prima profondità massima (che sarà 1):
initialize:-
    %retractall(current_depth(_)), % tolgo tutti i fatti di current_depth aggiunti precedentemente
    %assert(current_depth(1)), % setto la prima profondità da provare 
    
    retractall(current_Gn(_)), % tolgo tutti i fatti di current_Gn aggiunti precedentemente
    assert(current_Gn(0)). % setto la prima profondità da provare 

% IDEA INTELLIGENTE per migliorare la strategia "itdeeping": 
% Non mi serve provare PROFMAX = 170 mila per un labirinto
% di dimensione 10 x 10, quindi in questo caso poichè voglio visitare uno stato
% al più una sola volta, allora posso inserire un controllo dove verifico che se 
% la profondità che devo andare a testare adesso è maggiore di 100 allora
% stoppo tutto il programma PERCHE' SONO CERTO CHE CON LA DIMENSIONE 10 X 10
% del labirinto è impossibile avere cammini che coprono più di 100 stati,
% in questo modo in maniera furba evito di entrare nel loop nel momento in cui
% NON DOVESSE ESSERCI UNA SOLUZIONE !! 
% Questo controllo però posso
% farlo SOLO SE CONOSCO A PRIORI LA DIMENSIONE DEL LABIRINTO E GLI OSTACOLI
% NON CAMBIANO DINAMICAMENTE e questo non è sempre possibile. Per questo 
% il prof dice sempre che dobbiamo sfruttare il più possibile sulla conoscenza
% che abbiamo sul dominio stesso. 
% QUESTO E' PROPRIO QUELLO CHE DOVRAI NEL 
% PROGETTO D'ESAME per quanto riguarda il mini progetto sul Prolog !!!!


% Definizione di fn/1 deve essere fornita
% Definizione di fn/1 deve essere fornita
fn([_, _, Fn, _], Fn).

% Confronto basato su Fn e Gn in modo da mantenere l'ordine stabile
compare_by_fn_s(Order, [Dir1, _, Fn1, _], [Dir2, _, Fn2, _]) :-
    
    compare(CompareFn, Fn1, Fn2), % confronta i due valori di Fn1 e Fn2 usando la funzione CompareFn(..) che definiamo sotto.
    
    (CompareFn = (=) -> % controllo se Fn1 e Fn1 sono uguali.
        
        compare(OrderS, Dir1, Dir2), % Ordina in base al valore di G1 e G2 (che sono le g(n) dei due stati) nel caso in cui Fn1 e Fn2 siano uguali.
        Order = OrderS % allora dico che l'ordine è quello trovato dalla compare(OrderS, G1, G2).
    ;
        Order = CompareFn % altrimenti ordina semplicemente in base ad Fn1 e Fn2 e l'ordine finale, che in questo caso è quello che ho ottenuto da 
        % compare(CompareFn, Fn1, Fn2), lo salvo dentro "Order".
    ).

% Ordina la lista in base a Fn e Gn mantenendo l'ordine stabile.
% La lista ordinata finale verrà inserita nel secondo parametro "ListaOrdinata".
ordina_lista(Lista, ListaOrdinata) :-
    % "predsort" è un algoritmo di sorting del Prolog che prende come primo parametro una funzione ("compare_by_fn_s" che abbiamo definito sopra) 
    % in base alla quale possiamo specificare su quali elementi della Lista vogliamo eseguire l'ordinamento.
    predsort(compare_by_fn_s, Lista, ListaOrdinata).


% Estrae le teste delle liste
estrai_teste([], []).
% prende dalla lista ordinata solamente le azioni
estrai_teste([[Testa, _, _, _] | Resto], [Testa | RestoTeste]) :-
    estrai_teste(Resto, RestoTeste).


rimuovi_lista_interna(_, [], []).
rimuovi_lista_interna(ListaInterna, [ListaInterna|Resto], NuovaLista) :-
    length(ListaInterna, Lunghezza),
    Lunghezza =:= 4,
    rimuovi_lista_interna(ListaInterna, Resto, NuovaLista).
rimuovi_lista_interna(ListaInterna, [AltraLista|Resto], [AltraLista|NuovoResto]) :-
    rimuovi_lista_interna(ListaInterna, Resto, NuovoResto).


% Il predicato rimuovi_se_lunghezza_diversa prende da ListaDiListe (che contiene sia le quadruple e sia non quadruple) solo gli elementi che sono veramente delle quadruple
% e li inserisce in NuovaLista.
rimuovi_se_lunghezza_diversa(ListaDiListe, NuovaLista) :-
        include(lista_di_lunghezza_4, ListaDiListe, NuovaLista).
% Controlla se gli elementi interni alla a "Lista" sono veramente 4.
lista_di_lunghezza_4(Lista) :- 
        length(Lista, 4).


% caso base
rimuovi_coda_non_istantiata([], []).

% serve per controllare se la lista (come primo parametro) abbia la coda non istanziata
rimuovi_coda_non_istantiata([H|T], Result) :-
    length(T, L),
    L > 0,  % Verifico che ci sia almeno una possibile coda
    append([H|T], [], Result). % appende in coda la lista vuota alla prima e mi mette tutto nella terza lista (Result). In questo modo tolgo la coda non istanziata.

rimuovi_coda_non_istantiata(ListaConCoda, ListaSenzaCoda) :-
    ListaConCoda = [_], % Se c'è solo un elemento, non c'è coda da rimuovere
    ListaSenzaCoda = ListaConCoda.



% Verifico se la lista è vuota controllando la sua lunghezza
lista_vuota(Lista) :-
    length(Lista, 0). % se la lunghezza di Lista è 0 allora ottengo "true".


% - caso base 1..
scorri_lista(_, [HeadCurrent|_], _, _, SRipartenza, _):-
    write('Sono nel caso base scorri_lista e HeadCurrent corrente is: '), write(HeadCurrent), write('\n'),
    HeadCurrent==SRipartenza, % mi assicuro che la testa corrente sia uguale a SRipartenza (in questo modo sono certo che HeadCurrent sia lo stato dal quale devo partire per calcolare gli stati
    % e aggiungerli in testa a ListaStatiVisitatiNew che è il primo parametro di scorri_lista). Dal caso base uscirò quando sarò certo che HeadCurrent ->(5,1) == Posizione -> (5,1)
    write('Caso base scorri_lista terminato. '), write('\n'),
    !.

% dove pos(5, 1) è lo stato di ripartenza.
% Adesso chiamo scorri_lista per mettere avanti a  pos(5, 3), tutti gli stati che ci sono tra il primo pos(5, 3) (testa del primo parametro) e pos(5, 1)(SRipartenza):


% ricostruzione_cammino(ListaStatiVisitatiFinale, CamminoFinaleRicotruito) % chiamata esterna che faccio solo la prima volta.

% ricostruzione_cammino([HeadCurrent| [HeadTail | RestoTail] ], [AzioneRis|CamminoFinaleRicotruito]):- % intestazione predicato che contiene la chiamata ricorsiva
% ricostruzione_cammino([HeadCurrent|_], _):- % caso base
% ricostruzione_cammino([HeadTail | RestoTail], CamminoFinaleRicotruito), % chiamata ricorsiva fino al caso base

scorri_lista([HeadCurrent|ListaStatiVisitatiNewAggiornato], [ HeadCurrent| [HeadTail | RestoTail] ], _, StatoBloccato, SRipartenza, [ HeadCurrent | ListaStatiIntermedi]):-

    % Alla prima chiamata di scorri_lista:
    % [HeadCurrent| [HeadTail | RestoTail] ] = [(5,3) | [(5,2) | (5,1), ...] ]
    % HeadCurrent == (5,3)
    % HeadTail == (5,2)
    % SRipartenza == (5,1)

    % Quando esco dal caso base scorri_lista:
    % [HeadCurrent| [HeadTail | RestoTail] ] = [(5,2) | [(5,1) | ....] ]
    % HeadCurrent == (5,2)
    % HeadTail == (5,1)

    % Quando esco dal caso base scorri_lista:
    % [HeadCurrent| [HeadTail | RestoTail] ] = [(5,1) | [......] ]
    % HeadCurrent == (5,1)
    % HeadTail == (...)

    write('Sono nel caso due di scorri_lista PRIMA della chiamata ricorsiva e i parametri correnti sono i seguenti: '), write('\n'),
    write('HeadCurrent (nel secondo caso scorri_lista(..)'), write(HeadCurrent), write('\n'),
    write('HeadTail (nel secondo caso scorri_lista(..)'), write(HeadTail), write('\n'),
    write('RestoTail (nel secondo caso scorri_lista(..)'), write(RestoTail), write('\n'),

    % NON RIESCO A FARGLI CAPIRE CHE OGNI VOLTA CHE TERMINA UNA CHIAMATA RICORSIVA(DOPO CHE IL CASO BASE E' TERMINATO con successo), ogni valore di HeadCurrent
    % deve essere messo in testa al primo parametro di scorri_lista !!!! (prova chatgpt..)

    scorri_lista([_|ListaStatiVisitatiNewAggiornato], [HeadTail|RestoTail], _, StatoBloccato, SRipartenza, ListaStatiIntermedi), % chiamata ricorsiva fino al caso base

    % una volta arrivato al caso base di scorri_lista, inizierò ad inserire in testa al primo parametro (ovvero a ListaStatiVisitatiNew, ovvero in testa a pos(5,3))
    % tutte gli stati intermedi fino a quando termineranno tutte le sottochiamate di scorri_lista.

    %StatoIntermedio = HeadCurrent,
    %ListaStatiVisitatiNewAggiornato = [HeadCurrent|ListaStatiVisitatiNewAggiornato],

    % una volta che sono arrivato al caso base di scorri_lista, inizierò ad inserire in testa al primo parametro (ovvero a "ListaStatiVisitatiNew") 
    % di questo scorri_lista tutti gli stati intermedi che ho trovato:
    write('HeadCurrent (nel secondo caso scorri_lista(..) DOPO della chiamata ricorsiva'), write(HeadCurrent), write('\n'),
    write('HeadTail (nel secondo caso scorri_lista(..) DOPO della chiamata ricorsiva'), write(HeadTail), write('\n'),
    write('RestoTail (nel secondo caso scorri_lista(..) DOPO della chiamata ricorsiva'), write(RestoTail), write('\n'),
    write('ListaStatiVisitatiNewAggiornato DOPO della chiamata ricorsiva: '), write(ListaStatiVisitatiNewAggiornato), write('\n').



% simuliamo il ciclo for suggli elementi di una lista:
% (ricorda: le var sempre con la lettera maiuscola!)
for([], _, _, _). % caso base
for([Head|_], ListaStatiVisitati, Gn, Head):- % [posizione|restoLista] = ListaVisitati
    
    write('---- Head di ListaStatiVisitati corrente Nel PRIMO for PRIMA DI APPLICABILE: '), write(Head), write('\n'),

    %(applicabile(Az, Posizione, Gn, _, [Posizione|RestoLista]) -> 

    %   write('---- Az Nel for DOPO DI APPLICABILE (prima di risolvi): '), write(Az), write('\n'),
    %   risolvi(Posizione, [Az|_], [Posizione|RestoLista], Gn)),
    %    write('---- Az Nel for DOPO DI APPLICABILE (dopo di risolvi): '), write(Az), write('\n'),


    % Prendo tutte le azioni applicabili (e le salvo in LRis) nello stato corrente descritto dalla variabile "Posizione" in questo momento:
    findall([Azioni, Head, Fn, Gn], applicabile(Azioni, Head, Gn, Fn, ListaStatiVisitati), LRis),
    write('ListaAzioniApplicabili (non corretta) (nel primo for(..)): '), write(LRis), write('\n'),

    % verifico che NON CI SIA NESSUNA AZIONE APPLICABILE nello stato corrente:
    %lista_vuota(LRis), %c'era prima..

    % verifico che CI SIA ALMENO UN'AZIONE APPLICABILE nello stato corrente:
    \+lista_vuota(LRis). % una volta che anche questo è vero allora in Posizione ci sarà la posizione corrente che restituisco al chiamante.

    %!.

    % a questo punto vado alla posizione sucessiva ovvero allo stato successivo richiamando ricorsivamente la clausola for:
    %for(RestoLista, ListaStatiVisitati, Gn, _). % considero la nuova testa (che sarà nella posizione successiva rispetto a quella di prima).


% lo uso solo per controllare se "RestoLista" non è vuota, qualora non lo fosse allora richiamo for([Posizione|RestoLista], ListaStatiVisitati, Gn, Posizione) su RestoLista:
for([_|RestoLista], ListaStatiVisitati, Gn, SRipartenza):-
    
    write('---- controllo RestoLista Nel SECONDO for: '), write(RestoLista), write('\n'),
    
    % verifico che CI SIANO ALTRI STATI IN RestoLista:
    %\+lista_vuota(RestoLista),

    % richiamo di nuovo il for di sopra.
    for(RestoLista, ListaStatiVisitati, Gn, SRipartenza).

    %!.

    %for(ListaStatiVisitatiNew, ListaStatiVisitatiNew, Gn, SRipartenza)


% la nuova lista con in cima solo SRipartenza (in questo esempio di sotto SRipartenza == pos(3,9) e quindi dovrò cancellare dalla testa pos(2,10) e pos(3,10)) verrà salvata in "ListaStatiVisitatiDirettiNew":

% ListaStatiVisitatiDiretti (corrente) (nel secondo risolvi(..)): [pos(2,10),pos(3,10),pos(3,9),pos(2,9),pos(1,9),pos(1,8),pos(1,7),pos(1,6),pos(1,5),
% pos(1,4),pos(1,3),pos(1,2),pos(1,1),pos(2,1),pos(2,2),pos(2,3),pos(2,4),pos(3,4),pos(3,3),pos(3,2),pos(3,1),pos(4,1),pos(5,1),pos(5,2),pos(5,1),pos(6,1),
% pos(6,2),pos(6,3),pos(6,4),pos(5,4),pos(4,4),pos(4,3),pos(4,2)]

% primo parametro: ListaStatiVisitatiDiretti
% al termine del caso base "ListaStatiVisitatiDirettiNew" conterrà tutti gli stati di "ListaStatiVisitatiDiretti"
metti_testa_SRipartenza([Head|Tail], SRipartenza, Tail):- % caso base
    Head==SRipartenza,
    write('Sono arrivato al caso base di metti_testa_SRipartenza e quindi al termine di questa chiamata ListaStatiVisitatiDirettiNew sara uguale a Tail, 
    ovvero a ListaStatiVisitatiDiretti senza però lo stato di ripartenza perche lo mettera il secondo caso di risolvi..'), write('\n'), 
    !.

metti_testa_SRipartenza([Head|Tail], SRipartenza, ListaStatiVisitatiDirettiNew):-

    write('caso base 1 metti_testa_SRipartenza e Head corrente'), write(Head), write('\n'),
    metti_testa_SRipartenza(Tail, SRipartenza, ListaStatiVisitatiDirettiNew). % chiamata ricorsiva fino al raggiungimento del caso base.



% Questo sarà il wrapper che eseguirà il predicato risolvi utilizzando la 
% profondità imposta nell'initialize che è quella corrente:
prova(CamminoFinaleRicotruitoDirettoINV):-

    iniziale(S0), 
    current_Gn(Gn),
    write('---- Gn di partenza: '), write(Gn), write('\n'), write('\n'),

    % parametro 3: ListaStatiVisitati (conterrà tutti gli stati visitati compreso quelli nei quali ho fatto BT)
    % parametro 6: ListaStatiVisitatiDiretti (conterrà tutti gli stati visitati senza considerare quelli nei quali ho fatto BT)
    risolvi(S0, _, [], Gn, CamminoFinaleRicotruito, [], CamminoFinaleRicotruitoDiretto), 

    write('\n'), write('\n'),
    write('\n'), write('\n'),
    %write('---- CamminoFINALERicostruito NON INVERTITO TROVATO CON TERMINAZIONE APERTA: '), write(CamminoFinaleRicotruito), write('\n'), write('\n'),
    %inversioneCamminoFinaleRicostruito(CamminoFinaleRicotruito, CamminoFinaleRicotruitoINV),
    inverti(CamminoFinaleRicotruito, CamminoFinaleRicotruitoINV),
    write('---- CamminoFinaleRicotruitoINV TROVATO: '), write(CamminoFinaleRicotruitoINV), write('\n'),
    write('---- lunghezza CamminoFinaleRicotruitoINV TROVATO: '), length(CamminoFinaleRicotruitoINV, L),  write(L), write('\n'),
    write('\n'), write('\n'),

    %write('---- CamminoFinaleRicotruitoDiretto NON INVERTITO TROVATO CON TERMINAZIONE APERTA: '), write(CamminoFinaleRicotruitoDiretto), write('\n'), write('\n'),
    %inversioneCamminoFinaleRicostruito(CamminoFinaleRicotruito, CamminoFinaleRicotruitoINV),
    inverti(CamminoFinaleRicotruitoDiretto, CamminoFinaleRicotruitoDirettoINV),
    write('---- CamminoFinaleRicotruitoDirettoINV TROVATO: '), write(CamminoFinaleRicotruitoDirettoINV), write('\n'),
    write('---- lunghezza CamminoFinaleRicotruitoDirettoINV TROVATO: '), length(CamminoFinaleRicotruitoDirettoINV, LDir),  write(LDir), write('\n'),
    !.


% invertiamo il cammino finale ricostruito
%inversioneCamminoFinaleRicostruito(CamminoFinaleRicotruito, CamminoFinaleRicotruitoINV):-


% inverti PIU' EFFICIENTE:
inverti(L, InvL):- % wrapper
    inver(L, [], InvL).

inver([], Temp, Temp). % caso base

inver([Head | Tail], Temp, Ris):- % caso ricorsivo
    inver(Tail, [Head | Temp], Ris).




% Se nel prova di sopra il programma fallisce, allora vuol dire che 
% per il D che stava usando, non esiste una soluzione e quindi
% entrerò nel predicato prova di sotto che si preoccuperà di 
% aumentare la profondità D di 1 e dopodichè richiamerà ricorsivamente il
% predicato prova (di sopra) in modo che riprovi ad applicare il risolvi(..)
% con la nuova profondità D che ho settato qui sotto:
%prova(Cammino):-
%    current_depth(D), % recupero la D corrente
%    DNew is D+1, % creo la nuova D aggiungendo 1 alla D vecchia 
%    retractall(current_depth(_)), % cancello tutti i fatti current_depth(_) (anche se ce ne sarà ogni volta solo una) perchè voglio considerare la nuova profondità
%    assert(current_depth(DNew)), % Asserisco che la nuova profondità massima sarà DNew!
%    prova(Cammino). % INFINE FACCIO LA CHIAMATA RICORSIVA, ovviamente l'interprete
    % rispetterà l'ordine e quindi eseguirà prima il prova di sopra, se questo fallirà
    % allora entrerà in questo prova dove aggiornerà la nuova profondità massima
    % da rivalutare e così via..




% MI SERVE COME WRAPPER, OVVERO COME PREDICATO PIU' GENERALE PER SCRIVERE MENO COMANI IN INPUT 
% DA DARE AL PROLOG PER IL RITROVAMENTO DELLA SOLUZIONE.
% % MaxProf = NUM MAX DI PASSI CHE FACCIAMO PER ESPLORARE UN RAMO IN PROFONDITA'
%prova(Cammino, MaxProf):- 
%    iniziale(S0), risolvi(S0, Cammino, [], MaxProf). 


% Scorro la ListaStatiVisitati in questo modo:
% 1) Parto dalla testa corrente e me la metto in una variabile (HeadCurrent), 
% 2) Prendo l'elemento subito successivo alla testa corrente (NextHeadCurrent),
% 3) Faccio la differenza tra: HeadCurrent - NextHeadCurrent
% 4) Ci saranno diversi casi possibili:
%    4.1) (0,1) -> "destra"
%    4.2) (0,-1) -> "sinistra"
%    4.3) (1,0) -> "su"
%    4.3) (-1,0) -> "giu"
% 5) Se la NextHeadCurrent == StatoIniziale
%    5.1) Caso base.
%    Altrimenti:
%    5.1) Ricomincio da 1).


% (3,2) - (3,1) = (0,1)
% (1,2) - (1,1) = (0,1) 

% 
% caso "giu" pos(X1,Y1), pos(X2,Y2):
% pos(X1,Y1) = pos(2,1) 
% pos(X2,Y2) = pos(1,1)
% (X1 > X2)

% caso "su" pos(X1,Y1), pos(X2,Y2):
% pos(X1,Y1) = pos(2,1) 
% pos(X2,Y2) = pos(3,1)
% (X1 < X2)

% caso "destra" pos(X1,Y1), pos(X2,Y2):
% pos(X1,Y1) = pos(3,2) 
% pos(X2,Y2) = pos(3,1)
% (Y1 > Y2)

% caso "sinistra" pos(X1,Y1), pos(X2,Y2):
% pos(X1,Y1) = pos(3,1) 
% pos(X2,Y2) = pos(3,2)
% (Y2 > Y1)


%Azioni possibili:
azioneEseguita(pos(X1,_), pos(X2,_), AzioneRis):-
    X1>X2,
    AzioneRis = "giu",
    !.

azioneEseguita(pos(X1,_), pos(X2,_), AzioneRis):-
    X1<X2,
    AzioneRis = "su",
    !.

azioneEseguita(pos(_,Y1), pos(_,Y2), AzioneRis):-
    Y1>Y2,
    AzioneRis = "destra",
    !.

azioneEseguita(pos(_,Y1), pos(_,Y2), AzioneRis):-
    Y1<Y2,
    AzioneRis = "sinistra",
    !.



%inserisci caso base..
ricostruzione_cammino([HeadCurrent|_], _):-
    write('Sono nel caso base ricostruzione_cammino e HeadTail corrente: '), write(HeadCurrent), write('\n'),
    iniziale(HeadCurrent), % mi assicuro che la testa corrente sia lo stato iniziale.
    !,
    write('Caso base ricostruzione_cammino terminato. '), write('\n').


% primo parametro = ListaStatiVisitatiFinale
ricostruzione_cammino([HeadCurrent| [HeadTail | RestoTail] ], [AzioneRis|CamminoFinaleRicotruito]):-

    write('HeadCurrent (nel secondo caso ricostruzione_cammino(..)'), write(HeadCurrent), write('\n'),
    write('HeadTail (nel secondo caso ricostruzione_cammino(..)'), write(HeadTail), write('\n'),
    write('RestoTail (nel secondo caso ricostruzione_cammino(..)'), write(RestoTail), write('\n'),

    ricostruzione_cammino([HeadTail | RestoTail], CamminoFinaleRicotruito), % chiamata ricorsiva fino al caso base
    

    % una volta che ho completato il caso base verrà eseguito questo di sotto a partire dall'ultima chiamata ricorsiva fatta:
    azioneEseguita(HeadCurrent, HeadTail, AzioneRis),
    write('AzioneRis (nel secondo caso ricostruzione_cammino(..) dopo azioneEseguita'), write(AzioneRis), write('\n').



% Caso base: se lo stato S corrente è quello finale, allora mi fermo.
% - La lista vuota mi serve per restituire all'utente tutte le azioni che il robottino 
%   ha eseguito.
% - Il "-" come terzo parametro lo metto giusto per avere lo stesso numero di parametri con l'altro "risolvi" ricorsivo
%   e quindi poichè nel caso base qui sotto lo stato S è finale allora non mi frega di salvarmelo.
% - Il "-" come quarto parametro lo metto perhè se mi trovo nello stato finale non mi interessa di vedere la profondità massima.
risolvi(S, Cammino, ListaStatiVisitati, _, CamminoFinaleRicotruito, ListaStatiVisitatiDiretti, CamminoFinaleRicotruitoDiretto):-
    
    write('S (corrente) (nel CASO BASE risolvi(..): '), write(S), write('\n'),
    write('Cammino (nel CASO BASE risolvi(..): '), write(Cammino), write('\n'),
    finale(S), 
    write('arrivato (nel CASO BASE risolvi(..)'), write(Cammino), write('\n'), write('\n'),
    

    ListaStatiVisitatiFinale = [S|ListaStatiVisitati],
    write('ListaStatiVisitatiFinale (nel CASO BASE risolvi(..)'), write(ListaStatiVisitatiFinale), write('\n'), write('\n'),


    ListaStatiVisitatiDirettiFinale = [S|ListaStatiVisitatiDiretti],
    write('ListaStatiVisitatiDirettiFinale (nel CASO BASE risolvi(..)'), write(ListaStatiVisitatiDirettiFinale), write('\n'), write('\n'),

    ricostruzione_cammino(ListaStatiVisitatiFinale, CamminoFinaleRicotruito),
    write('CamminoFinaleRicotruito ANCHE CON AZIONI PER USCIRE DA UNO STATO BLOCCANTE (nel CASO BASE risolvi(..)'), write(CamminoFinaleRicotruito), write('\n'),

    ricostruzione_cammino(ListaStatiVisitatiDirettiFinale, CamminoFinaleRicotruitoDiretto),
    write('CamminoFinaleRicotruitoDiretto SENZA AZIONI PER USCIRE DA UNO STATO BLOCCANTE (nel CASO BASE risolvi(..)'), write(CamminoFinaleRicotruitoDiretto), write('\n'),

    !. % con il cut dico di tagliare tutte le eventuali alternative di BT.



% "PrimaAzione" bisogna metterlo in testa a "Cammino" in modo tale che quando tutte le chiamate ricorsive termineranno, 
%  partendo dall'ultima sotto-chiamata fatta e andando a ritroso, verrà eseguito questo: 
%  1) Verrà presa la "PrimaAzione" dell'ultima sotto-chiamata fatta (dopo la quale sono arrivato al caso base) e verrà messa in testa a "Cammino",
%  2) Verrà presa la "PrimaAzione" della penultima sotto-chiamata fatta e verrà messa in testa a "Cammino",
%  3) Verrà presa la "PrimaAzione" della terzultima sotto-chiamata fatta e verrà messa in testa a "Cammino",
%  ecc.. FINO A QUANDO NON ARRIVA ALLA PRIMISSA CHIAMATA CHE E' STATA FATTA per "risolvi(S, [PrimaAzione|Cammino], ListaStatiVisitati, Gn):- " 
% presente qui sotto e a quel punto nel secondo parametro ci sarà TUTTO IL CAMMINO TROVATO.
% A questo punto, poichè l'ulti 

%risolvi(S, [PrimaAzione|Cammino], ListaStatiVisitati, Gn):-
%    var(Cammino), % verifico che Cammino non sia istanziata




risolvi(S, [PrimaAzione|Cammino], ListaStatiVisitati, Gn, CamminoFinaleRicotruito, ListaStatiVisitatiDiretti, CamminoFinaleRicotruitoDiretto):- 

    write('ListaStatiVisitati (corrente) (nel secondo risolvi(..)): '), write(ListaStatiVisitati), write('\n'),

    write('ListaStatiVisitatiDiretti (corrente) (nel secondo risolvi(..)): '), write(ListaStatiVisitatiDiretti), write('\n'),

    write('S (corrente) (nel secondo risolvi(..)): '), write(S), write('\n'),

    \+finale(S),
     % Se ho ancora dei passi residui da compiere allora provo ancora ad andare in 
    % profondità, altrimenti fallisco.
    GNew is Gn+1,
    % applicabile(Az,S), % dico "istanziami Az con una delle azioni che sono applicabili nello stato S corrente nel quale mi trovo adesso" (chiaramente se ci saranno più azioni applicabili in un certo momento, l'interprete si memorizzerà questi punti di BT in modo da poterci tornare qualora non trovasse la soluzione seguendo una certa strada).
    
    % Con con la findall(..) di sotto posso trovare tutte le coppie del tipo (Az, Fn)
    %   ove:
    %   - Az = azione applicabile.
    %   - Fn = stima del costo partendo dal nodo nel quale entrerò qualora eseguissi "Az" fino ad arrivare ad uno dei due stati finali.
    % che sono applicabili nello stato S e li salvo in "ListaAzioniApplicabili".
    % Quindi, in "ListaAzioniApplicabili" avremo una coppia (azione, f(n)).
    
    %write('[_|ListaAzioniApplicabili] (corrente): ', write([_|ListaAzioniApplicabili])),
    write('Cammino (corrente) (nel secondo risolvi(..)): '), write(Cammino), write('\n'),
    
    findall([Azioni,S,Fn,GNew], applicabile(Azioni, S, GNew, Fn, ListaStatiVisitati), LRis), % (provare a prendere un'azione per volta usando Azioni..)
    write('ListaAzioniApplicabili (non corretta) (nel secondo risolvi(..)): '), write(LRis), write('\n'),

    rimuovi_se_lunghezza_diversa(LRis, LRisCorretta),
    write('ListaAzioniApplicabili (corretta) (nel secondo risolvi(..)): '), write(LRisCorretta), write('\n'),

    % c'erano prima:
    %sort_by_tail_and_extract_heads(LRisCorretta, ListaAzioniApplicabili),
    %write('ListaAzioniApplicabili (corretta e ordinata): '), write(ListaAzioniApplicabili), nl,

    ordina_lista(LRis, TempOrd),
    estrai_teste(TempOrd, ListaAzioniApplicabiliCorrenteCorrettaEOrdinata),
    write('ListaAzioniApplicabiliCorrenteCorrettaEOrdinata (corretta e ordinata) (nel secondo risolvi(..)): '), write(ListaAzioniApplicabiliCorrenteCorrettaEOrdinata), write('\n'),
    % ESEMPIO DIRETTO corretto: iniziale(S0), findall([Az|Fn], applicabile(Az, S0, 0, Fn), LRis). (nota: Gn = 0 all'inizio)
    % OUTPUT: LRis = [[su, 13], [giu, 13], [destra, 11]].

    % Adesso in "ListaAzioniApplicabili" ABBIAMO UNA LISTA di coppie del tipo (azione, f(n)):
    % continua da qui..

    %c'erano prima queste due righe di sotto:
    %ListaAzioniApplicabili = [PrimaAzione|RestoAzioni], % Prende solo la testa della lista
    %write('ListaAzioniApplicabili (corretta con cima best): '), write(ListaAzioniApplicabili), nl,

    ListaAzioniApplicabiliCorrenteCorrettaEOrdinata = [PrimaAzione|_],

    %!, % se arrivo qui allora tutti i BT precedenti li taglio (non cambia nulla..)

    write('PrimaAzione (nel secondo risolvi(..)): '), write(PrimaAzione), write('\n'), write('\n'),
    trasforma(PrimaAzione, S, Snuovo), % dico "esegui l'azione Az in modo da spostarti dallo stato S allo stato SNuovo"
    %\+member(Snuovo, ListaStatiVisitati), % specifico che non voglio andare in un nuovo stato nel quale ci sono già stato. (E' necessario per evitare che il robot entri in loop!)
    write('Snuovo in cui sono entrato (nel secondo risolvi(..)): '), write(Snuovo), write('\n'), write('\n'),
    
    % c'era prima:
    %risolvi(Snuovo, RestoAzioni, [S|ListaStatiVisitati], NuovaProfMax,GNew). % Il terzo parametro serve per ricordarmi da ora in poi che nello stato S CI SONO GIA' STATO !
    % NuovaProfMax conterrà nella chiamata ricorsiva che farò la nuova profondità massima da rispettare perchè ho tolto un 
    % passo che farò nel momento in cui faccio la chiamata ricorsiva perchè ho eseguito un passo in profondità.

    % prima di eseguire la chiamata ricorsiva aggiungo in coda al "Cammino" trovato fino ad ora, lo stato Snuovo che ho appena trovato:
    %Cammino = [Cammino|Snuovo],

    %append(Cammino, [PrimaAzione], NuovoCammino),

    risolvi(Snuovo, Cammino, [S|ListaStatiVisitati], GNew, CamminoFinaleRicotruito, [S|ListaStatiVisitatiDiretti], CamminoFinaleRicotruitoDiretto).


% Quando entro qui sotto vuol dire che S è uno stato nel quale l'agente è bloccato.
risolvi(S, [], ListaStatiVisitati, Gn, CamminoFinaleRicotruito, ListaStatiVisitatiDiretti, CamminoFinaleRicotruitoDiretto):-

    write('ListaStatiVisitati (corrente) (nel terzo risolvi(..)): '), write(ListaStatiVisitati), write('\n'),
    write('ListaStatiVisitatiDiretti (corrente) (nel terzo risolvi(..)): '), write(ListaStatiVisitatiDiretti), write('\n'),
    write('S (corrente) (nel terzo risolvi(..)): '), write(S), write('\n'),

    \+finale(S),

    % aggiungo in testa a lista visitati lo stato nel quale sono bloccato in questo momento. (Non farò la stessa cosa per "ListaStatiVisitatiDiretti")
    ListaStatiVisitatiNew = [S | ListaStatiVisitati],
    
    write('ListaStatiVisitatiNew (nel terzo risolvi(..)): '), write(ListaStatiVisitatiNew), write('\n'),

    % ListaStatiVisitati = [pos(1,3), pos(1,2), pos(1,1)]
    % Adesso estraiamo da  ListaStatiVisitati il secondo stato dopo la testa (pos(1,2)):

    % - In pos(1,2) E' applicabile qualche azione?
    %   - NO -> spostati al prossimo elemento di Lista visitati (ovvero pos(1,1))

    % - In pos(1,1) E' applicabile qualche azione?
    %   - NO -> next


    %   - SI ->: 
    %       S = pos(1,1)
    %       risolvi(S, [PrimaAzione|Cammino], ListaStatiVisitati, Gn):-

    % ListaStatiVisitatiNew = [(5,3), (5,2), (5,1)]
    % - Io voglio che alla fine del for di sotto ListaStatiVisitatiNew sia questo:
    % ListaStatiVisitatiNew = [(5,2), (5,3), (5,2), (5,1)]
    % In modo tale che in testa a (5,3) ci sia tutta la lista di stati che ho seguito per poter tornare in uno stato dal quale riprendere la computazione del cammino
    % (in questo caso c'è un solo stato intermedio che ho dovuto attraversare per riuscire a riprendere la computazione del cammino che è (5,2))

    for(ListaStatiVisitatiNew, ListaStatiVisitatiNew, Gn, SRipartenza),

    % provo a chiamare qui il risolvi.. In modo tale da fargli capire che lo stato nel quale adesso c'è sicuramente almeno una soluzione applicabile è SRipartenza:
    %!, % taglio tutti i punti di BT trovati fino a questo momento tanto sono certo che l'agente si è bloccato e quindi dovrà ricominciare da SRipartenza per cercare una nuova strada.
    
    write('SRipartenza (nel terzo risolvi(..)): '), write(SRipartenza), write('\n'),
    
    % adesso ho ListaStatiVisitatiNew = [pos(5, 3), pos(5, 2), pos(5, 1), pos(6, 1), pos(6, 2), pos(6, 3), pos(6, 4), ...]
    % e so dal for che SRipartenza == (5,1).

    % dove pos(5, 1) è lo stato di ripartenza.
    % Adesso chiamo scorri_lista per mettere avanti a  pos(5, 3), tutti gli stati che ci sono tra il primo pos(5, 3) (testa del primo parametro) e pos(5, 1)(SRipartenza):
    
    %scorri_lista([ StatoIntermedio | [HeadCurrent| [HeadTail | RestoTail] ] ], _, _, Posizione):-
    
    ListaStatiVisitatiNewAggiornato = ListaStatiVisitatiNew,
    
    write('ListaStatiVisitatiNewAggiornato prima di chiamare scorri_lista): '), write(ListaStatiVisitatiNewAggiornato), write('\n'),

    scorri_lista(ListaStatiVisitatiNewAggiornato, ListaStatiVisitatiNew, _, S, SRipartenza, ListaStatiIntermedi), % scorri_lista conosce qual è lo stato "SRipartenza" e quindi può sfruttarlo.

    write('ListaStatiVisitatiNewAggiornato dopo aver completato TUTTO scorri_lista): '), write(ListaStatiVisitatiNewAggiornato), write('\n'), % deve essere rimasto invariato
    write('ListaStatiIntermedi dopo aver completato TUTTO scorri_lista): '), write(ListaStatiIntermedi), write('\n'),


    %rimuovi_terminazione_aperta(ListaStatiIntermedi, ListaStatiIntermediSTA),
    rimuovi_coda_non_istantiata(ListaStatiIntermedi, ListaStatiIntermediSTA),

    write('ListaStatiIntermedi SENZA TERMINAZIONE APERTA (non invertita)): '), write(ListaStatiIntermediSTA), write('\n'),

    select(_, ListaStatiIntermediSTA, ListaStatiIntermediSTASenzaReplica), % Tolgo da ListaStatiIntermediSTA il primo elemento perchè sarebbe una ripetizione e memorizzo l'aggiornamento in ListaStatiIntermediSTASenzaReplica

    write('ListaStatiIntermediSTASenzaReplica (nel terzo risolvi(..) NON INVERTITA): '), write(ListaStatiIntermediSTASenzaReplica), write('\n'),

    inverti(ListaStatiIntermediSTASenzaReplica, ListaStatiIntermediSTASenzaReplicaINV), % devo invertirla altrimenti quando ci saranno più stati intermedi non li avrò nel giusto ordine quando li inserirò
    % nella lista complessiva degli stati visitati (e quindi il cammino finale sarà sbagliato).

    write('ListaStatiIntermediSTASenzaReplicaINV (nel terzo risolvi(..) (ListaStatiIntermediSTASenzaReplica invertita)): '), write(ListaStatiIntermediSTASenzaReplicaINV), write('\n'),

    % [(5,1), (5,2), (5,3)]

    % inserisco in cima agli elementi di "ListaStatiVisitatiNewAggiornato" tutta la "ListaStatiIntermediSTASenzaReplicaINV" e mi salvo tutto nella nuova lista "ListaStatiIntermediFinale":
    append(ListaStatiIntermediSTASenzaReplicaINV, ListaStatiVisitatiNewAggiornato, ListaStatiIntermediFinale),

    write('ListaStatiIntermediFinale (nel terzo risolvi(..)): '), write(ListaStatiIntermediFinale), write('\n'), write('\n'),

    %ListaStatiVisitatiNew2 = [SRipartenza | ListaStatiIntermediFinale], % aggiungo in testa a ListaStatiVisitatiNew lo stato dal quale il for di prima mi ha detto di ripartire.
    %write('ListaStatiVisitatiNew2 (nel terzo risolvi(..)): '), write(ListaStatiVisitatiNew2), write('\n'),

    
    % Adesso tolgo da "ListaStatiVisitatiDiretti" tutti gli stati fino ad arrivare ad SRipartenza in modo tale che dentro "ListaStatiVisitatiDiretti" avrò solo
    % ed esclusivamente gli stati che mi hanno permesso di arrivare direttamente alla soluzione.
    % Per fare questo chiamo il predicato di sotto che si preoccuperà semplicemente di togliere tutti gli stati (partendo sempre dalla testa) 
    % presenti in "ListaStatiVisitatiDiretti" fino ad arrivare ad SRipartenza:
    
    %write('ListaStatiVisitatiDiretti (nel terzo risolvi(..)) PRIMA DI metti_testa_SRipartenza: '), write(ListaStatiVisitatiDiretti), write('\n'), write('\n'),

    % la nuova lista con in cima solo SRipartenza (in questo esempio di sotto SRipartenza == pos(3,9)) verrà salvata in "ListaStatiVisitatiDirettiNew":

    % ListaStatiVisitatiDiretti (corrente) (nel secondo risolvi(..)): [pos(2,10),pos(3,10),pos(3,9),pos(2,9),pos(1,9),pos(1,8),pos(1,7),pos(1,6),pos(1,5),
    % pos(1,4),pos(1,3),pos(1,2),pos(1,1),pos(2,1),pos(2,2),pos(2,3),pos(2,4),pos(3,4),pos(3,3),pos(3,2),pos(3,1),pos(4,1),pos(5,1),pos(5,2),pos(5,1),pos(6,1),
    % pos(6,2),pos(6,3),pos(6,4),pos(5,4),pos(4,4),pos(4,3),pos(4,2)]
    metti_testa_SRipartenza(ListaStatiVisitatiDiretti, SRipartenza, ListaStatiVisitatiDirettiNew),

    write('ListaStatiVisitatiDirettiNew (nel terzo risolvi(..)) DOPO DI metti_testa_SRipartenza: '), write(ListaStatiVisitatiDirettiNew), write('\n'), write('\n'),

    risolvi(SRipartenza, [_|_], ListaStatiIntermediFinale, Gn, CamminoFinaleRicotruito, ListaStatiVisitatiDirettiNew, CamminoFinaleRicotruitoDiretto).


% Start:
% initialize, prova.
