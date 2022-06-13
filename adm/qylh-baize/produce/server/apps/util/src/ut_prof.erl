%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(ut_prof).

%% API
-export([tc/4, tc/5]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 分析函数执行时间
-spec tc(module(), function(), any(), integer(), function()) ->
	{}.
%%-----------------------------------------------
tc(Mod, Fun, Args, N) ->
	tc(Mod, Fun, Args, N, fun io:format/2).

tc(Mod, Fun, Args, N, Logger) ->
	Result = tc_loop(Mod, Fun, Args, N, []),
	Sorted = lists:sort(Result),
	Min = hd(Sorted),
	Max = hd(lists:reverse(Sorted)),
	Avg = lists:sum(Sorted) / length(Sorted),
	Logger(
		"Min Time: ~w(micro seconds), ~w(seconds)~n"
		"Max Time: ~w(micro seconds), ~w(seconds)~n"
		"Avg Time: ~w(micro seconds), ~w(seconds)",
		[Min, Min/1000000, Max, Max/1000000, Avg, Avg/1000000]
	).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
tc_loop(Mod, Fun, Args, N, Acc) when N > 0 ->
	{Time, _} = timer:tc(Mod, Fun, Args),
	tc_loop(Mod, Fun, Args, N-1, [Time | Acc]);
tc_loop(_Mod, _Fun, _Args, 0, Acc) ->
	Acc.