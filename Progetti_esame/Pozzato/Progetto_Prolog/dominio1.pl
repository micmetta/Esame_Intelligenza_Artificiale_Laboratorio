% In questo file descriviamo tutto il dominio d'interesse che in questo caso
% sarà il labirinto CON PIU' USCITE nel quale il nostro agente intelligente dovrà muoversi.

% 5x5
%num_righe(5). % mi serve per conoscere i limiti del labirinto
%num_colonne(5). % mi serve per conoscere i limiti del labirinto

% colonna, riga
%iniziale(pos(1,1)).
%iniziale(pos(2,1)).

%finale(pos(1,5)).
%finale(pos(5,5)).

% primo muro
%occupata(pos(1,5)). % se l'aggiungi la soluzione non esisterà più!!
%occupata(pos(1,2)).
%occupata(pos(3,3)).
%occupata(pos(3,5)).


% 3x3

num_righe(10). % mi serve per conoscere i limiti del labirinto
num_colonne(10). % mi serve per conoscere i limiti del labirinto

% colonna, riga
iniziale(pos(1,1)).
%iniziale(pos(2,1)).

finale(pos(1,10)).
finale(pos(10,1)).
finale(pos(10,10)).

% muri
occupata(pos(1,2)).
occupata(pos(1,3)).
occupata(pos(2,3)).
occupata(pos(3,3)).
occupata(pos(5,3)).
occupata(pos(6,3)).
occupata(pos(6,2)).
occupata(pos(6,1)).
occupata(pos(5,4)).
occupata(pos(3,5)).
occupata(pos(4,5)).
occupata(pos(5,5)).
occupata(pos(6,5)).
occupata(pos(7,5)).
occupata(pos(8,5)).


