%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_agent).

-behaviour(gen_server).

-include("attr.hrl").
-include("buff.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/2]).
-export([load/5]).
-export([relogin/3]).
-export([reconn/3]).
-export([logout/1]).
-export([kickgame/3]).
-export([kickscene/2]).
-export([query/2]).
-export([dump/2]).
-export([make_site/3]).

-define(DUMP_REF(RoleID), {RoleID,?MODULE,dump}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link(RoleID, GatePid) ->
    RegName = role_util:reg_name(RoleID),
    gen_server:start_link({local,RegName}, ?MODULE, {RoleID,GatePid}, []).

%% 加载数据
load(RoleRef, User, Token, IP, SDKArgs) ->
    gen_server:call(RoleRef, {load, User, Token, IP, SDKArgs}).

%% 重复登录
relogin(RoleRef, GatePid, Token) ->
    gen_server:call(RoleRef, {relogin, GatePid, Token}).

%% 断线重连
reconn(RoleRef, GatePid, Token) ->
    gen_server:call(RoleRef, {reconn, GatePid, Token}).

%% 退出游戏
logout(RoleRef) ->
    gen_server:cast(RoleRef, logout).

%% 踢掉玩家
kickgame(RoleRef, Reqs, Errno) ->
    gen_server:cast(RoleRef, {kickgame, Reqs, Errno}).

%% 踢掉场景
kickscene(RoleRef, Actor) ->
    gen_server:cast(RoleRef, {kickscene, Actor}).

%% 查询数据
query(RoleRef, Keys) ->
    gen_server:call(RoleRef, {query, Keys}).

%% 持久化数据
dump(_Ref, RoleSt) ->
    do_dump(RoleSt).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({RoleID, GatePid}) ->
    process_flag(trap_exit, true),
    link(GatePid),
    role_util:set_id(RoleID),
    {ok, #role_st{role=RoleID, gate=GatePid}}.

%% 顶号重登
handle_call({relogin, GatePid, Token}, _From, RoleSt)
when RoleSt#role_st.stype == ?SCENE_STYPE_DUNGE_RACE ->
    ?debug("relogin"),
    RoleSt2 = do_relogin(GatePid, RoleSt),
    Tos = #m_scene_leave_tos{mchunt=false},
    {ok, Toc, RoleSt3} = scene_handler:handle(?SCENE_LEAVE, Tos, RoleSt2),
    ?ucast(GatePid, Toc),
    {reply, {ok, RoleSt#role_st.name}, RoleSt3#role_st{token=Token}};
handle_call({relogin, GatePid, Token}, _From, RoleSt) ->
    ?debug("relogin"),
    RoleSt2 = do_relogin(GatePid, RoleSt),
    #role_st{
        role=RoleID, name=RoleName, spid=ScenePid, scene=SceneID, room=RoomID
    } = RoleSt,
    {ok, Actor, Actors} = scene:call(ScenePid, {relogin, RoleID}),
    {ok, Lines} = scene_manager:get_lines(SceneID, RoomID),
    ?ucast(GatePid, #m_scene_change_toc{
        scene   = SceneID,
        line    = RoleSt#role_st.line,
        actor   = scene_util:p_actor(Actor),
        actors  = scene_util:p_actor(Actors),
        lines   = [scene_util:p_line(L) || L <- maps:values(Lines)],
        type    = ?SCENE_CHANGE_PROTAL,
        relogin = true
    }),
    {reply, {ok, RoleName}, RoleSt2#role_st{token=Token}};

%% 断线重连
handle_call({reconn, GatePid, Token}, _From, RoleSt) ->
    ?debug("reconn:~w", [RoleSt#role_st.role]),
    #role_st{name=RoleName, user=User, token=Valid} = RoleSt,
    case Valid == Token of
        true  ->
            RoleSt2 = do_relogin(GatePid, RoleSt),
            #role_st{
                role=RoleID, spid=ScenePid, scene=SceneID, room=RoomID
            } = RoleSt2,
            {ok, Actor, Actors} = scene:call(ScenePid, {relogin, RoleID}),
            {ok, Lines} = scene_manager:get_lines(SceneID, RoomID),
            ?ucast(GatePid, #m_scene_enter_toc{
                scene   = SceneID,
                line    = RoleSt#role_st.line,
                actor   = scene_util:p_actor(Actor),
                actors  = scene_util:p_actor(Actors),
                lines   = [scene_util:p_line(L) || L <- maps:values(Lines)]
            }),
            task_handler:handle(?TASK_LIST, reconn, RoleSt2),
            {reply, {ok, self(), RoleName, User}, RoleSt2};
        false ->
            {reply, ?err(?ERR_LOGIN_BAD_TOKEN), RoleSt}
    end;

%% 查询角色信息
handle_call({query, Keys}, _From, RoleSt) when is_list(Keys) ->
    Vals = lists:map(fun
        ({bag, BagID}) ->
            role_bag:get_bagitems(BagID);
        (Key) ->
            role_data:get(Key)
    end, Keys),
    {reply, {ok, Vals}, RoleSt};

%% 加载数据
handle_call({load, User, Token, IP, SDKArgs}, _From, RoleSt) ->
    {ok, RoleSt1} = do_init(User, Token, IP, SDKArgs, RoleSt),
    insert_cache(),
    online_server:hook_login(RoleSt1),
    RoleSt2 = role_hook:hook_login(RoleSt1),
    IsFirst = role_count:get_times(?ROLE_COUNT_LOGIN) == 0,
    ?_if(IsFirst, role_event:event(?EVENT_LOGIN)),
    role_count:add_times(?ROLE_COUNT_LOGIN),
    DumpRef = ?DUMP_REF(RoleSt#role_st.role),
    role_timer:add_task(DumpRef, 0, 5*60, ?MODULE, dump),
    log_junhai:log_login(User, IP, SDKArgs, ?nil),
    {reply, {ok, RoleSt2#role_st.name}, RoleSt2};

handle_call(Req, _From, RoleSt) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, RoleSt}.


%% 协议转发
handle_cast({pt, Mod, MsgID, Msg}, RoleSt) ->
    try
        Mod:handle(MsgID, Msg, RoleSt)
    of
        {ok, Toc, RoleSt2} when is_record(RoleSt2, role_st) ->
            ?ucast(Toc),
            {noreply, RoleSt2};
        {ok, RoleSt2} when is_record(RoleSt2, role_st) ->
            {noreply, RoleSt2};
        _ ->
            {noreply, RoleSt}
    catch
        throw:{error, Errno, Args} ->
            ?ucast(#m_game_error_toc{errno=Errno, args=Args}),
            {noreply, RoleSt};
        error:{badmatch, {error, Errno, Args}} ->
            ?ucast(#m_game_error_toc{errno=Errno, args=Args}),
            {noreply, RoleSt};
        Error:Reason:Stacktrace ->
            ?ucast(#m_game_error_toc{errno=?ERR_GAME_SYS_ERROR}),
            ?stacktrace(Error, Reason, Stacktrace),
            {noreply, RoleSt}
    end;

handle_cast(Msg, RoleSt) ->
    try
        do_handle_cast(Msg, RoleSt)
    catch
        throw:{error, Errno, Args}:_ ->
            ?ucast(#m_game_error_toc{errno=Errno, args=Args}),
            {noreply, RoleSt};
        error:{badmatch, {error, Errno, Args}}:_ ->
            ?ucast(#m_game_error_toc{errno=Errno, args=Args}),
            {noreply, RoleSt};
        Class:Reason:Stacktrace ->
            ?stacktrace(Class, Reason, Stacktrace),
            {noreply, RoleSt}
    end.

handle_info(chime_login, RoleSt) ->
    role_event:event(?EVENT_LOGIN),
    role_count:add_times(?ROLE_COUNT_LOGIN),
    {noreply, RoleSt};

%% 网关挂掉
handle_info({'EXIT', _, _Reason}, RoleSt) ->
    fight_collect:break(RoleSt),
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    scene:cast(ScenePid, {offline, RoleID}),
    online_server:hook_logout(RoleSt),
    dump_base_data(),
    Timer = erlang:send_after(timer:minutes(1), self(), stop),
    put(k_delay_timer, Timer),
    {noreply, RoleSt};

handle_info(stop, RoleSt) ->
    {stop, normal, RoleSt};

handle_info(Info, RoleSt) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, RoleSt}.


terminate(Reason, RoleSt) ->
    ?debug("role terminate: ~p", [Reason]),
    #role_st{role=RoleID, user=User, ip=IP, sdk=SDKArgs} = RoleSt,
    ?terminate(Reason),
    try
        {ok, Actor} = do_leave(RoleSt),
        sync_role_data(Actor, RoleSt),

        fight_collect:break(RoleSt),
        role_timer:del_all(RoleID),

        log_junhai:log_offline(User, IP, SDKArgs, ?nil),

        role_hook:hook_logout(RoleSt)
    catch Class:Reason2:Stacktrace ->
        ?stacktrace(Class, Reason2, Stacktrace)
    end,
    do_dump(RoleSt),
    ok.

code_change(_OldVsn, RoleSt, _Extra) ->
    {ok, RoleSt}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 加经验
do_handle_cast({add_exp, Exp, Log}, RoleSt) ->
    role_bag:gain([{?ITEM_EXP, Exp}], Log, RoleSt),
    {noreply, RoleSt};

%% 打怪
do_handle_cast({kill_creep, CreepID, Rarity}, RoleSt) ->
    role_event:event(?EVENT_CREEP, {CreepID, Rarity}),
    {noreply, RoleSt};

%% 怪物掉经验
do_handle_cast({drop_exp, Exp, Coef}, RoleSt) ->
    role_drop:drop_exp(Exp, Coef, RoleSt),
    {noreply, RoleSt};

%% 怪物掉物品
%% 实际获得通过邮件发送，这里只做掉落表现
do_handle_cast({drop_item, Creep, Drops, _IsDummy}, RoleSt) when
?is_timeboss(Creep);
RoleSt#role_st.stype == ?SCENE_STYPE_BOSS_NOTIRED ->
    Drops2 = [
        role_drop:p_drop(Drop, ?DROP_MODE_DUMMY2) ||
        Drop <- Drops
    ],
    ?ucast(#m_scene_drop_toc{drops = Drops2}),
    {noreply, RoleSt};

do_handle_cast({drop_item, Creep, Drops, IsDummy}, RoleSt) ->
    role_drop:drop_item(Creep, Drops, IsDummy, RoleSt),
    {noreply, RoleSt};

%% 同步坐标
do_handle_cast({move, Coord}, RoleSt) ->
    {noreply, RoleSt#role_st{coord=Coord}};

%% 发送到网关
do_handle_cast({send, Toc}, RoleSt) ->
    gen_server:cast(RoleSt#role_st.gate, {send, Toc}),
    {noreply, RoleSt};

%% 事件
do_handle_cast({event, Event, Args}, RoleSt) ->
    RoleSt2 = role_event:notify(Event, Args, RoleSt),
    {noreply, RoleSt2};

%% 升级
do_handle_cast({upgrade, LvAdd}, RoleSt) ->
    #role_st{role=RoleID, spid=ScenePid, user=User, ip=IP, sdk=SDKArgs} = RoleSt,
    #role_info{level=NewLv} = role_data:get(?DB_ROLE_INFO),
    lists:foreach(fun
        (Level) ->
            role_event:event(?EVENT_LEVEL, Level),
            role_hook:hook_upgrade(Level, RoleSt)
    end, lists:seq(NewLv-LvAdd+1, NewLv)),
    log_update_role(NewLv, RoleSt),
    role_attr:recalc(role_level, RoleSt),
    scene:update_actor(ScenePid, RoleID, [{level, NewLv}]),
    log_junhai:log_upgrade(User, IP, SDKArgs, ?nil),
    {noreply, RoleSt};

%% 路由转发
do_handle_cast({route, Mod, Fun}, RoleSt) ->
    case Mod:Fun(RoleSt) of
        {ok, RoleSt2} when is_record(RoleSt2, role_st) ->
            {noreply, RoleSt2};
        _ ->
            {noreply, RoleSt}
    end;

do_handle_cast({route, Mod, Fun, ?nil}, RoleSt) ->
    do_handle_cast({route, Mod, Fun}, RoleSt);

do_handle_cast({route, Mod, Fun, Args}, RoleSt) ->
    case Mod:Fun(Args, RoleSt) of
        {ok, RoleSt2} when is_record(RoleSt2, role_st) ->
            {noreply, RoleSt2};
        _ ->
            {noreply, RoleSt}
    end;

do_handle_cast({func, Fun}, RoleSt) when is_function(Fun, 0) ->
    Fun(),
    {noreply, RoleSt};

do_handle_cast({func, Fun}, RoleSt) when is_function(Fun, 1) ->
    case Fun(RoleSt) of
        {ok, RoleSt2} when is_record(RoleSt2, role_st) ->
            {noreply, RoleSt2};
        _ ->
            {noreply, RoleSt}
    end;

%% 死亡
do_handle_cast({dead, KillerID, KillerType}, RoleSt) ->
    ?debug("dead:~w", [{KillerID, KillerType}]),
    #role_st{role=RoleID} = RoleSt,
    case KillerType of
        ?ACTOR_TYPE_ROLE ->
            role_util:is_local(KillerID)
                andalso friend_server:add_enemy(RoleID, KillerID);
        _ ->
            ignore
    end,
    role_event:event(?EVENT_ROLE_DEATH),
    {noreply, RoleSt};

%% 踢出场景
do_handle_cast({kickscene, Actor}, RoleSt) ->
    ?debug("kickout scene: ~w", [{Actor#actor.uid, Actor#actor.scene}]),
    Site = case RoleSt#role_st.jump of
        ?nil -> make_site(cfg_game:capital(), 0);
        Jump -> Jump
    end,
    #site{scene=SceneID, room=RoomID, coord=Coord} = Site,
    Actor2 = Actor#actor{coord=Coord},
    Actor3 = scene_hook:hook_kickout(Actor2, RoleSt),
    {ok, RoleSt2} = do_enter(SceneID, RoomID, Actor3, RoleSt),
    {noreply, RoleSt2};

%% 退出登录
do_handle_cast(logout, RoleSt) ->
    ?debug("logout"),
    online_server:hook_logout(RoleSt),
    fight_collect:break(RoleSt),
    {stop, normal, RoleSt};

%% 踢掉玩家
do_handle_cast({kickgame, Reqs, Errno}, RoleSt) ->
    case check_kickout_reqs(Reqs, RoleSt) of
        true  -> unlink_gateway(Errno, RoleSt);
        false -> ignore
    end,
    {stop, normal, RoleSt};

%% 整点
do_handle_cast(chime, RoleSt) ->
    ?debug("chime:~w", [RoleSt#role_st.role]),
    role_hook:hook_reset(RoleSt),
    realname_handler:hook_reset(RoleSt),
    % 其他活动管理器整点重置，开启时有可能比玩家进程慢，
    % 管理器此时还没去监听玩家事件,延迟发送即可
    role_count:get_times(?ROLE_COUNT_LOGIN) == 0 andalso
        erlang:send_after(timer:seconds(10), self(), chime_login),
    {noreply, RoleSt};

do_handle_cast(dump, RoleSt) ->
    do_dump(RoleSt),
    {noreply, RoleSt};

do_handle_cast({setdata, Rec}, RoleSt) ->
    role_data:set(Rec),
    {noreply, RoleSt};

do_handle_cast(Msg, RoleSt) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, RoleSt}.


do_init(User, Token, IP, SDKArgs, RoleSt) ->
    role_event:init(),
    role_data:init(RoleSt#role_st.role),
    RoleSt2 = init_state(User, Token, IP, SDKArgs, RoleSt),
    role_hook:hook_reset(RoleSt2),
    role_attr:init(RoleSt2),
    enter_scene(RoleSt2).

init_state(User, Token, IP, SDKArgs, RoleSt) ->
    RoleInfo = #role_info{name=Name} = role_data:get(?DB_ROLE_INFO),
    role_data:set(RoleInfo#role_info{login=ut_time:seconds()}),
    #role_guild{guild=GuildID} = role_data:get(?DB_ROLE_GUILD),
    RoleSt#role_st{
        name  = Name,
        user  = User,
        token = Token,
        guild = GuildID,
        gpid  = ?_if(GuildID == 0, ?nil, guild:get_pid(GuildID)),
        team  = 0,
        state = ?ROLE_STATE_NORMAL,
        ip    = IP,
        sdk   = SDKArgs
    }.

enter_scene(RoleSt) ->
    #role_site{cur=Cur, pre=Pre} = role_data:get(?DB_ROLE_SITE),
    Actor = init_actor(RoleSt),
    try
        {ok, RoleSt2} = try_enter(Cur, Actor, RoleSt),
        case Pre /= ?nil of
            true  -> {ok, RoleSt2#role_st{jump=Pre}};
            false -> {ok, RoleSt2}
        end
    catch Class1:Reason1:Stacktrace1 ->
        ?stacktrace(Class1, Reason1, Stacktrace1),
        try
            try_enter(Pre, Actor, RoleSt)
        catch Class2:Reason2:Stacktrace2 ->
            ?stacktrace(Class2, Reason2, Stacktrace2),
            Capital = make_site(cfg_game:capital(), 0),
            try_enter(Capital, Actor, RoleSt)
        end
    end.

try_enter(Site, Actor, RoleSt) ->
    #site{scene=SceneID, room=RoomID, coord=Coord} = Site,
    Coord2 = case scene_util:walkable(SceneID, Coord) of
        true  -> Coord;
        false -> scene_util:get_born(SceneID)
    end,
    Actor2 = Actor#actor{coord=Coord2, dest=Coord2},
    do_enter(SceneID, RoomID, Actor2, RoleSt).

init_actor(RoleSt) ->
    RoleInfo   = role_data:get(?DB_ROLE_INFO),
    RoleAttr   = role_data:get(?DB_ROLE_ATTR),
    RoleSkill  = role_data:get(?DB_ROLE_SKILL),
    RoleGuild  = role_data:get(?DB_ROLE_GUILD),
    RoleTalent = role_data:get(?DB_ROLE_TALENT),
    Skills = maps:merge(RoleSkill#role_skill.skills, RoleTalent#role_talent.skills),
    {Marry, MName, MType} = role_marriage:get_info(RoleSt#role_st.role),
    NowSecs  = ut_time:seconds(),
    RoleMisc = role_data:get(?DB_ROLE_MISC),
    Actor = #actor{
        uid    = RoleSt#role_st.role,
        pid    = self(),
        type   = ?ACTOR_TYPE_ROLE,
        name   = RoleInfo#role_info.name,
        state  = ?ACTOR_STATE_NORMAL,
        bctype = ?BCTYPE_GRID,
        suid   = game_env:get_suid(),
        zoneid = RoleInfo#role_info.zoneid,
        dir    = ut_rand:random(0, 360),
        buffs  = process_buff(RoleAttr#role_attr.buffs, NowSecs, RoleInfo#role_info.logout),
        initattr = role_util:get_attr(),
        buffattr = #{},
        attr   = RoleAttr#role_attr.attr,
        skills = Skills,
        endcds = #{},
        power  = mod_attr:power(RoleAttr#role_attr.attr),
        level  = RoleInfo#role_info.level,
        career = RoleInfo#role_info.career,
        gender = RoleInfo#role_info.gender,
        viplv  = role_vip:get_level(),
        figure = RoleInfo#role_info.figure,
        captain = team_server:get_captain(RoleSt#role_st.team),
        team   = RoleSt#role_st.team,
        guild  = RoleSt#role_st.guild,
        gname  = guild:get_name(RoleSt#role_st.guild),
        gpost  = RoleGuild#role_guild.post,
        group  = 0,
        pkmode = RoleInfo#role_info.pkmode,
        crime  = RoleInfo#role_info.crime,
        killer = 0,
        marry  = Marry,
        mname  = MName,
        mtype  = MType,
        exargs = #{},
        icon   = RoleInfo#role_info.icon,
        hostile = [ID || {ID,IsEnemy} <- maps:to_list(RoleMisc#role_misc.enemy_suids), IsEnemy]
    },
    Actor2 = fix_buff(Actor),
    scene_actor:recalc_attr(Actor2).

dump_base_data() ->
    lists:foreach(fun
        (Tab) ->
            Data = role_data:get(Tab),
            db:dirty_write(Data)
    end, [
        ?DB_ROLE_INFO,
        ?DB_ROLE_ATTR,
        ?DB_ROLE_VIP,
        ?DB_ROLE_GUILD
    ]).

%% 重新登录
do_relogin(GatePid, RoleSt) ->
    ut_misc:cancel_timer( erase(k_delay_timer) ),
    unlink_gateway(?ERR_GAME_LOGIN_ELSE, RoleSt),
    link(GatePid),
    online_server:hook_login(RoleSt),
    RoleSt#role_st{gate=GatePid}.

%% 与网关断开连接
unlink_gateway(Errno, RoleSt) ->
    unlink(RoleSt#role_st.gate),
    exit(RoleSt#role_st.gate, {kickout, Errno}).

%% 同步 actor 到玩家数据
sync_role_data(Actor, RoleSt) ->
    try
        sync_role_info(Actor, RoleSt),
        sync_role_attr(Actor, RoleSt),
        sync_role_site(Actor, RoleSt)
    catch Class:Reason:Stacktrace ->
        ?stacktrace(Class, Reason, Stacktrace)
    end.

sync_role_info(Actor, _RoleSt) ->
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    role_data:set(RoleInfo#role_info{
        logout = ut_time:seconds(),
        crime  = Actor#actor.crime
    }).

sync_role_attr(Actor, _RoleSt) ->
    RoleAttr = role_data:get(?DB_ROLE_ATTR),
    #actor{attr=Attr, buffs=Buffs, state=State} = Actor,
    Attr2  = case ?is_death(State) of
        true  -> ?_setattr(Attr, ?ATTR_HP, ?_attr(Attr,?ATTR_HPMAX));
        false -> Attr
    end,
    Buffs2 = case buff_util:had_effect(Actor, ?BUFF_EFFECT_DEL_ANGER) of
        true  ->
            case lists:keyfind(?BUFF_EFFECT_ADD_ANGER, #p_buff.eff, maps:values(Buffs)) of
                false -> Buffs;
                Buff  -> maps:put(Buff#p_buff.group, Buff#p_buff{value=0}, Buffs)
            end;
        false ->
            Buffs
    end,
    role_data:set(RoleAttr#role_attr{
        attr  = Attr2,
        buffs = Buffs2
    }).

sync_role_site(Actor, RoleSt) ->
    #role_st{role=RoleID, type=Type, stype=SType} = RoleSt,
    RoleSite = case
        Type == ?SCENE_TYPE_DUNGE orelse
        Type == ?SCENE_TYPE_ACT orelse
        SType == ?SCENE_STYPE_BOSS_HOME orelse
        SType == ?SCENE_STYPE_BOSS_WILD orelse
        SType == ?SCENE_STYPE_BOSS_PET orelse
        SType == ?SCENE_STYPE_BOSS_FISSURE
    of
        true  -> stay_prev(Actor, RoleSt);
        false -> stay_situ(Actor, RoleSt)
    end,
    role_data:set(RoleSite#role_site{id=RoleID}).

%% 留在原地
stay_situ(Actor, RoleSt) ->
    #role_st{scene=SceneID, room=RoomID} = RoleSt,
    Coord = case ?is_death(Actor#actor.state) of
        true  -> scene_util:get_reborn(SceneID);
        false -> Actor#actor.coord
    end,
    Site  = make_site(SceneID, RoomID, Coord),
    #role_site{pre=RoleSt#role_st.jump, cur=Site}.

%% 回到上一张地图
stay_prev(_Actor, RoleSt) ->
    #role_site{cur=RoleSt#role_st.jump}.

make_site(SceneID, RoomID) ->
    make_site(SceneID, RoomID, scene_util:get_born(SceneID)).
make_site(SceneID, RoomID, Coord) ->
    #site{scene=SceneID, room=RoomID, coord=Coord}.

do_enter(SceneID, RoomID, Actor, RoleSt) ->
    {ok, Actor2, Actors, Lines} = scene_manager:enter(SceneID, RoomID, Actor),
    scene_change:post_enter(0, SceneID, RoomID, Actor2, Actors, Lines, RoleSt).

do_leave(RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    ?debug("do_leave-----------------:~w", [{ScenePid, RoleID}]),
    scene:call(ScenePid, {leave, RoleID}).

do_dump(RoleSt) ->
    role_data:dump(),
    log_api:update_role(RoleSt),
    log_api:update_online_time(RoleSt),
    log_api:log_equip(RoleSt).

log_update_role(NewLv, RoleSt) ->
    % 80级前，每十级同步一次玩家数据
    NeedUpdate = if
        NewLv > 80 -> true;
        true -> NewLv rem 10 == 0
    end,
    NeedUpdate andalso log_api:update_role(RoleSt).

check_kickout_reqs([{gamechan, GameChan} | T], RoleSt=#role_st{user=User}) ->
    case GameChan == User#game_user.gamechan of
        true  -> check_kickout_reqs(T, RoleSt);
        false -> false
    end;
check_kickout_reqs([], _RoleSt) ->
    true.

insert_cache() ->
    RoleInfo  = role_data:get(?DB_ROLE_INFO),
    RoleAttr  = role_data:get(?DB_ROLE_ATTR),
    RoleVip   = role_data:get(?DB_ROLE_VIP),
    RoleGuild = role_data:get(?DB_ROLE_GUILD),
    Cache = role_util:make_cache([RoleInfo, RoleAttr, RoleVip, RoleGuild]),
    role_cache:dirty_insert(Cache).

process_buff(Buffs, NowSecs, LogoutSecs) ->
    maps:fold(fun
        (Group, Buff, Acc) when Buff#p_buff.eff == ?BUFF_EFFECT_ADD_ANGER ->
            #cfg_buff{tick=Tick, args=Args} = cfg_buff:find(Buff#p_buff.id),
            PerAdd = proplists:get_value(anger_add, Args),
            TotAdd = max(0, round(PerAdd * (NowSecs - LogoutSecs) * 1000 / Tick)),
            Value2 = min(cfg_game:max_anger(), Buff#p_buff.value + TotAdd),
            maps:put(Group, Buff#p_buff{value=Value2}, Acc);
        (Group, Buff, Acc) ->
            case Buff#p_buff.etime > 0 andalso NowSecs >= Buff#p_buff.etime of
                true  -> Acc;
                false -> maps:put(Group, Buff, Acc)
            end
    end, #{}, Buffs).

fix_buff(Actor) ->
    NowSecs = ut_time:seconds(),
    RoleVip = role_data:get(?DB_ROLE_VIP),
    VipLv   = role_vip:get_level(RoleVip),
    Actor1  = case
        VipLv > 0 andalso
        (not buff_util:had_effect(Actor, ?BUFF_EFFECT_VIP))
    of
        true  ->
            VipBuffs = role_vip:get_vip_buff(RoleVip),
            buff_util:add_buffs(Actor, VipBuffs, NowSecs, false, false);
        false ->
            Actor
    end,

    #role_skill{skills=Skills} = role_data:get(?DB_ROLE_SKILL),
    AngerSkillID = 205001,
    Actor2 = case
        maps:is_key(AngerSkillID, Skills) andalso
        (not buff_util:had_effect(Actor, ?BUFF_EFFECT_ADD_ANGER))
    of
        true  ->
            #cfg_skill_level{buffs=AngerBuffs} = cfg_skill_level:find(AngerSkillID, 1),
            buff_util:add_buffs(Actor1, AngerBuffs, NowSecs, false, false);
        false ->
            Actor1
    end,
    Actor2.
