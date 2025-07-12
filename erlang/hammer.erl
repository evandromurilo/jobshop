-module(hammer).
-export([start/0, loop_available/0, loop_taken/0]).

start() ->
    spawn(hammer, loop_available, []).

loop_available() ->
    receive
	{Client, geth} ->
	    Client ! {self(), granted},
	    loop_taken();
	{Client, puth} ->
	    Client ! {self(), whut},
	    loop_available()
    end.

loop_taken() ->
    receive
	{Client, puth} ->
	    Client ! {self(), thanks},
	    loop_available();
	{Client, geth} ->
	    Client ! {self(), busy}, % should actually wait till puth and send granted
	    loop_taken()
    end.


