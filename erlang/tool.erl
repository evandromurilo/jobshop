-module(tool).
-export([start/1, loop_available/2, loop_taken/2]).

start(Type) ->
    spawn(tool, loop_available, [Type, []]).

loop_available(Type, []) ->
    receive
	{Client, get} ->
	    Client ! {granted, {Type, self()}},
	    loop_taken(Type, []);
	{_, put} ->
	    loop_available(Type, [])
    end;
loop_available(Type, [H|T]) ->
    H ! {granted, {Type, self()}},
    loop_taken(Type, T).

loop_taken(Type, Q) ->
    receive
	{Client, put} ->
	    Client ! {self(), thanks},
	    loop_available(Type, Q);
	{Client, get} ->
	    loop_taken(Type, Q ++ [Client])
    end.


