-module(jobshop).
-export([start/0]).

start() ->
    JobShop = spawn(jobshop, start, [])
