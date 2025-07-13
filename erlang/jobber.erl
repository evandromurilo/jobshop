-module(jobber).
-export([start/1, loop_available/1]).

start(Toolbox) ->
    spawn(jobber, loop_available, [Toolbox]).

loop_available(Toolbox) ->
    receive
	{Client, easy_job} ->
	    Client ! {self(), object};
	{Client, hard_job} ->
	    Toolbox ! {self(), get, hammer},
	    receive
		{granted, Tool} ->
		    Toolbox ! {self(), put, Tool},
		    Client ! {self(), object}
	    end;
	{Client, avg_job} ->
	    Toolbox ! {self(), get, anytool},
	    receive
		{granted, Tool} ->
		    Toolbox ! {self(), put, Tool},
		    Client ! {self(), object}
	    end
    end,
    loop_available(Toolbox).
