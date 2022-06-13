%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_timer).

-behaviour(gen_server).

-include("game.hrl").
-include("errno.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([add_task/4, add_task/5, add_task/6]).
-export([del_task/1]).
-export([rep_task/4, rep_task/5, rep_task/6]).
-export([del_all/1]).
-export([run_tick_fun/1]).
-export([run_stop_fun/1]).

-define(SERVER, ?MODULE).

-define(LOOP, 1).

-define(tref(Ref), {?MODULE, Ref}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%%-----------------------------------------------
%% @doc 新增定时任务
-spec add_task(Ref, Last, Tick, Mod, TickFun, StopFun) -> Return when
	Ref     :: {RoleID :: integer(), Tag :: atom()},
	Last    :: integer(),
	Tick    :: integer(),
	Mod     :: atom(),
	TickFun :: atom(),
	StopFun :: atom(),
	Return  :: no_return().
%%-----------------------------------------------
add_task(Ref, Last, Mod, StopFun) ->
	add_task(Ref, Last, 0, Mod, ?nil, StopFun).

add_task(Ref, Last, Tick, Mod, TickFun) ->
	add_task(Ref, Last, Tick, Mod, TickFun, ?nil).

add_task(Ref, Last, Tick, Mod, TickFun, StopFun) ->
	Msg = {add_task, Ref, Last, Tick, Mod, TickFun, StopFun},
	gen_server:cast(?SERVER, Msg).


%%-----------------------------------------------
%% @doc 删除定时任务
-spec del_task(any()) ->
	no_return().
%%-----------------------------------------------
del_task(Ref) ->
	gen_server:cast(?SERVER, {del_task, Ref}).

%%-----------------------------------------------
%% @doc 替换定时任务
-spec rep_task(Ref, Last, Tick, Mod, TickFun, StopFun) -> Return when
	Ref  :: {RoleID :: integer(), Tag :: atom()}
		  | {RoleID :: integer(), Tag :: atom(), Args :: any()},
	Last :: integer(),
	Tick :: integer(),
	Mod  :: atom(),
	TickFun :: atom(),
	StopFun :: atom(),
	Return  :: no_return().
%%-----------------------------------------------
rep_task(Ref, Last, Mod, StopFun) ->
	rep_task(Ref, Last, 0, Mod, ?nil, StopFun).

rep_task(Ref, Last, Tick, Mod, TickFun) ->
	rep_task(Ref, Last, Tick, Mod, TickFun, ?nil).

rep_task(Ref, Last, Tick, Mod, TickFun, StopFun) ->
	Msg = {rep_task, Ref, Last, Tick, Mod, TickFun, StopFun},
	gen_server:cast(?SERVER, Msg).

del_all(RoleID) ->
	gen_server:cast(?SERVER, {del_all, RoleID}).

run_tick_fun({?MODULE, Ref}) ->
	case get_tw_task(Ref) of
		{Mod, TickFun, _} when TickFun /= ?nil ->
			RoleID = element(1, Ref),
			role:route(RoleID, Mod, TickFun, Ref, Ref);
		_ ->
			ignore
	end.

run_stop_fun({?MODULE, Ref}) ->
	case del_tw_task(Ref) of
		{Mod, _, StopFun} when StopFun /= ?nil ->
			RoleID = element(1, Ref),
			role:route(RoleID, Mod, StopFun, Ref, Ref);
		_ ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ut_twheel:new(?MODULE),
	erlang:send_after(timer:seconds(?LOOP), self(), loop),
	{ok, #{}}.


handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).


terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.

do_handle_cast({add_task, Ref, Last, Tick, Mod, TickFun, StopFun}, State) ->
	do_add_task(Ref, Last, Tick, Mod, TickFun, StopFun),
	{noreply, ut_misc:maps_append(element(1, Ref), Ref, State)};

do_handle_cast({del_task, Ref}, State) ->
	do_del_task(Ref),
	{noreply, ut_misc:maps_delete(element(1, Ref), Ref, State)};

do_handle_cast({rep_task, Ref, Last, Tick, Mod, TickFun, StopFun}, State) ->
	do_del_task(Ref),
	do_add_task(Ref, Last, Tick, Mod, TickFun, StopFun),
	{noreply, State};

do_handle_cast({del_all, RoleID}, State) ->
	RefList = maps:get(RoleID, State, []),
	[do_del_task(Ref) || Ref <- RefList],
	{noreply, maps:remove(RoleID, State)};

do_handle_cast(Msg, State) ->
	?error("unhandle cast: ~w", [Msg]),
	{noreply, State}.


do_handle_info(loop, State) ->
	erlang:send_after(timer:seconds(?LOOP), self(), loop),
	try
		ut_twheel:tick(?MODULE)
	catch Class:Reason:Stacktrace ->
		?stacktrace(Class, Reason, Stacktrace)
	end,
	{noreply, State};

do_handle_info(Info, State) ->
	?error("unhandle info: ~w", [Info]),
	{noreply, State}.

do_add_task(Ref, Last, Tick, Mod, TickFun, StopFun) ->
	set_tw_task(Ref, {Mod, TickFun, StopFun}),
	Hdl = {?MODULE, run_tick_fun, run_stop_fun},
	ut_twheel:add_task(?MODULE, ?tref(Ref), Last, Tick, Hdl).

do_del_task(Ref) ->
	del_tw_task(Ref),
	ut_twheel:del_task(?MODULE, ?tref(Ref)).

-define(k_tw_task, ?tref(Ref)).
get_tw_task(Ref) ->
	get(?k_tw_task).

set_tw_task(Ref, Task) ->
	put(?k_tw_task, Task).

del_tw_task(Ref) ->
	erase(?k_tw_task).
