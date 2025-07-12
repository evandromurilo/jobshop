-module(jobshop).
-export([start/0]).

start() ->
    spawn(jobshop,
