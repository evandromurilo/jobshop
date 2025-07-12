-module(jobber).
-export([start/1, loop_available/1]).

start(Hammer) ->
    spawn(jobber, loop_available, [Hammer]).

loop_available(Hammer) ->
    receive
	{Client, easy_job} ->
	    Client ! {self(), object};
	{Client, hard_job} ->
	    Hammer ! {self(), geth},
	    receive
		{Hammer, granted} ->
		    Hammer ! {self(), puth},
		    Client ! {self(), object}
	    end
    end,
    loop_available(Hammer).
