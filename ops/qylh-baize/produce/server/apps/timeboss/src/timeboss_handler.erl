%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(timeboss_handler).

-include("game.hrl").
-include("role.hrl").
-include("timeboss.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).
-export([hook_upgrade/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% boss列表
handle(?TIMEBOSS_LIST, _Tos, RoleSt) ->
	#role_st{role=RoleID} = RoleSt,
	SUID = game_env:get_suid(),
	Bosses  = rpc_call_cross(timeboss_server, get_bosses, [SUID]),
	Bosses2 = lists:map(fun
		(Boss) ->
			#timeboss{boss=BossID, owners=Owners, care=Cared} = Boss,
			#cfg_timeboss{floor=FloorID} = cfg_timeboss:find(BossID),
			HadBox = lists:keymember(SUID, 1, Owners),

			#p_timeboss{
				id    = Boss#timeboss.boss,
				born  = Boss#timeboss.born,
				floor = FloorID,
				role  = max(0, Boss#timeboss.role),
				box   = HadBox,
				care  = lists:member(RoleID, Cared)
			}
	end, Bosses),
	?ucast(#m_timeboss_list_toc{bosses=Bosses2});

%% 伤害排名
handle(?TIMEBOSS_RANKING, _Tos, RoleSt) ->
	case in_timeboss_scene(RoleSt) of
		true  ->
			#role_st{spid=ScenePid, role=RoleID, team=TeamID} = RoleSt,
			Captain = team_server:get_captain(TeamID),
			scene:route(ScenePid, timeboss_server, send_ranking, {RoleID,Captain});
		false ->
			ignore
	end;

%% 掷骰子
handle(?TIMEBOSS_DICING, _Tos, RoleSt) ->
	case in_timeboss_scene(RoleSt) of
		true  ->
			#role_st{spid=ScenePid, role=RoleID, name=RoleName} = RoleSt,
			Score = ut_rand:random(1, 100),
			?debug("TIMEBOSS_DICING-----------------------:~w", [Score]),
			Args  = {RoleID, RoleName, Score},
			scene:route(ScenePid, timeboss_server, dice_do, Args);
		false ->
			ignore
	end;

%% 宝箱信息
handle(?TIMEBOSS_BOXINFO, _Tos, RoleSt) ->
	case in_timeboss_scene(RoleSt) of
		true  ->
			#role_st{spid=ScenePid, role=RoleID} = RoleSt,
			scene:route(ScenePid, timeboss_server, send_boxinfo, RoleID);
		false ->
			ignore
	end;

%% 宝箱开启
handle(?TIMEBOSS_BOXOPEN, Tos, RoleSt) ->
	case in_timeboss_scene(RoleSt) of
		true  ->
			#role_st{spid=ScenePid, role=RoleID} = RoleSt,
			#m_timeboss_boxopen_tos{type=Type, boss=BossID, times=Times} = Tos,
			check_open_reqs(Type, BossID),
			{Cost, DropList} = cfg_timeboss_box_reward:find(BossID, Type, Times),
			#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
			Gain = creep_drop:calc(RoleLv, DropList),
			SUID = game_env:get_suid(),
			Args = {RoleID, SUID, BossID, Times, Type, Gain},
			Succ = fun() ->
				ok = scene:sync_route(ScenePid, timeboss_server, open_box, Args)
			end,
			role_bag:deal(Cost, Gain, ?LOG_TIMEBOSS_OPENBOX, Succ, RoleSt);
		false ->
			ignore
	end;

%% 关注boss
handle(?TIMEBOSS_CARE, Tos, RoleSt) ->
	#m_timeboss_care_tos{id=BossID, op=Op, type=Type} = Tos,
	#role_st{role=RoleID} = RoleSt,
	timeboss_server:care_boss(RoleID, BossID, Op),
	?ucast(#m_timeboss_care_toc{id=BossID, op=Op, type=Type});

%% 掉落记录
handle(?TIMEBOSS_DROPPED, _Tos, RoleSt) ->
	Logs = cluster:rpc_call_cross(
		?CROSS_RULE_24_8, game_logger, get_logs, [timeboss_drop_log]
	),
	?ucast(#m_timeboss_dropped_toc{logs=lists:reverse(Logs)}).

hook_upgrade(NewLv, _RoleSt=#role_st{role=RoleID}) ->
	AutoCare = cfg_timeboss:auto_care(NewLv),
	lists:foreach(fun
		(BossID) ->
			timeboss_server:care_boss(RoleID, BossID, 1)
	end, AutoCare),

	AutoCancel = cfg_timeboss:auto_cancel(),
	lists:foreach(fun
		({BossID, Level}) ->
			?_if(Level =< NewLv, timeboss_server:care_boss(RoleID, BossID, 2))
	end, AutoCancel).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
rpc_call_cross(M, F, A) ->
	cluster:rpc_call_cross(?CROSS_RULE_24_8, M, F, A).

in_timeboss_scene(RoleSt) ->
	RoleSt#role_st.stype == ?SCENE_STYPE_TIMEBOSS.

check_open_reqs(1, _BossID) ->
	ok;
check_open_reqs(2, BossID) ->
	#cfg_timeboss_box{reqs=Reqs} = cfg_timeboss:box(BossID),
	check_open_reqs2(Reqs).

check_open_reqs2([{vip, CfgVip} | T]) ->
	VipLv = role_vip:get_level(),
	?_check(VipLv >= CfgVip, ?ERR_VIP_NOT_ENOUGH),
	check_open_reqs2(T);
check_open_reqs2([]) ->
	ok.
