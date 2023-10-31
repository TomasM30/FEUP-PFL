:- use_module(library(lists)).
:- use_module(library(random)).
:- use_module(library(clpfd)).
:- consult('display.pl').
:- consult('Menu_configurations.pl').
:- consult('utils.pl').


% start_game
start :-
    home,
    board(_, Board),
    display_board(Board),
    validate_piece.

% in_bounds(+Board,+Coordinate)
% Checks if calculated coordinate is inside Board
check_bounds(Board, Col-Row) :-
    length(Board, Size),
    between(1, Size, Col),
    between(1, Size, Row).

% validate_move(+Board,+CoordsOrigin,+CoordsDestination)
% Checks if the move is valid or not on placement phase
validate_move_PP(GameState, ColI-RowI, ColF-RowF, -1) :-
    write('Valid Move!').
validate_move_PP(GameState, ColI-RowI,ColF-RowF, size) :-
    [Board, Player, Phase] = GameState,
    check_bounds(ColI-RowI), check_bounds(ColF-RowF),
    board(Board),
    nth1(RowI, Board, RowList),
    nth1(ColI, RowList, Cell),
    Cell = ' - ',
    (
        (ColF - ColI = size ->
            Row is RowI + 1,
            NewSize is size - 1,
            validate_move_PP(GameState, ColI-ColF, Row-RowF, NewSize)
        ; RowF - RowI = size ->
            Col is ColI + 1,
            NewSize is size - 1,
            validate_move_PP(GameState, Col-RowI, ColF-RowF, NewSize)
        ; true
        )
    ),
    write('Invalid Move! \n').  

% Check if there are any possible moves for the current player
has_possible_moves(GameState, Moves) :-
    [Board, Player, _] = GameState,
    player_value_pieces(Player, Pieces, size, _),
    has_possible_moves(Board, Player, Pieces, Moves, size).

% Base case: No pieces left, no possible moves
has_possible_moves(_, _, 0, _, _) :- fail.

% If there are pieces left, check for possible moves
has_possible_moves(Board, Player, Pieces, Moves, size) :-
    check_possible_moves(Board, Player, Pieces, 1, 1, Moves, size).

% Check for possible moves starting from a specific row and column
check_possible_moves(_, _, _, Row, _, _, _) :- Row > 10, !, fail.

check_possible_moves(Board, Player, Pieces, Row, 10, Moves, size) :-
    NewRow is Row + 1,
    check_possible_moves(Board, Player, Pieces, NewRow, 1, Moves, size).

check_possible_moves(Board, Player, Pieces, 10, 10, Moves, size) :-
    write('No more valid moves, the player should pass! \n').

check_possible_moves(Board, Player, Pieces, Row, Col, Moves, size) :-
    Col < 11,
    ColF is Col + size,
    RowF is Row + size,
    (
        (validate_move_PP([Board, Player, _], Col-Row, ColF-Row, Size) ->
            append(Moves, [Col-Row, ColF-Row], NewMoves)
        ; validate_move_PP([Board, Player, _], Col-Row, Col-RowF, Size) ->
            append(Moves, [Col-Row, Col-RowF], NewMoves)
        ; true
        )
    ),
    NewPieces is Pieces - 1,
    NewPieces > 0,
    % Continue checking the next cell and the next piece
    NextCol is Col + 1,
    check_possible_moves(Board, Pieces, Row, NextCol).

% choose_move(+GameState,+Player,+Level,-Move)
% Choose move a human player
choose_move([Board, Player, _], ColI-RowI-ColF-RowF):-
    \+difficulty(Player, _),                    
    repeat,
    get_move(ColI-RowI-ColF-RowF, piece),
    player_value_pieces(_, _, size, piece),                 
    validate_move_PP([Board,Player, _], ColI-RowI, ColF-RowF, size), !.  

% choose move a bot player, fica pra mais tarde
% choose_move([Board,Player,ForcedMoves,TotalMoves], Move):-
    % difficulty(Player, Level),                  
    % choose_move([Board,Player,ForcedMoves,TotalMoves], Player, Level, Move), !.   

% move(+GameState, +Move, -NewGameState)
% Moves a piece
move(GameState, ColI-RowI-ColF-RowF, NewGameState):-                       
    [Board, Player, _] = GameState,
    

% game_cycle(+GameState)
% Loop that keeps the game running
game_cycle(GameState):-
    pp_over(GameState), !, 
    game_over(GameState, Winner), !,
    display_game(GameState),
    show_winner(GameState, Winner).
game_cycle(GameState):-
    display_game(GameState),
    print_turn(GameState),
    choose_move(GameState, Move),
    move(GameState, Move, NewGameState), !,
    game_cycle(NewGameState).
game_cycle(GameState):-
    display_game(GameState),
    print_turn(GameState),
    choose_move_SP(GameState, Move),
    move_SP(GameState, Move, NewGameState), !,
    game_cycle(NewGameState).