%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(tester).

-include("game.hrl").

%% API
-export([start/1]).
-export([host/0]).
-export([port/0]).

-define(CONCURRENCY_NUM, 20).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start([AccountPrefix, TotalNum]) ->
	start_tester(ut_conv:to_integer(TotalNum), AccountPrefix).

host() ->
	"120.79.93.201".
	% "192.168.120.128".

port() ->
	9002.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
start_tester(TotalNum, Prefix) ->
	GroupNum = ut_math:ceil(TotalNum / ?CONCURRENCY_NUM),
	lists:foreach(fun
		(GroupID) ->
			spawn(fun() -> start_tester2(GroupNum, GroupID, Prefix) end)
	end, lists:seq(1, ?CONCURRENCY_NUM)).

start_tester2(0, _GroupID, _Prefix) ->
	ok;
start_tester2(GroupNum, GroupID, Prefix) ->
	tester_agent:start(GroupID*1000+GroupNum, Prefix),
	timer:sleep(timer:seconds(1)),
	start_tester2(GroupNum-1, GroupID, Prefix).
