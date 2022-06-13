%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_pet).

-include("creep.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").

%% API
-export([handle/2]).
-export([send_info/2]).
-export([give_reward/2]).
-export([pre_collect/3]).
-export([over_notify/6]).
-export([get_drops/2]).

-define(SCENE_STYPE, ?SCENE_STYPE_DUNGE_PET).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 面板
handle(?DUNGE_PANEL, RoleSt) ->
	#cfg_dunge_enter{times=MaxTimes} = cfg_dunge:enter(?SCENE_STYPE),
	?ucast(#m_dunge_panel_toc{
		stype = ?SCENE_STYPE,
		id    = 0,
		info  = #{
			"max_times"  => MaxTimes,
			"buy_times"  => role_count:get_scene_buy(?SCENE_STYPE),
			"rest_times" => dunge_util:rest_times(?SCENE_STYPE)
		}
	}).

send_info(RoleID, SceneSt) ->
	#scene_st{scene=SceneID, dunge=DungeID} = SceneSt,
	#dunge_st{wave=CurWave, wtime=WaveETime} = dunge_util:get_state(),
	case scene_actor:get_actor(RoleID) of
		?nil  ->
			ignore;
		Actor ->
			RestTimes = maps:get(rest_times, Actor#actor.enter),
			?ucast(RoleID, #m_dunge_info_toc{
				stype = ?SCENE_STYPE_DUNGE_PET,
				id    = SceneID,
				info  = #{
					"cur_wave"   => CurWave,
					"max_wave"   => cfg_dunge_wave:max(DungeID),
					"end_time"   => SceneSt#scene_st.etime,
					"wave_etime" => WaveETime,
					"dunge"      => DungeID,
					"rest_times" => RestTimes
				}
			})
	end.

give_reward({ClrWave, Drops, DungeID, DungeLv, Captain, RestTimes, MergeTimes}, RoleSt) ->
	case RestTimes > 0 of
		true  ->
			#cfg_dunge_wave{reward=DropList} = cfg_dunge_wave:find(DungeID, ClrWave, DungeLv),
			Gain  = creep_drop:calc(DungeLv, DropList),
			Gain2 = role_bag:multiple(Gain, MergeTimes),
			{ok, Obtain} = role_bag:gain(Gain2, ?LOG_DUNGE_PET_WAVE, RoleSt),
			over_notify(RoleSt#role_st.role, DungeID, true, ClrWave, Drops, Obtain);
		false ->
			dunge_team:assist_reward(Captain, RoleSt),
			over_notify(RoleSt#role_st.role, DungeID, true, ClrWave, Drops, #{})
	end.

pre_collect(Actor, _Collect, _SceneSt) ->
	RestTimes = maps:get(rest_times, Actor#actor.enter),
	?_check(RestTimes > 0, ?ERR_DUNGE_PET_CANNOT_COLLECT).

over_notify(RoleID, DungeID, IsClear, ClrWave, Drops, Reward) ->
	?ucast(RoleID, #m_dunge_over_toc{
		stype  = ?SCENE_STYPE,
		id     = DungeID,
		clear  = IsClear,
		reward = Drops,
		stat   = #{"wave"=>ClrWave},
		count  = Reward
	}).

%% 掉落宝箱
get_drops(Actor, _SceneSt) ->
	case cfg_creep:aiargs(Actor#actor.id) of
		?nil   ->
			[];
		AIArgs ->
			Killer = scene_actor:get_actor(Actor#actor.killer),
			CanDrop = is_record(Killer, actor)
				andalso role:is_role(Killer#actor.uid)
				andalso dunge_util:rest_times(Killer) > 0,
			case CanDrop of
				true  ->
					#dunge_st{opts=Opts} = dunge_util:get_state(),
					DropKey = maps:get(drop_key, Opts, 0),
					Boxes  = proplists:get_value(box, AIArgs, []),
					Boxes1 = proplists:get_value(DropKey, Boxes, []),
					Boxes2 = lists:filtermap(fun
						({CreepID, _, _, Prob}) ->
							case ut_rand:random(1, ?PER_10000) =< Prob of
								true  -> {true, CreepID};
								false -> false
							end
					end, Boxes1),
					lists:foldl(fun
						(CreepID, Acc) ->
							#cfg_creep{drops=Drops} = cfg_creep:find(CreepID),
							Drops ++ Acc
					end, [], Boxes2);
				false ->
					[]
			end
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
