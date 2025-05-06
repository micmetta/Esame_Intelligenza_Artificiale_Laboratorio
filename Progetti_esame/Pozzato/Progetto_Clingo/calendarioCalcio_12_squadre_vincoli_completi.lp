


% Definizione 12 squadre:
squadra("Juventus"; "Inter"; "Milan"; "Verona"; "Napoli"; "Fiorentina"; "Genoa"; "Monza"; "Lazio"; "Salernitana"; "Sassuolo"; "Atalanta").


% Definizione degli stadi per le squadre
stadio("Juventus", "Allianz Stadium").
stadio("Inter", "San Siro").
stadio("Milan", "San Siro").
stadio("Verona", "Stadio Bentegodi").
stadio("Napoli", "Stadio Diego Armando Maradona").
stadio("Fiorentina", "Stadio Artemio Franchi").
stadio("Genoa", "Stadio Luigi Ferraris").
stadio("Monza", "Stadio Brianteo").
stadio("Lazio", "Stadio Olimpico").
stadio("Salernitana", "Stadio Arechi").
stadio("Sassuolo", "Mapei Stadium - Citta del Tricolore").
stadio("Atalanta", "Gewiss Stadium").


% definisco le giornate di andata e di ritorno: (IN MEDIA SEMBRA CHE CI METTA IN MEDIA 200s) - 702s e (Time: 400.396s e CPU Time: 4718.969s)
giornata_andata(1..11).
giornata_ritorno(12..22).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VINCOLI SUL GIRONE DI ANDATA:

% - Inserisco TUTTI I VINCOLI NEL GIRONE DI ANDATA (anche in base a quello che ha detto il prof) (considerando anche i derby)


% alla fine bisognerà mettere 10..10 (per le 20 squadre):
% 3..3 (per le 6 squadre)
% 4..4 (per le 8 squadre)
% 5..5 (per le 10 squadre)
% 6..6 (per le 12 squadre)
% 7..7 (per le 14 squadre)
% 10..10 (per le 20 squadre)
% Ogni giornata di andata deve avere esattamente 7 partite dove le squadre che si affrontano devono essere diverse tra loro:
6 {partita(G, Squadra1, Squadra2, StadioCasa):
    squadra(Squadra1),
    squadra(Squadra2),
    Squadra1 != Squadra2,
    stadio(Squadra1, StadioCasa)} 6:- giornata_andata(G).


% Non devono esserci duplicati tra le partite del girone di andata:
partite_andata_replicate:-
    partita(G1, Squadra1, Squadra2, Stadio1),
    partita(G2, Squadra1, Squadra2, Stadio2),
    giornata_andata(G1),
    giornata_andata(G2),
    G1!=G2, % fondamentale..
    Stadio1==Stadio2.

:- partite_andata_replicate.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specifico che non voglio ottenere quei modelli che in una stessa giornata permettono di far giocare in uno stesso stadio partite differenti:
partite_diverse_in_una_stessa_giornata_si_giocano_nello_stesso_stadio:-
    partita(G1, Squadra1, Squadra2, Stadio1),
    partita(G2, Squadra3, Squadra4, Stadio2),
    giornata_andata(G1),
    giornata_andata(G2),
    G1==G2,
    Squadra1!=Squadra3,
    Squadra2!=Squadra4,
    Stadio1==Stadio2.

:- partite_diverse_in_una_stessa_giornata_si_giocano_nello_stesso_stadio.


% Specifico che non voglio ottenere quei modelli che in una stessa giornata permettono di far giocare in uno stesso stadio 
% partite differenti dove la squadra di casa è la stessa: 
partite_diverse_in_una_stessa_giornata_si_giocano_nello_stesso_stadio_con_squadra_casa_uguale:-
    partita(G1, Squadra1, Squadra2, Stadio1),
    partita(G2, Squadra3, Squadra4, Stadio2),
    giornata_andata(G1),
    giornata_andata(G2),
    G1==G2,
    Squadra1==Squadra3,
    Squadra2!=Squadra4,
    Stadio1==Stadio2.

:- partite_diverse_in_una_stessa_giornata_si_giocano_nello_stesso_stadio_con_squadra_casa_uguale.


% Specifico che non voglio ottenere quei modelli che in una stessa giornata permettono di far giocare in uno stesso stadio 
% partite differenti dove la squadra fuori casa è la stessa:
partite_diverse_in_una_stessa_giornata_si_giocano_nello_stesso_stadio_con_squadra_fuori_casa_uguale:-
    partita(G1, Squadra1, Squadra2, Stadio1),
    partita(G2, Squadra3, Squadra4, Stadio2),
    giornata_andata(G1),
    giornata_andata(G2),
    G1==G2,
    Squadra1!=Squadra3,
    Squadra2==Squadra4,
    Stadio1==Stadio2.

:- partite_diverse_in_una_stessa_giornata_si_giocano_nello_stesso_stadio_con_squadra_fuori_casa_uguale.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Specifico che non voglio che per una qualsiasi coppia di partite del girone di andata (in giornate differenti) ci sia già la partita di ritorno:
ritorno_partite_giocate_in_una_giornata_andata_viene_giocato_sempre_in_una_giornata_andata:-
    partita(G1, Squadra1, Squadra2, _), % STADIO INDIFFERENTE
    partita(G2, Squadra3, Squadra4, _), % STADIO INDIFFERENTE

    giornata_andata(G1),
    giornata_andata(G2),
    
    G1!=G2, % fondamentale..
    Squadra1==Squadra4,
    Squadra2==Squadra3.

:- ritorno_partite_giocate_in_una_giornata_andata_viene_giocato_sempre_in_una_giornata_andata.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Specifico che non voglio che per una qualsiasi coppia di partite del girone di andata (nella stessa giornata) 
%   ci sia già la partita di ritorno: 
% partita(6,"Juventus","Sassuolo","Allianz Stadium") e partita(6,"Sassuolo","Juventus","Mapei Stadium - Citta del Tricolore")
ritorno_partite_giocate_in_una_giornata_andata_viene_giocato_sempre_nella_stessa_giornata_andata:-
    partita(G1, Squadra1, Squadra2, _), % STADIO INDIFFERENTE (aggiunto dopo l'errore)
    partita(G2, Squadra3, Squadra4, _), % STADIO INDIFFERENTE (aggiunto dopo l'errore)

    giornata_andata(G1),
    giornata_andata(G2),

    G1==G2, % fondamentale..
    Squadra1==Squadra4,
    Squadra2==Squadra3.

:- ritorno_partite_giocate_in_una_giornata_andata_viene_giocato_sempre_nella_stessa_giornata_andata.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gestisco casi diversi di uno stesso vincolo:

% - Con i 6 vincoli qui sotto impongo che in una stessa partita del girone di andata una squadra non giochi più di una volta.

% - Non voglio che in una stessa giornata di andata vengano giocate due partite differenti da una stessa squadra di casa:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata:-
    partita(G1, Squadra1, Squadra2, _),
    partita(G2, Squadra3, Squadra4, _),
    giornata_andata(G1),
    giornata_andata(G2),
    G1==G2,
    Squadra1==Squadra3,
    Squadra2!=Squadra4.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata.

% - Non voglio che in una stessa giornata di andata vengano giocate due partite differenti da una stessa squadra entrambe fuori casa:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_caso_3:-
    partita(G1, Squadra1, Squadra2, _),
    partita(G2, Squadra3, Squadra4, _),
    giornata_andata(G1),
    giornata_andata(G2),
    G1==G2,
    Squadra1!=Squadra3,
    Squadra2==Squadra4.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_caso_3.

% - Non voglio che in una stessa giornata di andata vengano giocate due partite differenti da una stessa squadra prima in casa e poi fuori casa:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_caso_2:-
    partita(G1, Squadra1, Squadra2, _),
    partita(G2, Squadra3, Squadra4, _),
    giornata_andata(G1),
    giornata_andata(G2),
    G1==G2,
    Squadra1==Squadra4,
    Squadra2!=Squadra3.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_caso_2.

% - Uguale a sopra ma specifico che non voglio neanche che Squadra2 == Squadra3:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_andata_caso_2_completezza:-
    partita(G1, Squadra1, Squadra2, _),
    partita(G2, Squadra3, Squadra4, _),
    giornata_andata(G1),
    giornata_andata(G2),
    G1==G2,
    Squadra1==Squadra4,
    Squadra2==Squadra3.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_andata_caso_2_completezza.


% - Non voglio che in una stessa giornata di andata vengano giocate due partite differenti da una stessa squadra, prima fuori casa e poi in casa:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_andata_caso_4:-
    partita(G1, Squadra1, Squadra2, _),
    partita(G2, Squadra3, Squadra4, _),
    giornata_andata(G1),
    giornata_andata(G2),
    G1==G2,
    Squadra1!=Squadra4,
    Squadra2==Squadra3.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_andata_caso_4.

% - Uguale a sopra ma specifico che non voglio neanche che Squadra1 == Squadra4:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_andata_caso_4_completezza:-
    partita(G1, Squadra1, Squadra2, _),
    partita(G2, Squadra3, Squadra4, _),
    giornata_andata(G1),
    giornata_andata(G2),
    G1==G2,
    Squadra1==Squadra4,
    Squadra2==Squadra3.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_andata_caso_4_completezza.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VINCOLO FACOLTATIVO 1:
% - Ciascuna squadra non deve giocare mai più di due partite nel girone di andata consecutive in casa o fuori casa  % (time: 2s max)
% QUESTO VINCOLO FACOLTATIVO 1 LO SUDDIVIDO NEI DUE SOTTO-VINCOLI PRESENTI QUI SOTTO:

% - Ciascuna squadra non deve giocare mai più di due partite nel girone di andata consecutive in casa:
:-  partita(G1, Squadra, _, _),
    partita(G2, Squadra, _, _),
    partita(G3, Squadra, _, _),

    squadra(Squadra),

    giornata_andata(G1),
    giornata_andata(G2),
    giornata_andata(G3),

    G2 = G1 + 1,
    G3 = G2 + 1.


% - Ciascuna squadra non deve giocare mai più di due partite nel girone di andata consecutive fuori casa:
:-  partita(G1, _, Squadra, _),
    partita(G2, _, Squadra, _),
    partita(G3, _, Squadra, _),

    squadra(Squadra),

    giornata_andata(G1),
    giornata_andata(G2),
    giornata_andata(G3),

    G2 = G1 + 1,
    G3 = G2 + 1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FINE VINCOLI GIRONE DI ANDATA


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VINCOLI SUL GIRONE DI RITORNO:

% - Per il Girone di ritorno eseguo questi semplici passi:
%   - 1) Genero tutte le possibili partite di ritorno (utilizzando l'aggregato 7..7 nel caso a 14 squadre)
%   - 2) Cerco di conservare solamente le partite delle giornate di ritorno CHE SONO DAVVERO I RITORNI DELLE PARTITE DI ANDATA.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - 1) 

% Mi creo un predicato che conterrà PER OGNI GIORNATA DI ANDATA TUTTE LE PARTITE DI QUELLA GIORNATA:
%partita_andata(G, SquadraCasa, SquadraFuoriCasa, StadioCasa) :- partita(G, SquadraCasa, SquadraFuoriCasa, StadioCasa), giornata_andata(G).
%#show partita_andata/4.


% alla fine bisognerà mettere 10..10 (per le 20 squadre):
% 3..3 (per le 6 squadre)
% 4..4 (per le 8 squadre)
% 5..5 (per le 10 squadre)
% 6..6 (per le 12 squadre)
% 7..7 (per le 14 squadre)
% 10..10 (per le 20 squadre)
% Adesso specifico che per ogni giornata di ritorno devono esserci esattamente 7 partite:
6 {partita(G, Squadra1, Squadra2, StadioCasa):
    squadra(Squadra1),
    squadra(Squadra2),
    Squadra1 != Squadra2,
    stadio(Squadra1, StadioCasa)} 6:- giornata_ritorno(G).

% Adesso specifico che per ogni "partita_andata" ci deve essere esattamente una partita giocata in una giornata di ritorno a squadre invertite:
%1 { partita(GiornataRitorno, SquadraFuoriCasaAndata, SquadraCasaAndata, StadioFuoriCasaAndata): 
%    giornata_ritorno(GiornataRitorno), stadio(SquadraFuoriCasaAndata, StadioFuoriCasaAndata)} 1 :- partita_andata(G, SquadraCasaAndata, SquadraFuoriCasaAndata, StadioCasaAndata).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gestisco casi diversi di uno stesso vincolo:

% - Con i 6 vincoli qui sotto (STESSI VINCOLI MESSI NEL GIRONE DI ANDATA) impongo che in una stessa partita del girone di ritorno una squadra non giochi più di una volta.

% - Non voglio che in una stessa giornata di ritorno vengano giocate due partite differenti da una stessa squadra di casa:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno:-
    partita(G1, Squadra1, Squadra2, _),
    partita(G2, Squadra3, Squadra4, _),
    giornata_ritorno(G1),
    giornata_ritorno(G2),
    G1==G2,
    Squadra1==Squadra3,
    Squadra2!=Squadra4.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno.


% - Non voglio che in una stessa giornata di ritorno vengano giocate due partite differenti da una stessa squadra entrambe fuori casa:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno_caso_3:-
    partita(G1, Squadra1, Squadra2, _),
   partita(G2, Squadra3, Squadra4, _),
    giornata_ritorno(G1),
    giornata_ritorno(G2),
    G1==G2,
    Squadra1!=Squadra3,
    Squadra2==Squadra4.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno_caso_3.



% - Non voglio che in una stessa giornata di ritorno vengano giocate due partite differenti da una stessa squadra prima in casa e poi fuori casa:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno_caso_2:-
    partita(G1, Squadra1, Squadra2, _),
    partita(G2, Squadra3, Squadra4, _),
    giornata_ritorno(G1),
    giornata_ritorno(G2),
    G1==G2,
    Squadra1==Squadra4,
    Squadra2!=Squadra3.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno_caso_2.

% - Uguale a sopra ma specifico che non voglio neanche che Squadra2 == Squadra3:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno_caso_2_completezza:-
    partita(G1, Squadra1, Squadra2, _),
    partita(G2, Squadra3, Squadra4, _),
    giornata_ritorno(G1),
    giornata_ritorno(G2),
    G1==G2,
    Squadra1==Squadra4,
    Squadra2==Squadra3.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno_caso_2_completezza.



% - Non voglio che in una stessa giornata di ritorno vengano giocate due partite differenti da una stessa squadra, prima fuori casa e poi in casa:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno_caso_4:-
    partita(G1, Squadra1, Squadra2, _),
    partita(G2, Squadra3, Squadra4, _),
    giornata_ritorno(G1),
    giornata_ritorno(G2),
    G1==G2,
    Squadra1!=Squadra4,
    Squadra2==Squadra3.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno_caso_4.

% - Uguale a sopra ma specifico che non voglio neanche che Squadra1 == Squadra4:
squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno_caso_4_completezza:-
    partita(G1, Squadra1, Squadra2, _),
    partita(G2, Squadra3, Squadra4, _),
    giornata_ritorno(G1),
    giornata_ritorno(G2),
    G1==G2,
    Squadra1==Squadra4,
    Squadra2==Squadra3.

:- squadra_casa_presente_in_due_partite_differenti_della_stessa_giornata_di_ritorno_caso_4_completezza.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Con il vincolo di sotto impongo che non sia possibile che in una qualsiasi partita di ritorno ci siano due partite in uno stesso stadio:
% partita(17,"Inter","Napoli","San Siro") e partita(17,"Milan","Monza","San Siro")
:- partita(G, SquadraCasa1, _, Stadio1), 
   partita(G, SquadraCasa2, _, Stadio2), 
   giornata_ritorno(G), 
   stadio(SquadraCasa1, Stadio1), 
   stadio(SquadraCasa2, Stadio2),
   SquadraCasa1!=SquadraCasa2,
   Stadio1==Stadio2.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VINCOLO FACOLTATIVO 1:
% - Ciascuna squadra non deve giocare mai più di due partite consecutive in casa o fuori casa  
%   Poiche', dopo 5 minuti ancora non finiva (con -t 12) 
%   ABBIAMO SPEZZATO QUESTO VINCOLO IN 3 PARTI in questo modo siamo riusciti ad ottimizzare i tempi e a fare in modo che in tot il time fosse di max 3s ANCHE con questo primo vincolo
%   FACOLTATIVO: 

% 1) PRESENTE ALLA FINE DEI VINCOLI DEL GIRONE DI ANDATA.
% 2) PRESENTE ALLA FINE DEI VINCOLI DEL GIRONE DI RITORNO (qui sotto).
% 3) PRESENTE DOPO IL 2) IN MODO TALE DA FAR RISPETTARE IL VINCOLO ANCHE PER LE GIORNATE A CAVALLO TRA QUELLA DI ANDATA E QUELLA DI RITORNO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VINCOLO FACOLTATIVO 1:
% - Ciascuna squadra non deve giocare mai più di due partite nel girone di ritorno consecutive in casa o fuori casa % (time: 2s max)

% - Ciascuna squadra non deve giocare mai più di due partite nel girone di ritorno consecutive in casa:
:-  partita(G1, Squadra, _, _),
    partita(G2, Squadra, _, _),
    partita(G3, Squadra, _, _),

    squadra(Squadra),

    giornata_ritorno(G1),
    giornata_ritorno(G2),
    giornata_ritorno(G3),

    G2 = G1 + 1,
    G3 = G2 + 1.


% - Ciascuna squadra non deve giocare mai più di due partite nel girone di ritorno consecutive fuori casa:
:-  partita(G1, _, Squadra, _),
    partita(G2, _, Squadra, _),
    partita(G3, _, Squadra, _),

    squadra(Squadra),

    giornata_ritorno(G1),
    giornata_ritorno(G2),
    giornata_ritorno(G3),

    G2 = G1 + 1,
    G3 = G2 + 1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VINCOLO FACOLTATIVO 1:

% - Ciascuna squadra non deve giocare mai più di due partite (anche se si trovano a cavallo tra il girone di andata e quello di ritorno) consecutive in casa:
:-  partita(G1, Squadra, _, _),
    partita(G2, Squadra, _, _),
    partita(G3, Squadra, _, _),

    squadra(Squadra),

    G1<23,
    G2<23,
    G3<23,

    G2 = G1 + 1,
    G3 = G2 + 1.


% - Ciascuna squadra non deve giocare mai più di due partite (anche se si trovano a cavallo tra il girone di andata e quello di ritorno) consecutive fuori casa:
:-  partita(G1, _, Squadra, _),
    partita(G2, _, Squadra, _),
    partita(G3, _, Squadra, _),

    squadra(Squadra),

    G1<23,
    G2<23,
    G3<23,

    G2 = G1 + 1,
    G3 = G2 + 1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FINE VINCOLI GIRONE DI RITORNO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VINCOLO FACOLTATIVO 2:
% - La distanza tra una coppia di gare di andata e ritorno è di almeno 10 giornate,
%   ossia se SquadraA vs SquadraB è programmata per la giornata 12, il ritorno
%   SquadraB vs SquadraA verrà schedulato non prima dalla giornata 22.
% - DA DIRE AL PROF: Con 10 squadre, la distanza di almeno 10 giornate NON PUO' ESSERE SODDISFATTA, ma una distanza di almeno 9 giornate SI.
dist_min:-

    partita(GAndata, SquadraA, SquadraB, _),
    partita(GRitorno, SquadraB, SquadraA, _),
    SquadraA != SquadraB,

    GAndata < 12,
    GRitorno > 11,
    GAndata!=GRitorno,

    (GRitorno - GAndata) < 10.


:- dist_min.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Mi creo un predicato che conterrà PER OGNI GIORNATA DI ANDATA TUTTE LE PARTITE DI QUELLA GIORNATA ma a squadre invertite:
partita_andata(G, SquadraCasa, SquadraFuoriCasa, StadioCasa) :- partita(G, SquadraCasa, SquadraFuoriCasa, StadioCasa), giornata_andata(G).

% IL VINCOLO QUI SOTTO E' STATO SPOSTATO QUI, MENTRE PRIMA SI TROVAVA SUBITO DOPO LA GENERAZIONE DELLE PARTITE DI RITORNO in modo da ottimizzare i tempi finali (riverifica questa cosa)..
% Adesso specifico che per ogni "partita_andata" ci deve essere esattamente una partita giocata in una giornata di ritorno a squadre invertite:
1 { partita(GiornataRitorno, SquadraFuoriCasaAndata, SquadraCasaAndata, StadioFuoriCasaAndata): 
    giornata_ritorno(GiornataRitorno), stadio(SquadraFuoriCasaAndata, StadioFuoriCasaAndata)} 1 :- partita_andata(G, SquadraCasaAndata, SquadraFuoriCasaAndata, StadioCasaAndata).




% PREDICATI DI SUPPORTO:
quante_partite_giocate_nel_girone_di_andata_da_ogni_squadra(Squadra, NumeroPartiteCasa, NumeroPartiteFuoriCasa, NumeroPartiteTot) :-
    squadra(Squadra),  
    NumeroPartiteCasa = #count{G : partita(G, Squadra, _, _), giornata_andata(G)},
    NumeroPartiteFuoriCasa = #count{G : partita(G, _, Squadra, _), giornata_andata(G)},
    NumeroPartiteTot = NumeroPartiteCasa + NumeroPartiteFuoriCasa.


quante_partite_giocate_nel_girone_di_ritorno_da_ogni_squadra(Squadra, NumeroPartiteCasa, NumeroPartiteFuoriCasa, NumeroPartiteTot):-
    squadra(Squadra),  
    NumeroPartiteCasa = #count{G : partita(G, Squadra, _, _), giornata_ritorno(G)},
    NumeroPartiteFuoriCasa = #count{G : partita(G, _, Squadra, _), giornata_ritorno(G)},
    NumeroPartiteTot = NumeroPartiteCasa + NumeroPartiteFuoriCasa.


quante_partite_giocate_sia_in_andata_che_in_ritorno_da_ogni_squadra(Squadra, NumeroPartiteCasa, NumeroPartiteFuoriCasa, NumeroPartiteTot) :-
    squadra(Squadra),  
    NumeroPartiteCasa = #count{G : partita(G, Squadra, _, _)},
    NumeroPartiteFuoriCasa = #count{G : partita(G, _, Squadra, _)},
    NumeroPartiteTot = NumeroPartiteCasa + NumeroPartiteFuoriCasa.

% MI DICE: dammi_tutte_le_squadre_che_giocano_3_partite_consecutive_in_casa("Juventus",1,2,3)
dammi_tutte_le_squadre_che_giocano_3_partite_consecutive_in_casa(Squadra, G1, G2, G3):- 
    
    squadra(Squadra),
    partita(G1, Squadra, _, _),
    partita(G2, Squadra, _, _),
    partita(G3, Squadra, _, _),

    G1<23,
    G2<23,
    G3<23,

    G2 = G1 + 1,
    G3 = G2 + 1.


% dimmi_per_ogni_partita_di_andata_dopo_quante_giornate_ci_sara_il_ritorno("Lazio","Monza",9,10,1)
dimmi_per_ogni_partita_di_andata_dopo_quante_giornate_ci_sara_il_ritorno(SquadraA, SquadraB, GAndata, GRitorno, Dist):-

    partita(GAndata, SquadraA, SquadraB, _),
    partita(GRitorno, SquadraB, SquadraA, _),
    SquadraA != SquadraB,

    GAndata < 12,
    GRitorno > 11,
    GAndata!=GRitorno,

    Dist = (GRitorno - GAndata).


% La stampa di questo predicato la utilizzo per questo:
% - Per 14 squadre: dovrai avere tutte le squadre con valore 13 per essere certo che nel giorone di andata ogni squadra ha giocato esattamente una volta contro ogni altra squadra.
%#show quante_partite_giocate_nel_girone_di_andata_da_ogni_squadra/4. % 5 per 6 squadre, con 10 squadre deve essere 9 partite per ogni squadra.

% La stampa di questo predicato la utilizzo per questo:
% - Per 14 squadre: dovrai avere tutte le squadre con valore 13 per essere certo che anche nel giorone di ritorno ogni squadra ha giocato esattamente una volta contro ogni altra squadra.
%#show quante_partite_giocate_nel_girone_di_ritorno_da_ogni_squadra/4. % 5 per 6 squadre, con 10 squadre deve essere 9 partite per ogni squadra.

% - Per 14 squadre: dovrai avere tutte le squadre con valore 26 per essere certo che in totale (considerando sia nel girone di andata che in quello di ritorno) 
%   ogni squadra ha giocato esattamente una volta contro ogni altra squadra.

% - Per 6 squadre: dovrai avere tutte le squadre con valore 10 per essere certo che in totale (considerando sia nel girone di andata che in quello di ritorno) 
%   ogni squadra ha giocato esattamente una volta contro ogni altra squadra.
%#show quante_partite_giocate_sia_in_andata_che_in_ritorno_da_ogni_squadra/4. % con 12 squadre deve essere 22 partite per ogni squadra.



% per vedere tutte le partite:
#show partita/4.

% CREATO PER IL 1° VINCOLO FACOLTATIVO: (se ti da solamente l'insieme vuoto vuol dire probabilmente che il 1° vincolo è stato implementato correttamente)
% dammi_tutte_le_squadre_che_giocano_3_partite_consecutive_in_casa("Juventus",13,14,15) - le soluzione cambiano ad ogni iterazione quindi lo devi stampare ogni volta per essere sicuro non sbagliare.
%#show dammi_tutte_le_squadre_che_giocano_3_partite_consecutive_in_casa/4.

% CREATO PER IL 2° VINCOLO FACOLTATIVO:
% dimmi_per_ogni_partita_di_andata_dopo_quante_giornate_ci_sara_il_ritorno("Napoli","Genoa",9,18,9)
%#show dimmi_per_ogni_partita_di_andata_dopo_quante_giornate_ci_sara_il_ritorno/5. % start: 13:56