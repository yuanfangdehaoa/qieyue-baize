%%%===================================================================
%%% @author z.hua
%%% @doc
%%% 时间轮
%%% @end
%%%===================================================================

-module(ut_twheel).

-include("game.hrl").

%% API
-export([new/1]).
-export([tick/1, tick/2]).
-export([add_task/5]).
-export([del_task/2]).
-export([ext_task/3]).

-define(DW_SIZE, 366).
-define(HW_SIZE, 24).
-define(MW_SIZE, 60).
-define(SW_SIZE, 60).

-record(twheel, {
	  ref    % Wheel Ref
	, dwheel % key=#task.slot[0..DW_SIZE-1] val=[#task.ref]
	, hwheel % key=#task.slot[0..HW_SIZE-1] val=[#task.ref]
	, mwheel % key=#task.slot[0..MW_SIZE-1] val=[#task.ref]
	, swheel % key=#task.slot[0..SW_SIZE-1] val=[#task.ref]
	, tasks  % key=#task.ref, val=#task{}
}).

-record(task, {
	  ref  % Task Ref
	, tick % 触发间隔
	, hdl  % 处理器 {Mod, TickFun, StopFun}
	, slot % 当前在哪个时间槽
	, cron % 什么时候执行任务 Clock
	, stop % 什么时候结束任务 Clock
}).

-export_type([twheel/0]).

-type twheel() :: #twheel{}.

%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
new(WRef) ->
	case get_wheel(WRef) == undefined of
		true  -> ok;
		false -> throw({already_defined, WRef})
	end,
	set_clock(WRef, {0, 0, 0, 0}),
	set_wheel(#twheel{
		ref    = WRef,
		dwheel = new_wheel(?DW_SIZE),
		hwheel = new_wheel(?HW_SIZE),
		mwheel = new_wheel(?MW_SIZE),
		swheel = new_wheel(?SW_SIZE),
		tasks  = maps:new()
	}).

%%-----------------------------------------------
%% @doc 运行时间轮
-spec tick(any(), any()) ->
	no_return().
%%-----------------------------------------------
tick(WRef) ->
	tick(WRef, 1).

tick(WRef, N) ->
	TW  = get_wheel(WRef),
	TW2 = do_tick(TW, N),
	set_wheel(TW2).


%%-----------------------------------------------
%% @doc 添加任务
-spec add_task(
	WheelRef :: any(),
	TaskRef  :: any(),
	TaskLast :: integer(),
	TaskTick :: integer(),
	{
		Module  :: module(),
		TickFun :: function(),
		StopFun :: function()
	}
) ->
	no_return().
%%-----------------------------------------------
add_task(WRef, TRef, Last, Tick, Hdl) ->
	TW  = #twheel{tasks=Tasks} = get_wheel(WRef),
	Max = ?DW_SIZE * ?HW_SIZE * ?MW_SIZE * ?SW_SIZE,
	TW2 = case
		(Tick < 0 orelse Tick >= Max orelse Last < 0) orelse
		(maps:is_key(TRef, Tasks))
	of
		true  -> TW;
		false -> do_add(TW, new_task(WRef, TRef, Tick, Last, Hdl))
	end,
	set_wheel(TW2).


%%-----------------------------------------------
%% @doc 删除任务
-spec del_task(any(), any()) ->
	no_return().
%%-----------------------------------------------
del_task(WRef, TRef) ->
	TW  = get_wheel(WRef),
	TW2 = do_del(TW, TRef),
	set_wheel(TW2).


%%-----------------------------------------------
%% @doc 延长任务时间
-spec ext_task(any(), any(), integer()) ->
	no_return().
%%-----------------------------------------------
ext_task(WRef, TRef, Last) ->
	TW  = #twheel{tasks=Tasks} = get_wheel(WRef),
	TW2 = case maps:find(TRef, Tasks) of
		{ok, Task} ->
			Task2 = Task#task{stop=walk(get_clock(WRef), Last)},
			TW#twheel{tasks=maps:put(TRef, Task2, Tasks)};
		error ->
			TW
	end,
	set_wheel(TW2).

%%%-------------------------------------------------------------------
%%% Internal Functions
%%%-------------------------------------------------------------------
new_wheel(Size) ->
	maps:from_list([{I, []} || I <- lists:seq(0, Size-1)]).

new_task(WRef, TRef, Tick, Last, Hdl) ->
	Stop = case Last of
		0 -> {?DW_SIZE,0,0,0};
		_ -> walk(get_clock(WRef), Last)
	end,
	#task{ref=TRef, tick=Tick, hdl=Hdl, stop=Stop}.

%% {DayOfYear, Hour, Minute, Second}
get_wheel(WRef) ->
	get({wheel, WRef}).

set_wheel(TW) ->
	put({wheel, TW#twheel.ref}, TW).

get_clock(WRef) ->
	get({clock, WRef}).

set_clock(WRef, Clock) ->
	put({clock, WRef}, Clock).

do_add(TW, Task) ->
	Clock = {D, H, M, _} = get_clock(TW#twheel.ref),
	#task{ref=TRef, tick=Tick, hdl={Mod, TickFun, _}, stop=Stop} = Task,
	?_if(Tick == 0 andalso TickFun /= ?nil, do_run(Mod, TickFun, TRef)),
	Cron  = ?_if(Tick == 0, Stop, walk(Clock, Tick)),
	Task2 = Task#task{cron=Cron},
	case Cron of
		{D, H, M, S2} -> add_to_swheel(TW, S2, Task2);
		{D, H, M2, _} -> add_to_mwheel(TW, M2, Task2);
		{D, H2, _, _} -> add_to_hwheel(TW, H2, Task2);
		{D2, _, _, _} -> add_to_dwheel(TW, D2, Task2)
	end.

add_to_dwheel(TW, Slot, Task = #task{ref=Ref}) ->
	TW#twheel{
		dwheel = maps_append(Slot, Ref, TW#twheel.dwheel),
		tasks  = maps:put(Ref, Task#task{slot={d, Slot}}, TW#twheel.tasks)
	}.

add_to_hwheel(TW, Slot, Task = #task{ref=TRef}) ->
	TW#twheel{
		hwheel = maps_append(Slot, TRef, TW#twheel.hwheel),
		tasks  = maps:put(TRef, Task#task{slot={h, Slot}}, TW#twheel.tasks)
	}.

add_to_mwheel(TW, Slot, Task = #task{ref=TRef}) ->
	TW#twheel{
		mwheel = maps_append(Slot, TRef, TW#twheel.mwheel),
		tasks  = maps:put(TRef, Task#task{slot={m, Slot}}, TW#twheel.tasks)
	}.

add_to_swheel(TW, Slot, Task = #task{ref=TRef}) ->
	TW#twheel{
		swheel = maps_append(Slot, TRef, TW#twheel.swheel),
		tasks  = maps:put(TRef, Task#task{slot={s, Slot}}, TW#twheel.tasks)
	}.

do_del(TW, TRef) ->
	case maps:take(TRef, TW#twheel.tasks) of
		{#task{slot={d,Slot}}, Tasks2} ->
			TW#twheel{
				dwheel = maps_delete(Slot, TRef, TW#twheel.dwheel),
				tasks  = Tasks2
			};
		{#task{slot={h,Slot}}, Tasks2} ->
			TW#twheel{
				hwheel = maps_delete(Slot, TRef, TW#twheel.hwheel),
				tasks  = Tasks2
			};
		{#task{slot={m,Slot}}, Tasks2} ->
			TW#twheel{
				mwheel = maps_delete(Slot, TRef, TW#twheel.mwheel),
				tasks  = Tasks2
			};
		{#task{slot={s,Slot}}, Tasks2} ->
			TW#twheel{
				swheel = maps_delete(Slot, TRef, TW#twheel.swheel),
				tasks  = Tasks2
			};
		error ->
			TW
	end.

do_tick(TW, N) ->
	Clock  = {D, H, M, _} = get_clock(TW#twheel.ref),
	Clock2 = walk(Clock, N),
	set_clock(TW#twheel.ref, Clock2),
	case Clock2 of
		{D, H, M, S2} ->
			run_swheel(TW, S2);
		{D, H, M2, S2} ->
			TW2 = run_mwheel(TW, M2),
			run_swheel(TW2, S2);
		{D, H2, M2, S2} ->
			TW2 = run_hwheel(TW, H2),
			TW3 = run_mwheel(TW2, M2),
			run_swheel(TW3, S2);
		{D2, H2, M2, S2} ->
			TW2 = run_dwheel(TW, D2),
			TW3 = run_hwheel(TW2, H2),
			TW4 = run_mwheel(TW3, M2),
			run_swheel(TW4, S2)
	end.

run_dwheel(TW, D) ->
	lists:foldl(fun
		(TRef, Acc) ->
			case maps:find(TRef, Acc#twheel.tasks) of
				{ok, Task} ->
					{_, H, _, _} = Task#task.cron,
					add_to_hwheel(do_del(Acc, TRef), H, Task);
				error ->
					Acc
			end
	end, TW, maps:get(D, TW#twheel.dwheel)).

run_hwheel(TW, H) ->
	lists:foldl(fun
		(TRef, Acc) ->
			case maps:find(TRef, Acc#twheel.tasks) of
				{ok, Task} ->
					{_, _, M, _} = Task#task.cron,
					add_to_mwheel(do_del(Acc, TRef), M, Task);
				error ->
					Acc
			end
	end, TW, maps:get(H, TW#twheel.hwheel)).

run_mwheel(TW, M) ->
	lists:foldl(fun
		(TRef, Acc) ->
			case maps:find(TRef, Acc#twheel.tasks) of
				{ok, Task} ->
					{_, _, _, S} = Task#task.cron,
					add_to_swheel(do_del(Acc, TRef), S, Task);
				error ->
					Acc
			end
	end, TW, maps:get(M, TW#twheel.mwheel)).

run_swheel(TW, S) ->
	lists:foldl(fun
		(TRef, Acc) ->
			case maps:find(TRef, Acc#twheel.tasks) of
				{ok, Task} ->
					run_task(Acc, Task);
				error ->
					do_del(Acc, TRef)
			end
	end, TW, maps:get(S, TW#twheel.swheel)).

run_task(TW, Task) ->
	#task{tick=Tick, ref=TRef, hdl={Mod, TickFun, StopFun}, stop=Stop} = Task,
	case TickFun /= undefined andalso Tick > 0 of
		true  -> do_run(Mod, TickFun, TRef);
		false -> ignore
	end,
	case get_clock(TW#twheel.ref) >= Stop of
		true  ->
			case StopFun == undefined of
				true  -> ignore;
				false -> do_run(Mod, StopFun, TRef)
			end,
			do_del(TW, TRef);
		false ->
			do_add(do_del(TW, TRef), Task)
	end.

do_run(Mod, Fun, Ref) ->
	Mod:Fun(Ref).

walk(Clock) ->
	walk(Clock, 1).
walk({D, H, M, S}, N) ->
	S2 = S + N,
	M2 = M + S2 div ?SW_SIZE,
	H2 = H + M2 div ?MW_SIZE,
	D2 = D + H2 div ?HW_SIZE,
	{D2 rem ?DW_SIZE, H2 rem ?HW_SIZE, M2 rem ?MW_SIZE, S2 rem ?SW_SIZE}.

maps_append(Key, Elem, Map) ->
	maps:update_with(Key, fun(L) -> [Elem | L] end, [Elem], Map).

maps_delete(Key, Elem, Map) ->
	maps:update_with(Key, fun(L) -> lists:delete(Elem, L) end, [], Map).

%%%-----------------------------------------------------------------------------
%%% Test Functions
%%%-----------------------------------------------------------------------------
-define(TEST, true).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

walk_test_() ->
	[
		?_assertEqual({0,0,0,1}, walk({0,0,0,0})),
		?_assertEqual({0,0,0,59}, walk({0,0,0,0}, 59)),
		?_assertEqual({0,0,1,0}, walk({0,0,0,0}, 60)),
		?_assertEqual({0,0,59,59}, walk({0,0,0,0}, 59*60+59)),
		?_assertEqual({0,1,0,0}, walk({0,0,0,0}, 60*60)),
		?_assertEqual({0,23,59,59}, walk({0,0,0,0}, 23*60*60+59*60+59)),
		?_assertEqual({1,0,0,0}, walk({0,0,0,0}, 24*60*60)),
		?_assertEqual({365,23,59,59}, walk({0,0,0,0}, 365*24*60*60+23*60*60+59*60+59)),
		?_assertEqual({0,0,0,0}, walk({0,0,0,0}, 366*24*60*60))
	].

-endif.