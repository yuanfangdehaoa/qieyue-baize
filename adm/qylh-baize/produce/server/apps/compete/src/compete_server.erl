%%%=================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=================================

-module(compete_server).

-behaviour(gen_server).

-include("activity.hrl").
-include("compete.hrl").
-include("faker.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
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
-export([get_panel/1]).
-export([get_state/0]).
-export([enroll/7]).
-export([guess/5]).
-export([update_power/3]).
-export([add_exp/2]).
-export([role_enter/1]).
-export([role_leave/1]).
-export([hook_ready/1]).
-export([hook_start/1]).
-export([hook_stop/1]).
-export([hook_post/1]).
-export([battle_result/5]).
-export([send_prepare_info/2]).
-export([send_battle_info/2]).
-export([send_match_info/3]).
-export([send_ranking/2]).
-export([send_history/3]).
-export([hook_divide/5]).

-export([gm_stop/0]).

-define(SERVER, ?MODULE).

-define(ACT_ENROLL_LOCAL, 11011).
-define(ACT_ENROLL_CROSS, 11021).

-define(is_select(State), State#compete_st.period == ?COMPETE_PERIOD_SELECT).
-define(is_rank(State), State#compete_st.period == ?COMPETE_PERIOD_RANK).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, {}, []).

get_panel(RoleID) ->
	[ActID | _] = activity:get_acts(?ACTIVITY_GROUP_COMPETE),
	ServName = compete_util:get_server_by_act(ActID),
	% ?debug("get_state--------------:~w", [ServName]),
	gen_server:call(ServName, {get_panel, RoleID}).

get_state() ->
	[ActID | _] = activity:get_acts(?ACTIVITY_GROUP_COMPETE),
	ServName = compete_util:get_server_by_act(ActID),
	% ?debug("get_state--------------:~w", [ServName]),
	gen_server:call(ServName, get_state).

%% 报名
enroll(ActID, RoleID, Name, SUID, Gender, Level, Power) ->
	ServName = compete_util:get_server_by_act(ActID),
	gen_server:call(ServName, {enroll,RoleID,Name,SUID,Gender,Level,Power}).

guess(RoleID, ActID, GroupID, GuessID, Type) ->
	ServName = compete_util:get_server_by_act(ActID),
	gen_server:call(ServName, {guess, RoleID, GroupID, GuessID, Type}).

%% 更新报名玩家战力
update_power(RoleID, Name, Power) ->
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	Msg = {power, RoleID, Name, Level, Power},
	case activity:is_start(?ACT_ENROLL_LOCAL) of
		true  ->
			gen_server:cast(?MODULE, Msg);
		false ->
			case activity:is_start(?ACT_ENROLL_CROSS) of
				true  -> gen_server:cast({?MODULE,?CROSS_RULE_24_8}, Msg);
				false -> ignore
			end
	end.

add_exp(RoleID, ExpAdd) ->
	gen_server:cast(?SERVER, {add_exp,RoleID,ExpAdd}).

role_enter(RoleID) ->
	gen_server:cast(?SERVER, {enter, RoleID}).

role_leave(RoleID) ->
	gen_server:cast(?SERVER, {leave, RoleID}).


hook_ready(ActID) ->
	ServName = compete_util:get_server_by_act(ActID),
	Period   = compete_util:get_period(ActID),
	?debug("hook_ready: ~p", [{ActID, Period}]),
	gen_server:cast(ServName, {ready, ActID, Period}).

hook_start(ActID) ->
	ServName = compete_util:get_server_by_act(ActID),
	Period   = compete_util:get_period(ActID),
	gen_server:cast(ServName, {start, ActID, Period}).

hook_stop(ActID) ->
	ServName = compete_util:get_server_by_act(ActID),
	Period   = compete_util:get_period(ActID),
	gen_server:cast(ServName, {stop, Period}).

hook_post(ActID) ->
	ServName = compete_util:get_server_by_act(ActID),
	Period   = compete_util:get_period(ActID),
	gen_server:cast(ServName, {post, Period}).

send_prepare_info(SceneID, RoleID) ->
	ServName = compete_util:get_server_by_scene(SceneID),
	% ?debug("get_state--------------:~w", [ServName]),
	gen_server:cast(ServName, {send_prepare_info, RoleID}).

send_battle_info(SceneID, RoleID) ->
	ServName = compete_util:get_server_by_scene(SceneID),
	% ?debug("get_state--------------:~w", [ServName]),
	gen_server:cast(ServName, {send_battle_info, RoleID}).

send_match_info(ActID, Type, RoleID) ->
	ServName = compete_util:get_server_by_act(ActID),
	gen_server:cast(ServName, {send_match_info, Type, RoleID}).

send_ranking(SceneID, RoleID) ->
	ServName = compete_util:get_server_by_scene(SceneID),
	% ?debug("get_state--------------:~w", [ServName]),
	gen_server:cast(ServName, {send_ranking, RoleID}).

send_history(ActID, RoleID, LocalHistory) ->
	ServName = compete_util:get_server_by_act(ActID),
	% ?debug("get_state--------------:~w", [ServName]),
	gen_server:cast(ServName, {send_history, RoleID, LocalHistory}).

battle_result(Type, GroupID, RoleID, ScoreAdd, Reward) ->
	erlang:send(?SERVER, {result, {Type, GroupID, RoleID, ScoreAdd, Reward}}).

gm_stop() ->
	[ActID | _] = activity:get_acts(?ACTIVITY_GROUP_COMPETE),
	ServName = compete_util:get_server_by_act(ActID),
	gen_server:cast(ServName, gm_stop).

%% ====== 跨服分组处理
hook_divide(LocalNode, _OldGrp, _NewGrp, OldCross, NewCross) ->
	?debug("compete_server hook_divide"),
	try
		{ok, Data} = cluster:gen_call_node(OldCross, compete_server, {divide_old,LocalNode}),
		ok = cluster:gen_call_node(NewCross, compete_server, {divide_new,Data})
	catch Class:Reason:Stacktrace ->
		?stacktrace(Class, Reason, Stacktrace)
	end,
	ok.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_COMPETE_ROLE, [named_table, {keypos,#compete_role.id}]),
	ets:new(?ETS_COMPETE_GROUP, [named_table, {keypos,#compete_group.id}]),
	[ActID | _] = activity:get_acts(?ACTIVITY_GROUP_COMPETE),
	{ok, #compete_st{
		act_id = ActID,
		local  = cluster:is_local(),
		period = ?COMPETE_PERIOD_TRUCE,
		pass   = [],
		join   = []
	}}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, State) ->
	game_misc:write(compete_season, State#compete_st.season, true),
	Roles = ets:tab2list(?ETS_COMPETE_ROLE),
	game_misc:write(compete_roles, Roles, true),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 报名
do_handle_call({enroll,RoleID,Name,SUID,Gender,Level,Power}, _From, State) ->
	#compete_st{period=Period} = State,
	?_check(Period == ?COMPETE_PERIOD_ENROLL, ?ERR_COMPETE_NOT_ENROLL),
	IsEnroll = ets:member(?ETS_COMPETE_ROLE, RoleID),
	?_check(not IsEnroll, ?ERR_COMPETE_HAD_ENROLLED),
	ets:insert(?ETS_COMPETE_ROLE, #compete_role{
		id     = RoleID,
		name   = Name,
		suid   = SUID,
		gender = Gender,
		level  = Level,
		power  = Power,
		score1 = 0,
		score2 = 0,
		rank   = 0,
		exp    = 0,
		reward = #{},
		miss   = false,
		win    = 0,
		lose   = 0
	}),
	{reply, ok, State};

%% 竞猜
do_handle_call({guess, RoleID, GroupID, GuessID, Type}, _From, State) ->
	#compete_st{period=Period, phase=Phase} = State,
	?_check(Period == ?COMPETE_PERIOD_RANK, ?ERR_COMPETE_NOT_GUESS),
	?_check(Phase == ?COMPETE_PHASE_PREPARE, ?ERR_COMPETE_NOT_GUESS),
	case ets:lookup(?ETS_COMPETE_GROUP, GroupID) of
		[Group] ->
			#compete_group{versus=Versus, guess=Guess} = Group,
			?_check(length(Versus) == 2, ?ERR_GAME_BAD_ARGS),
			HadGuess = lists:keymember(RoleID, 1, Guess),
			?_check(not HadGuess, ?ERR_COMPETE_HAD_GUESS),
			IsVersus = lists:keymember(GuessID, 2, Versus),
			?_check(IsVersus, ?ERR_GAME_BAD_ARGS),
			ets:insert(?ETS_COMPETE_GROUP, Group#compete_group{
				guess = [{RoleID,GuessID,Type} | Guess]
			});
		[] ->
			throw(?err(?ERR_GAME_BAD_ARGS))
	end,
	{reply, ok, State};

do_handle_call({pre_enter, RoleID}, _From, State=#compete_st{pass=Pass}) ->
	?_check(lists:keymember(RoleID, 1, Pass), ?ERR_COMPETE_NOT_ENROLLED),
	{reply, ok, State};

do_handle_call({get_panel, RoleID}, _From, State) ->
	IsEnroll  = ets:member(?ETS_COMPETE_ROLE, RoleID),
	EnrollNum = ets:info(?ETS_COMPETE_ROLE, size),
	{reply, {ok, IsEnroll, EnrollNum, State}, State};

do_handle_call(get_state, _From, State) ->
	{reply, State, State};

do_handle_call({divide_old, Node}, _From, State) ->
	RoleList = lists:filter(fun
		(#compete_role{id=RoleID}) ->
			SUID = game_uid:guid2suid(RoleID),
			case cluster:is_same(SUID, Node#cls_node.suid) of
				true  ->
					ets:delete(?ETS_COMPETE_ROLE, RoleID),
					true;
				false ->
					false
			end
	end, ets:tab2list(?ETS_COMPETE_ROLE)),
	?debug("divide_old: ~p", [RoleList]),
	{reply, {ok, term_to_binary(RoleList)}, State};

do_handle_call({divide_new, Data}, _From, State) ->
	RoleList = binary_to_term(Data),
	ets:insert(?ETS_COMPETE_ROLE, RoleList),
	?debug("divide_new: ~p", [RoleList]),
	{reply, ok, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.


%% -------------------- 报名阶段 --------------------
%% 报名准备
do_handle_cast({ready, _ActID, ?COMPETE_PERIOD_ENROLL}, State) ->
	?debug("~ts", ["报名准备"]),
	{noreply, State};

%% 报名开始
do_handle_cast({start, ActID, ?COMPETE_PERIOD_ENROLL}, State) ->
	?debug("~ts: ~w", ["报名开始", State#compete_st.season]),
	case game_misc:read(compete_started, false) of
		true  ->
			{noreply, State#compete_st{
				act_id = ActID,
				period = ?COMPETE_PERIOD_ENROLL
			}};
		false ->
			game_misc:write(compete_started, true),
			ut_misc:cancel_timer(State#compete_st.timer),
			ets:delete_all_objects(?ETS_COMPETE_ROLE),
			ets:delete_all_objects(?ETS_COMPETE_GROUP),
			{noreply, State#compete_st{
				act_id = ActID,
				period = ?COMPETE_PERIOD_ENROLL,
				pass   = [],
				join   = [],
				round  = 0,
				phase  = 0,
				stime  = 0,
				etime  = 0,
				match  = [],
				rank   = []
			}}
	end;

%% 报名结束
do_handle_cast({stop, ?COMPETE_PERIOD_ENROLL}, State) ->
	#compete_st{local=IsLocal} = State,
	game_misc:write(compete_started, false),
	Roles = ets:tab2list(?ETS_COMPETE_ROLE),
	Sort = lists:reverse(lists:keysort(#compete_role.power, Roles)),
	Num  = cfg_compete_misc:find(join_num, IsLocal),
	% 通过
	Pass = lists:sublist(Sort, Num),
	ets:delete_all_objects(?ETS_COMPETE_ROLE),
	ets:insert(?ETS_COMPETE_ROLE, Pass),

	% 淘汰
	Oust = lists:nthtail(length(Pass), Sort),
	Cost = cfg_compete_misc:find(enroll_cost, IsLocal),
	lists:foreach(fun
		(#compete_role{id=RoleID}) ->
			mail:send(RoleID, ?MAIL_COMPETE_ENROLL_OUST, Cost)
	end, Oust),

	?notify(?MSG_COMPETE_ENROLL_STOP),

	?debug("~ts, pass=~w, oust=~w", ["报名结束", Pass, Oust]),
	{noreply, State#compete_st{
		period = ?COMPETE_PERIOD_OUST,
		pass   = [{RoleID,Power} || #compete_role{id=RoleID, power=Power} <- Pass]
	}};


%% -------------------- 海选阶段 --------------------
%% 海选赛准备
do_handle_cast({ready, ActID, Period=?COMPETE_PERIOD_SELECT}, State) ->
	?debug("~ts", ["海选赛准备"]),
	% 创建准备场景
	#cfg_activity{scene=SceneID} = cfg_activity:find(ActID),
	scene:create(SceneID, 0, #{act_id=>ActID}),
	{noreply, State#compete_st{
		act_id = ActID,
		period = Period,
		round  = 0,
		phase  = ?COMPETE_PHASE_PREPARE,
		stime  = ut_time:seconds(),
		etime  = activity:stime(ActID)
	}};

%% 海选赛开始
do_handle_cast({start, ActID, Period=?COMPETE_PERIOD_SELECT}, State) ->
	?debug("~ts", ["海选赛开始"]),
	Round  = 1,
	State2 = State#compete_st{
		act_id = ActID,
		period = Period,
		round  = Round,
		phase  = ?COMPETE_PHASE_PREPARE
	},
	next_settle(Period, Round, 0),
	compete_util:send_prepare_info(State2),
	{noreply, State2};

%% 海选赛结束
do_handle_cast({stop, ?COMPETE_PERIOD_SELECT}=Msg, State) ->
	erlang:send_after(timer:seconds(7), self(), Msg),
	compete_util:send_prepare_info(State),
	{noreply, State};

%% -------------------- 争霸阶段 --------------------
%% 争霸准备
do_handle_cast({ready, ActID, Period=?COMPETE_PERIOD_RANK}, State) ->
	?debug("~ts", ["争霸准备"]),
	State2 = State#compete_st{
		act_id = ActID,
		period = Period,
		round  = 0,
		phase  = ?COMPETE_PHASE_PREPARE,
		stime  = ut_time:seconds(),
		etime  = activity:stime(ActID)
	},
	compete_util:send_prepare_info(State2),
	{noreply, State2};

%% 争霸赛开始
do_handle_cast({start, ActID, Period=?COMPETE_PERIOD_RANK}, State) ->
	?debug("~ts", ["争霸赛开始"]),
	Round  = 1,
	State2 = State#compete_st{
		act_id = ActID,
		period = Period,
		round  = Round,
		phase  = ?COMPETE_PHASE_PREPARE
	},
	next_settle(Period, Round, 0),
	compete_util:send_prepare_info(State2),
	{noreply, State2};

%% 争霸赛结束
do_handle_cast({stop, ?COMPETE_PERIOD_RANK}=Msg, State) ->
	?debug("~ts", ["争霸赛结束"]),
	erlang:send_after(timer:seconds(3), self(), Msg),

	State2 = State#compete_st{
		season = State#compete_st.season + 1,
		period = ?COMPETE_PERIOD_TRUCE,
		etime  = ut_time:seconds() + 30
	},
	compete_util:send_prepare_info(State2),

	{noreply, State2};

%% 活动结束清理
do_handle_cast({post, ?COMPETE_PERIOD_RANK}, State) ->
	?debug("~ts", ["活动结束清理"]),
	game_misc:write(compete_started, false),
	do_clear(),
	{noreply, State};

%% 循环加经验
do_handle_cast({add_exp, RoleID, ExpAdd}, State) ->
	case ets:lookup(?ETS_COMPETE_ROLE, RoleID) of
		[Role=#compete_role{exp=OldExp}] ->
			Role2 = Role#compete_role{exp=OldExp+ExpAdd},
			ets:insert(?ETS_COMPETE_ROLE, Role2),
			compete_util:send_prepare_info(Role2, State);
		[] ->
			ignore
	end,
	{noreply, State};

do_handle_cast({send_ranking, RoleID}, State) ->
	Roles  = ets:tab2list(?ETS_COMPETE_ROLE),
	Roles1 = lists:keysort(#compete_role.rank, Roles),
	Roles2 = lists:sublist(Roles1, 5),
	Ranking = lists:map(fun
		(Role) ->
			#p_compete_ranking{
				role  = Role#compete_role.id,
				name  = Role#compete_role.name,
				score = Role#compete_role.score1,
				rank  = Role#compete_role.rank
			}
	end, Roles2),

	case lists:keyfind(RoleID, #compete_role.id, Roles) of
		false ->
			MyRank  = 0,
			MyScore = 0;
		Mine  ->
			MyRank  = Mine#compete_role.rank,
			MyScore = Mine#compete_role.score1
	end,

	?ucast(RoleID, #m_compete_ranking_toc{
		ranking  = Ranking,
		my_rank  = MyRank,
		my_score = MyScore
	}),
	{noreply, State};

do_handle_cast({send_history, RoleID, LocalHistory}, State) ->
	History  = case cluster:is_local() of
		true  -> LocalHistory;
		false -> LocalHistory ++ game_misc:read(compete_history, [])
	end,
	History2 = lists:map(fun
		({Season, Sorted}) ->
			Ranking = lists:map(fun
				(Role) ->
					#p_ranking{
						base = role:get_base(Role#compete_role.id),
						rank = Role#compete_role.rank,
						sort = 0,
						data = #{}
					}
			end, Sorted),
			#p_compete_history{season=Season, ranking=Ranking}
	end, History),
	?ucast(RoleID, #m_compete_history_toc{history=History2}),
	{noreply, State};

do_handle_cast({send_match_info, Type, RoleID}, State) ->
	Groups1 = ets:tab2list(?ETS_COMPETE_GROUP),
	Groups2 = lists:foldl(fun
		(Group, Acc) when Group#compete_group.type == Type ->
			#compete_group{
				id=GroupID, versus=Versus, guess=Guess, winner=Winner
			} = Group,
			VSRoles = lists:filtermap(fun
				({Pos, VSRoleID}) ->
					case VSRoleID > 0 of
						true  ->
							{true, #p_compete_versus{
								pos  = Pos,
								role = role:get_base(VSRoleID)
							}};
						false ->
							false
					end
			end, Versus),
			GuessID = case lists:keyfind(RoleID, 1, Guess) of
				false    -> 0;
				{_,ID,_} -> ID
			end,
			PGroup = #p_compete_group{
				id     = GroupID rem 1000,
				vs     = lists:keysort(#p_compete_versus.pos, VSRoles),
				guess  = GuessID,
				winner = Winner
			},
			[PGroup | Acc];
		(_, Acc) ->
			Acc
	end, [], Groups1),
	% io:format("Groups2---------------:~9999999p~n", [Groups2]),
	?ucast(RoleID, #m_compete_match_toc{
		type        = Type,
		round       = State#compete_st.round,
		guess_stime = State#compete_st.stime,
		guess_etime = State#compete_st.etime,
		groups      = Groups2
	}),
	{noreply, State};

do_handle_cast({send_battle_info, RoleID}, State) ->
	?ucast(RoleID, #m_compete_battle_toc{
		etime = State#compete_st.etime
	}),
	{noreply, State};

do_handle_cast({send_prepare_info, RoleID}, State) ->
	case ets:lookup(?ETS_COMPETE_ROLE, RoleID) of
		[Role] ->
			compete_util:send_prepare_info(Role, State);
		[] ->
			ignore
	end,
	{noreply, State};

%% 战力变化
do_handle_cast({power, RoleID, Name, Level, Power}, State) ->
	case ets:member(?ETS_COMPETE_ROLE, RoleID) of
		true  ->
			ets:update_element(?ETS_COMPETE_ROLE, RoleID, [
				{#compete_role.name, Name},
				{#compete_role.level, Level},
				{#compete_role.power, Power}
			]);
		false ->
			ignore
	end,
	{noreply, State};

do_handle_cast({leave, RoleID}, State) ->
	{noreply, State#compete_st{
		join = lists:delete(RoleID, State#compete_st.join)
	}};

do_handle_cast({enter, RoleID}, State) ->
	{noreply, State#compete_st{
		join = [RoleID | State#compete_st.join]
	}};

do_handle_cast(started, State) ->
	?debug("started----------------------"),
	Season = game_misc:read(compete_season, 1),
	Roles  = game_misc:read(compete_roles, []),
	ets:insert(?ETS_COMPETE_ROLE, Roles),
	{noreply, State#compete_st{season=Season}};

do_handle_cast(gm_stop, State) ->
	do_clear(),
	{noreply, State#compete_st{period=?COMPETE_PERIOD_TRUCE}};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


%% -------------------- 海选赛进行中 --------------------
%% 准备
do_handle_info({prepare, ?COMPETE_PERIOD_SELECT}, State) when ?is_select(State) ->
	#compete_st{local=IsLocal, period=Period, round=Round} = State,
	Last  = cfg_compete_misc:find(select_prepare_last, IsLocal),
	STime = ut_time:seconds(),
	ETime = STime + Last,
	Timer = next_battle(Period, Last),
	% 匹配
	Match  = do_select_match(IsLocal, Round),
	State2 = State#compete_st{
		phase = ?COMPETE_PHASE_PREPARE,
		stime = STime,
		etime = ETime,
		timer = Timer,
		match = Match
	},
	compete_util:send_prepare_info(State2),
	?debug("~ts: round=~w, match=~w", ["海选赛战斗准备", Round, Match]),
	{noreply, State2};

%% 战斗
do_handle_info({battle, ?COMPETE_PERIOD_SELECT}, State) when ?is_select(State) ->
	#compete_st{local=IsLocal, match=Match, period=Period, round=Round,act_id=ActId} = State,

	#cfg_activity{time = [{_,EndTime}]} = cfg_activity:find(ActId),
	ActEndTime = ut_time:datetime_to_seconds({ut_time:date(), EndTime}),

	Last  = cfg_compete_misc:find(select_battle_last, IsLocal),
	MaxRound = cfg_compete_misc:find(select_round, IsLocal),
	STime = ut_time:seconds(),
	ETime = ?_if(Round =:=MaxRound,ActEndTime,STime + Last),
	?debug("~p~n",[{?MODULE,?LINE,ETime}]),
	Timer = ?_if(Round =:= MaxRound,next_settle(Period, Round+1, ActEndTime-STime+1),next_settle(Period, Round+1, Last+1)),
	% 开始战斗
	do_select_battle(Match, STime, ETime, State),
	?debug("~ts: round=~w, match=~w", ["海选赛战斗中", Round, Match]),
	{noreply, State#compete_st{
		phase = ?COMPETE_PHASE_BATTLE,
		stime = STime,
		etime = ETime,
		timer = Timer
	}};

%% 结束
do_handle_info({result, Result}, State) when ?is_select(State) ->
	{_Type, _GroupID, RoleID, ScoreAdd, RewardAdd} = Result,
	?debug("~ts: ~w", ["海选赛战斗结束", Result]),
	[Role] = ets:lookup(?ETS_COMPETE_ROLE, RoleID),
	#compete_role{score1=Score1, reward=Reward, win=Win, lose=Lose} = Role,
	ets:insert(?ETS_COMPETE_ROLE, Role#compete_role{
		score1 = Score1 + ScoreAdd,
		reward = update_reward(Reward, RewardAdd),
		win    = ?_if(ScoreAdd > 0, Win+1, Win),
		lose   = ?_if(ScoreAdd == 0, Lose+1, Lose)
	}),
	{noreply, State};

%% 结算
do_handle_info({settle, ?COMPETE_PERIOD_SELECT, NewRound}, State) when ?is_select(State) ->
	#compete_st{period=Period, join=Join, local=IsLocal, round=Round} = State,
	MaxRound = cfg_compete_misc:find(select_round, IsLocal),
	?_if(Round < MaxRound, next_prepare(Period)),
	Sorted = do_sort(score1),
	case Round > 1 andalso NewRound =< MaxRound andalso lists:keyfind(1, #compete_role.rank, Sorted) of
		#compete_role{id=RoleID} ->
			?debug("~ts: ~w", ["海选赛结算，下一轮", NewRound]),
			{ok, Cache} = role:get_cache(RoleID),
			#role_cache{id=RoleID, name=RoleName} = Cache,
			?notify(Join, ?MSG_COMPETE_BATTLE_NO1, [{role,RoleID,RoleName}]);
		_ ->
			ignore
	end,
	{noreply, State#compete_st{round=min(NewRound, MaxRound)}};

%% 海选结束
do_handle_info({stop, ?COMPETE_PERIOD_SELECT}, State) ->
	#compete_st{local=IsLocal} = State,

	SortRoles = do_sort(score1),
	PassRoles = [ID || #compete_role{id=ID, score1=Score} <- SortRoles, Score > 0],

	% 天榜
	RankLen1 = cfg_compete_misc:find(rank_len1, IsLocal),
	RoleIDs1 = lists:sublist(PassRoles, RankLen1),
	do_group(RoleIDs1, ?COMPETE_BATTLE_RANK1),
	Reward1  = cfg_compete_misc:find(rank_reward1, IsLocal),
	mail:batch_send(RoleIDs1, ?MAIL_COMPETE_SELECT_REWARD1, Reward1),
	lists:foreach(fun
		(RoleID) ->
			[Role] = ets:lookup(?ETS_COMPETE_ROLE, RoleID),
			ets:insert(?ETS_COMPETE_ROLE, Role#compete_role{
				reward = update_reward(Role#compete_role.reward, Reward1),
				score2 = 1000
			})
	end, RoleIDs1),

	% 地榜
	RankLen2 = cfg_compete_misc:find(rank_len2, IsLocal),
	RoleIDs2 = lists:sublist(PassRoles, length(RoleIDs1)+1, RankLen2),
	do_group(RoleIDs2, ?COMPETE_BATTLE_RANK2),
	Reward2  = cfg_compete_misc:find(rank_reward2, IsLocal),
	mail:batch_send(RoleIDs2, ?MAIL_COMPETE_SELECT_REWARD2, Reward2),
	lists:foreach(fun
		(RoleID) ->
			[Role] = ets:lookup(?ETS_COMPETE_ROLE, RoleID),
			ets:insert(?ETS_COMPETE_ROLE, Role#compete_role{
				reward = update_reward(Role#compete_role.reward, Reward2)
			})
	end, RoleIDs2),

	?debug("~ts, group=~w", ["海选赛结束", ets:tab2list(?ETS_COMPETE_GROUP)]),

	{noreply, State#compete_st{rank=RoleIDs1++RoleIDs2}};

%% -------------------- 争霸赛战斗中 --------------------
%% 准备
do_handle_info({prepare, ?COMPETE_PERIOD_RANK}, State) when ?is_rank(State) ->
	?debug("~ts: ~w", ["争霸赛战斗准备", State#compete_st.round]),
	#compete_st{local=IsLocal, period=Period} = State,
	Last  = cfg_compete_misc:find(rank_prepare_last, IsLocal),
	STime = ut_time:seconds(),
	ETime = STime + Last,
	Timer = next_battle(Period, Last),
	State2 = State#compete_st{
		phase = ?COMPETE_PHASE_PREPARE,
		stime = STime,
		etime = ETime,
		timer = Timer
	},
	compete_util:send_prepare_info(State2),
	{noreply, State2};

%% 战斗
do_handle_info({battle, ?COMPETE_PERIOD_RANK}, State) when ?is_rank(State) ->
	#compete_st{local=IsLocal, period=Period, round=Round} = State,
	STime = ut_time:seconds(),
	Last  = cfg_compete_misc:find(rank_battle_last, IsLocal),
	ETime = STime + Last,
	Timer = next_settle(Period, Round+1, Last+1),
	do_rank_battle(STime, ETime, State),
	?debug("~ts: round=~w", ["争霸赛战斗中", Round]),
	State2 = State#compete_st{
		phase = ?COMPETE_PHASE_BATTLE,
		stime = STime,
		etime = ETime,
		timer = Timer
	},
	compete_util:send_prepare_info(State2),
	{noreply, State2};

%% 结束
do_handle_info({result, Result}, State) when ?is_rank(State) ->
	{Type, GroupID, RoleID, ScoreAdd0, RewardAdd} = Result,
	?debug("~ts: ~w", ["争霸赛战斗结束", Result]),
	ScoreAdd = case Type of
		?COMPETE_BATTLE_RANK1 when ScoreAdd0 > 0 -> 4;
		?COMPETE_BATTLE_RANK1                    -> 3;
		?COMPETE_BATTLE_RANK2 when ScoreAdd0 > 0 -> 2;
		?COMPETE_BATTLE_RANK2                    -> 1
	end,
	[Role] = ets:lookup(?ETS_COMPETE_ROLE, RoleID),
	#compete_role{score2=Score2, reward=Reward, win=Win, lose=Lose} = Role,
	Role2  = Role#compete_role{
		score2 = Score2 + ScoreAdd,
		reward = update_reward(Reward, RewardAdd),
		miss   = ScoreAdd0 == 99,
		win    = ?_if(ScoreAdd0 > 0, Win+1, Win),
		lose   = ?_if(ScoreAdd0 == 0, Lose+1, Lose)
	},
	ets:insert(?ETS_COMPETE_ROLE, Role2),
	case ScoreAdd0 > 0 of
		true  ->
			[Group] = ets:lookup(?ETS_COMPETE_GROUP, GroupID),
			Group2  = Group#compete_group{winner=RoleID},
			ets:insert(?ETS_COMPETE_GROUP, Group2);
		false ->
			ignore
	end,
	compete_util:send_prepare_info(Role2, State),
	{noreply, State};

%% 结算
do_handle_info({settle, ?COMPETE_PERIOD_RANK, NewRound}, State) when ?is_rank(State) ->
	#compete_st{local=IsLocal, period=Period, round=Round} = State,
	MaxRound = cfg_compete_misc:find(rank_round, IsLocal),
	case Round < MaxRound of
		true  ->
			next_prepare(Period),
			do_rank_match(NewRound);
		false ->
			ignore
	end,
	?debug("~ts: ~w, group=~w", ["争霸赛结算，下一轮", NewRound, lists:keysort(#compete_group.id, ets:tab2list(?ETS_COMPETE_GROUP))]),
	lists:foreach(fun
		(Role) ->
			ets:insert(?ETS_COMPETE_ROLE, Role#compete_role{miss=false})
	end, ets:tab2list(?ETS_COMPETE_ROLE)),
	lists:foreach(fun
		(Group) when Group#compete_group.round == Round ->
			lists:foreach(fun
				({RoleID, GuessID, Type}) ->
					CfgGuess = cfg_compete_guess:find(Type, IsLocal),
					#cfg_compete_guess{right=Right, wrong=Wrong} = CfgGuess,
					case GuessID == Group#compete_group.winner of
						true  -> mail:send(RoleID, ?MAIL_COMPETE_GUESS_RIGHT, Right);
						false -> mail:send(RoleID, ?MAIL_COMPETE_GUESS_WRONG, Wrong)
					end
			end, Group#compete_group.guess);
		(_) ->
			ignore
	end, ets:tab2list(?ETS_COMPETE_GROUP)),
	compete_util:send_prepare_info(State),
	{noreply, State#compete_st{round=min(NewRound, MaxRound)}};

%% 争霸结束
do_handle_info({stop, ?COMPETE_PERIOD_RANK}, State) ->
	Groups = ets:tab2list(?ETS_COMPETE_GROUP),
	game_misc:write(compete_result, Groups),

	% 天榜冠军
	case ets:lookup(?ETS_COMPETE_GROUP, 1401) of
		[#compete_group{winner=Winner1}] ->
			{ok, Cache1} = role:get_cache(Winner1),
			#role_cache{id=RoleID1,name=RoleName1} = Cache1,
			Args1 = [{role,RoleID1,RoleName1}],
			case State#compete_st.local of
				true  -> ?notify(?MSG_COMPETE_CHAMPION1, Args1);
				false -> cluster:notify(?CROSS_RULE_24_8, ?MSG_COMPETE_CHAMPION1, Args1)
			end;
		[] ->
			ignore
	end,

	% 地榜冠军
	case ets:lookup(?ETS_COMPETE_GROUP, 2401) of
		[#compete_group{winner=Winner2}] ->
			{ok, Cache2} = role:get_cache(Winner2),
			#role_cache{id=RoleID2,name=RoleName2} = Cache2,
			Args2 = [{role,RoleID2,RoleName2}],
			case State#compete_st.local of
				true  -> ?notify(?MSG_COMPETE_CHAMPION2, Args2);
				false -> cluster:notify(?CROSS_RULE_24_8, ?MSG_COMPETE_CHAMPION2, Args2)
			end;
		[] ->
			ignore
	end,

	update_history(State#compete_st.season),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

next_prepare(Period) ->
	erlang:send(self(), {prepare, Period}).

next_battle(Period, Secs) ->
	erlang:send_after(timer:seconds(Secs), self(), {battle, Period}).

next_settle(Period, Round, Secs) ->
	Msg = {settle, Period, Round},
	case Secs == 0 of
		true  -> erlang:send(self(), Msg);
		false -> erlang:send_after(timer:seconds(Secs), self(), Msg)
	end.

%% 海选赛匹配
do_select_match(IsLocal, Round) ->
	All  = ets:tab2list(?ETS_COMPETE_ROLE),
	Rule = cfg_compete_match:find(Round, IsLocal, length(All)),
	do_select_match2(All, Rule, []).

do_select_match2([Role1 | Others], Rule, Match) ->
	#compete_role{id=RoleID1, rank=Rank1} = Role1,
	case do_select_match3(Rule, Rank1) of
		mirror ->
			RoleID2 = mirror,
			Others2 = Others;
		Rank2  ->
			case lists:keytake(Rank2, #compete_role.rank, Others) of
				false ->
					RoleID2 = mirror,
					Others2 = Others;
				{value,Role2,T} ->
					RoleID2 = Role2#compete_role.id,
					Others2 = T
			end
	end,
	do_select_match2(Others2, Rule, [{RoleID1,RoleID2} | Match]);
do_select_match2([], _Rule, Match) ->
	Match.

do_select_match3([{{TopMin,TopMax}, {LastMin,LastMax}} | T], Rank) ->
	case TopMin =< Rank andalso Rank =< TopMax of
		true  -> ut_rand:random(LastMin, LastMax);
		false -> do_select_match3(T, Rank)
	end;
do_select_match3([], Rank) ->
	?error("match error: ~w", [Rank]),
	mirror.


do_rank_match(1) ->
	ignore;
do_rank_match(Round) ->
	Groups  = ets:tab2list(?ETS_COMPETE_GROUP),
	Groups1 = [G || G <- Groups, G#compete_group.round == Round-1],
	Groups2 = lists:keysort(#compete_group.id, Groups1),
	?debug("do_rank_match-------------------:~w", [{Round, Groups2}]),
	do_rank_match2(Groups2, Round).

do_rank_match2([Group | T], Round) ->
	#compete_group{id=GroupID, type=Type, winner=Winner} = Group,
	{Pos, GroupID2} = next_rank_match(GroupID),
	case ets:lookup(?ETS_COMPETE_GROUP, GroupID2) of
		[Group2=#compete_group{versus=Versus}] ->
			ets:insert(
				?ETS_COMPETE_GROUP,
				Group2#compete_group{versus=[{Pos,Winner} | Versus]}
			);
		[] ->
			ets:insert(
				?ETS_COMPETE_GROUP,
				compete_group(GroupID2, [{Pos,Winner}], Type, Round)
			)
	end,
	do_rank_match2(T, Round);
do_rank_match2([], _Round) ->
	ok.

next_rank_match(GroupID) ->
	{Pos, GroupID2} = next_rank_match2(GroupID rem 1000),
	{Pos, (GroupID div 1000 * 1000) + GroupID2}.

%% 16进8
next_rank_match2(101) -> {1,201};
next_rank_match2(102) -> {2,201};
next_rank_match2(103) -> {1,202};
next_rank_match2(104) -> {2,202};
next_rank_match2(105) -> {1,203};
next_rank_match2(106) -> {2,203};
next_rank_match2(107) -> {1,204};
next_rank_match2(108) -> {2,204};
%% 8进4
next_rank_match2(201) -> {1,301};
next_rank_match2(203) -> {2,301};
next_rank_match2(202) -> {1,302};
next_rank_match2(204) -> {2,302};
%% 4进2
next_rank_match2(301) -> {1,401};
next_rank_match2(302) -> {2,401}.


do_sort(ScoreType) ->
	Sorted1 = lists:sort(fun
		(Role1, Role2) ->
			#compete_role{score1=Score1_1, score2=Score2_1, power=Power1} = Role1,
			#compete_role{score1=Score1_2, score2=Score2_2, power=Power2} = Role2,
			case ScoreType of
				score1 ->
					Score1 = Score1_1,
					Score2 = Score1_2;
				score2 ->
					Score1 = Score2_1,
					Score2 = Score2_2
			end,
			case Score1 == Score2 of
				true  -> Power1 < Power2;
				false -> Score1 < Score2
			end
	end, ets:tab2list(?ETS_COMPETE_ROLE)),
	{_, Sorted2} = lists:foldl(fun
		(Role, {Rank, AccSort}) ->
			{Rank-1, [Role#compete_role{rank=Rank} | AccSort]}
	end, {length(Sorted1), []}, Sorted1),
	ets:insert(?ETS_COMPETE_ROLE, Sorted2),
	Sorted2.


do_select_battle([{RoleID1, RoleID2} | T], STime, ETime, State) ->
	IsReady1 = lists:member(RoleID1, State#compete_st.join),
	IsReady2 = lists:member(RoleID2, State#compete_st.join),
	?debug("------------------:~w", [{IsReady1, IsReady2}]),
	Type = ?COMPETE_BATTLE_SELECT,
	if
		IsReady1, IsReady2 ->
			do_battle(RoleID1, RoleID2, Type, 0, STime, ETime, State);
		IsReady1 ->
			do_battle(RoleID1, mirror, Type, 0, STime, ETime, State);
		IsReady2 ->
			do_battle(mirror, RoleID2, Type, 0, STime, ETime, State);
		true ->
			ignore
	end,
	do_select_battle(T, STime, ETime, State);
do_select_battle([], _STime, _ETime, _State) ->
	ok.


do_rank_battle(STime, ETime, State=#compete_st{round=Round}) ->
	lists:foreach(fun
		(Group) when Group#compete_group.round == Round ->
			#compete_group{id=GroupID, type=Type, versus=Versus} = Group,
			?debug("do_rank_battle: ~w", [{GroupID, Versus}]),
			do_rank_battle2(Versus, GroupID, Type, STime, ETime, State);
		(_) ->
			ignore
	end, ets:tab2list(?ETS_COMPETE_GROUP)).

do_rank_battle2([{_,RoleID}], GroupID, Type, _STime, _ETime, State) ->
	battle_miss(Type, GroupID, RoleID, State);
do_rank_battle2([{_,RoleID1}, {_,RoleID2}], GroupID, Type, STime, ETime, State) ->
	IsReady1 = lists:member(RoleID1, State#compete_st.join),
	IsReady2 = lists:member(RoleID2, State#compete_st.join),
	if
		IsReady1, IsReady2 ->
			do_battle(RoleID1, RoleID2, Type, GroupID, STime, ETime, State);
		IsReady1; RoleID2 == 0 ->
			battle_miss(Type, GroupID, RoleID1, State);
		IsReady2; RoleID1 == 0 ->
			battle_miss(Type, GroupID, RoleID2, State);
		true ->
			[#compete_role{power=Power1}] = ets:lookup(?ETS_COMPETE_ROLE, RoleID1),
			[#compete_role{power=Power2}] = ets:lookup(?ETS_COMPETE_ROLE, RoleID2),
			case Power1 > Power2 of
				true  -> battle_miss(Type, GroupID, RoleID1, State);
				false -> battle_miss(Type, GroupID, RoleID2, State)
			end
	end.

%% 轮空
battle_miss(Type, GroupID, RoleID, State) ->
	#compete_st{act_id=ActID, local=IsLocal, round=Round} = State,
	?debug("~ts: ~w", ["轮空", [{Round, RoleID}]]),
	Reward = cfg_compete_battle_reward:win(Round, IsLocal, Type),
	role:route(
		RoleID, compete_battle, battle_stop, {ActID,0,Reward,true}
	),
	?ucast(RoleID, #m_compete_stat_toc{
		is_win = true,
		reward = maps:from_list(Reward)
	}),
	erlang:send(self(), {result, {Type, GroupID, RoleID, 99, Reward}}).

do_battle(RoleID1, RoleID2, Type, GroupID, STime, ETime, State) ->
	#compete_st{act_id=ActID, round=Round} = State,
	RoomID  = lists:concat([RoleID1, "-", RoleID2, "-", State#compete_st.round]),
	#cfg_activity{reqs=Reqs} = cfg_activity:find(ActID),
	SceneID = proplists:get_value(battle, Reqs),
	Args = #{
		type  => Type,
		round => Round,
		stime => STime,
		etime => ETime,
		group => GroupID
	},
	scene:create(SceneID, RoomID, Args),
	?_if(
		is_integer(RoleID1),
		do_battle2(RoleID1, RoleID2, SceneID, RoomID, 1, State)
	),
	?_if(
		is_integer(RoleID2),
		do_battle2(RoleID2, RoleID1, SceneID, RoomID, 2, State)
	).

do_battle2(RoleID, RivalID, SceneID, RoomID, Index, State) ->
	#compete_st{act_id=ActID, round=Round} = State,
	FakerID = case RivalID == mirror of
		true  ->
			Gender = ut_rand:choose([?GENDER_MALE, ?GENDER_FEMALE]),
			ut_rand:choose(cfg_faker:gender(Gender));
		false ->
			0
	end,
	[#compete_role{level=Level, power=Power}] = ets:lookup(?ETS_COMPETE_ROLE, RoleID),
	Args = {ActID,Round,SceneID,RoomID,RivalID,Index,FakerID},
	?debug("=========================>do_battle2: ~w", [{RoleID, RivalID, SceneID, RoomID}]),
	role:route(RoleID, compete_prepare, start_battle, Args),
	?ucast(RoleID, #m_compete_versus_toc{
		role1 = versus_role(RoleID, 0, Level, Power),
		role2 = versus_role(RivalID, FakerID, Level, Power)
	}).

versus_role(RoleID, FakerID, Level, Power) ->
	case RoleID == mirror of
		true  ->
		    #faker{base=Base} = faker:get(FakerID),
		    MinPower = round(Power * 0.6),
		    MaxPower = round(Power * 0.7),
		    MinLevel = Level - 10,
		    MaxLevel = Level + 10,
			#p_compete_vsrole{
				id     = FakerID,
				gender = Base#p_role_base.gender,
				name   = Base#p_role_base.name,
				level  = ut_rand:random(MinLevel, MaxLevel),
				suid   = Base#p_role_base.suid,
				power  = ut_rand:random(MinPower, MaxPower),
				win    = 0,
				lose   = 0,
				score  = 0
			};
		false ->
			[Role] = ets:lookup(?ETS_COMPETE_ROLE, RoleID),
			#p_compete_vsrole{
				id     = RoleID,
				gender = Role#compete_role.gender,
				name   = Role#compete_role.name,
				level  = Role#compete_role.level,
				suid   = Role#compete_role.suid,
				power  = Role#compete_role.power,
				win    = Role#compete_role.win,
				lose   = Role#compete_role.lose,
				score  = Role#compete_role.score1
			}
	end.

update_reward(OldReward, RewardList) ->
	lists:foldl(fun
		({ItemID, Num}, Acc) ->
			ut_misc:maps_increase(ItemID, Num, Acc);
		(_, Acc) ->
			Acc
	end, OldReward, RewardList).


do_group(RoleIDs, Type=?COMPETE_BATTLE_RANK1) ->
	{Area1, Area2, Area3, Area4} = do_group2(RoleIDs),
	do_group4(Area1, Type, 1101, 1102),
	do_group4(Area2, Type, 1103, 1104),
	do_group4(Area3, Type, 1105, 1106),
	do_group4(Area4, Type, 1107, 1108);
do_group(RoleIDs, Type=?COMPETE_BATTLE_RANK2) ->
	{Area1, Area2, Area3, Area4} = do_group2(RoleIDs),
	do_group4(Area1, Type, 2101, 2102),
	do_group4(Area2, Type, 2103, 2104),
	do_group4(Area3, Type, 2105, 2106),
	do_group4(Area4, Type, 2107, 2108).

do_group2([RoleID]) ->
	{[RoleID], [], [], []};
do_group2([RoleID1, RoleID2]) ->
	{[RoleID1], [RoleID2], [], []};
do_group2([RoleID1, RoleID2, RoleID3]) ->
	{[RoleID1], [RoleID2], [RoleID3], []};
do_group2([RoleID1, RoleID2, RoleID3, RoleID4 | T]) ->
	Others = ut_rand:shuffle(T),
	do_group3(Others, 1, {[RoleID1], [RoleID2], [RoleID3], [RoleID4]});
do_group2([]) ->
	{[], [], [], []}.

do_group3([RoleID | T], AreaID0, AreaInfo) ->
	AreaID = ?_if(AreaID0 > 4, 1, AreaID0),
	RoleIDs2  = [RoleID | element(AreaID, AreaInfo)],
	AreaInfo2 = setelement(AreaID, AreaInfo, RoleIDs2),
	do_group3(T, AreaID+1, AreaInfo2);
do_group3([], _AreaID, AreaInfo) ->
	AreaInfo.

do_group4([RoleID1], Type, GroupID1, _GroupID2) ->
	ets:insert(
		?ETS_COMPETE_GROUP,
		compete_group(GroupID1, [{1,RoleID1}], Type, 1)
	);
do_group4([RoleID1, RoleID2], Type, GroupID1, _GroupID2) ->
	ets:insert(
		?ETS_COMPETE_GROUP,
		compete_group(GroupID1, [{1,RoleID1},{2,RoleID2}], Type, 1)
	);
do_group4([RoleID1, RoleID2, RoleID3], Type, GroupID1, GroupID2) ->
	ets:insert(?ETS_COMPETE_GROUP, [
		compete_group(GroupID1, [{1,RoleID1},{2,RoleID2}], Type, 1),
		compete_group(GroupID2, [{1,RoleID3}], Type, 1)
	]);
do_group4([RoleID1, RoleID2, RoleID3, RoleID4], Type, GroupID1, GroupID2) ->
	ets:insert(?ETS_COMPETE_GROUP, [
		compete_group(GroupID1, [{1,RoleID1},{2,RoleID2}], Type, 1),
		compete_group(GroupID2, [{1,RoleID3},{2,RoleID4}], Type, 1)
	]);
do_group4([], _Type, _GroupID1, _GroupID2) ->
	ignore.

compete_group(GroupID, Versus, Type, Round) ->
	#compete_group{
		id     = GroupID,
		type   = Type,
		round  = Round,
		versus = Versus,
		guess  = [],
		winner = 0
	}.

update_history(Season) ->
	Sorted = do_sort(score2),
	Result = {Season, Sorted},
	?debug("update_history----------------------------:~w", [Result]),
	History  = game_misc:read(compete_history, []),
	History2 = lists:sublist([Result | History], 5),
	game_misc:write(compete_history, History2, true),
	give_rank_reward(Sorted).

give_rank_reward(Sorted) ->
	IsLocal = cluster:is_local(),
	lists:foreach(fun
		(Role) ->
			#compete_role{id=RoleID, rank=Rank} = Role,
			Reward = cfg_compete_rank_reward:find(IsLocal, Rank),
			?_if(
				Reward /= [],
				mail:send(RoleID, ?MAIL_COMPETE_RANK_REWARD, Reward, [Rank])
			)
	end, Sorted).

do_clear() ->
	ActIDs = cfg_activity:group(?ACTIVITY_GROUP_COMPETE),
	lists:foreach(fun
		(ActID) ->
			#cfg_activity{scene=SceneID} = cfg_activity:find(ActID),
			case SceneID > 0 andalso scene_util:is_same_node(SceneID) of
				true  -> scene:destroy(SceneID);
				false -> ignore
			end
	end, ActIDs).
