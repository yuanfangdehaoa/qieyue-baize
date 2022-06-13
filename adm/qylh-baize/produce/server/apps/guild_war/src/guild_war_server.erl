%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_war_server).

-behaviour(gen_server).

-include("activity.hrl").
-include("creep.hrl").
-include("game.hrl").
-include("guild.hrl").
-include("guildwar.hrl").
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
-export([get_entry/3]).
-export([get_zone/1]).
-export([hook_ready/1]).
-export([hook_start/1]).
-export([hook_stop/1]).
-export([hook_post/1]).
-export([pre_enter/3]).
-export([get_reborn/2]).
-export([hook_enter/2]).
-export([hook_leave/2]).
-export([pre_collect/3]).
-export([hook_role_dead/3]).
-export([hook_creep_dead/3]).
-export([hook_revive/3]).
-export([is_winner/1]).
-export([give_chief_reward/1]).
-export([add_chief_buff/1]).
-export([del_chief_buff/1]).

-define(SERVER, ?MODULE).

-define(ACT_GROUP, 102).
-define(is_round1(ActID), (ActID == 10201 orelse ActID == 10203)).
-define(is_round2(ActID), (ActID == 10202 orelse ActID == 10204)).

-record(state, {act_id, scene, timer, divide}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%% 划分战区
% 第一轮
hook_ready(ActID) when ?is_round1(ActID) ->
	Guilds10 = ets:tab2list(?ETS_GW_GUILD),
	Guilds11 = lists:sublist(lists:keysort(#gw_guild.rank, Guilds10), 16),
	Guilds1  = [G#gw_guild.id || G <- Guilds11],

	Guilds20 = guild:get_guilds(),
	Guilds21 = [G || G <- Guilds20, not lists:member(G#p_guild_base.id, Guilds1)],
	Guilds22 = lists:keysort(#p_guild_base.rank, Guilds21),
	Guilds23 = lists:sublist(Guilds22, 20-length(Guilds1)),
	Guilds2  = [G#p_guild_base.id || G <- Guilds23],

	Division = round1_divide(Guilds1 ++ Guilds2, [1,2,3,4,5], #gw_divide{}),
	?debug("----------round 1 divide: ~p", [Division]),
	gen_server:cast(?SERVER, {divide, ready, ActID, Division, []});
% 第二轮
hook_ready(ActID) when ?is_round2(ActID) ->
	Guilds0  = ets:tab2list(?ETS_GW_GUILD),
	Guilds1  = lists:keysort(#gw_guild.rank, Guilds0),
	Division = round2_divide(Guilds1, [1,2,3,4,5], #gw_divide{}),
	?debug("----------round 2 divide: ~p", [Division]),
	gen_server:cast(?SERVER, {divide, ready, ActID, Division, []}).

% 升/降级
hook_post(ActID) when ?is_round2(ActID) ->
	Guilds0 = ets:tab2list(?ETS_GW_GUILD),
	Guilds1 = lists:map(fun
		(G) ->
			RankID = G#gw_guild.rank rem 10,
			ZoneID = G#gw_guild.field div 10,
			SeqID  = G#gw_guild.field rem 10,
			if
				SeqID == 1, RankID == 1, ZoneID > 1 -> % 升级
					mail_upgrade(ZoneID - 1, G#gw_guild.id),
					FieldID = (ZoneID - 1) * 10 + 2,
					G#gw_guild{
						field = FieldID,
						rank  = FieldID * 10 + 2
					};
				SeqID == 2, RankID == 2, ZoneID < 5 -> % 降级
					mail_degrade(ZoneID + 1, G#gw_guild.id),
					FieldID = (ZoneID + 1) * 10 + 1,
					G#gw_guild{
						field = FieldID,
						rank  = FieldID * 10 + 1
					};
				true ->
					G
			end
	end, Guilds0),
	?debug("----------round 3 divide: ~p", [Guilds1]),
	Guilds2  = lists:keysort(#gw_guild.rank, Guilds1),

	lists:foldl(fun
		(Guild, Rank) ->
			?debug("--------------:~w", [{Guild#gw_guild.id, Rank}]),
			MembIDs = guild:get_membids(Guild#gw_guild.id),
			lists:foreach(fun
				(RoleID) ->
					case role:is_alive(RoleID) of
						true  ->
							role_event:event(RoleID, ?EVENT_GWAR_RANK, Rank);
						false ->
							role_offmsg:insert(
								RoleID, role_event, event, [?EVENT_GWAR_RANK, Rank]
							)
					end
			end, MembIDs),
			Rank+1
	end, 1, Guilds2),

	Division = round3_divide(Guilds2, [1,2,3,4,5], #gw_divide{}),
	gen_server:cast(?SERVER, {divide, post, ActID, Division, Guilds2}).

%% 活动开始
hook_start(ActID) ->
	#cfg_activity{msgno=MsgNo} = cfg_activity:find(ActID),
	?notify(MsgNo),
	?debug("----------hook_start"),
	gen_server:cast(?SERVER, {start, ActID}).

%% 活动结束
hook_stop(ActID) ->
	?debug("----------hook_stop"),
	gen_server:cast(?SERVER, {stop_all, ActID}).

%% 玩家进入场景前
pre_enter(_SceneID, _Args, RoleSt) ->
	#role_st{role=RoleID, guild=GuildID, gpid=GuildPid} = RoleSt,
	?_check(GuildID > 0, ?ERR_SCENE_NO_GUILD),
	case ets:lookup(?ETS_GW_GUILD, GuildID) of
		[#gw_guild{field=FieldID}] ->
			[#gw_field{winner=Winner}] = ets:lookup(?ETS_GW_FIELD, FieldID),
			?_check(Winner == 0, ?ERR_GUILDWAR_ALREADY_STOP),
			{ok, #guild_memb{time=JoinTime}} = guild:get_member(GuildPid, RoleID),
			CanEnter = ut_time:seconds() - JoinTime >= cfg_game:guildwar_join(),
			?_check(CanEnter, ?ERR_GUILDWAR_JOIN_TOO_LATE),
			ok;
		[] ->
			throw(?err(?ERR_GUILDWAR_CAN_NOT_JOIN))
	end.

get_entry(_ActID, SceneID, _RoleSt=#role_st{guild=GuildID}) ->
	#gw_divide{field=FieldInfo} = gen_server:call(?SERVER, get_divide),
	Room  = maps:get(GuildID, FieldInfo, 0),
	Coord = do_get_born(SceneID, GuildID),
	[#gw_guild{group=Group}] = ets:lookup(?ETS_GW_GUILD, GuildID),
	#{room=>Room, coord=>Coord, opts=>#{group=>Group}}.

get_zone(GuildID) when GuildID > 0 ->
	#gw_divide{field=FieldInfo} = gen_server:call(?SERVER, get_divide),
	field2zone(maps:get(GuildID, FieldInfo, 0));
get_zone(_) ->
	0.

get_reborn(Actor, SceneSt) ->
	do_get_born(SceneSt#scene_st.scene, Actor#actor.guild).

%% 玩家进入场景
hook_enter(Actor, SceneSt) ->
	?debug("--------------hook_enter"),
	FieldID = maps:get(field, SceneSt#scene_st.opts),
	#actor{uid=RoleID, guild=GuildID, gname=GuildName, name=RoleName} = Actor,
	gen_server:cast(?SERVER,
		{enter, FieldID, GuildID, GuildName, RoleID, RoleName}
	),
	[#gw_field{guilds=Guilds}] = ets:lookup(?ETS_GW_FIELD, FieldID),
	[RivalID] = lists:delete(GuildID, Guilds),
	Result = game_misc:read(gw_result, #gw_result{}),
	#gw_result{winner=Winner, victory=Victory} = Result,
	case RivalID == Winner of
		true  ->
			BuffIDs = cfg_guildwar_victory_reward:against_buffs(Victory),
			buff_util:add_buffs(Actor, BuffIDs);
		false ->
			ignore
	end,
	role_event:event(Actor#actor.uid, ?EVENT_DUNGE_ENTER, {?SCENE_STYPE_GUILD_WAR, 0, 0}).

%% 玩家离开场景
hook_leave(Actor, SceneSt) ->
	FieldID = maps:get(field, SceneSt#scene_st.opts),
	#actor{uid=RoleID, guild=GuildID} = Actor,
	gen_server:cast(?SERVER, {leave, FieldID, GuildID, RoleID}).

%% 采集前
pre_collect(Actor, Collect, _SceneSt) ->
	?debug("----------------pre_collect:~w", [Collect#actor.owner]),
	IsOccupy = Actor#actor.guild == Collect#actor.owner,
	?_check(not IsOccupy, ?ERR_GUILDWAR_ALREADY_OCCUPY),
	ok.

%% 击杀玩家
hook_role_dead(Atker, _Defer, _SceneSt) ->
	gen_server:cast(?SERVER, {kill, Atker#actor.uid}).

%% 占领水晶
hook_creep_dead(Atker, Defer, SceneSt) when ?is_coll(Defer) ->
	FieldID = maps:get(field, SceneSt#scene_st.opts),
	#actor{uid=RoleID, guild=GuildID} = Atker,
	[#gw_guild{group=Group}] = ets:lookup(?ETS_GW_GUILD, GuildID),
	CreepID = case Group == 1 of
		true  ->
			% 蓝方占领
			case Defer#actor.owner > 0 of
				true  -> Defer#actor.id + 10; % 红水晶变蓝水晶
				false -> Defer#actor.id + 20  % 白水晶变蓝水晶
			end;
		false ->
			% 红方占领
			case Defer#actor.owner > 0 of
				true  -> Defer#actor.id - 10; % 蓝水晶变红水晶
				false -> Defer#actor.id + 10  % 白水晶变红水晶
			end
	end,
	Defer2 = Defer#actor{owner=GuildID, id=CreepID},
	scene_actor:set_actor(Defer2),
	NewCryst = make_cryst(Defer2, FieldID, GuildID),
	gen_server:cast(?SERVER, {occupy, FieldID, RoleID, Defer#actor.id, NewCryst}),
	RoleIDs  = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
	?notify(RoleIDs, ?MSG_GUILDWAR_OCCUPY_CRYST, [
		Defer#actor.name,
		Atker#actor.gname
	]);
hook_creep_dead(_Atker, _Defer, _SceneSt) ->
	?debug("hook_dead-----------------------:~p", [_Defer]),
	ok.

%% 玩家复活
hook_revive(Actor, _Type, _SceneSt) when ?is_role(Actor) ->
	ok;
hook_revive(_Actor, _Type, _SceneSt) ->
	ok.

is_winner(GuildID) ->
	Result = game_misc:read(gw_result, #gw_result{}),
	Result#gw_result.winner == GuildID.

give_chief_reward(_RoleSt = #role_st{role=RoleID}) ->
	Reward = cfg_game:guildwar_chief_reward2(),
	mail:send(RoleID, ?MAIL_GUILDWAR_FIRST_REWARD, Reward).

add_chief_buff(RoleSt) ->
	BuffID = cfg_game:guildwar_chief_buff(),
	buff:add([BuffID], RoleSt).

del_chief_buff(RoleSt) ->
	BuffID = cfg_game:guildwar_chief_buff(),
	buff:del([BuffID], RoleSt).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_GW_FIELD, [named_table, {keypos, #gw_field.id}]),
	ets:new(?ETS_GW_GUILD, [named_table, {keypos, #gw_guild.id}]),
	ets:new(?ETS_GW_ROLE, [named_table, {keypos, #gw_role.id}]),
	ets:new(?ETS_GW_CRYST, [named_table, {keypos, #gw_cryst.id}]),

	Fields = db:dirty_match_all(?DB_GW_FIELD),
	ets:insert(?ETS_GW_FIELD, Fields),

	Guilds = db:dirty_match_all(?DB_GW_GUILD),
	ets:insert(?ETS_GW_GUILD, Guilds),
	{ok, #state{divide=#gw_divide{}}}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
	do_dump(),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call(get_divide, _From, State) ->
	{reply, State#state.divide, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.

%% 占领水晶
do_handle_cast({occupy, FieldID, RoleID, OldCrystID, NewCryst}, State) ->
	ets:delete(?ETS_GW_CRYST, {FieldID, OldCrystID}),
	ets:insert(?ETS_GW_CRYST, NewCryst),
	ets:update_counter(?ETS_GW_ROLE, RoleID, [
		{#gw_role.occupy, 1},
		{#gw_role.score, cfg_game:guildwar_score_occupy()}
	]),
	send_battle_to_scene(FieldID, State),
	{noreply, State};

%% 击杀玩家
do_handle_cast({kill, RoleID}, State) ->
	ets:update_counter(?ETS_GW_ROLE, RoleID, [
		{#gw_role.kill, 1},
		{#gw_role.score, cfg_game:guildwar_score_kill()}
	]),
	{noreply, State};

%% 玩家离开
do_handle_cast({leave, FieldID, GuildID, RoleID}, State) ->
	update_guild_role(FieldID, GuildID, RoleID, -1),
	{noreply, State};

%% 玩家进入
do_handle_cast({enter, FieldID, GuildID, GuildName, RoleID, RoleName}, State) ->
	update_guild_role(FieldID, GuildID, RoleID, 1),
	ets:insert_new(?ETS_GW_ROLE, #gw_role{
		id    = RoleID,
		name  = RoleName,
		guild = GuildID,
		gname = GuildName,
		field = FieldID
	}),
	send_battle_to_role(FieldID, RoleID),
	{noreply, State};

%% 决出胜负
do_handle_cast({stop_one, FieldID}, State) ->
	[Field] = ets:lookup(?ETS_GW_FIELD, FieldID),
	do_stat(Field, State),
	{noreply, State};

%% 活动结束
do_handle_cast({stop_all, ActID}, State) ->
	ut_misc:cancel_timer(State#state.timer),

	Fields = ets:tab2list(?ETS_GW_FIELD),
	lists:foreach(fun
		(Field) ->
			do_stat(Field, State)
	end, Fields),

	?_if(?is_round2(ActID), do_dump()),

	{noreply, State#state{timer=?nil}};

%% 活动开始
do_handle_cast({start, ActID}, State) ->
	#cfg_activity{scene=SceneID} = cfg_activity:find(ActID),
	#gw_divide{group=Group} = State#state.divide,
	maps:fold(fun
		(FieldID, _, _) ->
			scene:create(SceneID, FieldID, #{field=>FieldID})
	end, ok, Group),
	Timer = loop_add_score(),
	{noreply, State#state{act_id=ActID, scene=SceneID, timer=Timer}};

%% 划分战区
do_handle_cast({divide, Phase, ActID, Division, Guilds}, State) ->
	ets:delete_all_objects(?ETS_GW_FIELD),
	ets:delete_all_objects(?ETS_GW_GUILD),
	ets:delete_all_objects(?ETS_GW_ROLE),
	ets:delete_all_objects(?ETS_GW_CRYST),
	maps:fold(fun
		(FieldID, [GuildID1, GuildID2], _) ->
			ZoneID = field2zone(FieldID),
			case Phase == post of
				true  ->
					#gw_guild{rank=Rank1} = lists:keyfind(GuildID1, #gw_guild.id, Guilds),
					#gw_guild{rank=Rank2} = lists:keyfind(GuildID2, #gw_guild.id, Guilds);
				false ->
					Rank1 = 0,
					Rank2 = 0
			end,
			ets:insert(?ETS_GW_GUILD, make_guild(FieldID, GuildID1, 1, Rank1)),
			ets:insert(?ETS_GW_GUILD, make_guild(FieldID, GuildID2, 2, Rank2)),
			ets:insert(?ETS_GW_FIELD, #gw_field{
				id     = FieldID,
				zoneid = ZoneID,
				guilds = [GuildID1, GuildID2],
				winner = 0
			}),
			?_if(Phase == ready, mail_predict(ActID, ZoneID, [GuildID1, GuildID2]));
		(FieldID, [GuildID], _) ->
			ZoneID = field2zone(FieldID),
			Guild  = make_guild(FieldID, GuildID, 1, FieldID*10+1),
			ets:insert(?ETS_GW_GUILD, Guild),
			Winner = ?_if(Phase == ready, GuildID, 0),
			Field  = #gw_field{
				id     = FieldID,
				zoneid = ZoneID,
				guilds = [GuildID],
				winner = Winner
			},
			ets:insert(?ETS_GW_FIELD, Field),
			case Phase == ready of
				true  ->
					mail_predict(ActID, ZoneID, [GuildID]),
					post_win(ActID, Field, Guild, ?nil),
					update_winner(ActID, FieldID, Guild);
				false ->
					ignore
			end;
		(_FieldID, [], _) ->
			ignore
	end, ok, Division#gw_divide.group),
	do_dump(),
	{noreply, State#state{divide=Division}};

do_handle_cast(reload, State) ->
	Fields = db:dirty_match_all(?DB_GW_FIELD),
	ets:insert(?ETS_GW_FIELD, Fields),

	Guilds = db:dirty_match_all(?DB_GW_GUILD),
	ets:insert(?ETS_GW_GUILD, Guilds),
	{noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.

%% 循环加公会经验
do_handle_info(loop_add_score, State) ->
	Timer = loop_add_score(),
	NTime = ut_time:seconds(),
	ets:safe_fixtable(?ETS_GW_GUILD, true),
	add_guild_score(ets:first(?ETS_GW_GUILD), NTime, State),
	ets:safe_fixtable(?ETS_GW_GUILD, false),
	{noreply, State#state{timer=Timer}};

do_handle_info(dump, State) ->
	do_dump(),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.


loop_add_score() ->
	erlang:send_after(timer:seconds(3), self(), loop_add_score).


round1_divide(Guilds, [ZoneID | RemZones], Division)
when length(Guilds) >= 3 ->
	{Guilds1, RemGuilds} = lists:split(min(4, length(Guilds)), Guilds),
	% 按战力排序
	Guilds2 = [{G, guild:get_power(G)} || G <- Guilds1],
	Guilds3 = [G || {G, _} <- lists:reverse(lists:keysort(2, Guilds2))],
	% 第1名vs第3名，第2名vs第4名
	Division2 = case Guilds3 of
		[GuildID1, GuildID2, GuildID3, GuildID4] ->
			FieldID1  = ZoneID * 10 + 1,
			Division1 = do_divide(Division, FieldID1, [GuildID1, GuildID3]),
			FieldID2  = ZoneID * 10 + 2,
			do_divide(Division1, FieldID2, [GuildID2, GuildID4]);
		[GuildID1, GuildID2, GuildID3] ->
			FieldID1  = ZoneID * 10 + 1,
			Division1 = do_divide(Division, FieldID1, [GuildID1, GuildID3]),
			FieldID2  = ZoneID * 10 + 2,
			do_divide(Division1, FieldID2, [GuildID2])
	end,
	round1_divide(RemGuilds, RemZones, Division2);
round1_divide(Guilds, [ZoneID | _], Division)
when length(Guilds) >= 1 ->
	do_divide(Division, ZoneID * 10 + 1, Guilds);
round1_divide([], _ZoneIDs, Division) ->
	Division.


round2_divide(Guilds, [ZoneID | RemZones], Division) ->
	{Guilds1, RemGuilds} = lists:partition(fun
		(G) ->
			field2zone(G#gw_guild.field) == ZoneID
	end, Guilds),
	Guilds2 = [G#gw_guild.id || G <- Guilds1],

	if
		length(Guilds2) >= 3 ->
			% 胜方vs胜方，负方vs负方
			Division2 = case Guilds2 of
				[GuildID1, GuildID2, GuildID3, GuildID4] ->
					FieldID1  = ZoneID * 10 + 1,
					Division1 = do_divide(Division, FieldID1, [GuildID1, GuildID3]),
					FieldID2  = ZoneID * 10 + 2,
					do_divide(Division1, FieldID2, [GuildID2, GuildID4]);
				[GuildID1, GuildID2, GuildID3] ->
					FieldID1  = ZoneID * 10 + 1,
					Division1 = do_divide(Division, FieldID1, [GuildID1, GuildID3]),
					FieldID2  = ZoneID * 10 + 2,
					do_divide(Division1, FieldID2, [GuildID2])
			end,
			round2_divide(RemGuilds, RemZones, Division2);
		length(Guilds2) >= 1 ->
			do_divide(Division, ZoneID * 10 + 1, Guilds2);
		true ->
			Division
	end;
round2_divide([], _ZoneIDs, Division) ->
	Division;
round2_divide(_Guilds, [], Division) ->
	Division.


round3_divide(Guilds, [ZoneID | RemZones], Division) ->
	{Guilds1, RemGuilds} = lists:splitwith(fun
		(G) ->
			field2zone(G#gw_guild.field) == ZoneID
	end, Guilds),
	Guilds2 = [G#gw_guild.id || G <- Guilds1],
	if
		length(Guilds2) >= 3 ->
			Division2 = case Guilds2 of
				[GuildID1, GuildID2, GuildID3, GuildID4] ->
					FieldID1  = ZoneID * 10 + 1,
					Division1 = do_divide(Division, FieldID1, [GuildID1, GuildID2]),
					FieldID2  = ZoneID * 10 + 2,
					do_divide(Division1, FieldID2, [GuildID3, GuildID4]);
				[GuildID1, GuildID2, GuildID3] ->
					FieldID1  = ZoneID * 10 + 1,
					Division1 = do_divide(Division, FieldID1, [GuildID1, GuildID2]),
					FieldID2  = ZoneID * 10 + 2,
					do_divide(Division1, FieldID2, [GuildID3])
			end,
			round3_divide(RemGuilds, RemZones, Division2);
		length(Guilds2) >= 1 ->
			do_divide(Division, ZoneID * 10 + 1, Guilds2);
		true ->
			Division
	end;
round3_divide([], _ZoneIDs, Division) ->
	Division;
round3_divide(_Guilds, [], Division) ->
	Division.


do_divide(Division, FieldID, GuildIDs) ->
	Division#gw_divide{
		group = maps:put(FieldID, GuildIDs, Division#gw_divide.group),
		field = lists:foldl(fun
			(GuildID, Acc) ->
				maps:put(GuildID, FieldID, Acc)
		end, Division#gw_divide.field, GuildIDs)
	}.

make_guild(FieldID, GuildID, GroupID, Rank) ->
	#gw_guild{
		id     = GuildID,
		field  = FieldID,
		group  = GroupID,
		power  = guild:get_power(GuildID),
		roles  = [],
		role   = 0,
		score  = 0,
		rank   = Rank
	}.

do_stat(Field, State) ->
	#state{act_id=ActID, scene=SceneID} = State,
	#gw_field{id=FieldID, winner=Winner} = Field,
	case Winner == 0 of
		true  ->
			do_guild_stat(ActID, FieldID),
			do_role_stat(ActID, FieldID);
		false ->
			ignore
	end,
	scene:destroy(SceneID, FieldID).

do_guild_stat(ActID, FieldID) ->
	[Field]  = ets:lookup(?ETS_GW_FIELD, FieldID),
	[GuildID1, GuildID2] = Field#gw_field.guilds,
	[Guild1] = ets:lookup(?ETS_GW_GUILD, GuildID1),
	[Guild2] = ets:lookup(?ETS_GW_GUILD, GuildID2),
	case Guild1#gw_guild.score == Guild2#gw_guild.score of
		true  ->
			case Guild1#gw_guild.power >= Guild2#gw_guild.power of
				true  ->
					do_guild_stat3(ActID, Field, Guild1, Guild2);
				false ->
					do_guild_stat3(ActID, Field, Guild2, Guild1)
			end;
		false ->
			case Guild1#gw_guild.score > Guild2#gw_guild.score of
				true  ->
					do_guild_stat3(ActID, Field, Guild1, Guild2);
				false ->
					do_guild_stat3(ActID, Field, Guild2, Guild1)
			end
	end.

do_guild_stat3(ActID, Field, WinGuild, LoseGuild) ->
	#gw_field{id=FieldID} = Field,
	WinGuild2  = WinGuild#gw_guild{rank = FieldID*10+1},
	LoseGuild2 = LoseGuild#gw_guild{rank = FieldID*10+2},
	ets:insert(?ETS_GW_GUILD, WinGuild2),
	ets:insert(?ETS_GW_GUILD, LoseGuild2),
	Field2 = Field#gw_field{winner=WinGuild#gw_guild.id},
	ets:insert(?ETS_GW_FIELD, Field2),
	lists:foreach(fun
		(RoleID) ->
			ets:update_counter(?ETS_GW_ROLE, RoleID, [
				{#gw_role.score,cfg_game:guildwar_score_winner()}
			])
	end, WinGuild#gw_guild.roles),
	post_win(ActID, Field2, WinGuild2, LoseGuild2),
	post_lose(ActID, Field2, WinGuild2, LoseGuild2),
	update_winner(ActID, FieldID, WinGuild).

post_win(_ActID, Field, WinGuild, LoseGuild) ->
	#gw_field{zoneid=ZoneID} = Field,
	lists:foreach(fun
		(RoleID) ->
			role_event:event(RoleID, ?EVENT_GWAR_WIN, ZoneID)
	end, WinGuild#gw_guild.roles),
	case LoseGuild == ?nil of
		true  ->
			mail:batch_send(
				WinGuild#gw_guild.roles,
				?MAIL_GUILDWAR_WIN_REWARD,
				cfg_guildwar_guild_reward:win(ZoneID),
				[""]
			);
		false ->
			mail:batch_send(
				WinGuild#gw_guild.roles,
				?MAIL_GUILDWAR_WIN_REWARD,
				cfg_guildwar_guild_reward:win(ZoneID),
				[guild:get_name(LoseGuild#gw_guild.id)]
			)
	end,
	ok.

post_lose(_ActID, Field, WinGuild, LoseGuild) ->
	#gw_field{zoneid=ZoneID} = Field,
	% 失败奖励
	mail:batch_send(
		LoseGuild#gw_guild.roles,
		?MAIL_GUILDWAR_LOSE_REWARD,
		cfg_guildwar_guild_reward:lose(ZoneID),
		[guild:get_name(WinGuild#gw_guild.id)]
	),
	ok.

update_winner(ActID, FieldID, WinGuild) ->
	case ?is_round2(ActID) andalso FieldID == 11 of
		true  -> do_update_winner(WinGuild);
		false -> ignore
	end.

do_update_winner(WinGuild) ->
	Result = #gw_result{winner=Loser} = game_misc:read(gw_result, #gw_result{}),
	case Loser == WinGuild#gw_guild.id of
		true  ->
			Victory = Result#gw_result.victory + 1,
			Breakup = 0;
		false ->
			Victory = 1,
			Breakup = Result#gw_result.victory
	end,
	game_misc:write(gw_result, Result#gw_result{
		winner  = WinGuild#gw_guild.id,
		victory = Victory,
		v_allot = 0,
		breakup = Breakup,
		b_allot = 0
	}),
	{ok, [WinInfo]} = guild:get_data(WinGuild#gw_guild.id, [?DB_GUILD_INFO]),
	MembIDs = [M#guild_memb.id || M <- WinInfo#guild_info.membs],
	mail:batch_send(MembIDs, ?MAIL_GUILDWAR_FIRST_RANK),

	WinChief = lists:keyfind(
		?GUILD_POST_CHIEF, #guild_memb.post, WinInfo#guild_info.membs
	),
	role:route(WinChief#guild_memb.id, ?MODULE, give_chief_reward, ?nil, ?nil),

	?notify(?MSG_GUILDWAR_FIRST_RANK, [
		WinInfo#guild_info.name,
		WinChief#guild_memb.name
	]),

	case Loser > 0 andalso Loser /= WinGuild#gw_guild.id of
		true  ->
			{ok, [LoseGuild]} = guild:get_data(Loser, [?DB_GUILD_INFO]),
			LoseChief = lists:keyfind(
				?GUILD_POST_CHIEF, #guild_memb.post, LoseGuild#guild_info.membs
			),
			role:route(
				LoseChief#guild_memb.id, ?MODULE, del_chief_buff, ?nil, ?nil
			),
			lists:foreach(fun
				(RoleID) ->
					role_event:event(RoleID, ?EVENT_GWAR_BREAK, Breakup)
			end, WinGuild#gw_guild.roles);
		false ->
			ignore
	end.

do_role_stat(_ActID, FieldID) ->
	[Field] = ets:lookup(?ETS_GW_FIELD, FieldID),
	#gw_field{zoneid=ZoneID, winner=Winner} = Field,
	Roles1 = ets:match_object(?ETS_GW_ROLE, #gw_role{field=FieldID, _='_'}),
	Roles2 = lists:keysort(#gw_role.score, Roles1),
	{_, RankList} = lists:foldl(fun
		(Role, {Rank, AccRoles}) ->
			Rewards = cfg_guildwar_role_reward:find(ZoneID, Rank),
			mail:send(
				Role#gw_role.id,
				?MAIL_GUILDWAR_ROLE_REWARD,
				Rewards,
				[Role#gw_role.occupy, Role#gw_role.kill, Rank]
			),
			Ranking = #p_gw_ranking{
				rank      = Rank,
				role_id   = Role#gw_role.id,
				role_name = Role#gw_role.name,
				gname     = Role#gw_role.gname,
				kill      = Role#gw_role.kill,
				occupy    = Role#gw_role.occupy,
				contrib   = proplists:get_value(?ITEM_CONTRIB, Rewards, 0)
			},
			{Rank-1, [Ranking | AccRoles]}
	end, {length(Roles2), []}, Roles2),
	RankList2 = lists:sublist(lists:keysort(#p_gw_ranking.rank, RankList), 10),
	lists:foreach(fun
		(#gw_role{id=RoleID, guild=GuildID}) ->
			MyRank = lists:keyfind(RoleID, #p_gw_ranking.role_id, RankList),
			?ucast(RoleID, #m_guild_war_ranklist_toc{
				is_win   = Winner == GuildID,
				ranklist = RankList2,
				my_rank  = ?_if(MyRank == false, ?nil, MyRank)
			})
	end, Roles1).


update_guild_role(_FieldID, GuildID, RoleID, Incr) ->
	[Guild] = ets:lookup(?ETS_GW_GUILD, GuildID),
	ets:insert(?ETS_GW_GUILD, Guild#gw_guild{
		role  = Guild#gw_guild.role + Incr,
		roles = [RoleID | lists:delete(RoleID, Guild#gw_guild.roles)]
	}).

add_guild_score('$end_of_table', _NTime, _State) ->
    ok;
add_guild_score(GuildID, NTime, State) ->
	[Guild] = ets:lookup(?ETS_GW_GUILD, GuildID),
	[Field] = ets:lookup(?ETS_GW_FIELD, Guild#gw_guild.field),
	case Field#gw_field.winner > 0 of
		true  ->
			ignore;
		false ->
			Crysts = get_occupied_crysts(GuildID),
			Score  = lists:foldl(fun
				(Cryst, Acc) ->
					DiffTime = NTime - Cryst#gw_cryst.time,
					Acc + cfg_guildwar_add_score:find(DiffTime)
			end, 0, Crysts),
			#gw_guild{field=FieldID, score=OldScore} = Guild,
			NewScore = OldScore + Score,
			% ?debug("add_score--------------:~p", [{GuildID, NewScore}]),
			ets:insert(?ETS_GW_GUILD, Guild#gw_guild{score=NewScore}),
			guild_score_notify(FieldID, GuildID, OldScore, NewScore, State),
			?_if(
				NewScore >= cfg_game:guildwar_score_max(),
				gen_server:cast(?SERVER, {stop_one, Guild#gw_guild.field})
			)
	end,
	send_battle_to_scene(Guild#gw_guild.field, State),
    add_guild_score(ets:next(?ETS_GW_GUILD, GuildID), NTime, State).

guild_score_notify(FieldID, GuildID, OldScore, NewScore, State) ->
	ScoreList = cfg_game:guildwar_score_notify(),
	Score = find_notify_score(ScoreList, OldScore, NewScore),
	case Score > 0 of
		true  ->
			ScenePid = scene:get_pid(State#state.scene, FieldID),
			RoleIDs = scene:get_actids(ScenePid, ?ACTOR_TYPE_ROLE),
			?notify(RoleIDs, ?MSG_GUILDWAR_GUILD_SCORE, [
				guild:get_name(GuildID),
				Score
			]);
		false ->
			ignore
	end.

find_notify_score([Score | T], OldScore, NewScore) ->
	case OldScore < Score andalso Score =< NewScore of
		true  -> Score;
		false -> find_notify_score(T, OldScore, NewScore)
	end;
find_notify_score([], _OldScore, _NewScore) ->
	0.

send_battle_to_scene(FieldID, State) ->
	scene:bcast(State#state.scene, FieldID, make_battle_toc(FieldID)).

send_battle_to_role(FieldID, RoleID) ->
	?ucast(RoleID, make_battle_toc(FieldID)).

make_battle_toc(FieldID) ->
	[Field] = ets:lookup(?ETS_GW_FIELD, FieldID),
	Battle  = lists:map(fun
		(GuildID) ->
			[Guild] = ets:lookup(?ETS_GW_GUILD, GuildID),
			Crysts  = get_occupied_crysts(GuildID),
			#p_gw_battle{
				guild  = Guild#gw_guild.id,
				group  = Guild#gw_guild.group,
				role   = Guild#gw_guild.role,
				score  = Guild#gw_guild.score,
				crysts = [element(2, Cryst#gw_cryst.id) || Cryst <- Crysts],
				coord  = lists:nth(Guild#gw_guild.group, scene_actor_30301:get_born())
			}
	end, Field#gw_field.guilds),
	#m_guild_war_battle_toc{battle=Battle}.

do_get_born(SceneID, GuildID) ->
	[Guild] = ets:lookup(?ETS_GW_GUILD, GuildID),
	Crysts  = get_occupied_crysts(GuildID),
	#gw_guild{group=Group} = Guild,
	case Crysts == [] of
		true  ->
			lists:nth(Group, scene_config:born(SceneID));
		false ->
			#gw_cryst{coord=Coord} = ut_rand:choose(Crysts),
			Coord
	end.

get_occupied_crysts(GuildID) ->
	Pattern = #gw_cryst{owner=GuildID, _='_'},
	ets:match_object(?ETS_GW_CRYST, Pattern).

make_cryst(Actor, FieldID, Owner) ->
	#gw_cryst{
		id    = {FieldID, Actor#actor.id},
		owner = Owner,
		time  = ut_time:seconds(),
		coord = Actor#actor.coord
	}.

field2zone(FieldID) ->
	FieldID div 10.

zone_name(ZoneID) ->
	proplists:get_value(ZoneID, cfg_game:guildwar_zone_name()).

mail_predict(ActID, ZoneID, GuildIDs) ->
	if
		?is_round1(ActID) ->
			mail_predict(ActID, ?MAIL_GUILDWAR_ROUND1_PREDICT, ZoneID, GuildIDs);
		?is_round2(ActID) ->
			mail_predict(ActID, ?MAIL_GUILDWAR_ROUND2_PREDICT, ZoneID, GuildIDs);
		true ->
			ignore
	end.

mail_predict(ActID, MailID, ZoneID, GuildIDs) ->
	{_, Time} = ut_time:seconds_to_datetime( activity:stime(ActID) ),
	StartTime = ut_time:time_to_string(Time),
	ZoneName  = zone_name(ZoneID),
	lists:foreach(fun
		(GuildID) ->
			{ok, [GuildInfo]} = guild:get_data(GuildID, [?DB_GUILD_INFO]),
			#guild_info{name=GuildName, membs=Membs} = GuildInfo,
			MembIDs = [M#guild_memb.id || M <- Membs],
			mail:batch_send(MembIDs, MailID, [], [StartTime, GuildName, ZoneName])
	end, GuildIDs).

mail_upgrade(ZoneID, GuildID) ->
	MembIDs  = game_role:get_guild_roles(GuildID),
	ZoneName = zone_name(ZoneID),
	mail:batch_send(MembIDs, ?MAIL_GUILDWAR_UPGRADE, [], [ZoneName]).

mail_degrade(ZoneID, GuildID) ->
	MembIDs  = game_role:get_guild_roles(GuildID),
	ZoneName = zone_name(ZoneID),
	mail:batch_send(MembIDs, ?MAIL_GUILDWAR_DEGRADE, [], [ZoneName]).

do_dump() ->
	Fields = ets:tab2list(?ETS_GW_FIELD),
	lists:foreach(fun
		(F) ->
			db:dirty_write(?DB_GW_FIELD, F)
	end, Fields),

	Guilds = ets:tab2list(?ETS_GW_GUILD),
	lists:foreach(fun
		(G) ->
			db:dirty_write(?DB_GW_GUILD, G)
	end, Guilds).
