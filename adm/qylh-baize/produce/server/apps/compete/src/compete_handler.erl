%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(compete_handler).

-include("activity.hrl").
-include("compete.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 面板信息
handle(?COMPETE_PANEL, _Tos, RoleSt=#role_st{role=RoleID}) ->
	{ok, IsEnroll, EnrollNum, State} = compete_server:get_panel(RoleID),
	ActEnroll = compete_util:get_act_enroll(),
	ActSelect = compete_util:get_act_select(),
	ActRank   = compete_util:get_act_rank(),
	?ucast(#m_compete_panel_toc{
		act_id       = State#compete_st.act_id,
		cur_period   = State#compete_st.period,
		power_rank   = rank:get_rank(?RANK_ID_POWER, RoleID),
		is_enroll    = IsEnroll,
		enroll_num   = EnrollNum,
		enroll_stime = ?_if(ActEnroll == ?nil, 0, ActEnroll#activity.stime),
		enroll_etime = ?_if(ActEnroll == ?nil, 0, ActEnroll#activity.etime),
		select_stime = ?_if(ActSelect == ?nil, 0, ActSelect#activity.stime),
		select_etime = ?_if(ActSelect == ?nil, 0, ActSelect#activity.etime),
		rank_stime   = ?_if(ActRank == ?nil, 0, ActRank#activity.stime),
		rank_etime   = ?_if(ActRank == ?nil, 0, ActRank#activity.etime)
	});

%% 报名
handle(?COMPETE_ENROLL, Tos, RoleSt) ->
	#m_compete_enroll_tos{act_id=ActID} = Tos,
	?_check(activity:is_start(ActID), ?ERR_SCENE_NO_ACTIVITY),
	#cfg_activity{type=ActType} = cfg_activity:find(ActID),
	IsLocal = ActType == ?ACTIVITY_TYPE_LOCAL,
	Reqs  = cfg_compete_misc:find(enroll_reqs, IsLocal),
	check_enroll_reqs(Reqs, RoleSt),
	#role_st{role=RoleID, name=Name} = RoleSt,
	#role_info{level=Level, gender=Gender} = role_data:get(?DB_ROLE_INFO),
	SUID  = game_env:get_suid(),
	Power = role_util:get_power(),
	Cost  = cfg_compete_misc:find(enroll_cost, IsLocal),
	Succ  = fun() ->
		ok = compete_server:enroll(ActID, RoleID, Name, SUID, Gender, Level, Power)
	end,
	role_bag:cost(Cost, ?LOG_COMPETE_ENROLL, Succ, RoleSt),
	mail:send(RoleID, ?MAIL_COMPETE_ENROLL_SUCC),
	?ucast(#m_compete_enroll_toc{act_id=ActID});

%% 备战信息
handle(?COMPETE_PREPARE, _Tos, RoleSt) ->
	#role_st{scene=SceneID, role=RoleID} = RoleSt,
	case compete_util:in_prepare_scene(SceneID) of
		false -> ignore;
		true  -> compete_server:send_prepare_info(SceneID, RoleID)
	end;

%% 战场信息
handle(?COMPETE_BATTLE, _Tos, RoleSt) ->
	#role_st{scene=SceneID, role=RoleID} = RoleSt,
	case compete_util:in_battle_scene(SceneID) of
		false -> ignore;
		true  -> compete_server:send_battle_info(SceneID, RoleID)
	end;

%% 购买buff
handle(?COMPETE_BUFF, Tos, RoleSt) ->
	#role_st{scene=SceneID, role=RoleID, spid=ScenePid} = RoleSt,
	#m_compete_buff_tos{buff_id=BuffID} = Tos,
	case compete_util:in_battle_scene(SceneID) of
		false ->
			ignore;
		true  ->
			IsLocal = scene_util:is_local(SceneID),
			Buffs = cfg_compete_misc:find(battle_buffs, IsLocal),
			case lists:keyfind(BuffID, 1, Buffs) of
				false ->
					throw(?err(?ERR_COMPETE_BUFF_NOT_FOUND));
				{_, RealBuff, AddTo, Cost} ->
					Succ = fun() ->
						Args = {RoleID, BuffID, RealBuff, AddTo},
						scene:sync_route(ScenePid, compete_battle, buy_buff, Args)
					end,
					role_bag:cost(Cost, ?LOG_COMPETE_BUYBUFF, Succ, RoleSt),
					?ucast(#m_compete_buff_toc{buff_id=BuffID})
			end
	end;

%% 竞猜
handle(?COMPETE_GUESS, Tos, RoleSt=#role_st{role=RoleID}) ->
	#m_compete_guess_tos{
		act_id=ActID, group=GroupID0, role=GuessID, type=GuessType, rank=RankType
	} = Tos,
	#cfg_activity{type=ActType} = cfg_activity:find(ActID),
	IsLocal = ActType == ?ACTIVITY_TYPE_LOCAL,
	#cfg_compete_guess{cost=Cost} = cfg_compete_guess:find(GuessType, IsLocal),
	GroupID = case RankType of
		?COMPETE_BATTLE_RANK1 -> 1000 + GroupID0;
		?COMPETE_BATTLE_RANK2 -> 2000 + GroupID0
	end,
	Succ = fun() ->
		ok = compete_server:guess(RoleID, ActID, GroupID, GuessID, GuessType)
	end,
	role_bag:cost(Cost, ?LOG_COMPETE_GUESS, Succ, RoleSt),
	?ucast(#m_compete_guess_toc{
		act_id=ActID, group=GroupID0, role=RoleID, type=GuessType, rank=RankType
	});

%% 匹配信息
handle(?COMPETE_MATCH, Tos, _RoleSt=#role_st{role=RoleID}) ->
	#m_compete_match_tos{type=Type} = Tos,
	[ActID | _] = activity:get_acts(?ACTIVITY_GROUP_COMPETE),
	compete_server:send_match_info(ActID, Type, RoleID);

%% 开始战斗
handle(?COMPETE_FIGHT, _Tos, RoleSt) ->
	#role_st{spid=ScenePid, scene=SceneID, role=RoleID} = RoleSt,
	case compete_util:in_battle_scene(SceneID) of
		false -> ignore;
		true  -> scene:route(ScenePid, compete_battle, battle_start, RoleID)
	end;

%% 往期战报
handle(?COMPETE_HISTORY, _Tos, _RoleSt=#role_st{role=RoleID}) ->
	[ActID | _]  = activity:get_acts(?ACTIVITY_GROUP_COMPETE),
	LocalHistory = game_misc:read(compete_history, []),
	compete_server:send_history(ActID, RoleID, LocalHistory);

%% 排行榜
handle(?COMPETE_RANKING, _Tos, RoleSt) ->
	#role_st{role=RoleID, scene=SceneID} = RoleSt,
	case compete_util:in_prepare_scene(SceneID) of
		false -> ignore;
		true  -> compete_server:send_ranking(SceneID, RoleID)
	end.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_enroll_reqs([{level, CfgLevel} | T], RoleSt) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	?_check(RoleLv >= CfgLevel, ?ERR_COMPETE_NOT_SATISFY),
	check_enroll_reqs(T, RoleSt);
check_enroll_reqs([{rank, CfgRank} | T], RoleSt) ->
	RoleRank = rank:get_rank(?RANK_ID_POWER, RoleSt#role_st.role),
	?_check(RoleRank > 0 andalso RoleRank =< CfgRank, ?ERR_COMPETE_NOT_SATISFY),
	check_enroll_reqs(T, RoleSt);
check_enroll_reqs([{wake, CfgWake} | T], RoleSt) ->
	#role_info{wake=Wake} = role_data:get(?DB_ROLE_INFO),
	?_check(Wake >= CfgWake, ?ERR_COMPETE_NOT_SATISFY),
	check_enroll_reqs(T, RoleSt);
check_enroll_reqs([_ | T], RoleSt) ->
	check_enroll_reqs(T, RoleSt);
check_enroll_reqs([], _RoleSt) ->
	ok.
