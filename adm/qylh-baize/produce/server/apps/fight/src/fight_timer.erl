%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fight_timer).

-include("game.hrl").
-include("scene.hrl").

%% API
-export([init/0]).
-export([loop/0]).
-export([add_task/4, add_task/5, add_task/6]).
-export([del_task/1]).
-export([run_tick_fun/1]).
-export([run_stop_fun/1]).

% TimeWheel Ref
-define(wref, ?MODULE).
% Task Ref
-define(tref(Ref), {?MODULE, Ref}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init() ->
	ut_twheel:new(?wref).

loop() ->
	ut_twheel:tick(?wref).

add_task(Ref, Last, Mod, StopFun) ->
	add_task(Ref, Last, 0, Mod, ?nil, StopFun).

add_task(Ref, Last, Tick, Mod, TickFun) ->
	add_task(Ref, Last, Tick, Mod, TickFun, ?nil).

add_task(Ref, Last, Tick, Mod, TickFun, StopFun) ->
	set_fight_task(Ref, {Mod, TickFun, StopFun}),
	Hdl = {?MODULE, run_tick_fun, run_stop_fun},
	ut_twheel:add_task(?wref, ?tref(Ref), Last, Tick, Hdl).

del_task(Ref) ->
	ut_twheel:del_task(?wref, ?tref(Ref)).


run_tick_fun({?MODULE, Ref}) ->
	case get_fight_task(Ref) of
		{Mod, TickFun, _} when TickFun /= ?nil ->
			scene:route(self(), Mod, TickFun, Ref);
		_ ->
			ignore
	end.

run_stop_fun({?MODULE, Ref}) ->
	case del_fight_task(Ref) of
		{Mod, _, StopFun} when StopFun /= ?nil ->
			scene:route(self(), Mod, StopFun, Ref);
		_ ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
-define(k_fight_task, ?tref(Ref)).
get_fight_task(Ref) ->
	get(?k_fight_task).

set_fight_task(Ref, Task) ->
	put(?k_fight_task, Task).

del_fight_task(Ref) ->
	erase(?k_fight_task).
