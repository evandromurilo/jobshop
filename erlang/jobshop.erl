-module(jobshop).
-export([start/0, loop/1]).

start() ->
    Tbox = toolbox:start(),
    Ja = jobber:start(Tbox),
    Jb = jobber:start(Tbox),
    Jobbers = [Ja, Jb],
    Shop = spawn(jobshop, loop, [Jobbers]),
    {Shop, Tbox}. % tbox is useful to debug

% round robin load balancer
loop([NextJobber|T]) ->
    receive
	{Client, Job} -> % easy_job, hard_job, avg_job
	    NextJobber ! {Client, Job}
    end,
    loop(T ++ [NextJobber]).
	
    


