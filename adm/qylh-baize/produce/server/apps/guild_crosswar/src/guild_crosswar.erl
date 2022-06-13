%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_crosswar).

-behaviour(gen_server).

-include_lib("eunit/include/eunit.hrl").

-include("activity.hrl").
-include("attr.hrl").
-include("btree.hrl").
-include("table.hrl").
-include("cgw.hrl").
-include("game.hrl").
-include("guild.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("msgno.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([check_reqs/1]).
-export([hook_start/1]).
-export([hook_stop/1]).
-export([hook_init/1]).
-export([decide_join_guilds/0]).
-export([hook_enter/2]).
-export([hook_fight/4]).
-export([hook_creep_dead/3]).
-export([hook_role_dead/3]).
-export([pre_collect/3]).
-export([finish_collect/3]).
-export([get_entry/3, get_entry/2]).
-export([pre_enter/3, pre_enter/2]).
-export([get_reborn/2]).
-export([can_attack_statue/1]).
-export([get_period/0]).
-export([get_guilds/0]).
-export([book/2]).
-export([get_match/0]).
-export([anger/2]).
-export([send_weekly_reward/3]).
-export([send_monthly_reward/2]).
-export([send_round_reward/7]).
-export([send_merge_reward/1]).
-export([hook_divide/5]).
-export([hook_chime/1]).
-export([sort/0]).

-define(SERVER, ?MODULE).
-define(k_cgw_score_retain, k_cgw_score_retain).
-record(state, {period, round}).


%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_period() ->
    Cross = cluster:get_cross(?CROSS_RULE_24_8),
    {ok, State} = gen_server:call({?SERVER,Cross}, get_state),
    ?debug("------:~w", [State]),
    State#state.period.



get_guilds() ->
    case cluster:is_local() of
        true  ->
            cluster:rpc_call_cross(?CROSS_RULE_24_8, ?MODULE, get_guilds, []);
        false ->
            ets:tab2list(?ETS_CGW_GUILDS)
    end.

book(GuildID, RivalID) ->
    Cross = cluster:get_cross(?CROSS_RULE_24_8),
    gen_server:call({?SERVER,Cross}, {book_it,GuildID,RivalID}).

get_match() ->
    case cluster:is_local() of
        true  ->
            cluster:rpc_call_cross(?CROSS_RULE_24_8, ?MODULE, get_match, []);
        false ->
            ets:tab2list(?ETS_CGW_BATTLE)
    end.

check_reqs(_ActID) ->

  Date = {Year, Month, _} = ut_time:date(),

  LastMon = ut_time:last_weekday_of_month(Date, 1),
  LastSun = ut_time:last_weekday_of_month(Date, 7),

  LastDay = calendar:last_day_of_the_month(Year, Month),
  LastDate0 = {Year,Month,LastDay},
  FirstDate = {Year,Month,1},
  FirstWeekDay = ut_time:day_of_week(FirstDate),
  LastWeekDay = ut_time:day_of_week(LastDate0),
  EndDateList = ?_if(ut_time:is_same_week(LastMon, LastSun),[],[ ut_time:add_days(LastSun,Day) || Day <- lists:seq(1,LastWeekDay)]), %% 月尾跨月日期
  StartDateList = ?_if(FirstWeekDay =/= 1,[FirstDate] ++[ ut_time:add_days(FirstDate,Day) || Day <- lists:seq(1,7 - FirstWeekDay)] ,[]), %% 月头跨月日期
  DateList = EndDateList ++ StartDateList,
  Res = case lists:member(Date,DateList) of true -> false; false -> true end,
  ?debug("~p~n",[{DateList,Res}]),
  Res.

hook_start(ActID) ->
%%    Date = ut_time:date(),
%%    LastSat = ut_time:last_weekday_of_month(Date, 6),
%%    LastSun = ut_time:last_weekday_of_month(Date, 7),
%%    ?debug("hook_start: ~w", [{ActID, LastSun, LastSun, ut_time:is_same_week(LastSat, LastSun)}]),
  #cfg_activity{reqs=Reqs} = cfg_activity:find(ActID),
  Period = proplists:get_value(period, Reqs),
  %% 2020.7.17 zhengjy 策划说每周都重新分配参赛的公会？被挤掉的公会保留分数，下次上榜的时候接着保留的分数继续参加
%%    case check_reqs(_ActId) orelse Period == divide of
%%        true  ->
  case Period of
    divide ->
      gen_server:cast(?SERVER, join);
    book   ->
      gen_server:cast(?SERVER, book);
    battle ->
      gen_server:cast(?SERVER, {battle_start,ActID});
    _ ->
      ignore
  end.
%%        false ->
%%            case Period == book andalso cluster:is_local() andalso game_env:get_opened_days() >= 20 of
%%                true  ->
%%                    Reward = cfg_game:cgw_divide_reward(),
%%                    lists:foreach(fun
%%                        (#p_guild_base{id=GuildID}) ->
%%                            MembIDs = guild:get_membids(GuildID),
%%                            mail:batch_send(MembIDs, 1000024, Reward)
%%                    end, guild:get_guilds(2)),
%%                    ok;
%%                false ->
%%                    ignore
%%            end
%%    end.

hook_stop(ActID) ->
    case check_reqs(ActID) of
        true  ->
            #cfg_activity{reqs=Reqs} = cfg_activity:find(ActID),
            Period = proplists:get_value(period, Reqs),
            case Period of
                divide ->
                    gen_server:cast(?SERVER, divide);
                book   ->
                    gen_server:cast(?SERVER, match);
                battle ->
                    gen_server:cast(?SERVER, {act_stop,ActID});
                _ ->
                    ignore
            end;
        false ->
            ignore
    end.

decide_join_guilds() ->
    [#cgw_guild{
        id     = G#p_guild_base.id,
        name   = G#p_guild_base.name,
        power  = G#p_guild_base.power,
        chief  = G#p_guild_base.chief,
        book1  = 0,
        book2  = 0,
        cost   = 0,
        group  = 0,
        rival1 = 0,
        rival2 = 0,
        rank   = 0,
        time   = 0,
        battle = #{},
        book_time = 0
    } || G <- guild:get_guilds(2)].

hook_init(_SceneSt) ->
    set_cryst_num(2).

can_attack_statue(_SceneSt) ->
    get_cryst_num() < 2.


hook_enter(Actor, SceneSt) ->
    #actor{uid=RoleID, guild=GuildID} = Actor,
    gen_server:cast(?SERVER, {enter,RoleID,GuildID,SceneSt#scene_st.room}).

hook_fight(Atker, Defer, _DmgVal, _SceneSt) when ?is_monst(Defer) ->
    Now = ut_time:seconds(),
    case get_injure_time(Defer#actor.id) of
        ?nil ->
            set_injure_time(Defer#actor.id, Now),
            notify_to_scene(?MSG_CGW_MONTHLY_FIRST_ATTACK, [Atker#actor.name, Defer#actor.name]);
        Last ->
            case Now - Last >= 3 of
                true  ->
                    set_injure_time(Defer#actor.id, Now),
                    notify_to_scene(?CGW_GROUP_DEFER, ?MSG_CGW_MONTHLY_CREEP_INJURE, [Defer#actor.name]);
                false ->
                    ignore
            end
    end;
hook_fight(_Atker, _Defer, _DmgVal, _SceneSt) ->
    ok.


hook_creep_dead(Atker, Defer, SceneSt) when ?is_cgw_crystal(Defer) ->
    ?debug("hook_creep_dead----------------------:~w", [{Defer#actor.uid, Defer#actor.id}]),
    set_cryst_num(get_cryst_num() - 1),
    CrystNum = get_cryst_num(),
    {RepairID, _} = lists:keyfind(Defer#actor.id, 2, cfg_game:cgw_repair()),
    % 采集物
    Creeps = [{RepairID, Defer#actor.coord, #{
        group  => ?CGW_GROUP_DEFER,
        exargs => #{owner=>Defer#actor.id}
    }}],
    creep_agent:add(Creeps, SceneSt),
    notify_to_scene(?MSG_CGW_MONTHLY_CRYST_DEAD, [2-CrystNum, Atker#actor.name]),
    ok;
hook_creep_dead(Atker, Defer, SceneSt) when ?is_cgw_statue(Defer) ->
    ?debug("hook_creep_dead----------------------:~w", [Defer#actor.id]),
    #scene_st{scene=SceneID, room=RoomID} = SceneSt,
    gen_server:cast(?SERVER, {battle_stop,SceneID,RoomID,Atker#actor.guild}),
    ok;
hook_creep_dead(_Atker, _Defer, _SceneSt) ->
    ?debug("hook_creep_dead----------------------:~w", [_Defer#actor.id]),
    ok.

hook_role_dead(Atker, Defer, _SceneSt) ->
    % 连杀
    AtkOldDKill = get_double_kill(Atker#actor.uid),
    AtkNewDKill = ?_if(AtkOldDKill == ?nil, 1, AtkOldDKill+1),
    set_double_kill(Atker#actor.uid, AtkNewDKill),
    case (AtkNewDKill rem 3 == 0) orelse (AtkNewDKill rem 5 == 0) of
        true  ->
            notify_to_scene(?MSG_CGW_MONTHLY_DOUBLE_KILL, [
                Atker#actor.gname,
                Atker#actor.name,
                AtkNewDKill
            ]);
        false ->
            ignore
    end,

    DefOldDKill = get_double_kill(Defer#actor.uid),
    set_double_kill(Defer#actor.uid, 0),
    case DefOldDKill == ?nil orelse DefOldDKill < 3 of
        true  ->
            ignore;
        false ->
            notify_to_scene(?MSG_CGW_MONTHLY_BREAK_KILL, [
                Defer#actor.gname,
                Defer#actor.name,
                Atker#actor.name,
                DefOldDKill
            ])
    end.

pre_collect(Actor, Collect, _SceneSt) ->
    ?_check(Actor#actor.group == Collect#actor.group, ?ERR_CGW_CANNOT_COLLECT).

finish_collect(Actor, Collect, SceneSt) ->
    case get_cryst_num() < 2 andalso maps:find(owner, Collect#actor.exargs) of
        {ok, CrystID} ->
            WorldLv = world_level:get_level(),
            {AttrID, AttCoef, DefCoef} = cfg_cgw_creep:find(CrystID, WorldLv),
            #p_coord{x=X, y=Y} = Collect#actor.coord,
            Creeps = [{CrystID,X,Y,AttrID,worldlv,AttCoef,DefCoef,#{
                group  => ?CGW_GROUP_DEFER,
                exargs => #{repair=>true}
            }}],
            creep_agent:add(Creeps, SceneSt),
            set_cryst_num(get_cryst_num() + 1),
            notify_to_scene(?MSG_CGW_MONTHLY_CRYST_REPAIR, [Actor#actor.name]),
            ok;
        _ ->
            ignore
    end.

get_entry(_ActID, SceneID, _RoleSt=#role_st{guild=GuildID}) ->
    ?debug("get_entry:~w", [GuildID]),
    case GuildID > 0 of
        true  ->
            case cluster:rpc_call_cross(?CROSS_RULE_24_8, ?MODULE, get_entry, [SceneID, GuildID]) of
                {ok, Entry} ->
                    Entry;
                Error ->
                    throw(Error)
            end;
        false ->
            throw(?err(?ERR_CGW_CANNOT_ENTER))
    end.

get_entry(SceneID, GuildID) ->
    case ets:lookup(?ETS_CGW_GUILDS, GuildID) of
        [#cgw_guild{group=GroupID, battle=Battle}] ->
            {ok, #state{round=Round}} = gen_server:call(?SERVER, get_state),
            RoomID = maps:get(Round, Battle),
            [#cgw_battle{winner=Winner}] = ets:lookup(?ETS_CGW_BATTLE, RoomID),
            case Winner > 0 of
                true  ->
                    ?err(?ERR_CGW_BATTLE_STOP);
                false ->
                    Nth   = ?_if(GroupID == ?CGW_GROUP_ATKER, 1, 2),
                    Coord = lists:nth(Nth, scene_config:born(SceneID)),
                    {ok, #{room=>RoomID, opts=>#{group=>GroupID}, coord=>Coord}}
            end;
        [] ->
            ?err(?ERR_CGW_CANNOT_ENTER)
    end.

pre_enter(_SceneID, _Args, RoleSt) ->
    ?_check(RoleSt#role_st.guild > 0, ?ERR_SCENE_NO_GUILD).

pre_enter(Actor, SceneSt) ->
    #scene_st{room=RoomID} = SceneSt,
    case ets:lookup(?ETS_CGW_BATTLE, RoomID) of
        [#cgw_battle{atk_id=AtkID, def_id=DefID}] ->
            if
                Actor#actor.guild == AtkID ->
                    ?_check(DefID > 0, ?ERR_CGW_BATTLE_MISS);
                Actor#actor.guild == DefID ->
                    ?_check(AtkID > 0, ?ERR_CGW_BATTLE_MISS);
                true ->
                    throw(?ERR_CGW_CANNOT_ENTER)
            end;
        [] ->
            throw(?ERR_CGW_CANNOT_ENTER)
    end.

get_reborn(Actor, SceneSt) ->
    Nth = ?_if(Actor#actor.group == ?CGW_GROUP_ATKER, 1, 2),
    lists:nth(Nth, scene_config:reborn(SceneSt#scene_st.scene)).

anger(Actor, SceneSt) ->
    Result = creep_ai:anger(Actor, SceneSt),
    case Result == ?SUCCESS of
        true  ->
            #actor{attr=Attr} = Actor,
            HpPer = ?_attr(Attr,?ATTR_HP) / ?_attr(Attr,?ATTR_HPMAX),
            LowHp = case HpPer =< 0.3 of
                true  -> 30;
                false -> 60
            end,
            notify_to_scene(?MSG_CGW_MONTHLY_LOW_HP, [LowHp]);
        false ->
            ignore
    end,
    Result.

send_weekly_reward(IsWin, GuildID, Rank) ->
    WorldLv = world_level:get_level(),
    {_, WinReward, _, LoseReward} = cfg_cgw_weekly_reward:find(Rank, WorldLv),
    {ok, #guild_memb{id=ChiefID}} = guild:get_chief(GuildID),
    case IsWin of
        true  -> mail:send(ChiefID, 1000016, WinReward, []);
        false -> mail:send(ChiefID, 1000017, LoseReward, [])
    end.

send_monthly_reward(GuildID, Rank) ->
    ?debug("send_monthly_reward: ~w", [{GuildID, Rank}]),
    WorldLv = world_level:get_level(),
    Reward  = cfg_cgw_monthly_reward:find(Rank, WorldLv),
    {ok, #guild_memb{id=ChiefID}} = guild:get_chief(GuildID),
    mail:send(ChiefID, 1000018, Reward, [Rank]).

send_round_reward(Round, GuildID, Rank, RoleIDs0, IsWin, IsMiss, IsAtker) ->
    ?debug("send_round_reward: ~w", [{Round, GuildID, Rank, RoleIDs0, IsWin, IsMiss}]),
    WorldLv = world_level:get_level(),
    {WinScore, _, LoseScore, _} = cfg_cgw_weekly_reward:find(Rank, WorldLv),
    {WinReward, LoseReward} = cfg_cgw_round_reward:find(WorldLv),

    case IsMiss of
        true  ->
            MailID  = ?_if(Round == 1, 1000019, 1000020),
            RoleIDs = guild:get_membids(GuildID),
            mail:batch_send(RoleIDs, MailID, WinReward);
        false ->
            lists:foreach(fun
                (RoleID) ->
                    ?ucast(RoleID, #m_cgw_result_toc{result=IsWin})
            end, RoleIDs0),
            case IsWin of
                true  ->
                    WinScore2 = ?_if(IsAtker, WinScore, 0),
                    mail:batch_send(RoleIDs0, 1000021, WinReward, [WinScore2]);
                false ->
                    LoseScore2 = ?_if(IsAtker, LoseScore, 0),
                    mail:batch_send(RoleIDs0, 1000022, LoseReward, [LoseScore2])
            end
    end.

%% ====== 跨服分组处理
hook_divide(LocalNode, _OldGrp, _NewGrp, OldCross, NewCross) ->
    ?debug("guild_crosswar hook_divide"),
    try
        {ok, Data} = cluster:gen_call_node(OldCross, guild_crosswar, {divide_old,LocalNode}),
        ok = cluster:gen_call_node(NewCross, guild_crosswar, {divide_new,LocalNode,Data})
    catch Class:Reason:Stacktrace ->
        ?stacktrace(Class, Reason, Stacktrace)
    end,
    ok.

send_merge_reward(GuildID) ->
    MembIDs = guild:get_membids(GuildID),
    mail:batch_send(MembIDs, 1000023, cfg_game:cgw_merge_reward()),
    ok.

hook_chime(Hour) ->
    case Hour == 0 andalso ut_time:day_of_month() == 1 of
        true  -> gen_server:cast(?SERVER, clear);
        false -> ignore
    end.

sort() ->
    gen_server:cast(?SERVER, sort).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
    process_flag(trap_exit, true),
    ets:new(?ETS_CGW_GUILDS, [named_table, public, {keypos,#cgw_guild.id}]),
    ets:new(?ETS_CGW_BATTLE, [named_table, public, {keypos,#cgw_battle.id}]),
	{ok, #state{period=?CGW_PERIOD_TRUCE, round=0}}.

handle_call(get_state, _From, State) ->
    {reply, {ok,State}, State};


handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(started, State) ->
    ets:insert(?ETS_CGW_GUILDS, game_misc:read(cgw_guilds, [])),
    ets:insert(?ETS_CGW_BATTLE, game_misc:read(cgw_battle, [])),
    {noreply, State};

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
do_handle_call({book_it,GuildID,RivalID}, _From, State) ->
    Reply = case State#state.period == ?CGW_PERIOD_BOOK of
        true  ->
            case ets:lookup(?ETS_CGW_GUILDS, GuildID) of
                [Guild] ->
                    ok;
                [] ->
                    Guild = ?nil,
                    throw(?err(?ERR_CGW_CANNOT_ENTER))
            end,
            #cgw_guild{book1=Book1, score=Score, rival1=MyRival1, group=Group1} = Guild,
            ?_check(MyRival1 == 0, ?ERR_CGW_HAD_BOOK),
            ?_check(
                Book1 < cfg_game:cgw_book_times1(),
                ?ERR_CGW_MAX_BOOK_TIMES1
            ),

            case ets:lookup(?ETS_CGW_GUILDS, RivalID) of
                [Rival] ->
                    ok;
                [] ->
                    Rival = ?nil,
                    throw(?err(?ERR_CGW_RIVAL_NOT_FOUND))
            end,
            #cgw_guild{book2=Book2, rival2=PeerRival2, group=Group2} = Rival,
            ?_check(Group1 /= Group2, ?ERR_CGW_SAME_GROUP),
            ?_check(
                Book2 < cfg_game:cgw_book_times2(),
                ?ERR_CGW_MAX_BOOK_TIMES2
            ),
            CostList  = cfg_game:cgw_book_score(),
            NeedScore = proplists:get_value(Book2+1, CostList),
            ?_check(Score >= NeedScore, ?ERR_CGW_SCORE_NOT_ENOUGH),

            ets:insert(?ETS_CGW_GUILDS, Guild#cgw_guild{cost=NeedScore, rival1=RivalID, book1=Book1+1}),
            ets:insert(?ETS_CGW_GUILDS, Rival#cgw_guild{rival2=GuildID, book_time=ut_time:seconds(), book2=Book2+1}),

            case PeerRival2 > 0 of
                true  ->
                    [PeerRival] = ets:lookup(?ETS_CGW_GUILDS, PeerRival2),
                    ets:insert(?ETS_CGW_GUILDS, PeerRival#cgw_guild{cost=0, rival1=0});
                false ->
                    ignore
            end,
            ok;
        false ->
            ?err(?ERR_CGW_NOT_BOOK_PERIOD)
    end,
    {reply, Reply, State};

do_handle_call({divide_old, Node}, _From, State) ->
    GuildList = lists:filter(fun
        (#cgw_guild{id=GuildID}) ->
            SUID = game_uid:guid2suid(GuildID),
            case cluster:is_same(SUID, Node#cls_node.suid) of
                true  ->
                    ets:delete(?ETS_CGW_GUILDS, GuildID),
                    true;
                false ->
                    false
            end
    end, ets:tab2list(?ETS_CGW_GUILDS)),
    ?debug("divide_old: ~p", [GuildList]),
    {reply, {ok, term_to_binary(GuildList)}, State};

do_handle_call({divide_new, Node, Data}, _From, State) ->
    GuildList = binary_to_term(Data),
    ?debug("divide_new: ~p", [GuildList]),
    Date = ut_time:seconds_to_date(Node#cls_node.otime),
    case ut_time:diff_days(Date, ut_time:today()) + 1 >= 20 of
        true  ->
            ets:insert(?ETS_CGW_GUILDS, GuildList);
        false ->
            lists:foreach(fun
                (#cgw_guild{id=GuildID}) ->
                    SUID = game_uid:guid2suid(GuildID),
                    cluster:rpc_call_node(SUID, ?MODULE, send_merge_reward, [GuildID])
            end, GuildList)
    end,
    do_sort(),
    %% 如果超过了16个就重新分
    case ets:info(?ETS_CGW_GUILDS, size) > 16 of
        true ->
            gen_server:cast(self(), join);
        false ->
            igore
    end,
    {reply, ok, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.


do_handle_cast({enter,RoleID,GuildID,RoomID}, State) ->
    [Battle] = ets:lookup(?ETS_CGW_BATTLE, RoomID),
    ets:insert(?ETS_CGW_BATTLE, Battle#cgw_battle{
        joined = lists:usort([{RoleID,GuildID} | Battle#cgw_battle.joined])
    }),
    {noreply, State};

%% 活动结束
do_handle_cast({act_stop, ActID}, State) ->
    ?debug("act_stop: ~w", [ActID]),

    #cfg_activity{scene=SceneID} = cfg_activity:find(ActID),
    lists:foreach(fun
        (#cgw_battle{id=RoomID}) ->
            scene:destroy(SceneID, RoomID)
    end, ets:tab2list(?ETS_CGW_BATTLE)),

    % 每轮结算
    do_round_settle(State#state.round),

    case State#state.round of
        1 ->
            % 交换攻守方
            lists:foreach(fun
                (G) ->
                    Group = ?_if(
                        G#cgw_guild.group == ?CGW_GROUP_ATKER,
                        ?CGW_GROUP_DEFER,
                        ?CGW_GROUP_ATKER
                    ),
                    ets:insert(?ETS_CGW_GUILDS, G#cgw_guild{group=Group})
            end, ets:tab2list(?ETS_CGW_GUILDS));
        2 ->
            do_sort(),
            do_weekly_settle(),
            do_dump(),
            Date = ut_time:date(),
            ?_if(
                Date == ut_time:last_weekday_of_month(Date, 7),
                do_monthly_settle()
            );
        _ ->
            ignore
    end,

    case State#state.round == 2 of
        true  -> {noreply, State#state{period=?CGW_PERIOD_TRUCE, round=0}};
        false -> {noreply, State}
    end;

%% 战斗结束
do_handle_cast({battle_stop, SceneID, RoomID, Winner}, State) ->
    ?debug("battle_stop, room=~w, winner=~w", [RoomID, Winner]),
    [B] = ets:lookup(?ETS_CGW_BATTLE, RoomID),
    B2  = B#cgw_battle{winner=Winner},
    ets:insert(?ETS_CGW_BATTLE, B2),
    scene:destroy(SceneID, RoomID),
    do_send_round_reward(State#state.round, Winner, B2),
    {noreply, State};

%% 战斗开始
do_handle_cast({battle_start, ActID}, State) ->
    ?debug("battle_start: ~w", [ActID]),
    NewRound = State#state.round + 1,
    MsgNo = case NewRound of
        1 -> ?MSG_CGW_ROUND1;
        2 -> ?MSG_CGW_ROUND2;
        _ -> 0
    end,
    ?_if(MsgNo > 0, cluster:notify(?CROSS_RULE_24_8, MsgNo, [])),
    #cfg_activity{scene=SceneID} = cfg_activity:find(ActID),
    lists:foreach(fun
        (B) ->
            #cgw_battle{id=RoomID, round=Round, atk_id=AtkID, def_id=DefID} = B,
            case Round == NewRound of
                true  ->
                    if
                        AtkID == 0 ->
                            ets:insert(?ETS_CGW_BATTLE, B#cgw_battle{winner=DefID}),
                            do_send_round_reward2(NewRound, DefID, 0, [], true, true, false);
                        DefID == 0 ->
                            ets:insert(?ETS_CGW_BATTLE, B#cgw_battle{winner=AtkID}),
                            do_send_round_reward2(NewRound, AtkID, 0, [], true, true, true);
                        true ->
                            {ok, ScenePid} = scene:create(SceneID, RoomID),
                            ?debug("create scene, scene=~w, room=~w", [SceneID, RoomID]),
                            ets:insert(?ETS_CGW_BATTLE, B#cgw_battle{scene=ScenePid}),
                            WorldLv = world_level:get_level(),
                            Creeps  = lists:map(fun
                                ({ID,X,Y}) ->
                                    {AttrID, AttCoef, DefCoef} = cfg_cgw_creep:find(ID, WorldLv),
                                    {ID,X,Y,AttrID,worldlv,AttCoef,DefCoef,#{group=>?CGW_GROUP_DEFER}}
                            end, cfg_game:cgw_creeps()),
                            creep:add(Creeps, ScenePid)
                    end;
                false ->
                    ignore
            end
    end, ets:tab2list(?ETS_CGW_BATTLE)),
    {noreply, State#state{period=?CGW_PERIOD_BATTLE, round=NewRound}};

%% 匹配对手
do_handle_cast(match, State) ->
    ets:delete_all_objects(?ETS_CGW_BATTLE),
    {{Match1,Atker1,Defer1}, {Match2,Atker2,Defer2}} = do_match(ets:tab2list(?ETS_CGW_GUILDS)),

    ?debug("match1================:~p", [{Match1, Atker1, Defer1}]),
    ?debug("match2================:~p", [{Match2, Atker2, Defer2}]),

    ID1 = match_book(Match1, 1, 11),
    match_unbook(ut_rand:shuffle(Atker1), ut_rand:shuffle(Defer1), 1, ID1),

    ID2 = match_book(Match2, 2, 21),
    match_unbook(ut_rand:shuffle(Atker2), ut_rand:shuffle(Defer2), 2, ID2),

    {noreply, State#state{period=?CGW_PERIOD_BATTLE}};

%% 约战阶段
do_handle_cast(book, State) ->
    {noreply, State#state{period=?CGW_PERIOD_BOOK}};

%% 划分攻方、守方
do_handle_cast(divide, State) ->
    JoinNum = ets:info(?ETS_CGW_GUILDS, size),
    if
        JoinNum == 1 ->
            ignore;
        JoinNum rem 2 == 0 ->
            HeadNum = ut_math:ceil(JoinNum / 4),
            TailNum = ut_math:floor(JoinNum / 4),
            do_divide(JoinNum div 2, HeadNum, TailNum);
        true ->
            HeadNum = ut_math:ceil((JoinNum+1) / 4),
            TailNum = ut_math:floor((JoinNum+1) / 4),
            do_divide((JoinNum+1) div 2, HeadNum, TailNum)
    end,
    ?debug("divide: ~p", [ets:tab2list(?ETS_CGW_GUILDS)]),
    {noreply, State};

%% 决定参赛公会
do_handle_cast(join, State) ->
    %% 2020.7.17 zhengjy 不再等清除榜单再重新分配了，直接重新分配，下榜的记录分数，等到下次上榜接着上次的分数参加
%%    case ets:info(?ETS_CGW_GUILDS, size) of
%%        0 ->
    LastList = ets:tab2list(?ETS_CGW_GUILDS),
    ScoreBase = cfg_game:cgw_base_score(),
    RetainScoreMap =
        case erlang:get(?k_cgw_score_retain) of
            ?nil ->
                #{};
            Map ->
                Map
        end,
    F =
        fun(GuildId) ->
            case lists:keyfind(GuildId, #cgw_guild.id, LastList) of
                #cgw_guild{score = S} ->
                    %% 保留继续上榜的分数
                    S;
                _ ->
                    %% 从历史分数map获取，没有就取初始分数
                    maps:get(GuildId, RetainScoreMap, ScoreBase)
            end
        end,
    %% 重新分配之前先删掉所有的数据
    ets:delete_all_objects(?ETS_CGW_GUILDS),
    lists:foreach(
        fun(Node) ->
            Guilds =
                case cluster:rpc_call_node(Node, ?MODULE, decide_join_guilds, []) of
                    Guilds0 when is_list(Guilds0) ->
                        Guilds0;
                    _ ->
                        %% 不知道什么原因rpc失败，记录一下日志
                        ?error("guild_crosswar decide_join_guilds error : ~p~n", [{Node}]),
                        []
                end,
            lists:foreach(
                fun(G) ->
                    CgwGuild =
                        case lists:keyfind(G#cgw_guild.id, #cgw_guild.id, LastList) of
                            #cgw_guild{} = CgwGuild0 ->
                                CgwGuild0;
                            false ->
                                G#cgw_guild{score= F(G#cgw_guild.id) }
                        end,
                    ets:insert(?ETS_CGW_GUILDS, CgwGuild)
                end,Guilds)
%%                        ets:insert(?ETS_CGW_GUILDS, [G#cgw_guild{score= F(G#cgw_guild.id) } || G <- Guilds])
        end, cluster:get_locals(?CROSS_RULE_24_8)),
    do_sort(),
    RetainScoreMap2 =
        lists:foldl(
            fun(#cgw_guild{id = Id, score = ScoreSave}, MapAcc) ->
                maps:put(Id, ScoreSave, MapAcc)
            end, RetainScoreMap, LastList
        ),
    erlang:put(?k_cgw_score_retain, RetainScoreMap2),
    ?debug("join: ~p", [ets:tab2list(?ETS_CGW_GUILDS)]),
%%        _ ->
%%            ignore
%%    end,
    {noreply, State#state{period=?CGW_PERIOD_DIVIDE, round=0}};

do_handle_cast(clear, State) ->
    ?debug("clear"),
    ets:delete_all_objects(?ETS_CGW_GUILDS),
    ets:delete_all_objects(?ETS_CGW_BATTLE),
    erlang:erase(?k_cgw_score_retain),
    {noreply, State};

do_handle_cast(sort, State) ->
    do_sort(),
    {noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

do_sort() ->
    Guilds1 = lists:sort(fun
        (G1, G2) ->
            #cgw_guild{score=Score1, time=Time1, power=Power1} = G1,
            #cgw_guild{score=Score2, time=Time2, power=Power2} = G2,
            case Score1 == Score2 of
                true  ->
                    case Time1 == Time2 of
                        true  -> Power1 > Power2;
                        false -> Time1 < Time2
                    end;
                false ->
                    Score1 > Score2
            end
    end, ets:tab2list(?ETS_CGW_GUILDS)),
    Guilds2 = do_sort2(Guilds1, 1, []),
    ets:insert(?ETS_CGW_GUILDS, Guilds2),
    Guilds2.

do_sort2([G | T], Rank, Acc) ->
    do_sort2(T, Rank+1, [G#cgw_guild{rank=Rank} | Acc]);
do_sort2([], _Rank, Acc) ->
    lists:reverse(Acc).

do_divide(N, HeadNum, TailNum) ->
    Guilds = ets:tab2list(?ETS_CGW_GUILDS),
    Head = lists:sublist(Guilds, N),
    Tail = lists:nthtail(N, Guilds),
    Atkers = ut_rand:choose(Head, HeadNum, false)
         ++ ut_rand:choose(Tail, TailNum, false),

    lists:foreach(fun
        (G=#cgw_guild{id=GuildID}) ->
            G2 = case lists:keymember(GuildID, #cgw_guild.id, Atkers) of
                true  -> G#cgw_guild{group=?CGW_GROUP_ATKER};
                false -> G#cgw_guild{group=?CGW_GROUP_DEFER}
            end,
            ets:insert(?ETS_CGW_GUILDS, G2)
    end, Guilds),

    ok.

match_book(Match, Round, ID) ->
    lists:foldl(fun
        ({AtkID, DefID}, AccID) ->
            insert_match(AccID, Round, AtkID, DefID),
            AccID + 1
    end, ID, Match).

match_unbook([AtkID | T1], [DefID | T2], Round, ID) ->
    insert_match(ID, Round, AtkID, DefID),
    match_unbook(T1, T2, Round, ID+1);
match_unbook([AtkID], [], Round, ID) ->
    insert_match(ID, Round, AtkID, 0);
match_unbook([], [DefID], Round, ID) ->
    insert_match(ID, Round, 0, DefID);
match_unbook([], [], _Round, _ID) ->
    ok.

insert_match(ID, Round, AtkID, DefID) ->
    % ?debug("match: ~w", [{ID, Round, AtkID, DefID}]),
    case AtkID > 0 of
        true  ->
            [AtkGuild] = ets:lookup(?ETS_CGW_GUILDS, AtkID),
            #cgw_guild{name=AtkName, battle=AtkBattle} = AtkGuild,
            AtkBattle2 = maps:put(Round, ID, AtkBattle),
            ets:insert(?ETS_CGW_GUILDS, AtkGuild#cgw_guild{battle=AtkBattle2});
        false ->
            AtkName = ""
    end,
    case DefID > 0 of
        true  ->
            [DefGuild] = ets:lookup(?ETS_CGW_GUILDS, DefID),
            #cgw_guild{name=DefName, battle=DefBattle} = DefGuild,
            DefBattle2 = maps:put(Round, ID, DefBattle),
            ets:insert(?ETS_CGW_GUILDS, DefGuild#cgw_guild{battle=DefBattle2});
        false ->
            DefName = ""
    end,
    ets:insert(?ETS_CGW_BATTLE, #cgw_battle{
        id       = ID,
        round    = Round,
        atk_id   = AtkID,
        atk_name = AtkName,
        def_id   = DefID,
        def_name = DefName
    }).


-define(k_cryst_num, k_cryst_num).
get_cryst_num() ->
    get(?k_cryst_num).

set_cryst_num(Num) ->
    put(?k_cryst_num, Num).


do_round_settle(Round) ->
    WorldLv = world_level:get_level(),
    NowTime = ut_time:seconds(),
    lists:foreach(fun
        (B) ->
            case B#cgw_battle.round == Round of
                true  ->
                    #cgw_battle{atk_id=AtkID, def_id=DefID, winner=Winner0} = B,
                    Winner = ?_if(Winner0 == 0, DefID, Winner0),
                    B2 = B#cgw_battle{winner=Winner},
                    ets:insert(?ETS_CGW_BATTLE, B2),
                    ?_if(Winner0 == 0, do_send_round_reward(Round, Winner, B2)),
                    case ets:lookup(?ETS_CGW_GUILDS, AtkID) of
                        [AtkGuild] ->
                            #cgw_guild{score=AtkScore, rank=AtkRank, cost=Cost} = AtkGuild,
                            DefRank = case ets:lookup(?ETS_CGW_GUILDS, DefID) of
                                [DefGuild] ->
                                    DefGuild#cgw_guild.rank;
                                [] ->
                                    AtkRank
                            end,
                            {WinScore1, _, LoseScore1, _} = cfg_cgw_weekly_reward:find(DefRank, WorldLv),
                            AddScore1 = ?_if(AtkID == Winner, WinScore1, LoseScore1-Cost),
                            ets:insert(?ETS_CGW_GUILDS, AtkGuild#cgw_guild{
                                score = AtkScore + AddScore1,
                                time  = NowTime
                            });
                        [] ->
                            ignore
                    end;
                false ->
                    ignore
            end
    end, ets:tab2list(?ETS_CGW_BATTLE)).

do_weekly_settle() ->
    case lists:keyfind(1, #cgw_guild.rank, ets:tab2list(?ETS_CGW_GUILDS)) of
        #cgw_guild{id=GuildID, name=GuildName, chief=ChiefName} ->
            ZoneID = game_uid:guid2ssid(GuildID),
            notify_to_nodes(?MSG_CGW_WEEKLY_TOP1, [ZoneID, ChiefName, GuildName]);
        false ->
            ignore
    end,
    lists:foreach(fun
        (B) ->
            case B#cgw_battle.round == 2 of
                true  ->
                    #cgw_battle{atk_id=AtkID, def_id=DefID, winner=Winner} = B,
                    case AtkID > 0 of
                        true  ->
                            [#cgw_guild{rank=AtkRank}] = ets:lookup(?ETS_CGW_GUILDS, AtkID),
                            case AtkID == Winner of
                                true  -> do_send_win_reward(AtkID, AtkRank);
                                false -> do_send_lose_reward(AtkID, AtkRank)
                            end;
                        false ->
                            ignore
                    end,
                    case DefID > 0 of
                        true  ->
                            [#cgw_guild{rank=DefRank}] = ets:lookup(?ETS_CGW_GUILDS, DefID),
                            case DefID == Winner of
                                true  -> do_send_win_reward(DefID, DefRank);
                                false -> do_send_lose_reward(DefID, DefRank)
                            end;
                        false ->
                            ignore
                    end;
                false ->
                    ignore
            end
    end, ets:tab2list(?ETS_CGW_BATTLE)),

    lists:foreach(fun
        (G) ->
            ets:insert(?ETS_CGW_GUILDS, G#cgw_guild{
                rival1    = 0,
                rival2    = 0,
                book1     = 0,
                book2     = 0,
                book_time = 0,
                cost      = 0
            })
    end, ets:tab2list(?ETS_CGW_GUILDS)).

do_send_win_reward(GuildID, Rank) ->
    SUID = game_uid:guid2suid(GuildID),
    cluster:rpc_call_node(SUID, ?MODULE, send_weekly_reward, [true, GuildID, Rank]).

do_send_lose_reward(GuildID, Rank) ->
    SUID = game_uid:guid2suid(GuildID),
    cluster:rpc_call_node(SUID, ?MODULE, send_weekly_reward, [false, GuildID, Rank]).

do_monthly_settle() ->
    ?debug("do_monthly_settle"),
    lists:foreach(fun
        (G) ->
            #cgw_guild{id=GuildID, rank=Rank, name=GuildName, chief=ChiefName} = G,
            case Rank =< 3 of
                true  ->
                    ZoneID = game_uid:guid2ssid(GuildID),
                    notify_to_nodes(?MSG_CGW_MONTHLY_TOP1, [ZoneID, ChiefName, GuildName, Rank]);
                false ->
                    ignore
            end,
            SUID = game_uid:guid2suid(GuildID),
            cluster:rpc_call_node(SUID, ?MODULE, send_monthly_reward, [GuildID, Rank])
    end, ets:tab2list(?ETS_CGW_GUILDS)).

-define(k_injure_time, {k_injure_time,CreepID}).
get_injure_time(CreepID) ->
    get(?k_injure_time).

set_injure_time(CreepID, Secs) ->
    put(?k_injure_time, Secs).


notify_to_nodes(Msgno, Args) ->
    cluster:notify(?CROSS_RULE_24_8, Msgno, Args).

notify_to_scene(Msgno, Args) ->
    notify_to_scene(0, Msgno, Args).

notify_to_scene(Group, Msgno, Args) ->
    RoleIDs = case Group == 0 of
        true  ->
            scene_actor:get_actids(?ACTOR_TYPE_ROLE);
        false ->
            lists:filter(fun
                (RoleID) ->
                    case scene_actor:get_actor(RoleID) of
                        ?nil  -> false;
                        Actor -> Actor#actor.group == Group
                    end
            end, scene_actor:get_actids(?ACTOR_TYPE_ROLE))
    end,
    ?notify(RoleIDs, Msgno, Args).


-define(k_double_kill, {k_double_kill,RoleID}).
get_double_kill(RoleID) ->
    get(?k_double_kill).

set_double_kill(RoleID, Times) ->
    put(?k_double_kill, Times).


do_send_round_reward(Round, Winner, Battle) ->
    #cgw_battle{round=Round2, joined=Joined, atk_id=AtkGuild, def_id=DefGuild} = Battle,
    case Round == Round2 of
        true  ->
            {AtkRoles, DefRoles} = lists:foldl(fun
                ({RoleID, GuildID}, {AccAtk, AccDef}) ->
                    case GuildID == AtkGuild of
                        true  ->
                            {[RoleID | AccAtk], AccDef};
                        false ->
                            {AccAtk, [RoleID | AccDef]}
                    end
            end, {[],[]}, Joined),
            do_send_round_reward2(Round, AtkGuild, DefGuild, AtkRoles, AtkGuild==Winner, false, true),
            do_send_round_reward2(Round, DefGuild, AtkGuild, DefRoles, DefGuild==Winner, false, false);
        false ->
            ignore
    end.

do_send_round_reward2(Round, GuildID, RivalID, Roles, IsWin, IsMiss, IsAtker) ->
    Rank = case ets:lookup(?ETS_CGW_GUILDS, RivalID) of
        [R] ->
            R#cgw_guild.rank;
        [] ->
            case ets:lookup(?ETS_CGW_GUILDS, GuildID) of
                [R] -> R#cgw_guild.rank;
                []  -> 0
            end
    end,
    case Rank > 0 of
        true  ->
            SUID = game_uid:guid2suid(GuildID),
            ?debug("do_send_round_reward2: ~w", [{SUID, Round, GuildID, Roles, IsWin, IsMiss}]),
            cluster:rpc_call_node(SUID, ?MODULE, send_round_reward, [Round,GuildID,Rank,Roles,IsWin,IsMiss,IsAtker]);
        false ->
            ignore
    end.

do_match(Guilds) ->
    lists:foldl(fun
        (G, {{AccMatch1,AccAtker1,AccDefer1}=AccRound1, {AccMatch2,AccAtker2,AccDefer2}=AccRound2}) ->
            #cgw_guild{id=GuildID, rival1=RivalID1, rival2=RivalID2, group=Group} = G,
            % ets:insert(?ETS_CGW_GUILDS, G#cgw_guild{score=Score-Cost, cost=0}),
            % ?debug("----------:~w", [{GuildID, Group, RivalID1, RivalID2}]),
            case Group of
                ?CGW_GROUP_ATKER ->
                    AccRound1_2 = case RivalID1 > 0 of
                        true  -> {[{GuildID,RivalID1} | AccMatch1], AccAtker1, AccDefer1};
                        false -> {AccMatch1, [GuildID | AccAtker1], AccDefer1}
                    end,
                    % ?debug("11111, AccRound1_2: ~w", [AccRound1_2]),
                    AccRound2_2 = case RivalID2 > 0 of
                        true  -> AccRound2;
                        false -> {AccMatch2, AccAtker2, [GuildID | AccDefer2]}
                    end,
                    % ?debug("11111, AccRound2_2: ~w", [AccRound2_2]),
                    {AccRound1_2, AccRound2_2};
                ?CGW_GROUP_DEFER ->
                    AccRound1_2 = case RivalID2 > 0 of
                        true  -> AccRound1;
                        false -> {AccMatch1, AccAtker1, [GuildID | AccDefer1]}
                    end,
                    % ?debug("22222, AccRound1_2: ~w", [AccRound1_2]),
                    AccRound2_2 = case RivalID1 > 0 of
                        true  -> {[{GuildID,RivalID1} | AccMatch2], AccAtker2, AccDefer2};
                        false -> {AccMatch2, [GuildID | AccAtker2], AccDefer2}
                    end,
                    % ?debug("22222, AccRound2_2: ~w", [AccRound2_2]),
                    {AccRound1_2, AccRound2_2}
            end
    end, {{[],[],[]},{[],[],[]}}, Guilds).

do_dump() ->
    game_misc:write(cgw_guilds, ets:tab2list(?ETS_CGW_GUILDS), true),
    game_misc:write(cgw_battle, ets:tab2list(?ETS_CGW_BATTLE), true).

%%%-----------------------------------------------------------------------------
%%% Test Functions
%%%-----------------------------------------------------------------------------
% do_match_test_() ->
%     Guilds01 = [
%         cgw_guild_help(1001, 1, 0, 0)
%     ],

%     Guilds02 = [
%         cgw_guild_help(1001, 1, 0, 0),
%         cgw_guild_help(1002, 2, 0, 0)
%     ],
%     Guilds03 = [
%         cgw_guild_help(1001, 1, 1002, 0),
%         cgw_guild_help(1002, 2, 0, 1001)
%     ],
%     Guilds04 = [
%         cgw_guild_help(1001, 1, 0, 1002),
%         cgw_guild_help(1002, 2, 1001, 0)
%     ],
%     Guilds05 = [
%         cgw_guild_help(1001, 1, 1002, 1002),
%         cgw_guild_help(1002, 2, 1001, 1001)
%     ],

%     Guilds06 = [
%         cgw_guild_help(1001, 1, 0, 0),
%         cgw_guild_help(1002, 1, 0, 0),
%         cgw_guild_help(1003, 2, 0, 0)
%     ],
%     Guilds07 = [
%         cgw_guild_help(1001, 1, 1003, 0),
%         cgw_guild_help(1002, 1, 0, 0),
%         cgw_guild_help(1003, 2, 0, 1001)
%     ],
%     Guilds08 = [
%         cgw_guild_help(1001, 1, 1003, 1003),
%         cgw_guild_help(1002, 1, 0, 0),
%         cgw_guild_help(1003, 2, 1001, 1001)
%     ],
%     Guilds09 = [
%         cgw_guild_help(1001, 1, 1003, 0),
%         cgw_guild_help(1002, 1, 0, 1003),
%         cgw_guild_help(1003, 2, 1002, 1001)
%     ],

%     Guilds10 = [
%         cgw_guild_help(1001, 1, 0, 0),
%         cgw_guild_help(1002, 1, 0, 0),
%         cgw_guild_help(1003, 2, 0, 0),
%         cgw_guild_help(1004, 2, 0, 0)
%     ],
%     Guilds11 = [
%         cgw_guild_help(1001, 1, 1003, 0),
%         cgw_guild_help(1002, 1, 0, 0),
%         cgw_guild_help(1003, 2, 0, 1001),
%         cgw_guild_help(1004, 2, 0, 0)
%     ],
%     Guilds12 = [
%         cgw_guild_help(1001, 1, 1003, 1003),
%         cgw_guild_help(1002, 1, 0, 0),
%         cgw_guild_help(1003, 2, 1001, 1001),
%         cgw_guild_help(1004, 2, 0, 0)
%     ],
%     Guilds13 = [
%         cgw_guild_help(1001, 1, 1003, 0),
%         cgw_guild_help(1002, 1, 0, 1003),
%         cgw_guild_help(1003, 2, 1002, 1001),
%         cgw_guild_help(1004, 2, 0, 0)
%     ],
%     Guilds14 = [
%         cgw_guild_help(1001, 1, 1003, 0),
%         cgw_guild_help(1002, 1, 1004, 0),
%         cgw_guild_help(1003, 2, 0, 1001),
%         cgw_guild_help(1004, 2, 0, 1002)
%     ],
%     Guilds15 = [
%         cgw_guild_help(1001, 1, 1003, 1004),
%         cgw_guild_help(1002, 1, 1004, 1003),
%         cgw_guild_help(1003, 2, 1002, 1001),
%         cgw_guild_help(1004, 2, 1001, 1002)
%     ],
%     Guilds16 = [
%         cgw_guild_help(1001, 1, 1004, 1003),
%         cgw_guild_help(1002, 1, 0, 0),
%         cgw_guild_help(1003, 2, 1001, 0),
%         cgw_guild_help(1004, 2, 0, 1001)
%     ],
%     Guilds17 = [
%         cgw_guild_help(1001, 1, 1003, 1004),
%         cgw_guild_help(1002, 1, 1004, 0),
%         cgw_guild_help(1003, 2, 0, 1001),
%         cgw_guild_help(1004, 2, 1001, 1002)
%     ],
%     Guilds18 = [
%         cgw_guild_help(1001, 1, 1003, 0),
%         cgw_guild_help(1002, 1, 1004, 1004),
%         cgw_guild_help(1003, 2, 0, 1001),
%         cgw_guild_help(1004, 2, 1002, 1002)
%     ],
%     Guilds19 = [
%         cgw_guild_help(1001, 1, 1003, 0),
%         cgw_guild_help(1002, 1, 1004, 1003),
%         cgw_guild_help(1003, 2, 1002, 1001),
%         cgw_guild_help(1004, 2, 0, 1002)
%     ],

%     [
%           ?_assertEqual({{[],[1001],[]},{[],[],[1001]}}, do_match(Guilds01))

%         , ?_assertEqual({{[],[1001],[1002]},{[],[1002],[1001]}}, do_match(Guilds02))
%         , ?_assertEqual({{[{1001,1002}],[],[]},{[],[1002],[1001]}}, do_match(Guilds03))
%         , ?_assertEqual({{[],[1001],[1002]},{[{1002,1001}],[],[]}}, do_match(Guilds04))
%         , ?_assertEqual({{[{1001,1002}],[],[]},{[{1002,1001}],[],[]}}, do_match(Guilds05))

%         , ?_assertEqual({{[],[1002,1001],[1003]},{[],[1003],[1002,1001]}}, do_match(Guilds06))
%         , ?_assertEqual({{[{1001,1003}],[1002],[]},{[],[1003],[1002,1001]}}, do_match(Guilds07))
%         , ?_assertEqual({{[{1001,1003}],[1002],[]},{[{1003,1001}],[],[1002]}}, do_match(Guilds08))
%         , ?_assertEqual({{[{1001,1003}],[1002],[]},{[{1003,1002}],[],[1001]}}, do_match(Guilds09))

%         , ?_assertEqual({{[],[1002,1001],[1004,1003]},{[],[1004,1003],[1002,1001]}}, do_match(Guilds10))
%         , ?_assertEqual({{[{1001,1003}],[1002],[1004]},{[],[1004,1003],[1002,1001]}}, do_match(Guilds11))
%         , ?_assertEqual({{[{1001,1003}],[1002],[1004]},{[{1003,1001}],[1004],[1002]}}, do_match(Guilds12))
%         , ?_assertEqual({{[{1001,1003}],[1002],[1004]},{[{1003,1002}],[1004],[1001]}}, do_match(Guilds13))
%         , ?_assertEqual({{[{1002,1004},{1001,1003}],[],[]},{[],[1004,1003],[1002,1001]}}, do_match(Guilds14))
%         , ?_assertEqual({{[{1002,1004},{1001,1003}],[],[]},{[{1004,1001},{1003,1002}],[],[]}}, do_match(Guilds15))
%         , ?_assertEqual({{[{1001,1004}],[1002],[1003]},{[{1003,1001}],[1004],[1002]}}, do_match(Guilds16))

%         , ?_assertEqual({{[{1002,1004},{1001,1003}],[],[]},{[{1004,1001}],[1003],[1002]}}, do_match(Guilds17))
%         , ?_assertEqual({{[{1002,1004},{1001,1003}],[],[]},{[{1004,1002}],[1003],[1001]}}, do_match(Guilds18))
%         , ?_assertEqual({{[{1002,1004},{1001,1003}],[],[]},{[{1003,1002}],[1004],[1001]}}, do_match(Guilds19))
%     ].

% cgw_guild_help(GuildID, Group, Rival1, Rival2) ->
%     #cgw_guild{
%         id        = GuildID,
%         name      = "",
%         power     = 9187595,
%         chief     = "",
%         score     = 1000,
%         rival1    = Rival1,
%         rival2    = Rival2,
%         book1     = 0,
%         book2     = 0,
%         book_time = 0,
%         cost      = 0,
%         group     = Group,
%         rank      = 4,
%         time      = 0,
%         battle    = #{}
%     }.
