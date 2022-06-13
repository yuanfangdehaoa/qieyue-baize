%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(warrior_war).
-include("warrior.hrl").
-include("proto.hrl").
-include("rank.hrl").
-include("ranking.hrl").
-include("enum.hrl").
-include("msgno.hrl").
-include("errno.hrl").
-include("scene.hrl").
-include("game.hrl").
-include("role.hrl").
-include("creep.hrl").

%% API
-export([handle/2]).
-export([hook_enter/2]).
-export([hook_role_dead/3]).
-export([hook_creep_dead/3]).
-export([hook_revive/3]).
-export([finish_collect/3]).
-export([hook_born/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%战场信息
handle({?WARRIOR_INFO, RoleID, Line}, SceneSt)->
	#scene_st{opts=#{etime := ETime, floor := Floor}} = SceneSt,
	?ucast(RoleID, #m_warrior_info_toc{end_time = ETime}),
	update_self(Line, RoleID, Floor).

%进入场景
hook_enter(Actor, SceneSt)->
	#actor{uid=RoleID, name=RoleName, line=Line, scene=SceneID} = Actor,
	#scene_st{opts=#{floor := Floor}} = SceneSt,
	warrior_server:set_kill(RoleID, 0),
	check_reward(SceneID, RoleID, Floor),
	{_RankList, {Score, Data}} = warrior_server:get_ranklist(Line, RoleID),
	OldFloor = maps:get("floor", Data, 0),
	case Floor > OldFloor of
		true  ->
			Data2 = maps:put("floor", Floor, Data),
			warrior_server:update_rank(Line, RoleID, Score, Data2);
		false ->
			ignore
	end,
	update_self(Line, RoleID, Floor),
	update_creep(RoleID),
	warrior_server:set_room(RoleID, SceneID, Floor),
	notify_top(RoleID, RoleName, Line, Floor).


%玩家死亡
hook_role_dead(Atker, Defer, SceneSt) ->
	someone_dead(Atker, Defer, SceneSt).


hook_creep_dead(Atker, Defer, SceneSt)->
	someone_dead(Atker, Defer, SceneSt).


%玩家复活
hook_revive(Actor, Type, SceneSt)->
	case Type of
		?REVIVE_TYPE_SAFE ->
			#actor{uid=RoleID} = Actor,
			#scene_st{opts=#{floor := Floor, act_id:=ActID}} = SceneSt,
			CfgWarrior = cfg_warrior_floor:find(Floor),
			check_down_floor(RoleID, CfgWarrior, ActID);
		_ ->
			ignore
	end.

%怪物出生
hook_born(Actor, _SceneSt)->
	#actor{id=CreepID} = Actor,
	case CreepID == 30396001 orelse CreepID == 30396002 of
		true ->
			RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
			?_if(CreepID==30396001, ?bcast(RoleIDs, #m_warrior_creep_toc{state=1})),
			#cfg_creep{name=Name} = cfg_creep:find(CreepID),
			?notify(RoleIDs, ?MSG_WARRIOR_BOX_BORN, [Name]);
		false ->
			ignore
	end.


%采集完成
finish_collect(Actor, Collect, SceneSt)->
	#actor{uid=RoleID, name=RoleName, line=Line} = Actor,
	#actor{id=CreepID} = Collect,
	#scene_st{opts=#{floor := Floor}} = SceneSt,
	#cfg_creep{opts=AddScore} = cfg_creep:find(CreepID),
	AddScore2 = ut_conv:to_integer(AddScore),
	{_RankList, {OldScore, Data}} = warrior_server:get_ranklist(Line, RoleID),
	warrior_server:update_rank(Line, RoleID, OldScore+AddScore2, Data),
	update_self(Line, RoleID, Floor),
	case CreepID == 30396001 of
		true ->
			RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
			?bcast(RoleIDs, #m_warrior_creep_toc{state=2}),
			?notify(RoleIDs, ?MSG_WARRIOR_COLLECT, [
				{role, RoleID, RoleName}, AddScore]);
		false ->
			ignore
	end.



%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%更新自己信息
update_self(Line, RoleID, Floor)->
	{_RankList, {Score, _}} = warrior_server:get_ranklist(Line, RoleID),
	Num = warrior_server:get_kill(RoleID),
	?ucast(RoleID, #m_warrior_update_toc{floor=Floor, score=Score, kill=Num}).

%检测是否升层
check_up_floor(RoleID, Num, CfgWarrior, ActID)->
	#cfg_warrior_floor{kill_target=Target, floor=Floor} = CfgWarrior,
	CfgWarrior2 = cfg_warrior_floor:find(Floor+1),
	case Num >= Target andalso CfgWarrior2 /= ?nil of
		true ->
			#cfg_warrior_floor{scene_id=SceneIDList, floor=NextFloor} = CfgWarrior2,
			{_, SceneID} = lists:keyfind(ActID, 1, SceneIDList),
			role:route(RoleID, warrior_handler, change_scene, {SceneID, NextFloor});
		false ->
			ignore
	end.

%检测是否降层
check_down_floor(RoleID, CfgWarrior, ActID)->
	#cfg_warrior_floor{is_down=IsDown, prob=Prob, floor=Floor} = CfgWarrior,
	case IsDown of
		true ->
			Random = ut_rand:random(1, 10000),
			case Random =< Prob of
				true ->
					#cfg_warrior_floor{scene_id=SceneIDList, floor=PreFloor} = cfg_warrior_floor:find(Floor-1),
					{_, SceneID} = lists:keyfind(ActID, 1, SceneIDList),
					role:route(RoleID, warrior_handler, change_scene, {SceneID, PreFloor});
				false ->
					ignore
			end;
		false ->
			ignore
	end.

%检查获得奖励
check_reward(SceneID, RoleID, Floor)->
	case warrior_server:is_floor_gain(RoleID, Floor) of
		false ->
			#cfg_warrior_floor{gain=Gain, cross_gain=CrossGain} = cfg_warrior_floor:find(Floor),
			#cfg_scene{kind=Kind} = cfg_scene:find(SceneID),
			Gain2 = case Kind == ?SCENE_KIND_CROSS of
				true  -> CrossGain;
				false -> Gain
			end,
			role:route(RoleID, warrior_handler, floor_gain, {Gain2, Floor}),
			warrior_server:floor_gain(RoleID, Floor);
		true ->
			ignore
	end.


someone_dead(Atker, Defer, SceneSt) when ?is_role(Atker)->
	#actor{uid=RoleID, line=Line} = Atker,
	#scene_st{opts=#{floor := Floor, act_id:=ActID}} = SceneSt,
	Num = warrior_server:get_kill(RoleID),
	CfgWarrior = #cfg_warrior_floor{kill_num=KillNum, score=Score} = cfg_warrior_floor:find(Floor),
	AddNum = case ?is_role(Defer) of
		true  -> lists:nth(1, KillNum);
		false -> lists:nth(2, KillNum)
	end,
	AddScore = case ?is_role(Defer) of
		true  ->
			lists:nth(1, Score);
		false ->
			case ?is_monst(Defer) of
				true  -> lists:nth(2, Score);
				false -> 0
			end
	end,
	Num2 = Num + AddNum,
	warrior_server:set_kill(RoleID, Num2),
	{_RankList, {OldScore, Data}} = warrior_server:get_ranklist(Line, RoleID),
	%总击杀数
	% TotalKill = maps:get("killnum", Data, 0),
	% Data2 = maps:put("killnum", TotalKill+1, Data),
	% %连斩数
	% OldCKill = maps:get("ckill", Data2, 0),
	% Ckill = warrior_server:get_c_kill(RoleID),
	% Ckill2 = Ckill + 1,
	% Data3 = case Ckill2 > OldCKill of
	% 	true  -> maps:put("ckill", Ckill2, Data2);
	% 	false -> Data2
	% end,
	% warrior_server:set_c_kill(RoleID, Ckill2),
	warrior_server:update_rank(Line, RoleID, OldScore+AddScore, Data),
	update_self(Line, RoleID, Floor),
	check_up_floor(RoleID, Num2, CfgWarrior, ActID);

someone_dead(_Atker, _Defer, _SceneSt)->
	ignore.


update_creep(RoleID)->
	ActIDs = scene_actor:get_actids(?ACTOR_TYPE_CREEP),
	HaveCreep = lists:foldl(fun
			(ActID, Acc) ->
				#actor{id=CreepID} = scene_actor:get_actor(ActID),
				Acc orelse CreepID == 30396001
		end, false, ActIDs),
	State = case HaveCreep of
		true  -> 1;
		false -> 2
	end,
	?ucast(RoleID, #m_warrior_creep_toc{state=State}).

%广播第一个到顶层
notify_top(RoleID, RoleName, Line, Floor) ->
	case Floor == length(cfg_warrior_floor:floors()) of
		true ->
			RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
			?_if(is_first_enter(Line), ?notify(RoleIDs, ?MSG_WARRIOR_FIRST_TOP, [
				{role, RoleID, RoleName}]));
		false ->
			ignore
	end.

%是否第一个进入
is_first_enter(Line)->
	case erlang:get({?MODULE, Line}) of
		?nil ->
			erlang:put({?MODULE, Line}, 1),
			true;
		_ ->
			false
	end.
