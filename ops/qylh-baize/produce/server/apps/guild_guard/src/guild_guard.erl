%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_guard).

-include("activity.hrl").
-include("attr.hrl").
-include("btree.hrl").
-include("dunge.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("guild.hrl").
-include("ranking.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").

%% API
-export([handle/2]).

-export([hook_start/1]).
-export([hook_stop/1]).
-export([hook_timeout/1]).
-export([pre_enter/3]).
-export([enter_opts/2]).
-export([get_entry/1]).
-export([get_expcoef/3]).
-export([hook_drop_exp/3]).

-export([init_dunge/1]).
-export([init_npcs/1]).
-export([init_role/1]).
-export([summon_later/2]).
-export([summon/1]).
-export([assault/1]).
-export([send_info/1, send_info/2]).
-export([send_npcs/1]).
-export([send_ranking/2]).
-export([update_npc/1]).
-export([is_npc_dead/1]).
-export([is_monst_dead/1]).
-export([is_fail/1]).
-export([stat/1]).
-export([give_reward/2]).

-export([init_creep/2]).
-export([guard/2]).
-export([update_damage/2]).
-export([update_npchp/2]).
-export([attack_npc/2]).

-define(GROUP_ALLY , 1).
-define(GROUP_ENEMY, 2).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(_MsgID, _RoleSt) ->
	ok.

hook_start(ActID) ->
	#cfg_activity{scene=SceneID} = cfg_activity:find(ActID),
	#cfg_scene{stype=SType} = cfg_scene:find(SceneID),
	DungeID = dunge_util:get_dunge(SType),
	lists:foreach(fun
		(#p_guild_base{id=GuildID}) ->
			scene:create(SceneID, GuildID, #{dunge=>DungeID})
	end, guild:get_guilds()).

hook_stop(ActID) ->
	#cfg_activity{scene=SceneID} = cfg_activity:find(ActID),
	% ?debug("------------------hook_stop"),
	scene:route(SceneID, ?MODULE, hook_timeout).

hook_timeout(_SceneSt) ->
	dunge_agent:event(hook_timeout, ?nil).

%% 玩家进入场景前
pre_enter(SceneID, _Args, RoleSt) ->
	#role_st{role=RoleID, guild=GuildID} = RoleSt,
	?debug("enter_guild_guard111: ~w", [{RoleID, SceneID, GuildID}]),
	?_check(GuildID > 0, ?ERR_SCENE_NO_GUILD),
	ScenePid = scene:get_pid(SceneID, GuildID),
	?debug("enter_guild_guard222: ~w", [ScenePid]),
	?_check(ScenePid /= ?nil, ?ERR_GUILD_GUARD_FINISHED),
	{ok, Memb} = guild:get_member(GuildID, RoleID),
	Secs = ut_time:seconds() - Memb#guild_memb.time,
	Need = cfg_game:guild_guard_join(),
	?_check(Secs >= Need, ?ERR_GUILD_GUARD_JOINTIME_LIMIT).


enter_opts(_Entry, _RoleSt) ->
	#{group=>?GROUP_ALLY}.

get_entry(RoleSt) ->
	#{room=>RoleSt#role_st.guild}.

get_expcoef(_Atker, _Defer, _SceneSt) ->
	#dunge_st{opts=Opts} = dunge_util:get_state(),
	Npcs = maps:get(npcs, Opts, []),
	case Npcs == [] of
		true  -> 0;
		false -> lists:sum([Coef || {_,_,Coef} <- Npcs])
	end.

hook_drop_exp(Actor, Exp, _SceneSt) ->
	DungeSt  = #dunge_st{opts=Opts} = dunge_util:get_state(),
	ExpStat  = maps:get(exp_stat, Opts, #{}),
	ExpStat2 = ut_misc:maps_increase(Actor#actor.uid, Exp, ExpStat),
	Opts2 = maps:put(exp_stat, ExpStat2, Opts),
	dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}).

%% ==================== 副本ai回调 ====================
init_dunge(_SceneSt) ->
	% ?debug("-------------------init_dunge"),
	DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
	WorldLv = world_level:get_level(),
	NowSecs = ut_time:seconds(),
	Interval = cfg_game:guild_guard_assault_interval(),
	Opts2 = Opts#{
		assault_wave => 0,
		assault_time => NowSecs + Interval
	},
	dunge_util:set_state(DungeSt#dunge_st{level=WorldLv, opts=Opts2}),
	ut_ranking:init(?RANK_ID_GUILD_GUARD, 5, 0, ?nil, []),
	assault_after(Interval),
	?SUCCESS.

summon_later(Secs, SceneSt) ->
	DungeSt   = dunge_util:get_state(),
	% ?debug("summon_later----------------------------:~w", [DungeSt#dunge_st.wtime]),
	WaveETime = ut_time:seconds() + Secs,
	dunge_util:set_state(DungeSt#dunge_st{wtime=WaveETime}),
	send_info(SceneSt),
	erlang:send_after(timer:seconds(Secs), self(), {route, ?MODULE, summon}),
	?SUCCESS.

summon(SceneSt) ->
	dunge_aiwave:summon(SceneSt),
	#dunge_st{wave=Wave} = dunge_util:get_state(),
	% ?debug("summon----------------------------:~w", [Wave]),
	?notify(
		scene_actor:get_actids(?ACTOR_TYPE_ROLE),
		?MSG_DUNGE_GUILD_GUARD_WAVE,
		[Wave]
	),
	?SUCCESS.

assault(SceneSt = #scene_st{dunge=DungeID}) ->
	% ?debug("assault----------------------------", []),
	DungeSt = #dunge_st{opts=Opts, level=Level} = dunge_util:get_state(),
	CurWave = maps:get(assault_wave, Opts, 0),
	MaxWave = cfg_game:guild_guard_assault_total(),
	case CurWave >= MaxWave of
		true  ->
			ignore;
		false ->
			Interval = cfg_game:guild_guard_assault_interval(),
			assault_after(Interval),
			#cfg_dunge_wave{creeps=Creeps} = cfg_dunge_wave:find(DungeID, 0, Level),
			dunge_creep:summon(Creeps, SceneSt),
			dunge_util:set_state(DungeSt#dunge_st{
				opts = Opts#{
					assault_wave => CurWave + 1,
					assault_time => ut_time:seconds() + Interval
				}
			}),
			?notify(
				scene_actor:get_actids(?ACTOR_TYPE_ROLE),
				?MSG_DUNGE_GUILD_GUARD_ASSAULT,
				[]
			)
	end.

assault_after(Secs) ->
	% ?debug("assault----------------------------", []),
	erlang:send_after(timer:seconds(Secs), self(), {route, ?MODULE, assault}).

init_npcs(SceneSt) ->
	% ?debug("-------------------init_npcs"),
	DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
	Npcs  = cfg_creep_born:find(SceneSt#scene_st.scene),
	Npcs1 = lists:map(fun
		({ID,X,Y,_}) ->
			{ID,X,Y,#{group=>?GROUP_ALLY}}
	end, cfg_creep_born:find(SceneSt#scene_st.scene)),
	Npcs2 = creep_agent:add(Npcs1, SceneSt),
	Npcs3 = lists:zipwith3(fun
		(Flag, NpcID, {_,_,_,Coef}) ->
			{Flag, NpcID, Coef}
	end, ['A','B','C'], Npcs2, Npcs),
	dunge_util:set_state(DungeSt#dunge_st{opts=Opts#{npcs=>Npcs3}}),
	?SUCCESS.

init_role(_SceneSt) ->
	% ?debug("init_role----------------------------", []),
	{hook_enter, [Actor]} = dunge_util:get_event(),
	scene_actor:set_actor(Actor#actor{group=?GROUP_ALLY}),
	?SUCCESS.

send_info(SceneSt) ->
	% ?debug("send_info----------------------------", []),
	#dunge_st{roles=RoleIDs} = dunge_util:get_state(),
	lists:foreach(fun
		(RoleID) ->
			?MODULE:send_info(RoleID, SceneSt)
	end, RoleIDs),
	?SUCCESS.

send_info(RoleID, SceneSt) ->
	% ?debug("send_info2222----------------------------", []),
	#scene_st{scene=SceneID, dunge=DungeID} = SceneSt,
	DungeSt = dunge_util:get_state(),
	#dunge_st{wave=CurWave, wtime=WaveETime, opts=Opts, kill=KillStat} = DungeSt,
	ExpStat  = maps:get(exp_stat, Opts, #{}),
	?ucast(RoleID, #m_dunge_info_toc{
		stype = ?SCENE_STYPE_GUILDGUARD,
		id    = SceneID,
		count = KillStat,
		info  = #{
			"cur_wave"   => CurWave,
			"max_wave"   => cfg_dunge_wave:max(DungeID),
			"start_time" => SceneSt#scene_st.stime,
			"end_time"   => SceneSt#scene_st.etime,
			"wave_etime" => WaveETime,
			"dunge"      => DungeID,
			"exp"        => maps:get(RoleID, ExpStat, 0),
			"assault"    => maps:get(assault_time, Opts, 0)
		}
	}).

send_npcs(_SceneSt) ->
	% ?debug("send_npcs----------------------------", []),
	#dunge_st{opts=#{npcs:=Npcs}} = dunge_util:get_state(),
	{hook_enter, [Actor]} = dunge_util:get_event(),
	lists:foreach(fun
		({_, NpcID, _}) ->
			#actor{attr=Attr} = scene_actor:get_actor(NpcID),
			?ucast(Actor#actor.uid, #m_actor_updatehp_toc{
				uid   = NpcID,
				hp    = ?_attr(Attr,?ATTR_HP),
				hpmax = ?_attr(Attr,?ATTR_HPMAX)
			})
	end, Npcs),
	?SUCCESS.

send_ranking(RoleID, SceneSt) when SceneSt#scene_st.stype == ?SCENE_STYPE_GUILDGUARD ->
	% ?debug("send_ranking----------------------------", []),
	#dunge_st{opts=Opts} = dunge_util:get_state(),
	DmgStat  = maps:get(dmg_stat, Opts, #{}),
	RankList = ut_ranking:get_all(?RANK_ID_GUILD_GUARD),
	Mine = case lists:keyfind(RoleID, #rankitem.id, RankList) of
		false -> #p_ranking{rank=0, sort=maps:get(RoleID, DmgStat, 0)};
		RItem -> rank_util:p_ranking(RItem)
	end,
	?ucast(RoleID, #m_rank_list_toc{
		id    = ?RANK_ID_GUILD_GUARD,
		total = 1,
		page  = 1,
		list  = [rank_util:p_ranking(RItem) || RItem <- RankList],
		mine  = Mine
	});
send_ranking(_, _) ->
	ignore.

update_npc(_SceneSt) ->
	% ?debug("update_npc----------------------------", []),
	{hook_creep_dead, [_, Actor]} = dunge_util:get_event(),
	DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
	Npcs  = maps:get(npcs, Opts, []),
	Npcs2 = lists:keydelete(Actor#actor.uid, 2, Npcs),
	Opts2 = maps:put(npcs, Npcs2, Opts),
	% ?debug("update_npc:~w", [Npcs2]),
	dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
	?SUCCESS.

is_npc_dead(_SceneSt) ->
	% ?debug("is_npc_dead----------------------------", []),
	{hook_creep_dead, [_, Actor]} = dunge_util:get_event(),
	#dunge_st{opts=#{npcs:=Npcs}} = dunge_util:get_state(),
	lists:keymember(Actor#actor.uid, 2, Npcs).

is_monst_dead(_SceneSt) ->
	% ?debug("is_monst_dead----------------------------", []),
	{hook_creep_dead, [_, Actor]} = dunge_util:get_event(),
	?is_monst(Actor) andalso
	Actor#actor.group == ?GROUP_ENEMY andalso
	maps:get(wave, Actor#actor.aiargs, 0) > 0.

is_fail(_SceneSt) ->
	% ?debug("is_fail----------------------------", []),
	#dunge_st{opts=#{npcs:=Npcs}} = dunge_util:get_state(),
	Npcs == [] orelse (not lists:keymember('C', 1, Npcs)).

stat(SceneSt) ->
	% ?debug("stat----------------------"),
	erlang:send(self(), timeout),
	creep_agent:clear(SceneSt),
	DungeSt = dunge_util:get_state(),
	#dunge_st{roles=RoleIDs, clear=IsClear, opts=Opts} = DungeSt,
	ExpStat  = maps:get(exp_stat, Opts, #{}),
	KillStat = maps:get(kill_stat, Opts, #{}),
	Ranking  = ut_ranking:get_all(?RANK_ID_GUILD_GUARD),
	lists:foreach(fun
		(RoleID) ->
			Rank = case lists:keyfind(RoleID, #rankitem.id, Ranking) of
				false -> 0;
				RItem -> RItem#rankitem.rank
			end,
			Reward1 = case IsClear of
				true  -> cfg_game:guild_guard_succ();
				false -> cfg_game:guild_guard_fail()
			end,
			Reward2 = cfg_guild_guard_rank:find(Rank),
			Gain = Reward1 ++ Reward2,
			case role:is_online(RoleID) of
				true  ->
					role:route(RoleID, ?MODULE, give_reward, Gain);
				false ->
					case IsClear of
						true  ->
							mail:send(RoleID, ?MAIL_GUILD_GUARD_SUCC, Gain);
						false ->
							mail:send(RoleID, ?MAIL_GUILD_GUARD_FAIL, Gain)
					end
			end,
			?ucast(RoleID, #m_dunge_over_toc{
				stype = SceneSt#scene_st.stype,
				id    = SceneSt#scene_st.dunge,
				clear = IsClear,
				count = KillStat,
				stat  = #{
					"exp"  => maps:get(RoleID, ExpStat, 0),
					"rank" => Rank
				}
			})
	end, RoleIDs),
	?SUCCESS.


give_reward(Gain, RoleSt) ->
	% ?debug("give_reward----------------------"),
	role_bag:gain(Gain, ?LOG_DUNGE_GUILD_GUARD, RoleSt).

%% ==================== 怪物ai回调 ====================
init_creep(Actor, SceneSt) ->
	% ?debug("init_creep----------------------"),
	#actor{id=CreepID, aiargs=AIArgs} = Actor,
	Pos = proplists:get_value(pos, cfg_creep:aiargs(CreepID)),
	AIArgs2 = maps:put(pos, Pos, AIArgs),
	Actor2  = Actor#actor{aiargs=AIArgs2, group=?GROUP_ENEMY, center=self},
	creep_ai:born(Actor2, SceneSt).

guard(Actor, SceneSt) ->
	% ?debug("guard----------------------"),
	Actor2 = creep_ai:find_in_threat(Actor, SceneSt),
    scene_actor:set_actor(Actor2),
	case Actor2#actor.enemy == 0 of
        true  -> ?FAILURE;
        false -> ?SUCCESS
    end.

update_damage(Actor, _SceneSt) ->
	% ?debug("update_damage----------------------"),
    {hook_injure, {Atker,DmgVal,_NewHp}} = creep_util:get_event(Actor#actor.uid),
    case ?is_role(Atker) of
    	true  ->
    		DungeSt  = #dunge_st{opts=Opts} = dunge_util:get_state(),
    		DmgStat  = maps:get(dmg_stat, Opts, #{}),
    		DmgStat2 = ut_misc:maps_increase(Atker#actor.uid, DmgVal, DmgStat),
    		Opts2  = maps:put(dmg_stat, DmgStat2, Opts),
    		dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
    		NewDmg = maps:get(Atker#actor.uid, DmgStat2, 0),
    		ut_ranking:update(?RANK_ID_GUILD_GUARD, Atker#actor.uid, NewDmg, #{});
    	false ->
    		ignore
    end,
	?SUCCESS.

update_npchp(Actor, _SceneSt) ->
	% ?debug("update_npchp----------------------"),
	#actor{uid=ActorID, name=Name, attr=Attr} = Actor,
	RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
	?bcast(RoleIDs, #m_actor_updatehp_toc{
		uid   = ActorID,
		hp    = ?_attr(Attr,?ATTR_HP),
		hpmax = ?_attr(Attr,?ATTR_HPMAX)
	}),
	#dunge_st{opts=#{npcs:=Npcs}} = dunge_util:get_state(),
	case lists:keyfind(ActorID, 2, Npcs) of
		false ->
			ignore;
		{Flag, _, _} ->
			LastSecs  = get({attack_notify, Flag}),
			LastSecs2 = ?_if(LastSecs == ?nil, 0, LastSecs),
			NowSecs   = ut_time:seconds(),
			case NowSecs - LastSecs2 >= 20 of
				true  ->
					?notify(RoleIDs, ?MSG_DUNGE_GUILD_GUARD_ATTACKED, [Name]),
					put({attack_notify, Flag}, NowSecs);
				false ->
					ignore
			end
	end,
	?SUCCESS.

attack_npc(Actor, SceneSt) ->
	% ?debug("attack_npc----------------------"),
	#dunge_st{opts=#{npcs:=Npcs}} = dunge_util:get_state(),
	Pos   = maps:get(pos, Actor#actor.aiargs),
	Flags = if
		Pos == 1; Pos == 2 -> ['A', 'C'];
		Pos == 3; Pos == 4 -> ['B', 'C'];
		Pos == 5; Pos == 6 -> ['C']
	end,
	case find_npc(Flags, Npcs) of
		?nil ->
			% ?debug("~ts", ["没有找到"]),
			?FAILURE;
		Npc ->
			% ?debug("~ts:~w", ["找到npc", Npc]),
			case scene_util:is_nearby(Actor, Npc, Actor#actor.atkrad) of
				true  ->
					scene_actor:set_actor(Actor#actor{enemy=Npc#actor.uid}),
					% ?debug("xxxxxxxxxxxxxxxxxxxxx~w", [{Actor#actor.id, Actor#actor.enemy}]),
					?SUCCESS;
				false ->
					walkto_npc(Actor, Pos, Npc, SceneSt)
			end
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
find_npc([Flag | T], Npcs) ->
	case lists:keyfind(Flag, 1, Npcs) of
		false ->
			find_npc(T, Npcs);
		{_, NpcID, _} ->
			case scene_actor:get_actor(NpcID) of
				?nil -> find_npc(T, Npcs);
				Npc  -> Npc
			end
	end;
find_npc([], _Npcs) ->
	?nil.

walkto_npc(Actor, Pos, Npc, SceneSt) ->
	% ?debug("walkto_npc----------------------"),
	% Dist = scene_util:calc_distance(Coord1, Coord2),
	% Move = min(50, Dist-AtkRad),
	case scene_util:is_nearby(Actor, Npc, Actor#actor.atkrad) of
		true  ->
			% ?debug("~ts ~w", ["走向npcaaaaaaaaaaaaa", {Actor#actor.coord, NpcID, Coord2}]),
			?SUCCESS;
		false ->
			% Offset = ut_rand:random(40, 100),
			% Dest = creep_aiwalk:dest(towards, Actor, Coord2, {offset,Offset}, SceneSt),
			% ?debug("~ts ~w", ["走向npc", {Actor#actor.coord, NpcID, Coord2}]),
			case creep_aiwalk:path(Actor, Npc#actor.coord, scene_path_stupid, 100, SceneSt) of
				?FAILURE ->
					% ?debug("FAILURE-------------------------"),
					walkto_npc2(Actor, Pos, SceneSt);
				?SUCCESS ->
					% ?debug("~ts ~w", ["在npc附近了222", {}]),
					% ?debug("SUCCESS-------------------------"),
					% scene_actor:set_actor(Actor#actor{enemy=NpcID}),
					?SUCCESS;
				?RUNNING ->
					% ?debug("RUNNING-------------------------"),
					Actor2 = scene_actor:get_actor(Actor#actor.uid),
					creep_ai:move(Actor2, SceneSt)
			end
	end.

walkto_npc2(Actor, Pos, SceneSt) ->
	Npcs = cfg_creep_born:find(SceneSt#scene_st.scene),
	Nth  = ?_if(Pos rem 2 == 1, 1, 2),
	{_, DstX, DstY, _} = lists:nth(Nth, Npcs),
	Dest = #p_coord{x=DstX, y=DstY},
	% ?debug("~ts ~w", ["走向npc222222222", {Nth, DstX, DstY}]),
	case creep_aipath:find(Actor, Dest, SceneSt) of
		?RUNNING ->
			% ?debug("~ts ~w", ["走向npc222222222---RUNNING", {DstX, DstY}]),
			Actor2 = scene_actor:get_actor(Actor#actor.uid),
			creep_ai:move(Actor2, 100, SceneSt);
		Result ->
			% ?debug("~ts ~w", ["走向npc222222222FAILURE", {DstX, DstY}]),
			Result
	end.