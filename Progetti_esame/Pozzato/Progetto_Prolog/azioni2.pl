

% In questo file inseriamo invece tutti predicati:
% applicabile(..) e trasforma(..) che invece permetteranno:
% 1) applicabile(..): all'agente di capire quali mosso sono le azioni applicabili in ogni stato 
%    mentre,
% 2) trasforma(..): gli permette di sapere come sarà il nuovo stato nel quale si sposterà
% in base all'azione eseguita.

% Calcolo dist Manhattan:
distanzaManhattan(pos(X1,Y1), pos(X2,Y2), Distanza):-
    Distanza is abs(X1-X2) + abs(Y1-Y2).

% Calcolo dist Euclidea:
distanzaEuclidea(pos(X1, Y1), pos(X2, Y2), Distanza) :-
    Distanza is sqrt((X1 - X2)^2 + (Y1 - Y2)^2).

% applicabile(Azione, Stato)
% - L'ordine nel quale dichiari i predicati "applicabile(..)" INFLUENZERA'
%   LE LUNGHEZZE DEI DIVERSI CAMMINI CHE VERRANNO TROVATI PERCHE' OVVIAMENTE I 
%   PUNTI DI BT CHE L'INTERPRETE SI FISSA SARANNO DIVERSI IN BASE ALL'ORDINE DI QUESTE
%   PREDICATI. E' chiaro che però se la soluzione esiste, il Prolog riuscirà 
%   sempre a trovarla indipendentemente dall'ordine di questi predicati.

% ListaAzioni = è 
applicabile(su, pos(Riga,Colonna), Gn, Fn, ListaStatiVisitati):- % Riga e Colonna sono 2 variabili di Prolog
    Riga > 1, % mi assicuro che la riga non sia la prima altrimenti non posso andare in su.
    RigaSopra is Riga-1, % mi calcolo il valore della riga superiore a dove mi trovo adesso e lo memorizzo nella var RigaSopra.
    
    \+occupata(pos(RigaSopra,Colonna)), % Verifico che non sia vero che sopra di me ci sia un ostacolo.

    \+member(pos(RigaSopra,Colonna), ListaStatiVisitati), % Verifico che non sia già stato nello stato in cui andrei con l'azione corrente.

    % - Calcolo la F(n) = h1(n) + h2(n) + g(n) 

    %H1 is distanzaManhattan(pos(RigaSopra,Colonna), finale(pos(1,5)), Distanza),
    %H2 is distanzaManhattan(pos(RigaSopra,Colonna), finale(pos(5,5)), Distanza),
    
    % Quando ci sono più uscite..
    distanzaManhattan(pos(RigaSopra,Colonna), pos(3,13), H1),
    distanzaManhattan(pos(RigaSopra,Colonna), pos(10,8), H2),
    distanzaManhattan(pos(RigaSopra,Colonna), pos(12,12), H3),
    
    %distanzaEuclidea(pos(RigaSopra,Colonna), pos(3,13), H1),
    %distanzaEuclidea(pos(RigaSopra,Colonna), pos(10,8), H2),
    %distanzaEuclidea(pos(RigaSopra,Colonna), pos(12,12), H3),

    % Calcolo del valore Fn:

    % Combinazione lineare
    % Fn is H1 + H2 + H3 + Gn.

    % Minimo:
    Fn is min(min(H1, H2), H3) + Gn.


    
applicabile(giu, pos(Riga,Colonna), Gn, Fn, ListaStatiVisitati):-
    num_righe(NR), % recupero il numero di righe del labirinto salvandomelo in NR
    Riga < NR, % mi assicuro che la riga corrente non sia l'ultima riga della matrice altrimenti non potrei spostarmi ancora in giù
    RigaSotto is Riga+1,
    \+occupata(pos(RigaSotto,Colonna)),

    \+member(pos(RigaSotto,Colonna), ListaStatiVisitati), % Verifico che non sia già stato nello stato in cui andrei con l'azione corrente.


    % - Calcolo la F(n) = h1(n) + h2(n) + g(n) 
    %H1 is distanzaManhattan(pos(RigaSopra,Colonna), finale(pos(1,5)), Distanza),
    %H2 is distanzaManhattan(pos(RigaSopra,Colonna), finale(pos(5,5)), Distanza),
    

    distanzaManhattan(pos(RigaSotto,Colonna), pos(3,13), H1),
    distanzaManhattan(pos(RigaSotto,Colonna), pos(10,8), H2),
    distanzaManhattan(pos(RigaSotto,Colonna), pos(12,12), H3),
    
    %distanzaEuclidea(pos(RigaSotto,Colonna), pos(3,13), H1),
    %distanzaEuclidea(pos(RigaSotto,Colonna), pos(10,8), H2),
    %distanzaEuclidea(pos(RigaSotto,Colonna), pos(12,12), H3),

    % Calcolo del valore Fn:

    % Combinazione lineare
    % Fn is H1 + H2 + H3 + Gn.

    % Minimo:
    Fn is min(min(H1, H2), H3) + Gn.


applicabile(destra, pos(Riga,Colonna), Gn, Fn, ListaStatiVisitati):-
    num_colonne(NC),
    Colonna < NC,
    ColonnaDestra is Colonna+1,
    \+occupata(pos(Riga,ColonnaDestra)),

    \+member(pos(Riga,ColonnaDestra), ListaStatiVisitati), % Verifico che non sia già stato nello stato in cui andrei con l'azione corrente.

    % - Calcolo la F(n) = h1(n) + h2(n) + g(n) 
    %H1 is distanzaManhattan(pos(RigaSopra,Colonna), finale(pos(1,5)), Distanza),
    %H2 is distanzaManhattan(pos(RigaSopra,Colonna), finale(pos(5,5)), Distanza),
    
    %distanzaManhattan(pos(Riga,ColonnaDestra), pos(1,5), H1),
    %distanzaManhattan(pos(Riga,ColonnaDestra), pos(5,5), H2),

    %Fn is H1 + H2 + Gn .

    distanzaManhattan(pos(Riga,ColonnaDestra), pos(3,13), H1),
    distanzaManhattan(pos(Riga,ColonnaDestra), pos(10,8), H2),
    distanzaManhattan(pos(Riga,ColonnaDestra), pos(12,12), H3),
    
    %distanzaEuclidea(pos(Riga,ColonnaDestra), pos(3,13), H1),
    %distanzaEuclidea(pos(Riga,ColonnaDestra), pos(10,8), H2),
    %distanzaEuclidea(pos(Riga,ColonnaDestra), pos(12,12), H3),

    % Calcolo del valore Fn:

    % Combinazione lineare
    % Fn is H1 + H2 + H3 + Gn.

    % Minimo:
    Fn is min(min(H1, H2), H3) + Gn.


applicabile(sinistra, pos(Riga,Colonna), Gn, Fn, ListaStatiVisitati):-
    Colonna > 1,
    ColonnaSinistra is Colonna-1,
    \+occupata(pos(Riga,ColonnaSinistra)),


    \+member(pos(Riga,ColonnaSinistra), ListaStatiVisitati), % Verifico che non sia già stato nello stato in cui andrei con l'azione corrente.

    % - Calcolo la F(n) = h1(n) + h2(n) + g(n) 
    %H1 is distanzaManhattan(pos(RigaSopra,Colonna), finale(pos(1,5)), Distanza),
    %H2 is distanzaManhattan(pos(RigaSopra,Colonna), finale(pos(5,5)), Distanza),
    
    %distanzaManhattan(pos(Riga,ColonnaSinistra), pos(1,5), H1),
    %distanzaManhattan(pos(Riga,ColonnaSinistra), pos(5,5), H2),

    %Fn is H1 + H2 + Gn.

    distanzaManhattan(pos(Riga,ColonnaSinistra), pos(3,13), H1),
    distanzaManhattan(pos(Riga,ColonnaSinistra), pos(10,8), H2),
    distanzaManhattan(pos(Riga,ColonnaSinistra), pos(12,12), H3),
    
    %distanzaEuclidea(pos(Riga,ColonnaSinistra), pos(3,13), H1),
    %distanzaEuclidea(pos(Riga,ColonnaSinistra), pos(10,8), H2),
    %distanzaEuclidea(pos(Riga,ColonnaSinistra), pos(12,12), H3),

    % Calcolo del valore Fn:

    % Combinazione lineare
    % Fn is H1 + H2 + H3 + Gn.

    % Minimo:
    Fn is min(min(H1, H2), H3) + Gn.



% trasforma(Azione, S0, S1): 
% predicato che mi dice come diventa il nuovo stato S1 nel quale entrerò
% dopo aver applicato l'azione nello stato precedente S0.

% Ricorda: non puoi scrivere Riga-1 direttamente al posto di RigaSopra nel pos di S1
trasforma(su, pos(Riga,Colonna), pos(RigaSopra,Colonna)):-
    write('Eseguo azione: '), write(su), write('\n'),

    RigaSopra is Riga-1. % sto dicendo che nel nuovo stato S1 la riga nella quale mi troverò sarà quella precedente
    % perchè appunto sono andato verso l'alto di una posizione. 
    
trasforma(giu, pos(Riga,Colonna), pos(RigaSotto,Colonna)):-
    write('Eseguo azione: '), write(giu), write('\n'),

    RigaSotto is Riga+1.

trasforma(destra, pos(Riga,Colonna), pos(Riga,ColonnaDestra)):-
    write('Eseguo azione: '), write(destra), write('\n'),

    ColonnaDestra is Colonna+1.

trasforma(sinistra, pos(Riga,Colonna), pos(Riga,ColonnaSinistra)):-
    write('Eseguo azione: '), write(sinistra), write('\n'),

    ColonnaSinistra is Colonna-1.








