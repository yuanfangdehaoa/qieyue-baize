%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(yunying_manager).

-behaviour(gen_server).

-include_lib("stdlib/include/ms_transform.hrl").
-include("game.hrl").
-include("yunying.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([get_yy_info/1]).
-export([set_yy_info/1]).
-export([hook_chime/1]).
-export([reload/0, reload/1]).
-export([gm_start/3]).
-export([gm_stop/1]).
-export([gm_delete/1]).
-export([gm_print/0, gm_print/1]).

-define(SERVER, ?MODULE).

-define(ETS_YY_INFO, ets_yy_info).

-define(CHECK_INTERVAL, 5).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_yy_info(YYActID) ->
	case ets:lookup(?ETS_YY_INFO, YYActID) of
		[R] -> R;
		[]  -> #yy_info{id=YYActID}
	end.

set_yy_info(YYInfo) ->
	gen_server:call(?SERVER, {set_yy_info, YYInfo}).

hook_chime(Hour) ->
	gen_server:cast(?SERVER, {chime, Hour}).

reload() ->
	gen_server:cast(?SERVER, reload).

reload(YYActID) ->
	gen_server:cast(?SERVER, {reload, YYActID}).

gm_start(YYActID, STime, ETime) ->
	gen_server:cast(?SERVER, {gm_start, YYActID, STime, ETime}).

gm_stop(YYActID) ->
	gen_server:cast(?SERVER, {gm_stop, YYActID}).

gm_delete(YYActIDs) when is_list(YYActIDs) ->
	gen_server:cast(?SERVER, {gm_delete, YYActIDs});
gm_delete(YYActID) when is_integer(YYActID) ->
	gen_server:cast(?SERVER, {gm_delete, [YYActID]}).

gm_print() ->
	[gm_print(Act) || Act <- lists:keysort(#yy_act.id, ets:tab2list(?ETS_YY_ACT))].

gm_print(YYActID) when is_integer(YYActID) ->
	case ets:lookup(?ETS_YY_ACT, YYActID) of
		[Act] ->
			gm_print(Act);
		[] ->
			{no_act, YYActID}
	end;
gm_print(Act) ->
	io:format("id=~w, stime=~s, etime=~s, state=~ts~n", [
		Act#yy_act.id,
		ut_time:seconds_to_string(Act#yy_act.act_stime),
		ut_time:seconds_to_string(Act#yy_act.act_etime),
		case Act#yy_act.act_state of
			?YY_ST_STARTED -> "进行中";
			?YY_ST_STOPPED -> "已结束"
		end
	]),
	ok.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_YY_INFO, [named_table, {keypos, #yy_info.id}]),
	ets:new(?ETS_YY_ACT, [named_table, {keypos, #yy_act.id}]),
	{ok, undefined}.


handle_call(Req, From, State) ->
	?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
	?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
	?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
	lists:foreach(fun
		(YYInfo) ->
			db:dirty_write(?DB_YY_INFO, YYInfo)
	end, ets:tab2list(?ETS_YY_INFO)),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({set_yy_info, YYInfo}, _From, State) ->
	ets:insert(?ETS_YY_INFO, YYInfo),
	{reply, ok, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.

%% 整点
do_handle_cast({chime, Hour}, State) ->
	Agents = supervisor:which_children(yunying_agent_sup),
	lists:foreach(fun
		({_, Pid, _, _}) ->
			yunying_agent:clear(Pid, Hour)
	end, Agents),
	{noreply, State};

%% stop_show 后重新调度该活动
do_handle_cast({reload, YYActID}, State) ->
	init_activity(YYActID),
	{noreply, State};

%% 重新加载配置
do_handle_cast(reload, State) ->
	do_init(),
	{noreply, State};

do_handle_cast(started, State) ->
	ets:insert(?ETS_YY_INFO, db:dirty_match_all(?DB_YY_INFO)),
	do_init(),
	do_check(),
	erlang:send_after(timer:seconds(?CHECK_INTERVAL), self(), check),
	{noreply, State};

do_handle_cast({gm_start, YYActID, STime, ETime}, State) ->
	YYAct = #yy_act{
		id         = YYActID,
		join_level = 0,
		join_wake  = 0,
		act_stime  = STime,
		act_etime  = ETime,
		act_state  = ?YY_ST_STOPPED,
		show_stime = STime,
		show_etime = ETime,
		show_state = ?YY_ST_STOPPED
	},
	ets:insert(?ETS_YY_ACT, YYAct),
	start_show(YYAct),
	start_act(YYAct),
	{noreply, State};

do_handle_cast({gm_stop, YYActID}, State) ->
	[YYAct] = ets:lookup(?ETS_YY_ACT, YYActID),
	YYAct2  = YYAct#yy_act{
		act_stime  = 0,
		act_etime  = 0,
		act_state  = ?YY_ST_STOPPED,
		show_stime = 0,
		show_etime = 0,
		show_state = ?YY_ST_STOPPED
	},
	ets:insert(?ETS_YY_ACT, YYAct2),
	stop_act(YYAct2),
	stop_show(YYAct2),
	{noreply, State};

do_handle_cast({gm_delete, YYActIDs}, State) ->
	lists:foreach(fun
		(YYActID) ->
			ets:delete(?ETS_YY_ACT, YYActID)
	end, YYActIDs),
	{noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(check, State) ->
	erlang:send_after(timer:seconds(?CHECK_INTERVAL), self(), check),
	do_check(),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

do_init() ->
	List = case cluster:is_local() of
		true  -> cfg_yunying:all() ++ cfg_festival:all();
		false -> cfg_yunying:list(true) ++ cfg_festival:list(true)
	end,
	lists:foreach(fun
		(YYActID) ->
			init_activity(YYActID)
	end, List).

init_activity(YYActID) ->
	Mod = yunying_util:cfg_act_mod(YYActID),
	#cfg_yunying{
		id=YYActID, level=Level, wake=Wake, cycle=Cycle, days=DayList,
		time=TimeList, show=ShowList
	} = Mod:find(YYActID),
	TimeList2 = [{T1, T2, T2} || {T1, T2} <- TimeList],
	ShowList2 = [{T1, T2, T2} || {T1, T2} <- ShowList],
	case ut_activity:schedule(Cycle, DayList, ShowList2) of
		{ok, ShowSTime, ShowETime} ->
			case ut_activity:schedule(Cycle, DayList, TimeList2) of
				{ok, ActSTime, ActETime} ->
					ets:insert(?ETS_YY_ACT, #yy_act{
						id         = YYActID,
						join_level = Level,
						join_wake  = Wake,
						act_stime  = ut_time:datetime_to_seconds(ActSTime),
						act_etime  = ut_time:datetime_to_seconds(ActETime),
						act_state  = ?YY_ST_STOPPED,
						show_stime = ut_time:datetime_to_seconds(ShowSTime),
						show_etime = ut_time:datetime_to_seconds(ShowETime),
						show_state = ?YY_ST_STOPPED
					});
				timeout ->
					ets:insert(?ETS_YY_ACT, #yy_act{
						id         = YYActID,
						join_level = Level,
						join_wake  = Wake,
						act_stime  = 0,
						act_etime  = 0,
						act_state  = ?YY_ST_STOPPED,
						show_stime = ut_time:datetime_to_seconds(ShowSTime),
						show_etime = ut_time:datetime_to_seconds(ShowETime),
						show_state = ?YY_ST_STOPPED
					})
			end;
		timeout ->
			ets:delete(?ETS_YY_ACT, YYActID)
	end.

do_check() ->
	Secs = ut_time:seconds(),
	ets:safe_fixtable(?ETS_YY_ACT, true),
    do_check(ets:first(?ETS_YY_ACT), Secs),
    ets:safe_fixtable(?ETS_YY_ACT, false).

do_check('$end_of_table', _Secs) ->
    ok;
do_check(YYActID, Secs) ->
	Mod = yunying_util:cfg_act_mod(YYActID),
	#cfg_yunying{reqs=Reqs} = Mod:find(YYActID),
	case check_reqs(Reqs) of
		true  -> do_check2(YYActID, Secs);
		false -> ignore
	end,
	do_check(ets:next(?ETS_YY_ACT, YYActID), Secs).

check_reqs([{opdays, Min, Max} | T]) ->
	Days = game_env:get_opened_days(),
	case Min =< Days andalso Days =< Max of
		true  -> check_reqs(T);
		false -> false
	end;
check_reqs([{opdays, Min} | T]) ->
	Days = game_env:get_opened_days(),
	case Min =< Days of
		true  -> check_reqs(T);
		false -> false
	end;
check_reqs([_ | T]) ->
	check_reqs(T);
check_reqs([]) ->
	true.

do_check2(YYActID, Secs) ->
	[YYAct] = ets:lookup(?ETS_YY_ACT, YYActID),
	% 展示开始
	if
		Secs >= YYAct#yy_act.show_stime,
		Secs < YYAct#yy_act.show_etime ->
			start_show(YYAct);
		true ->
			ignore
	end,
	% 活动开始
	if
		Secs >= YYAct#yy_act.act_stime,
		Secs < YYAct#yy_act.act_etime ->
			start_act(YYAct);
		true ->
			ignore
	end,
	% 活动结束
	if
		Secs >= YYAct#yy_act.act_etime ->
			stop_act(YYAct);
		true ->
			ignore
	end,
	% 展示结束
	if
		Secs >= YYAct#yy_act.show_etime ->
			stop_show(YYAct),
			?MODULE:reload(YYActID);
		true ->
			ignore
	end.

start_show(YYAct) when YYAct#yy_act.show_state == ?YY_ST_STARTED ->
	ignore;
start_show(YYAct) ->
	yunying_agent_sup:start_agent(YYAct#yy_act.id),
	ets:insert(?ETS_YY_ACT, YYAct#yy_act{show_state=?YY_ST_STARTED}),
	?bcast(
		get_notify_roles(YYAct),
		#m_yunying_start_toc{
			activity = #p_yy_activity{
				id         = YYAct#yy_act.id,
				act_stime  = YYAct#yy_act.act_stime,
				act_etime  = YYAct#yy_act.act_etime,
				show_stime = YYAct#yy_act.show_stime,
				show_etime = YYAct#yy_act.show_etime
			}
		}
	).

start_act(YYAct) when YYAct#yy_act.act_state == ?YY_ST_STARTED ->
	ignore;
start_act(YYAct = #yy_act{id=YYActID}) ->
	ets:insert(?ETS_YY_ACT, YYAct#yy_act{act_state=?YY_ST_STARTED}),
	ets:insert(?ETS_YY_INFO,#yy_info{id = YYActID}),
	RoleList = case cluster:is_local() of
		true  -> game_role:get_alive_roles();
		false -> game_role:get_online_roles()
	end,
	lists:foreach(fun
		(RolePid) ->
			role:route(RolePid, yunying_util, hook_start, YYActID)
	end, RoleList),
	yunying_hook:hook_start(YYActID).

stop_act(YYAct) when YYAct#yy_act.act_state == ?YY_ST_STOPPED ->
	ignore;
stop_act(YYAct = #yy_act{id=YYActID}) ->
	ets:insert(?ETS_YY_ACT, YYAct#yy_act{act_state=?YY_ST_STOPPED}),
	YYInfo  = get_yy_info(YYActID),
	YYInfo2 = YYInfo#yy_info{settle=true},
	ets:insert(?ETS_YY_INFO, YYInfo2),
	db:dirty_write(?DB_YY_INFO, YYInfo2),
	yunying_agent:settle(YYActID),
	RoleList = case cluster:is_local() of
		true  -> game_role:get_alive_roles();
		false -> game_role:get_online_roles()
	end,
	lists:foreach(fun
		(RolePid) ->
			role:route(RolePid, yunying_util, hook_stop, YYActID)
	end, RoleList),
	yunying_hook:hook_stop(YYActID).

stop_show(YYAct) when YYAct#yy_act.show_state == ?YY_ST_STOPPED ->
	ignore;
stop_show(YYAct = #yy_act{id=YYActID}) ->
	ets:insert(?ETS_YY_ACT, YYAct#yy_act{show_state=?YY_ST_STOPPED}),
	ets:delete(?ETS_YY_INFO, YYActID),
	db:dirty_delete(?DB_YY_INFO, YYActID),
	yunying_agent:stop(YYActID),
	?bcast(
		get_notify_roles(YYAct),
		#m_yunying_stop_toc{id=YYActID}
	).

get_notify_roles(YYAct) ->
	game_role:get_online_roles(#{
		level => YYAct#yy_act.join_level,
		wake  => YYAct#yy_act.join_wake
	}).
