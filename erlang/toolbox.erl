-module(toolbox).
-export([start/0, loop/2]).

% acho que tá funcionando, mas a interface está hard de usar

start() ->
    % anytool ??
    Mallet = tool:start(),
    Hammer = tool:start(),
    Tools = [{mallet, Mallet}, {hammer, Hammer}],
    spawn(toolbox, loop, [Tools, []]).

loop(Tools, Q) ->
    receive
	{Client, get, Type} ->
	    give_tools(Tools, Q ++ [{Client, Type}]);
	{Client, put, {Type, Pid}} ->
	    Pid ! {Client, put},
	    give_tools([{Type, Pid} | Tools], Q)
    end.

give_tools(Tools, Queries) ->
    {Tb, Qb} = rem_matches(Tools, Queries, 
			   fun({Type, _}, {_, Type}) -> true;
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

				   
				   
				      
						      
    

