%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_equip_dungeai).

-include("btree.hrl").
-include("dunge.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("item.hrl").
-include("msgno.hrl").

%% API
-export([init/1]).
-export([enter/1]).
-export([summon/1]).
-export([update_level/1]).
-export([update_drop/1]).
-export([stat_one/1]).
-export([stat/1]).
-export([is_boss_dead/1]).
-export([is_penult/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(SceneSt) ->
	#scene_st{dunge=DungeID} = SceneSt,
	#cfg_dunge{level=CreepLv} = cfg_dunge:find(DungeID),
	DungeSt = dunge_util:get_state(),
	dunge_util:set_state(DungeSt#dunge_st{
		level = CreepLv,
		opts  = #{dunge_lv=>1}
	}),
	?SUCCESS.

enter(_SceneSt) ->
	{hook_enter, [Actor]} = dunge_util:get_event(),
	scene_actor:set_actor(Actor#actor{group=Actor#actor.team}),
	?SUCCESS.

summon(SceneSt) ->
	#scene_st{dunge=DungeID} = SceneSt,
	DungeSt = dunge_util:get_state(),
	#dunge_st{level=CreepLv, wave=OldWave, opts=Opts, count=Count} = DungeSt,
	NewWave = OldWave + 1,
	CfgWave = cfg_dunge_wave:find(DungeID, NewWave, CreepLv),
	#cfg_dunge_wave{creeps=Creeps, last=Last} = CfgWave,
	DungeLv = maps:get(dunge_lv, Opts),
	{_, CreepInfo} = lists:keyfind(DungeLv, 1, Creeps),
	Creeps2 = dunge_creep:summon([CreepInfo], SceneSt),
	dunge_util:set_state(DungeSt#dunge_st{
		wave  = NewWave,
		wtime = ut_time:seconds() + Last,
		count = maps:put(NewWave, length(Creeps2), Count)
	}),
	?SUCCESS.

update_level(SceneSt) ->
	DungeSt = dunge_util:get_state(),
	#dunge_st{opts=Opts, roles=RoleIDs} = DungeSt,
	% 更新副本难度
	Opts2 = case DungeSt#dunge_st.wtime >= ut_time:seconds() of
		true  ->
			OldLv = maps:get(dunge_lv, Opts),
			case OldLv < 5 of
				true  -> maps:put(dunge_lv, OldLv+1, Opts);
				false -> Opts
			end;
		false ->
			Opts
	end,
	dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
	lists:foreach(fun
		(RoleID) ->
			dunge_equip:send_info(RoleID, SceneSt)
	end, RoleIDs),
	?SUCCESS.

update_drop(SceneSt) ->
	% 更新掉落统计
	DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
	{hook_drop, [_Defer, Drops]} = dunge_util:get_event(),
	#scene_st{dunge=DungeID} = SceneSt,
	Opts2 = drop_stat(dunge_team:calc_belong(), Drops, Opts, DungeID),
	dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
	?SUCCESS.

stat_one(SceneSt) ->
	{hook_over, [RoleID]} = dunge_util:get_event(),
	DungeSt  = dunge_util:get_state(),
	#dunge_st{clear=IsClear, opts=Opts, roles=RoleIDs} = DungeSt,
	RoleIDs2 = lists:delete(RoleID, RoleIDs),
	dunge_util:set_state(DungeSt#dunge_st{roles=RoleIDs2}),
	?ucast(RoleID, #m_dunge_over_toc{
		stype  = SceneSt#scene_st.stype,
		id     = SceneSt#scene_st.dunge,
		clear  = IsClear,
		reward = maps:get({drop, RoleID}, Opts, #{})
	}),
	?SUCCESS.

stat(SceneSt) ->
	#dunge_st{roles=RoleIDs, clear=IsClear, opts=Opts} = dunge_util:get_state(),
	Captain0 = team_server:get_captain(SceneSt#scene_st.room),
	Captain  = ?_if(Captain0 == ?nil, false, Captain0),
	lists:foreach(fun
		(RoleID) ->
			case scene_actor:get_actor(RoleID) of
				?nil  ->
					ignore;
				Actor ->
					RestTimes = dunge_util:rest_times(Actor),
					?_if(IsClear, give_reward(RoleID, Captain, RestTimes, SceneSt)),
					?ucast(RoleID, #m_dunge_over_toc{
						stype  = SceneSt#scene_st.stype,
						id     = SceneSt#scene_st.dunge,
						clear  = IsClear,
						reward = maps:get({drop, RoleID}, Opts, #{})
					})
			end
	end, RoleIDs),
	?SUCCESS.

is_boss_dead(_SceneSt) ->
	{hook_creep_dead, [_Atker, Defer]} = dunge_util:get_event(),
	Defer#actor.rarity == ?CREEP_RARITY_BOSS2.

is_penult(SceneSt) ->
	#dunge_st{wave=Wave} = dunge_util:get_state(),
	Wave + 1 == cfg_dunge_wave:max(SceneSt#scene_st.dunge).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
give_reward(RoleID, Captain, RestTimes, _SceneSt)->
	role:route(RoleID, dunge_equip, give_reward, {Captain, RestTimes}).

%% 掉落统计
drop_stat([], _Drops, Opts, _DungeID)->
	Opts;
drop_stat([RoleID | T], Drops, Opts, DungeID)->
	case scene_actor:get_actor(RoleID) of
		?nil  ->
			drop_stat(T, Drops, Opts, DungeID);
		Actor ->
			Times = dunge_util:merge_times(Actor),
			DropStat  = maps:get({drop, RoleID}, Opts, #{}),
			DropStat2 = lists:foldl(fun
				(#drop{id=ItemID, num=Num}, Acc) ->
					ut_misc:maps_increase(ItemID, Num*Times, Acc)
			end, DropStat, Drops),
			Opts2 = maps:put({drop, RoleID}, DropStat2, Opts),
			drop_stat(T, Drops, Opts2, DungeID)
	end.
