-module(hammer).
-export([start/0, loop_available/1, loop_taken/1]).

start() ->
    spawn(hammer, loop_available, [[]]).

loop_available([]) ->
    receive
	{Client, geth} ->
	    Client ! {self(), granted},
	    loop_taken([]);
	{_, puth} ->
	    loop_available([])
    end;
loop_available([H|T]) ->
    H ! {self(), granted},
    loop_taken(T).

loop_taken(Q) ->
    receive
	{Client, puth} ->
	    Client ! {self(), thanks},
	    loop_available(Q);
	{Client, geth} ->
	    loop_taken(Q ++ [Client])
    end.


