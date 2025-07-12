-module(tool).
-export([start/0, loop_available/1, loop_taken/1]).

start() ->
    spawn(tool, loop_available, [[]]).

loop_available([]) ->
    receive
	{Client, get} ->
	    Client ! {self(), granted},
	    loop_taken([]);
	{_, put} ->
	    loop_available([])
    end;
loop_available([H|T]) ->
    H ! {self(), granted},
    loop_taken(T).

loop_taken(Q) ->
    receive
	{Client, put} ->
	    Client ! {self(), thanks},
	    loop_available(Q);
	{Client, get} ->
	    loop_taken(Q ++ [Client])
    end.


