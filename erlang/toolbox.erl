-module(toolbox).
-export([start/0, loop/2]).

start() ->
    Mallet = tool:start(mallet),
    Hammer = tool:start(hammer),
    Tools = [{mallet, Mallet}, {hammer, Hammer}],
    spawn(toolbox, loop, [Tools, []]).

loop(Tools, Q) ->
    receive
	{Client, get, Query} ->
	    give_tools(Tools, Q ++ [{Client, Query}]);
	{Client, put, {Type, Pid}} ->
	    Pid ! {Client, put},
	    give_tools([{Type, Pid} | Tools], Q)
    end.

give_tools(Tools, Queries) ->
    {Tb, Qb} = rem_matches(Tools, Queries, 
			   fun(_, {_, anytool}) -> true; % anytool
			      ({Type, _}, {_, Type}) -> true; % exact tool
			      (_, _) -> false
			   end,
			   fun({_, Pid}, {Client, _}) -> Pid ! {Client, get} end),
    loop(Tb, Qb).

rem_matches(La, Lb, CondFun, DoFun) ->
    rem_matches_helper(La, Lb, CondFun, DoFun, [], []).

rem_matches_helper(La, [], _, _, Ra, Rb) -> % passei por todas as queries
    {La ++ Ra, Rb}; % todo: check if this concat messes up the order
rem_matches_helper([], [Hb|Tb], CondFun, DoFun, Ra, Rb) -> % acabaram as tools! sem match para Hb
    rem_matches_helper(Ra, Tb, CondFun, DoFun, [], [Hb|Rb]);
rem_matches_helper([Ha|Ta], [Hb|Tb], CondFun, DoFun, Ra, Rb) -> 
    case CondFun(Ha, Hb) of
	true ->
	    DoFun(Ha, Hb),
	    % somem Ha e Hb, reseto La
	    rem_matches_helper(Ta ++ Ra, Tb, CondFun, DoFun, [], Rb); % todo: check if this concat messes up the order
	false ->
	    % Ha vai para Ra, Lb preserva
	    rem_matches_helper(Ta, [Hb|Tb], CondFun, DoFun, [Ha|Ra], Rb)
    end.

				   
				   
				      
						      
    

