%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(yunying_agent).

-behaviour(gen_server).

-include("game.hrl").
-include("yunying.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("table.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/1]).
-export([get_yy_role/2]).
-export([set_yy_role/2]).
-export([get_yy_roles/1]).
-export([settle/1]).
-export([clear/2]).
-export([stop/1]).
-export([gm_stop/1]).

-define(SERVER(YYActID), yunying_util:reg_name(YYActID)).

-define(ETS_YY_ROLE(YYActID),
	ut_conv:to_atom(lists:concat(['ets_yy_role_', YYActID]))
).

-record(state, {id, rank}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link(YYActID) ->
	RegName = yunying_util:reg_name(YYActID),
	gen_server:start_link({local, RegName}, ?MODULE, {YYActID}, []).

get_yy_role(YYActID, RoleID) ->
	Tab = ?ETS_YY_ROLE(YYActID),
	case ets:info(Tab) == ?nil of
		true  ->
			#yy_role{key={YYActID, RoleID}};
		false ->
			case ets:lookup(Tab, {YYActID, RoleID}) of
				[R] -> R;
				[]  -> #yy_role{key={YYActID, RoleID}}
			end
	end.

set_yy_role(YYActID, YYRole) ->
	Tab = ?ETS_YY_ROLE(YYActID),
	case ets:info(Tab) == ?nil of
		true  -> ignore;
		false -> ets:insert(Tab, YYRole)
	end.

get_yy_roles(YYActID) ->
    ets:tab2list(?ETS_YY_ROLE(YYActID)).

%% 活动结算
settle(YYActID) ->
	gen_server:cast(?SERVER(YYActID), settle).

%% 活动清理
clear(Pid, Hour) when is_pid(Pid) ->
	gen_server:cast(Pid, {clear, Hour});
clear(YYActID, Hour) ->
	gen_server:cast(?SERVER(YYActID), {clear, Hour}).

%% 活动结束
stop(YYActID) ->
	gen_server:cast(?SERVER(YYActID), stop).

%% 活动结束
gm_stop(YYActID) ->
	gen_server:cast(?SERVER(YYActID), gm_stop).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({YYActID}) ->
	process_flag(trap_exit, true),
	loop_dump(),
	Table = ?ETS_YY_ROLE(YYActID),
	ets:new(Table, [named_table, public, {keypos,#yy_role.key}]),
	Roles = db:dirty_match_object(?DB_YY_ROLE, #yy_role{key={YYActID,'_'}, _='_'}),
	ets:insert(Table, Roles),

	Mod = yunying_util:cfg_act_mod(YYActID),
	#cfg_yunying{rank=RankID} = Mod:find(YYActID),
	?_if(RankID > 0, rank:open_rank(RankID)),

	{ok, #state{id=YYActID, rank=RankID}}.

handle_call(Req, From, State) ->
	?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
	?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
	?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, State) ->
	do_dump(State),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.

%% 活动结算
do_handle_cast(settle, State) ->
	#state{id=YYActID, rank=RankID} = State,
	?_if(RankID > 0,?info("~nsettle_yunying_id:~p,rank_id:~p~nrank data:~p~n ",[YYActID,RankID,rank_server:get_ranklist(RankID)])),
	?_if(RankID > 0, rank:close_rank(RankID)),
	yunying_reward:give(YYActID),
	{noreply, State};

%% 活动清理
do_handle_cast({clear, Hour}, State) ->
	Mod = yunying_util:cfg_act_mod(State#state.id),
	#cfg_yunying{clear=Clear} = Mod:find(State#state.id),
	do_clear(Clear, Hour, State#state.id),
	{noreply, State};

%% 活动结束
do_handle_cast(stop, State) ->
	?debug("yy_act stop: ~w", [State#state.id]),
	AllRoles = get_yy_roles(State#state.id),
	ets:delete_all_objects(?ETS_YY_ROLE(State#state.id)),
	[db:dirty_delete(?DB_YY_ROLE, R#yy_role.key) || R <- AllRoles],
	{stop, normal, State};

%% 活动结束
do_handle_cast(gm_stop, State) ->
	AllRoles = get_yy_roles(State#state.id),
	ets:delete_all_objects(?ETS_YY_ROLE(State#state.id)),
	[db:dirty_delete(?DB_YY_ROLE, R#yy_role.key) || R <- AllRoles],
	{stop, normal, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info({clear_rank, RankID}, State) ->
	rank:clear_rank(RankID),
	{noreply, State};

do_handle_info(dump, State) ->
	loop_dump(),
	do_dump(State),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.


%% 每天定时清理
do_clear([{daily, Hour}], Hour, YYActID) ->
	yunying_reward:give(YYActID),
	ets:delete_all_objects(?ETS_YY_ROLE(YYActID)),
	RoleList = case cluster:is_local() of
		true  -> game_role:get_alive_roles();
		false -> game_role:get_online_roles()
	end,
	lists:foreach(fun
		(RolePid) ->
			role:route(RolePid, yunying_task, add_listen, YYActID)
	end, RoleList);
%% 活动完成 Days 后清理
do_clear([{finish, Days, Hour}], Hour, YYActID) ->
	case ets:lookup(?ETS_YY_ACT, YYActID) of
		[#yy_act{act_stime=STime}] ->
			AllRoles = get_yy_roles(YYActID),
			ClrRoles = clear_by_finish(AllRoles, YYActID, STime, Days, []),
			lists:foreach(fun
				(RoleID) ->
					role:route(RoleID, yunying_task, add_listen, YYActID)
			end, ClrRoles);
		[] ->
			ignore
	end;
% 连续累充重置
do_clear([{continue_reset, Hour}], Hour, YYActID) ->
	yunying_task:continue_reset(YYActID);
do_clear(_Clear, _Hour, _YYInfo) ->
	ok.

clear_by_finish([YYRole | T], YYActID, STime, Days, ClrRoles) ->
	#yy_role{key={_, RoleID}=Key, tasks=Tasks, finish=FTime} = YYRole,
	case is_integer(FTime) andalso ut_time:diff_days(STime, FTime) >= Days of
		true  ->
			yunying_reward:give(YYActID, RoleID, Tasks),
			ets:delete(?ETS_YY_ROLE(YYActID), Key),
			clear_by_finish(T, YYActID, STime, Days, [RoleID|ClrRoles]);
		false ->
			clear_by_finish(T, YYActID, STime, Days, ClrRoles)
	end;
clear_by_finish([], _YYActID, _STime, _Days, ClrRoles) ->
	ClrRoles.


loop_dump() ->
	erlang:send_after(timer:minutes(15), self(), dump).

do_dump(State) ->
	lists:foreach(fun
		(YYRole) ->
			db:dirty_write(?DB_YY_ROLE, YYRole)
	end, ets:tab2list(?ETS_YY_ROLE(State#state.id))).
