%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(timeboss_server).

-behaviour(gen_server).

-include("activity.hrl").
-include("attr.hrl").
-include("btree.hrl").
-include("creep.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("timeboss.hrl").
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

-export([hook_ready/1]).
-export([hook_start/1, hook_start/2]).
-export([post_divide/0]).
-export([timeboss_entry/2]).
-export([get_bosses/1]).

-export([hook_loopsec/2]).
-export([pre_enter/2]).
-export([hook_enter/2]).
-export([hook_leave/2]).
-export([hook_shield_break/3]).
-export([hook_creep_dead/3]).
-export([dice_end/2]).
-export([dice_do/2]).
-export([send_ranking/2]).
-export([send_boxinfo/2]).
-export([open_box/2]).
-export([is_tired/2]).
-export([anger/2]).
-export([calc_belong/0]).

-export([care_boss/3]).
-export([get_entry/3]).
-export([give_reward/2]).

-define(SERVER, ?MODULE).

-define(ACT_REBORN, 11102).

-record(state, {init}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

hook_ready(ActID) ->
	% ?debug("hook_ready---------------------:~w", [_ActID]),
	?_if(ActID == ?ACT_REBORN, gen_server:cast(?SERVER, ready)).

hook_start(ActID) ->
	% ?debug("hook_start---------------------:~w", [_ActID]),
	?_if(ActID == ?ACT_REBORN, gen_server:cast(?SERVER, reborn)).

hook_start(?SERVER_TYPE_LOCAL, ?ACT_REBORN) ->
	lists:foreach(fun
		(BossID) ->
			CfgBoss = cfg_timeboss:find(BossID),
			#cfg_timeboss{name=BossName, scene=SceneID} = CfgBoss,
			#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
			?notify(
				?MSG_TIMEBOSS_REBORN,
				[BossName, SceneName, BossID]
			)
	end, cfg_timeboss:bosses());
hook_start(_ServType, _ActID) ->
	ignore.

post_divide() ->
	?debug("post_divide-----------"),
	gen_server:cast(?SERVER, divide).


%% 跨服调用
timeboss_entry(SUID, SceneID) ->
	?debug("timeboss_entry-----------------:~w", [{SUID, SceneID}]),
	case ets:lookup(?ETS_TIMEBOSS_ENTRY, {SceneID,SUID}) of
		[#timeboss_entry{room=RoomID}] ->
			#{room=>RoomID};
		[] ->
			#{}
	end.

get_bosses(SUID1) ->
	Entries = ets:tab2list(?ETS_TIMEBOSS_ENTRY),
	lists:filtermap(fun
		(#timeboss_entry{key={SceneID,SUID2}, room=RoomID}) when SUID1 == SUID2 ->
			case ets:lookup(?ETS_TIMEBOSS, {SceneID,RoomID}) of
				[Boss] ->
					{true, Boss};
				[] ->
					false
			end;
		(_) ->
			false
	end, Entries).

%% -------------------- 场景进程 --------------------
hook_loopsec(Secs, SceneSt) when Secs rem 3 == 0 ->
	case scene_actor:get_actids(?ACTOR_TYPE_CREEP) of
		[ActorID] ->
			Actor  = scene_actor:get_actor(ActorID),
			IsBoss = Actor /= ?nil andalso ?is_timeboss(Actor),
			?_if(IsBoss, update_ranking(Actor, SceneSt));
		_ ->
			ignore
	end;
hook_loopsec(_Secs, _SceneSt) ->
	ignore.

pre_enter(Actor, SceneSt) ->
	case is_tired(Actor, SceneSt) of
		true  ->
			#scene_st{scene=SceneID, room=RoomID} = SceneSt,
			case ets:lookup(?ETS_TIMEBOSS, {SceneID,RoomID}) of
				[#timeboss{box=BoxID, owners=Owners}] when BoxID > 0 ->
					CanOpen = can_open(Actor#actor.suid, Owners),
					?_check(CanOpen, ?ERR_TIMEBOSS_NO_TIMES);
				_ ->
					throw(?err(?ERR_TIMEBOSS_NO_TIMES))
			end;
		false ->
			ok
	end.

hook_enter(Actor, SceneSt) ->
	#scene_st{scene=SceneID, room=RoomID} = SceneSt,
	% send_ranking(Actor#actor.uid, SceneSt),
	gen_server:cast(?SERVER, {enter, SceneID, RoomID, Actor#actor.uid}).

hook_leave(Actor, SceneSt) ->
	#scene_st{scene=SceneID, room=RoomID} = SceneSt,
	gen_server:cast(?SERVER, {leave, SceneID, RoomID, Actor#actor.uid}).

%% 击破护盾
hook_shield_break(_Atker, Defer, _SceneSt) ->
	Last  = cfg_game:timeboss_dice_last(),
	ETime = ut_time:seconds() + Last,
	set_dice_info(#timeboss_dice{
		dice_etime  = ETime,
		dice_result = #{},
		max_score   = 0,
		owner_id    = 0,
		owner_name  = ""
	}),
	% ?debug("hook_shield_break-----------------: ~w", [{ut_time:datetime(), ut_time:seconds_to_datetime(ETime)}]),
	?bcast(
		scene_actor:get_actids(?ACTOR_TYPE_ROLE),
		#m_timeboss_dice_toc{etime=ETime}
	),
	Msg = {route, ?MODULE, dice_end, Defer#actor.id},
	erlang:send_after(timer:seconds(Last), self(), Msg).

dice_end(BossID, _SceneSt) ->
	% ?debug("dice_end---------------------~w", [{BossID, get_dice_info()}]),
	case clr_dice_info() of
		#timeboss_dice{owner_id=OwnerID, owner_name=OwnerName} when OwnerID > 0 ->
			#cfg_timeboss{name=Name, shield=Reward} = cfg_timeboss:find(BossID),
			?notify(
				scene_actor:get_actids(?ACTOR_TYPE_ROLE),
				?MSG_TIMEBOSS_SHIELD,
				[{role,OwnerID,OwnerName}]
			),
			case scene_actor:get_actor(OwnerID) of
				?nil  ->
					mail:send(OwnerID, ?MAIL_TIMEBOSS_SHIELD_REWARD, Reward, [Name]);
				Actor ->
					% ?debug("-------------------dice reward: ~w", [Reward]),
					Msg = {Reward,?LOG_TIMEBOSS_SHIELD},
					role:route(Actor#actor.pid, ?MODULE, give_reward, Msg)
			end;
		_ ->
			ignore
	end.

%% 掷骰子
dice_do({RoleID, RoleName, Score}, _SceneSt) ->
	case get_dice_info() of
		?nil ->
			ignore;
		Dice ->
			case maps:is_key(RoleID, Dice#timeboss_dice.dice_result) of
				true  -> ignore;
				false -> dice_do2(RoleID, RoleName, Score, Dice)
			end
	end.

%% 击杀boss
hook_creep_dead(_Atker, Defer, SceneSt) when ?is_timeboss(Defer) ->
	#scene_st{scene=SceneID, room=RoomID} = SceneSt,
	#actor{id=BossID, level=BossLv, name=BossName, born=BossCoord} = Defer,
	Ranking = update_ranking(Defer, SceneSt),
	Reborn  = next_reborn(),
	give_kill_reward(Defer, SceneSt),
	OwnNum = cfg_game:timeboss_box_owner(),
	Owners = lists:map(fun
		(RItem) ->
			{
				game_uid:guid2suid(RItem#p_timeboss_ranking.captain),
				RItem#p_timeboss_ranking.captain,
				RItem#p_timeboss_ranking.name
			}
	end, lists:sublist(Ranking, OwnNum)),

	#cfg_timeboss_box{coord={X,Y}} = cfg_timeboss:box(BossID),
	Creeps = [
		% 墓碑
		{1099999, BossCoord, #{
			name   => io_lib:format("~w~ts ~ts", [BossLv, cfg_lang:find(level), BossName]),
			exargs => #{"boss_reborn"=>Reborn}
		}},
		% 宝箱
		{1099998, #p_coord{x=X,y=Y}, #{
			owners => Owners,
			exargs => #{"boss_reborn"=>Reborn}
		}}
	],
	[TombID, BoxID] = creep_agent:add(Creeps, SceneSt),
	% ?debug("hook_creep_dead------------------------:~w", [{TombID, BoxID}]),

	Msg = {dead, SceneID, RoomID, TombID, BoxID, Reborn, Owners},
	gen_server:cast(?SERVER, Msg),

	{SUID, RoleID, RoleName} = hd(Owners),
	#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
	cluster:notify(
		?CROSS_RULE_24_8,
		?MSG_TIMEBOSS_KILL,
		[SceneName, BossName, SUID, {role,RoleID,RoleName}]
	);
hook_creep_dead(_Atker, _Defer, _SceneSt) ->
	ignore.


send_ranking({RoleID, Captain}, _SceneSt) ->
	Ranking = get_ranking(),
	RankKey = ?_if(Captain > 0, Captain, RoleID),
	case lists:keyfind(RankKey, #p_timeboss_ranking.captain, Ranking) of
		false ->
			MyRank = 0,
			MyDmg  = 0;
		RItem ->
			MyRank = RItem#p_timeboss_ranking.rank,
			MyDmg  = RItem#p_timeboss_ranking.damage
	end,
	?ucast(RoleID, #m_timeboss_ranking_toc{
		ranking = lists:sublist(Ranking, 5),
		my_rank = MyRank,
		my_dmg  = MyDmg
	}).

send_boxinfo(RoleID, SceneSt) ->
	#scene_st{scene=SceneID, room=RoomID} = SceneSt,
	case ets:lookup(?ETS_TIMEBOSS, {SceneID,RoomID}) of
		[Boss] when Boss#timeboss.box > 0->
			#timeboss{boss=BossID, owners=Owners, opened=Opened} = Boss,
			#cfg_timeboss_box{times=MaxTimes} = cfg_timeboss:box(BossID),
			Actor = scene_actor:get_actor(RoleID),
			?ucast(RoleID, #m_timeboss_boxinfo_toc{
				summoner = [Name || {_,_,Name} <- Owners],
				suids    = [SUID || {SUID,_,_} <- Owners],
				can_open = can_open(Actor#actor.suid, Owners),
				remain   = MaxTimes - maps:get(RoleID, Opened, 0),
				boss_id  = BossID
			});
		_ ->
			ignore
	end.

open_box({RoleID, SUID, BossID1, Times1, Type, Reward}, SceneSt) ->
	#scene_st{scene=SceneID, room=RoomID} = SceneSt,
	case ets:lookup(?ETS_TIMEBOSS, {SceneID,RoomID}) of
		[Boss] when Boss#timeboss.box > 0 ->
			#timeboss{boss=BossID2, owners=Owners, opened=Opened} = Boss,
			?_check(BossID1 == BossID2, ?ERR_GAME_BAD_ARGS),
			?_check(can_open(SUID, Owners), ?ERR_TIMEBOSS_NOT_SAME),
			Times2 = maps:get(RoleID, Opened, 0),
			#cfg_timeboss_box{times=MaxTimes} = cfg_timeboss:box(BossID1),
			?_check(Times2 < MaxTimes, ?ERR_TIMEBOSS_MAX_BOXTIMES),
			% ?debug("---------------:~w", [Times2]),
			?_check(Times1 == Times2+1, ?ERR_GAME_BAD_ARGS),
			gen_server:cast(?SERVER, {open, RoleID, SceneID, RoomID}),
			Reward1 = game_util:normalize_gain(RoleID, Reward),
			Reward2 = [{ID,N} || {ID,N,_} <- Reward1],
			?ucast(RoleID, #m_timeboss_boxopen_toc{
				type   = Type,
				reward = maps:from_list(Reward2)
			}),
			Actor = scene_actor:get_actor(RoleID),
			#cfg_timeboss{name=BossName} = cfg_timeboss:find(BossID1),
			reward_notify(Actor, BossName, Reward1, ?MSG_TIMEBOSS_BOX);
		_ ->
			?err(?ERR_GAME_BAD_ARGS)
	end.

is_tired(Actor, _SceneSt) ->
	CurTimes1 = buff_util:get_value(Actor, ?BUFF_ID_TIMEBOSS_JOIN_TIRED, 0),
	MaxTimes1 = cfg_game:timeboss_join_times(),
	CurTimes2 = buff_util:get_value(Actor, ?BUFF_ID_TIMEBOSS_RANK_TIRED, 0),
	MaxTimes2 = cfg_game:timeboss_rank_times(),
	CurTimes1 >= MaxTimes1 andalso CurTimes2 >= MaxTimes2.


anger(Actor, SceneSt) ->
	Result = creep_ai:anger(Actor, SceneSt),
	case Result == ?SUCCESS of
		true  ->
			#actor{id=BossID, name=BossName, attr=Attr} = Actor,
			HpPer = ?_attr(Attr,?ATTR_HP) / ?_attr(Attr,?ATTR_HPMAX),
			LowHp = case HpPer =< 0.3 of
				true  -> 30;
				false -> 70
			end,
			cluster:notify(
				?CROSS_RULE_24_8,
				?MSG_TIMEBOSS_LOWHP,
				[BossName, LowHp, BossID]
			);
		false ->
			ignore
	end,
	Result.

calc_belong() ->
	Ranking = get_ranking(),
	[RoleID || #p_timeboss_ranking{captain=RoleID} <- Ranking].

%% -------------------- 玩家进程 --------------------
%% 关注/取消关注
care_boss(RoleID, BossID, Op) ->
	Cross = cluster:get_cross(?CROSS_RULE_24_8),
	SUID  = game_env:get_suid(),
	Msg   = {care, Op, BossID, SUID, RoleID},
	gen_server:cast({?SERVER, Cross}, Msg).

get_entry(_ActID, SceneID, _RoleSt) ->
	% ?debug("get_entry------------------:~w", [SceneID]),
	SUID = game_env:get_suid(),
	cluster:rpc_call_cross(
		?CROSS_RULE_24_8, ?MODULE, timeboss_entry, [SUID,SceneID]
	).

give_reward({Reward, LogID}, RoleSt) ->
	% ?debug("give_reward----------------~w", [{Reward, LogID}]),
	role_bag:gain(Reward, LogID, RoleSt).


%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_TIMEBOSS, [named_table, {keypos,#timeboss.key}]),
	ets:new(?ETS_TIMEBOSS_ENTRY, [named_table, {keypos,#timeboss_entry.key}]),
	{ok, #state{init=false}}.

handle_call(Req, From, State) ->
	?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(started, State) ->
	lists:foreach(fun
		(SceneID) ->
			RoomNum = cfg_timeboss:room(SceneID),
			lists:foreach(fun
				(RoomID) ->
					% ?debug("create scene: ~w", [{SceneID, RoomID}]),
					scene:create(SceneID, RoomID)
			end, lists:seq(1, RoomNum))
	end, cfg_timeboss:scenes()),

	case State#state.init of
		true  -> ignore;
		false -> [do_init(BossID) || BossID <- cfg_timeboss:bosses()]
	end,
	{noreply, State#state{init=true}};

handle_cast(Msg, State) ->
	?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
	?try_handle_cast(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.

do_handle_cast({open, RoleID, SceneID, RoomID}, State) ->
	case ets:lookup(?ETS_TIMEBOSS, {SceneID,RoomID}) of
		[Boss=#timeboss{opened=Opened}] ->
			ets:insert(?ETS_TIMEBOSS, Boss#timeboss{
				opened = ut_misc:maps_increase(RoleID, 1, Opened)
			});
		[] ->
			ignore
	end,
	{noreply, State};

do_handle_cast({enter, SceneID, RoomID, _RoleID}, State) ->
	ets:update_counter(?ETS_TIMEBOSS, {SceneID,RoomID}, {#timeboss.role,1}),
	{noreply, State};

do_handle_cast({leave, SceneID, RoomID, _RoleID}, State) ->
	ets:update_counter(?ETS_TIMEBOSS, {SceneID,RoomID}, {#timeboss.role,-1}),
	{noreply, State};

do_handle_cast(ready, State) ->
	Bosses = ets:tab2list(?ETS_TIMEBOSS),
	lists:foreach(fun
		(Boss) ->
			?_if(Boss#timeboss.tomb > 0, do_remind(Boss))
	end, Bosses),
	{noreply, State};

do_handle_cast(reborn, State) ->
	Bosses = ets:tab2list(?ETS_TIMEBOSS),
	lists:foreach(fun
		(Boss) ->
			?_if(Boss#timeboss.tomb > 0, do_reborn(Boss))
	end, Bosses),
	{noreply, State};

do_handle_cast({dead, SceneID, RoomID, TombID, BoxID, RebSec, Owners}, State) ->
	case ets:lookup(?ETS_TIMEBOSS, {SceneID,RoomID}) of
		[Boss] ->
			ets:insert(?ETS_TIMEBOSS, Boss#timeboss{
				born   = RebSec,
				tomb   = TombID,
				box    = BoxID,
				owners = Owners
			});
		[] ->
			ignore
	end,
	{noreply, State};

do_handle_cast(divide, State) ->
	ets:delete_all_objects(?ETS_TIMEBOSS_ENTRY),
	SUIDs = ut_rand:shuffle(cluster:get_locals(suid, ?CROSS_RULE_24_8)),
	lists:foreach(fun
		(SceneID) ->
			RoomNum = cfg_timeboss:room(SceneID),
			allot_room(RoomNum, SUIDs, SceneID)
	end, cfg_timeboss:scenes()),
	{noreply, State};

%% 关注 Boss
do_handle_cast({care, 1, BossID, SUID, RoleID}, State) ->
	#cfg_timeboss{scene=SceneID} = cfg_timeboss:find(BossID),
	case ets:lookup(?ETS_TIMEBOSS_ENTRY, {SceneID,SUID}) of
		[#timeboss_entry{room=RoomID}] ->
			case ets:lookup(?ETS_TIMEBOSS, {SceneID,RoomID}) of
				[Boss] ->
					case lists:member(RoleID, Boss#timeboss.care) of
						true  ->
							ignore;
						false ->
							Care2 = [RoleID | Boss#timeboss.care],
							ets:insert(?ETS_TIMEBOSS, Boss#timeboss{care=Care2})
					end;
				[] ->
					ignore
			end;
		[] ->
			ignore
	end,
	{noreply, State};

%% 取消关注
do_handle_cast({care, 2, BossID, SUID, RoleID}, State) ->
	#cfg_timeboss{scene=SceneID} = cfg_timeboss:find(BossID),
	case ets:lookup(?ETS_TIMEBOSS_ENTRY, {SceneID,SUID}) of
		[#timeboss_entry{room=RoomID}] ->
			case ets:lookup(?ETS_TIMEBOSS, {SceneID,RoomID}) of
				[Boss] ->
					Care2 = lists:delete(RoleID, Boss#timeboss.care),
					ets:insert(?ETS_TIMEBOSS, Boss#timeboss{care=Care2});
				[] ->
					ignore
			end;
		[] ->
			ignore
	end,
	{noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.


do_init(BossID) ->
	CfgBoss = #cfg_timeboss{room=RoomNum} = cfg_timeboss:find(BossID),
	[do_summon(RoomID, CfgBoss, []) || RoomID <- lists:seq(1, RoomNum)].

do_remind(Boss) ->
	#timeboss{boss=BossID, care=Cared} = Boss,
	lists:foreach(fun
		(RoleID) ->
			?ucast(RoleID, #m_timeboss_remind_toc{id=BossID})
	end, Cared).

do_reborn(Boss) ->
	#timeboss{key={_,RoomID}, boss=BossID, tomb=TombID, box=BoxID} = Boss,
	% ?debug("do_reborn---------------------:~w", [BossID]),
	% 删除墓碑和宝箱
	CfgBoss = #cfg_timeboss{scene=SceneID} = cfg_timeboss:find(BossID),
	creep:del(SceneID, RoomID, ?MAIN_LINE, [TombID, BoxID]),
	% 召唤boss
	do_summon(RoomID, CfgBoss, Boss#timeboss.care).


do_summon(RoomID, CfgBoss, Cared) ->
	#cfg_timeboss{id=BossID, type=Type, scene=SceneID, coord={X,Y}} = CfgBoss,
	Coord = #p_coord{x=X, y=Y},
	% ?debug("do_summon---------------:~w", [{SceneID, RoomID, BossID}]),
	creep:add(SceneID, RoomID, ?MAIN_LINE, [{BossID,Coord}]),
	ets:insert(?ETS_TIMEBOSS, #timeboss{
		key  = {SceneID,RoomID},
		boss = BossID,
		type = Type,
		care = Cared
	}).

allot_room(RoomNum, SUIDs, SceneID) ->
	allot_room2(RoomNum, SUIDs, SceneID, 1).

allot_room2(RoomNum, SUIDs, SceneID, RoomID) ->
	NodeLen = 8 div RoomNum,
	case length(SUIDs) >= NodeLen of
		true  ->
			{SUIDs1, SUIDs2} = lists:split(NodeLen, SUIDs),
			allot_room3(SceneID, RoomID, SUIDs1),
			allot_room2(RoomNum, SUIDs2, SceneID, RoomID+1);
		false ->
			allot_room3(SceneID, RoomID, SUIDs)
	end.

allot_room3(SceneID, RoomID, SUIDs) ->
	lists:foreach(fun
		(SUID) ->
			ets:insert(?ETS_TIMEBOSS_ENTRY, #timeboss_entry{
				key  = {SceneID, SUID},
				room = RoomID
			})
	end, SUIDs).

-define(k_dice, {?MODULE, dice}).
get_dice_info() ->
	get(?k_dice).

set_dice_info(DiceInfo) ->
	put(?k_dice, DiceInfo).

clr_dice_info() ->
	erase(?k_dice).

-define(k_ranking, {?MODULE, ranking}).
get_ranking() ->
	get(?k_ranking).

set_ranking(Ranking) ->
	put(?k_ranking, Ranking).

update_ranking(Defer, _SceneSt) ->
	#actor{attr=Attr, exargs=ExArgs} = Defer,
	HpMax   = ?_attr(Attr, ?ATTR_HPMAX),
	Threats = fight_threat:sort(hybrid, maps:get(join_roles, ExArgs, #{})),

	{_, SortRoles0} = lists:foldl(fun
		({SortID, Damage}, {Rank, Acc}) ->
    		{Rank+1, [{SortID, Damage, Rank}|Acc]}
    end, {1, []}, Threats),
	SortRoles = lists:reverse(SortRoles0),
	Ranking   = lists:map(fun(
		{SortID, DmgVal, Rank}) ->
	    	case SortID of
	    		{role, RID} ->
	    			IsTeam  = false,
	    			Captain = RID,
	    			TeamID  = 0,
	            	{ok, #role_cache{name=Name}} = role:get_cache(RID);
	            {team, TID} ->
	            	IsTeam  = true,
	            	Captain = get_captain(TID),
	    			TeamID  = TID,
	            	{ok, #role_cache{name=Name}} = role:get_cache(Captain)
	        end,
	    	#p_timeboss_ranking{
				rank    = Rank,
				is_team = IsTeam,
				captain = Captain,
				name    = Name,
				damage  = round(?PER_10000 * DmgVal / HpMax),
				team    = TeamID
	    	}
    end, lists:sublist(SortRoles, 100)),
	set_ranking(Ranking),
	% RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
	% [send_ranking(RoleID, SceneSt) || RoleID <- RoleIDs],
	Ranking.

get_captain(TeamID) ->
	MembIDs = scene_team:get_membs(TeamID),
	get_captain2(MembIDs).

get_captain2([MembID | T]) ->
	case scene_actor:get_actor(MembID) of
		Actor when Actor#actor.captain > 0 ->
			Actor#actor.captain;
		_ ->
			get_captain2(T)
	end;
get_captain2([]) ->
	0.

give_kill_reward(Defer, SceneSt) ->
	lists:foreach(fun
		(RItem) ->
			#p_timeboss_ranking{rank=Rank, is_team=IsTeam, captain=ID, team=TeamID} = RItem,
			case IsTeam of
				true  ->
					MembIDs = scene_team:get_membs(TeamID),
					lists:foreach(fun
						(MembID) ->
							give_kill_reward2(MembID, Defer, Rank, SceneSt)
					end, MembIDs);
				false ->
					give_kill_reward2(ID, Defer, Rank, SceneSt)
			end
	end, get_ranking()).

give_kill_reward2(AtkUID, Defer, Rank, SceneSt) ->
	case scene_actor:get_actor(AtkUID) of
		?nil  ->
			ignore;
		Actor ->
			case give_rank_reward(Actor, Defer, Rank, SceneSt) of
				ok  -> ignore;
				max -> give_join_reward(Actor, Defer, SceneSt)
			end
	end.

give_rank_reward(Actor, Defer, Rank, SceneSt) ->
	BuffID = ?BUFF_ID_TIMEBOSS_RANK_TIRED,
	Times  = buff_util:get_value(Actor, BuffID, 0),
	case Times >= cfg_game:timeboss_rank_times() of
		true  ->
			max;
		false ->
			Reward = calc_reward(Actor, Defer, Rank),
			case Reward == [] of
				true  ->
					max;
				false ->
					do_add_tired(Actor, BuffID, 1, SceneSt),
					mail:send(
						Actor#actor.uid,
						?MAIL_TIMEBOSS_RANK_REWARD,
						Reward,
						[Defer#actor.name, Rank]
					),
					reward_notify(Actor, Defer#actor.name, Reward, ?MSG_TIMEBOSS_DROP),
					ok
			end
	end.

give_join_reward(Actor, Defer, SceneSt) ->
	BuffID = ?BUFF_ID_TIMEBOSS_JOIN_TIRED,
	Times  = buff_util:get_value(Actor, BuffID, 0),
	case Times >= cfg_game:timeboss_rank_times() of
		true  ->
			max;
		false ->
			do_add_tired(Actor, BuffID, 1, SceneSt),
			Reward = calc_reward(Actor, Defer, 999),
			mail:send(
				Actor#actor.uid,
				?MAIL_TIMEBOSS_JOIN_REWARD,
				Reward,
				[Defer#actor.name]
			),
			reward_notify(Actor, Defer#actor.name, Reward, ?MSG_TIMEBOSS_DROP)
	end.

%% 增加疲劳值
do_add_tired(Actor, BuffID, TiredAdd, _SceneSt) ->
	case buff_util:get_buff(Actor, BuffID) of
		?nil ->
			do_add_tired1(Actor, BuffID, TiredAdd);
		Buff ->
			#p_buff{value=Tired, etime=ETime1} = Buff,
			ETime2 = ut_time:midnight(),
			case ETime1 == ETime2 of
				true  ->
					case Tired >= max_tired(BuffID) of
						true  -> ignore;
						false -> do_add_tired2(Actor, BuffID, Tired+TiredAdd, ETime2)
					end;
				false ->
					do_add_tired2(Actor, BuffID, TiredAdd, ETime2)
			end
	end.

max_tired(?BUFF_ID_TIMEBOSS_RANK_TIRED) ->
	cfg_game:timeboss_rank_times();
max_tired(?BUFF_ID_TIMEBOSS_JOIN_TIRED) ->
	cfg_game:timeboss_join_times().

do_add_tired1(Actor, BuffID, Tired) ->
	ETime = ut_time:midnight(),
	do_add_tired2(Actor, BuffID, Tired, ETime).

do_add_tired2(Actor, BuffID, Tired, ETime) ->
	?debug("do_add_tired2--------------:~w", [{BuffID, Tired, ut_time:seconds_to_datetime(ETime)}]),
	Opts = #{value=>Tired, etime=>ETime, cover=>true},
	buff_util:add_buffs(Actor, [{BuffID, Opts}]).

calc_reward(Atker, Defer, Rank) ->
	#actor{uid=AtkUID, level=RoleLv} = Atker,
	#actor{id=BossID, level=BossLv} = Defer,
	case cfg_timeboss_rank_reward:find(BossID, Rank) of
		{Drops, Rare1, Rare2} ->
			Reward1 = creep_drop:calc(RoleLv, Drops),
			Reward2 = case RoleLv < BossLv of
				true  -> creep_drop:calc(RoleLv, Rare1);
				false -> creep_drop:calc(RoleLv, Rare2)
			end,
			Reward3 = Reward1 ++ Reward2,
			Reward4 = game_util:normalize_gain(AtkUID, Reward3),
			Reward4;
		_ ->
			[]
	end.

reward_notify(Atker, BossName, Reward, MsgNo) ->
	#actor{uid=AtkUID, name=AtkName, scene=SceneID} = Atker,

	Reward2 = lists:filtermap(fun
		({ItemID, Num, Opts}) ->
		    #cfg_item{notify=IsNotify} = cfg_item:find(ItemID),
			case IsNotify of
				false -> false;
				true  -> {true, item_util:new_item(ItemID, Num, Opts)}
			end
	end, Reward),
	lists:foreach(fun
		(Item) ->
			CacheID = cluster:rpc_call_center(item_cache, add_cache, [Item]),
			game_logger:add_log(
				timeboss_drop_log,
				#p_timeboss_dropped{
					time        = ut_time:seconds(),
					scene       = SceneID,
					picker_id   = AtkUID,
					picker_name = AtkName,
					boss        = BossName,
					item_id     = Item#p_item.id,
					cache_id    = CacheID
				}
			),
			case MsgNo of
				?MSG_TIMEBOSS_DROP ->
					cluster:notify(
						?CROSS_RULE_24_8,
						?MSG_TIMEBOSS_DROP,
						[
							{role,AtkUID,AtkName},
							BossName,
							{pitem,#{CacheID=>Item#p_item.id}}
						]
					);
				?MSG_TIMEBOSS_BOX  ->
					cluster:notify(
						?CROSS_RULE_24_8,
						?MSG_TIMEBOSS_BOX,
						[
							{role,AtkUID,AtkName},
							{pitem,#{CacheID=>Item#p_item.id}}
						]
					)
			end

	end, Reward2).

next_reborn() ->
	activity:stime(?ACT_REBORN).

dice_do2(RoleID, RoleName, Score, Dice) ->
	#timeboss_dice{dice_result=Result, max_score=MaxScore, owner_name=OwnerName} = Dice,
	?notify(
		scene_actor:get_actids(?ACTOR_TYPE_ROLE),
		?MSG_TIMEBOSS_DICE,
		[{role,RoleID,RoleName}, Score]
	),
	case Score > MaxScore of
		true  ->
			set_dice_info(Dice#timeboss_dice{
				dice_result = maps:put(RoleID, Score, Result),
				max_score   = Score,
				owner_id    = RoleID,
				owner_name  = RoleName
			}),
			?ucast(RoleID, #m_timeboss_dicing_toc{
				score   = Score,
				highest = Score,
				owner   = RoleName
			}),
			?bcast(
				scene_actor:get_actids(?ACTOR_TYPE_ROLE),
				RoleID,
				#m_timeboss_dicing_toc{
					score   = 0,
					highest = Score,
					owner   = RoleName
				}
			);
		false ->
			set_dice_info(Dice#timeboss_dice{
				dice_result = maps:put(RoleID, Score, Result)
			}),
			?ucast(RoleID, #m_timeboss_dicing_toc{
				score   = Score,
				highest = MaxScore,
				owner   = OwnerName
			})
	end.

can_open(SUID, Owners) ->
	lists:any(fun
		({OwnerSUID, _, _}) ->
			cluster:is_same(SUID, OwnerSUID)
	end, Owners).
