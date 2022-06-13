%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(compete_battle).

-include("activity.hrl").
-include("buff.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").

%% API
-export([hook_enter/2]).
-export([hook_role_dead/3]).
-export([hook_revive/3]).
-export([get_reborn/2]).
-export([hook_creep_dead/3]).
-export([hook_timeout/1]).
-export([buy_buff/2]).
-export([battle_start/2]).
-export([battle_stop/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_enter(Actor, SceneSt) ->
	#actor{uid=ActorID, enter=EnterOpts} = Actor,
	add_vs_role(ActorID),
	#{rival:=RivalID, index:=Index, faker:=FakerID} = EnterOpts,
	?debug("==========================hook_enter: ~w", [{Actor#actor.uid, RivalID}]),
	case RivalID == mirror of
		true  ->
			Robot = compete_robot:summon(Actor, Index, FakerID, SceneSt),
			set_robotid(Robot#actor.uid),
			add_vs_role(Robot#actor.uid);
		false ->
			ignore
	end.

hook_role_dead(Atker, Defer, SceneSt) ->
	case get_over() == true of
		true  ->
			ignore;
		false ->
			BuffID  = ?BUFF_ID_COMPETE_BATTLE_LIFE,
			OldBuff = buff_util:get_buff(Defer, BuffID),
			NewLife = OldBuff#p_buff.value - 1,
			?debug("hook_role_dead---------------------~w", [NewLife]),
			case NewLife =< 0 of
				true  ->
					IsLocal = cluster:is_local(),
					battle_win(Atker, IsLocal, SceneSt),
					battle_lose(Defer, IsLocal, SceneSt),
					stop_scene_later(),
					set_over();
				false ->
					?debug("revive---------------------"),
					buff_util:add_buffs(Defer, [{BuffID, #{value=>NewLife}}])
			end
	end.

%% 玩家复活
hook_revive(Actor, _Type, _SceneSt) when ?is_role(Actor) ->
	role:route(Actor#actor.pid, role_skill, refresh);
hook_revive(_Actor, _Type, _SceneSt) ->
	ok.

get_reborn(Actor, SceneSt) ->
	Index = maps:get(index, Actor#actor.enter),
    lists:nth(Index, scene_config:born(SceneSt#scene_st.scene)).

hook_creep_dead(Atker, Defer, SceneSt) ->
	case get_over() == true of
		true  ->
			ignore;
		false ->
			BuffID  = ?BUFF_ID_COMPETE_BATTLE_LIFE,
			OldBuff = buff_util:get_buff(Defer, BuffID),
			NewLife = OldBuff#p_buff.value - 1,
			?debug("hook_creep_dead---------------:~w", [NewLife]),
			case NewLife =< 0 of
				true  ->
					battle_win(Atker, cluster:is_local(), SceneSt),
					stop_scene_later(),
					set_over();
				false ->
					buff_util:add_buffs(Defer, [{BuffID, #{value=>NewLife}}])
			end
	end.

hook_timeout(SceneSt) ->
	?debug("======================hook_timeout:~w", [get_vs_roles()]),
	case get_over() == true of
		true  ->
			ignore;
		false ->
			IsLocal = cluster:is_local(),
			case get_vs_roles() of
				[ActorID1, ActorID2] ->
					Actor1 = scene_actor:get_actor(ActorID1),
					Actor2 = scene_actor:get_actor(ActorID2),
					if
						Actor1 /= ?nil,
						Actor2 /= ?nil ->
							#actor{attr=Attr1, power=Power1} = Actor1,
							#actor{attr=Attr2, power=Power2} = Actor2,
							BuffID = ?BUFF_ID_COMPETE_BATTLE_LIFE,
							Life1  = buff_util:get_value(Actor1, BuffID),
							Life2  = buff_util:get_value(Actor2, BuffID),
							#{?ATTR_HP:=CurHp1, ?ATTR_HPMAX:=MaxHp1} = Attr1,
							#{?ATTR_HP:=CurHp2, ?ATTR_HPMAX:=MaxHp2} = Attr2,
							HpPer1 = CurHp1 / MaxHp1,
							HpPer2 = CurHp2 / MaxHp2,
							if
								Life1 > Life2 ->
									battle_win(Actor1, IsLocal, SceneSt),
									battle_lose(Actor2, IsLocal, SceneSt);
								Life1 < Life2 ->
									battle_win(Actor2, IsLocal, SceneSt),
									battle_lose(Actor1, IsLocal, SceneSt);
								HpPer1 > HpPer2 ->
									battle_win(Actor1, IsLocal, SceneSt),
									battle_lose(Actor2, IsLocal, SceneSt);
								HpPer1 < HpPer2 ->
									battle_win(Actor2, IsLocal, SceneSt),
									battle_lose(Actor1, IsLocal, SceneSt);
								Power1 > Power2 ->
									battle_win(Actor1, IsLocal, SceneSt),
									battle_lose(Actor2, IsLocal, SceneSt);
								Power1 < Power2 ->
									battle_win(Actor2, IsLocal, SceneSt),
									battle_lose(Actor1, IsLocal, SceneSt);
								true ->
									?error("dead heat1: ~w", [{ActorID1, ActorID2}])
							end;
						Actor1 /= ?nil ->
							battle_win(Actor1, IsLocal, SceneSt),
							battle_lose(ActorID2, IsLocal, SceneSt);
						Actor2 /= ?nil ->
							battle_win(Actor2, IsLocal, SceneSt),
							battle_lose(ActorID1, IsLocal, SceneSt);
						true ->
							?error("dead heat2: ~w", [{ActorID1, ActorID2}]),
							ignore
					end;
				[ActorID] ->
					?error("bad versus info1: ~w", [ActorID]),
					case scene_actor:get_actor(ActorID) of
						?nil  -> ignore;
						Actor -> battle_win(Actor, IsLocal, SceneSt)
					end;
				_ ->
					?error("bad versus info2", []),
					ignore
			end,
			set_over(),
			stop_scene_later()
	end.

buy_buff({RoleID, BuffID, RealBuffID, AddTo}, _SceneSt) ->
	#cfg_buff{group=Group} = cfg_buff:find(BuffID),
	Actor = scene_actor:get_actor(RoleID),
	#actor{buffs=Buffs, enter=EnterOpts} = Actor,
	?_check(not maps:is_key(Group, Buffs), ?ERR_COMPETE_BUFF_HAD_BUY),
	?debug("---------------:~w", [Buffs]),
	case AddTo of
		self ->
			buff_util:add_buffs(Actor, [BuffID, RealBuffID]);
		peer ->
			buff_util:add_buffs(Actor, [BuffID]),
			Rival = case maps:get(rival, EnterOpts) of
				mirror  ->
					RobotID = get_robotid(),
					scene_actor:get_actor(RobotID);
				RivalID ->
					scene_actor:get_actor(RivalID)
			end,
			buff_util:add_buffs(Rival, [RealBuffID])
	end,
	ok.

battle_start(RoleID, _SceneSt) ->
	Robot = scene_actor:get_actor(get_robotid()),
	?debug("hook_start--------------------------~w", [get_robotid()]),
	?_if(Robot /= ?nil, creep_agent:event(Robot, hook_start, ?nil)),
	Actor = scene_actor:get_actor(RoleID),
	#{index:=Index} = Actor#actor.enter,
	?ucast(RoleID, #m_compete_fight_toc{index=Index}).

battle_stop({ActID,SceneID,Reward,IsMiss}, RoleSt) ->
	?debug("===========================battle_stop:~w", [{ActID, SceneID}]),
	role_bag:gain(Reward, ?LOG_COMPETE_BATTLE, RoleSt),
	case IsMiss of
		true  ->
			ignore;
		false ->
			Coord = scene_util:get_born(SceneID),
			scene_change:change(
				?SCENE_CHANGE_ACT, SceneID, 0, Coord, [], #{}, RoleSt
			)
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
-define(k_vs_roles, {?MODULE, vs}).
set_vs_roles(RoleIDs) ->
	put(?k_vs_roles, RoleIDs).

get_vs_roles() ->
	get(?k_vs_roles).

add_vs_role(RoleID) ->
	case get_vs_roles() of
		?nil  -> set_vs_roles([RoleID]);
		Roles -> set_vs_roles(lists:usort([RoleID | Roles]))
	end.

-define(k_robot, {?MODULE, robot}).
set_robotid(RobotID) ->
	put(?k_robot, RobotID).

get_robotid() ->
	get(?k_robot).


-define(k_over, {?MODULE, over}).
get_over() ->
	get(?k_over).

set_over() ->
	put(?k_over, true).

battle_win(Actor, IsLocal, SceneSt) when ?is_role(Actor) ->
	#scene_st{stime=StartTime, opts=Opts} = SceneSt,
	#{round:=Round, type:=Type, group:=GroupID} = Opts,
	Reward = cfg_compete_battle_reward:win(Round, IsLocal, Type),

	LifeBuff = buff_util:get_buff(Actor, ?BUFF_ID_COMPETE_BATTLE_LIFE),
	RestLife = LifeBuff#p_buff.value,

	TimeUsed = ut_time:seconds() - StartTime,
	Score1 = 10,
	Score2 = if
		TimeUsed =< 30 -> 2;
		TimeUsed =< 60 -> 1;
		true           -> 0
	end,
	Score3 = if
		RestLife == 3 -> 2;
		RestLife == 2 -> 1;
		true          -> 0
	end,
	ScoreAdd = Score1 + Score2 + Score3,
	?ucast(Actor#actor.uid, #m_compete_stat_toc{
		is_win = true,
		reward = maps:from_list(Reward)
	}),
	compete_server:battle_result(Type, GroupID, Actor#actor.uid, ScoreAdd, Reward),
	stop_battle(Actor, Reward, SceneSt);
battle_win(_Actor, _IsLocal, _SceneSt) ->
	ignore.

battle_lose(Actor, IsLocal, SceneSt) when is_record(Actor, actor), ?is_role(Actor) ->
	#scene_st{opts=Opts} = SceneSt,
	#{round:=Round, type:=Type, group:=GroupID} = Opts,
	Reward = cfg_compete_battle_reward:lose(Round, IsLocal, Type),
	?ucast(Actor#actor.uid, #m_compete_stat_toc{
		is_win = false,
		reward = maps:from_list(Reward)
	}),
	compete_server:battle_result(Type, GroupID, Actor#actor.uid, 0, Reward),
	stop_battle(Actor, Reward, SceneSt);
battle_lose(ActorID, IsLocal, SceneSt) when is_integer(ActorID) ->
	case get_robotid() == ActorID of
		true  ->
			ignore;
		false ->
			#scene_st{opts=Opts} = SceneSt,
			#{round:=Round, type:=Type} = Opts,
			Reward = cfg_compete_battle_reward:lose(Round, IsLocal, Type),
			mail:send(ActorID, ?MAIL_COMPETE_BATTLE_REWARD, Reward)
	end;
battle_lose(_Actor, _IsLocal, _SceneSt) ->
	ignore.

stop_battle(Actor, Reward, _SceneSt) ->
	#actor{pid=Pid, enter=EnterOpts} = Actor,
	#{act_id:=ActID, prepare:=SceneID} = EnterOpts,
	role:route(
		Pid, ?MODULE, battle_stop, {ActID,SceneID,Reward,false}
	).

stop_scene_later() ->
	erlang:send_after(timer:seconds(5), self(), {stop,normal}).
