%%%-------------------------------------------------------------------
%%% @author an
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(json_decode_perf_sup).

-behaviour(supervisor).

-export([start_link/0, init/1, t/1, t/2]).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
%  Mod = #{id => mod,
%    start => {mod, start_link, []},
%    restart => permanent,
%    shutdown => brutal_kill,
%    type => worker,
%    modules => [mod]},

  {ok, {#{strategy => one_for_one,
    intensity => 5,
    period => 30},
    []}
  }.

t(Name) -> t(Name, 100000).

t(Name, Cnt) ->  
  {ok, Data} = file:read_file(Name),

  io:format("Data size: ~p~n", [iolist_size(Data)]),
  io:format("Decoding Json data using jsx; "),
  JsxF = fun() -> jsx:decode(Data, [{labels, atom}, {return_maps, true}]) end,
  run_and_print(JsxF, Cnt),
  io:format("~n"),
  
  io:format("Decoding Json data using jiffy; "),
  JiffyF = fun() -> jiffy:decode(Data, [return_maps]) end,
  run_and_print(JiffyF, Cnt),
  io:format("~n"),

  io:format("Decoding Json data using mochijson2; "),
  MochiF = fun() -> mochijson2:decode(Data, [{format, map}]) end,
  run_and_print(MochiF, Cnt),
  io:format("~n").



run_and_print(F, Cnt) -> 
  {Time, _} = timer:tc(fun() -> run_t(Cnt, F) end),
  io:format("elapsed: ~p ms; speed: ~p jsons/sec", [Time / 1000, Cnt / Time * 1000000]).

run_t(0, _) -> ok;
run_t(N, F) -> F(), run_t(N - 1, F).  