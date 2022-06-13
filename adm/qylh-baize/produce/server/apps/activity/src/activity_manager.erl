%%%=============================================================================
%%% @author z.hua
%%% @doc
%%% 活动管理器
%%% @end
%%%=============================================================================

-module(activity_manager).

-behaviour(gen_server).

-include("activity.hrl").
-include("game.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("combat1v1.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([reload/0, reload/1]).
-export([gm_start/3]).
-export([gm_stop/1]).
-export([gm_print/0]).

-define(SERVER, ?MODULE).

-define(cronref(ActID), {activity, ActID}).

-define(CHECK_INTERVAL, 3).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%% 加载配置
reload() ->
	gen_server:cast(?SERVER, reload).

reload(ActID) ->
	gen_server:cast(?SERVER, {reload, ActID}).

gm_start(ActID, STime, ETime) ->
	?debug("gm_start---------------------"),
	gen_server:cast(?SERVER, {ready, ActID}),
	Msg = {gm_start,ActID, STime, ETime},
	erlang:send_after(timer:seconds(5), ?SERVER, Msg).

gm_stop(ActID) ->
	erlang:send(?SERVER, {gm_stop, ActID}),
	gen_server:cast(?SERVER, {post, ActID}).

gm_print() ->
	[
		io:format("id=~w, stime=~s, etime=~s, state=~ts~n", [
			Act#activity.id,
			ut_time:seconds_to_string(Act#activity.stime),
			ut_time:seconds_to_string(Act#activity.etime),
			case Act#activity.state of
				?ACT_ST_BEREADY -> "准备中";
				?ACT_ST_STARTED -> "进行中";
				?ACT_ST_STOPPED -> "已结束"
			end
		]) || Act <- lists:keysort(#activity.id, ets:tab2list(?ETS_ACTIVITY))
	],
	ok.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_ACTIVITY, [named_table, {keypos,#activity.id}]),
	{ok, undefined}.


handle_call(_Request, _From, State) ->
	{reply, {error, unknown_call}, State}.


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
do_handle_cast({ready, ActID}, State) ->
	case ets:lookup(?ETS_ACTIVITY, ActID) of
		[Activity] ->
			do_ready(Activity);
		[] ->
			ignore
	end,
	{noreply, State};

do_handle_cast({start, ActID}, State) ->
	case ets:lookup(?ETS_ACTIVITY, ActID) of
		[Activity] ->
			do_start(Activity);
		[] ->
			ignore
	end,
	{noreply, State};

do_handle_cast({stop, ActID}, State) ->
	case ets:lookup(?ETS_ACTIVITY, ActID) of
		[Activity] ->
			#cfg_activity{post=PostSecs} = cfg_activity:find(ActID),
			do_stop(Activity),
			?_if(PostSecs == 0, delay_reload(ActID));
		[] ->
			ignore
	end,
	{noreply, State};

do_handle_cast({post, ActID}, State) ->
	case ets:lookup(?ETS_ACTIVITY, ActID) of
		[Activity] ->
			do_post(Activity);
		[] ->
			ignore
	end,
	{noreply, State};

%% 重新加载配置
do_handle_cast(reload, State) ->
	do_init(),
	{noreply, State};

%% 活动结束后，重新调度
do_handle_cast({reload, ActID}, State) ->
	init_activity( cfg_activity:find(ActID) ),
	{noreply, State};

do_handle_cast(started, State) ->
	do_init(),
	loop_check(),
	{noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(check, State) ->
	loop_check(),
	do_check(),
	{noreply, State};

do_handle_info({reload, ActID}, State) ->
	init_activity( cfg_activity:find(ActID) ),
	{noreply, State};

do_handle_info({gm_start, ActID, STime, ETime}, State) ->
	[Activity] = ets:lookup(?ETS_ACTIVITY, ActID),
	Activity2  = Activity#activity{stime=STime, etime=ETime},
	ets:insert(?ETS_ACTIVITY, Activity2),
	do_start2(Activity2),
	{noreply, State};

do_handle_info({gm_stop, ActID}, State) ->
	[Activity] = ets:lookup(?ETS_ACTIVITY, ActID),
	do_stop(Activity),
	delay_reload(ActID),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.


do_init() ->
	lists:foreach(fun
		(ActID) ->
			init_activity( cfg_activity:find(ActID) )
	end, cfg_activity:all()),
	ok.

init_activity(CfgAct) ->
	#cfg_activity{id=ActID, cycle=Cycle, days=DayList, time=TimeList} = CfgAct,
	case ut_activity:schedule(Cycle, DayList, TimeList) of
		{ok, StartTime, StopTime} ->
			ets:insert(?ETS_ACTIVITY, #activity{
				id    = ActID,
				type  = CfgAct#cfg_activity.type,
				group = CfgAct#cfg_activity.group,
				level = CfgAct#cfg_activity.level,
				stime = ut_time:datetime_to_seconds(StartTime),
				etime = ut_time:datetime_to_seconds(StopTime),
				state = ?ACT_ST_STOPPED
			});
		{ok, StartTime} ->
			ets:insert(?ETS_ACTIVITY, #activity{
				id    = ActID,
				type  = CfgAct#cfg_activity.type,
				group = CfgAct#cfg_activity.group,
				level = CfgAct#cfg_activity.level,
				stime = ut_time:datetime_to_seconds(StartTime),
				etime = 0,
				state = ?ACT_ST_STOPPED
			});
		timeout ->
			ets:delete(?ETS_ACTIVITY, ActID)
	end.

loop_check() ->
	erlang:send_after(timer:seconds(?CHECK_INTERVAL), self(), check).

do_check() ->
	Secs = ut_time:seconds(),
	ets:safe_fixtable(?ETS_ACTIVITY, true),
    do_check2(ets:first(?ETS_ACTIVITY), Secs),
    ets:safe_fixtable(?ETS_ACTIVITY, false).

do_check2('$end_of_table', _Secs) ->
    ok;
do_check2(ActID, Secs) ->
	#cfg_activity{pre=PreSecs, post=PostSecs} = cfg_activity:find(ActID),
	[Activity] = ets:lookup(?ETS_ACTIVITY, ActID),
	#activity{id=ActID, stime=STime, etime=ETime, state=State} = Activity,
	PreTime  = STime - PreSecs,
	PostTime = ETime + PostSecs,
	if
		PreSecs > 0, Secs >= PreTime, Secs < STime, State == ?ACT_ST_STOPPED ->
			do_ready(Activity);
		ETime == 0, STime >= Secs-?CHECK_INTERVAL, STime =< Secs ->
			do_start(Activity),
			delay_reload(ActID);
		Secs >= STime, Secs < ETime, State /= ?ACT_ST_STARTED ->
			do_start(Activity);
		PostSecs > 0, Secs >= PostTime, Secs < PostTime+?CHECK_INTERVAL ->
			do_post(Activity),
			delay_reload(ActID);
		ETime > 0, Secs >= ETime ->
			do_stop(Activity),
			?_if(PostSecs == 0, delay_reload(ActID));
		true ->
			ignore
	end,
	do_check2(ets:next(?ETS_ACTIVITY, ActID), Secs).

do_ready(Activity) ->
	#cfg_activity{reqs=Reqs} = cfg_activity:find(Activity#activity.id),
	case check_reqs(Reqs, Activity) of
		true  -> do_ready2(Activity);
		false -> ignore
	end.

do_ready2(Activity) when Activity#activity.state == ?ACT_ST_BEREADY ->
	ignore;
do_ready2(Activity) ->
	ets:insert(?ETS_ACTIVITY, Activity#activity{state=?ACT_ST_BEREADY}),
	activity_hook:hook_ready(Activity),
	?bcast(
		game_role:get_online_roles(#{level => Activity#activity.level}),
		#m_activity_predict_toc{
			id    = Activity#activity.id,
			stime = Activity#activity.stime
		}
	).


do_start(Activity) ->
	#cfg_activity{reqs=Reqs} = cfg_activity:find(Activity#activity.id),
	case check_reqs(Reqs, Activity) of
		true  -> do_start2(Activity);
		false -> ignore
	end.

do_start2(Activity) when Activity#activity.state == ?ACT_ST_STARTED ->
	ignore;
do_start2(Activity) ->
	ets:insert(?ETS_ACTIVITY, Activity#activity{state=?ACT_ST_STARTED}),
	activity_hook:hook_start(Activity),
	?bcast(
		game_role:get_online_roles(#{level => Activity#activity.level}),
		#m_activity_start_toc{
			id    = Activity#activity.id,
			stime = Activity#activity.stime,
			etime = Activity#activity.etime
		}
	).


do_stop(Activity) when Activity#activity.state == ?ACT_ST_STOPPED ->
	ignore;
do_stop(Activity) ->
	ets:insert(?ETS_ACTIVITY, Activity#activity{state=?ACT_ST_STOPPED}),
	activity_hook:hook_stop(Activity),
	?bcast(
		game_role:get_online_roles(#{level => Activity#activity.level}),
		#m_activity_stop_toc{id=Activity#activity.id}
	).


do_post(Activity) ->
	activity_hook:hook_post(Activity).

check_reqs([{opdays, Min, Max} | T], Activity) ->
	OpenDays = game_env:get_opened_days(),
	case OpenDays >= Min andalso OpenDays =< Max of
		true  -> check_reqs(T, Activity);
		false -> false
	end;
check_reqs([{opdays, Min} | T], Activity) ->
	case game_env:get_opened_days() >= Min of
		true  -> check_reqs(T, Activity);
		false -> false
	end;
check_reqs([appointment | T], Activity) ->
	case cluster:is_local() of
		true ->
			#activity{stime=STime, etime=ETime} = Activity,
			case wedding_util:can_start(STime, ETime) of
				true  -> check_reqs(T, Activity);
				false -> false
			end;
		false ->
			false
	end;
check_reqs([{except_weekday, DoWs} | T], Activity) ->
	DoW = ut_time:day_of_week(),
	case lists:member(DoW, DoWs) of
		true  -> false;
		false -> check_reqs(T, Activity)
	end;
check_reqs([{mode,local} | T], Activity) ->
	case cluster:is_local() of
		true ->
			#activity{group=Group} = Activity,
			case Group of
				?ACTIVITY_GROUP_COMBAT1V1 ->
					case combat1v1_util:mode() == ?MODE_LOCAL of
						true ->
							check_reqs(T, Activity);
						false ->
							false
					end;
				_ ->
					check_reqs(T, Activity)
			end;
		false ->
			false
	end;
check_reqs([{mode,cross} | T], Activity) ->
	#activity{group=Group} = Activity,
	case Group of
		?ACTIVITY_GROUP_COMBAT1V1 ->
			case combat1v1_util:mode() == ?MODE_CROSS of
				true ->
					check_reqs(T, Activity);
				false ->
					false
			end;
		_ ->
			check_reqs(T, Activity)
	end;
check_reqs([{mod, Mod} | T], Activity) ->
	case Mod:check_reqs(Activity#activity.id) of
		true  ->
			check_reqs(T, Activity);
		false ->
			false
	end;
check_reqs([_ | T], Activity) ->
	check_reqs(T, Activity);
check_reqs(_, _) ->
	true.

delay_reload(ActID) ->
	erlang:send_after(timer:seconds(?CHECK_INTERVAL), self(), {reload,ActID}).
