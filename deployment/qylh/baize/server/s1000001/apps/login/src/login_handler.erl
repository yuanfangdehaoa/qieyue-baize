%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(login_handler).

-include("buff.hrl").
-include("game.hrl").
-include("gate.hrl").
-include("login.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("vip.hrl").

%% API
-export([handle/3, check_name/1]).

-define(GM_LOGIN, "DiHyxsjl4PTypmoWBJic68QV").

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 登录验证
handle(?LOGIN_VERIFY, Tos, GateSt = #gate_st{ip=IP, state=?ST_VERIFY}) ->
    #m_login_verify_tos{
        gamechan=GameChan, account=Account, token=Token, args=SDKArgs
    } = Tos,
    check_login(GameChan, Account, Token, SDKArgs, IP),
    {ok, User}  = get_user(GameChan, Account, SDKArgs, GateSt#gate_st.sock),
    ZoneID = ut_conv:to_integer(maps:get("zone_id", SDKArgs)),
    {ok, Roles} = get_roles(User#game_user.roles, ZoneID, []),
    {ok,
        #m_login_verify_toc{career=recommend_career(), roles=Roles},
        GateSt#gate_st{state=?ST_SELECT, user=User, token=Token, sdk=SDKArgs}
    };

%% 创建角色
handle(?LOGIN_CREATE, Tos, GateSt = #gate_st{state=?ST_SELECT}) ->
    #m_login_create_tos{career=Career, gender=Gender, name=Name} = Tos,
    #gate_st{user=User} = GateSt,
    check_create(Career, Gender, Name, User),
    {ok, RoleID} = create_role(Career, Gender, Name, GateSt),
    User2 = User#game_user{roles=[RoleID | User#game_user.roles]},
    case sdk:route() of
        {junhai, _} ->
            spawn(fun() ->
                RoleNum = game_uid:guid2seqid(RoleID),
                FullNum = case game_env:get_plat() of
                    lianyun -> 1800;
                    qiji    -> 1200;
                    _       -> 9999999
                end,
                case RoleNum == FullNum of
                    true  ->
                        NextID = game_env:get_suid() + 1,
                        ?info("role num reach ~w, auto open next server: ~w", [RoleNum, NextID]),
                        Sign = ut_str:md5("qylh-" ++ ut_conv:to_list(NextID)),
                        web_request:get("/api/server/auto_open/~w/~s", [NextID, Sign]);
                    false ->
                        ignore
                end
            end),
            case
                game_env:get_plat() == lianyun andalso
                game_env:get_env(refund) == true andalso
                User#game_user.roles == [] andalso
                lists:keyfind(User#game_user.id, 1, cfg_cb_refund:all())
            of
                {_, PayGold} ->
                    GainGold = ut_math:ceil(PayGold * 2),
                    ?info("role=~w, refund=~w", [RoleID, GainGold]),
                    Title = "预充值活动返还",
                    Text  = "亲爱的勇士：\n欢迎来到惊险奇趣的泰坦城，与您一起冒险的契约就此达成！\n这是您在预充值活动中获得的钻石奖励，请您注意查收。愿您一路光芒万丈，无尽荣耀！\n那么，请尽情享受您的冒险之旅吧！",
                    mail:send(RoleID, 0, Title, Text, [{?ITEM_GOLD,GainGold}], 21, ?MAIL_TYPE_REFUND);
                false ->
                    ignore
            end;
        _ ->
            ignore
    end,
    {ok,
        #m_login_create_toc{role_id=RoleID},
        GateSt#gate_st{state=?ST_SELECT, user=User2}
    };

%% 进入游戏
handle(?LOGIN_ENTER, Tos, GateSt = #gate_st{sock=Sock, state=?ST_SELECT}) ->
    #m_login_enter_tos{role_id=RoleID} = Tos,
    #gate_st{gpid=GatePid, sock=Sock, user=User, ip=IP, sdk=SDKArgs} = GateSt,
    check_enter(RoleID, Sock, User),
    kickout_others(User, RoleID),
    ReconnToken = lists:concat(["TOKEN-",RoleID,"-",ut_time:milliseconds()]),
    {ok, RolePid, RoleName, Reason} =
        start_role(RoleID, GatePid, User, ReconnToken, IP, SDKArgs),
    #merge{suids=MergedSUIDs} = game_misc:read(merge, #merge{}),
    Toc = #m_login_enter_toc{
        suids = [game_env:get_suid() | MergedSUIDs],
        open  = game_env:get_opened_time(),
        merge = game_env:get_merged_time(),
        token = ReconnToken
    },
    log_api:login(RoleID, IP, ut_time:seconds(), Reason),
    log_api:log_device(RoleID, SDKArgs),
    {ok, Toc, GateSt#gate_st{
        role  = RoleID,
        name  = RoleName,
        rpid  = RolePid,
        state = ?ST_NORMAL
    }};

%% 随机取名
handle(?LOGIN_NAME, Tos, GateSt = #gate_st{state=?ST_SELECT}) ->
    #m_login_name_tos{gender=Gender} = Tos,
    {ok, Name} = role_manager:gen_name(Gender),
    {ok, #m_login_name_toc{name=Name}, GateSt};

%% 断线重连
handle(?LOGIN_RECONN, Tos, GateSt = #gate_st{state=?ST_VERIFY}) ->
    #m_login_reconn_tos{role_id=RoleID, token=Token} = Tos,
    RoleRef = role:get_ref(RoleID),
    case catch role_agent:reconn(RoleRef, self(), Token) of
        {ok, RolePid, RoleName, User} ->
            kickout_others(User, RoleID),
            {ok, #m_login_reconn_toc{}, GateSt#gate_st{
                user  = User,
                rpid  = RolePid,
                role  = RoleID,
                name  = RoleName,
                state = ?ST_NORMAL
            }};
        _ ->
            throw(?err(?ERR_LOGIN_TOKEN_EXPIRE))
    end;

%% 离开游戏
handle(?LOGIN_LEAVE, _Tos, GateSt = #gate_st{state=?ST_NORMAL}) ->
    role_agent:logout(GateSt#gate_st.rpid),
    {stop, normal, GateSt#gate_st{state=?ST_VERIFY}};

handle(MsgID, Tos, GateSt) ->
    ?error("unhandle package: ~w ~p ~p", [MsgID, Tos, GateSt]),
    throw(?err(?ERR_GAME_BAD_PKG)).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_login(GameChan, Account, Token, SDKArgs, IP) ->
    ?_check(game_entry:is_opened(), ?ERR_GAME_NOT_OPENED),
    case Token == ut_str:md5(lists:concat([Account, ?GM_LOGIN])) of
        true  ->
            ?debug(
                GameChan /= "develop",
                "login by gm: game_chan=~p, account=~p",
                [GameChan, Account]
            );
        false ->
            sdk:verify(GameChan, Account, Token, SDKArgs, IP)
    end.

get_user(GameChan, Account, Args, Sock) ->
    ChanGroup = cfg_game_channel:find(GameChan),
    GameChan2 = ?_if(ChanGroup == ?nil, GameChan, ut_conv:to_list(ChanGroup)),
    case db:dirty_read(?DB_GAME_USER, {GameChan2, Account}) of
        [R] ->
            {ok, R};
        []  ->
            User = init_user(GameChan2, Account, Sock, Args),
            {ok, User#game_user{gamechan=GameChan}}
    end.

init_user(GameChan, Account, Sock, Args) ->
    {ok, {IP, _}} = inet:peername(Sock),
    #game_user{
        id       = {GameChan, Account},
        gamechan = GameChan,
        account  = Account,
        game_id  = maps:get("game_id", Args, ""),
        chan_id  = maps:get("channel_id", Args, ""),
        type     = ?ACCOUNT_NM,
        regip    = inet:ntoa(IP),
        ctime    = ut_time:seconds(),
        roles    = []
    }.

get_roles([RoleID | T], ZoneID, Roles) ->
    [RoleInfo]  = db:dirty_read(?DB_ROLE_INFO, RoleID),
    case RoleInfo#role_info.zoneid == ZoneID of
        true  ->
            [RoleAttr]  = db:dirty_read(?DB_ROLE_ATTR, RoleID),
            [RoleVip]   = db:dirty_read(?DB_ROLE_VIP, RoleID),
            [RoleGuild] = db:dirty_read(?DB_ROLE_GUILD, RoleID),
            {Marry, MName, MType} = role_marriage:get_info(RoleID),
            Role = #p_role_base{
                id     = RoleID,
                name   = RoleInfo#role_info.name,
                career = RoleInfo#role_info.career,
                gender = RoleInfo#role_info.gender,
                level  = RoleInfo#role_info.level,
                viplv  = role_vip:get_level(RoleVip),
                power  = mod_attr:power(RoleAttr#role_attr.attr),
                guild  = RoleGuild#role_guild.id,
                gname  = guild:get_name(RoleGuild#role_guild.id),
                gpost  = RoleGuild#role_guild.post,
                figure = RoleInfo#role_info.figure,
                charm  = RoleInfo#role_info.charm,
                wake   = RoleInfo#role_info.wake,
                marry  = Marry,
                mname  = MName,
                mtype  = MType,
                icon   = RoleInfo#role_info.icon,
                suid   = RoleInfo#role_info.suid,
                zoneid = RoleInfo#role_info.zoneid,
                team   = RoleInfo#role_info.team
            },
            get_roles(T, ZoneID, [Role | Roles]);
        false ->
            get_roles(T, ZoneID, Roles)
    end;
get_roles([], _ZoneID, Roles) ->
    {ok, Roles}.

recommend_career() ->
    ?CAREER_SWORDMAN.

check_create(Career, Gender, Name, User) ->
    enum:check_career(Career),
    enum:check_gender(Gender),
    Num = length(User#game_user.roles),
    ?_check(Num < cfg_game:role_amount(), ?ERR_LOGIN_MAX_AMOUNT),
    check_name(Name),
    ok.

check_name(Name) ->
    {Min, Max} = cfg_game:role_name(),
    Len = ut_str:len(Name),
    ?_check(Len >= Min andalso Len =< Max, ?ERR_LOGIN_BAD_LENGTH),
    % Sensitive = ut_word:is_sensitive(Name, fun cfg_name_filter:find/1),
    % ?_check(not Sensitive, ?ERR_LOGIN_BAD_NAME),
    ok.

create_role(Career, Gender, Name, GateSt) ->
    #gate_st{user=User, ip=IP, sdk=SDKArgs} = GateSt,
    {ok, RoleID} = role_manager:create(Name),
    ZoneID = ut_conv:to_integer(maps:get("zone_id", SDKArgs, game_uid:suid2ssid())),
    Fun = fun() ->
        RoleInfo = init_info(RoleID, Name, Career, Gender, User, ZoneID),
        db:write(?DB_ROLE_INFO, RoleInfo, write),
        db:write(?DB_ROLE_ATTR, init_attr(RoleID, Career, Gender), write),
        db:write(?DB_ROLE_SITE, init_site(RoleID, Career, Gender), write),
        RoleVip = #role_vip{id=RoleID, invest=#{1 => #r_vip_invest{}}},
        db:write(?DB_ROLE_VIP, RoleVip, write),
        db:write(?DB_ROLE_GUILD, #role_guild{id=RoleID}, write),
        GameUser = #game_user{
            id       = User#game_user.id,
            gamechan = User#game_user.gamechan,
            account  = User#game_user.account,
            type     = User#game_user.type,
            regip    = User#game_user.regip,
            ctime    = User#game_user.ctime,
            roles    = [RoleID | User#game_user.roles]
        },
        db:write(?DB_GAME_USER, GameUser, write),
        {ok, RoleInfo, RoleVip, GameUser}
    end,
    case db:transaction(Fun) of
        {atomic, {ok, RoleInfo, RoleVip, GameUser}} ->
            try
                log_api:create_role(RoleInfo, RoleVip, GameUser),
                log_junhai:log_create(GameUser, IP, SDKArgs, {RoleInfo,RoleVip})
            catch Class:Reason:Stacktrace ->
                ?stacktrace(Class, Reason, Stacktrace)
            end,
            {ok, RoleID};
        {aborted, R} ->
            ?error("create role error: ~p", [R]),
            ?err(?ERR_GAME_SYS_ERROR)
    end.

init_info(RoleID, Name, Career, Gender, User, ZoneID) ->
    #role_info{
        id     = RoleID,
        userid = {User#game_user.gamechan, User#game_user.account},
        name   = Name,
        career = Career,
        gender = Gender,
        level  = 1,
        exp    = 0,
        wake   = 0,
        charm  = 0,
        figure = #{},
        pkmode = ?PKMODE_PEACE,
        crime  = 0,
        login  = 0,
        logout = 0,
        state  = ?ROLE_STATE_NORMAL,
        ctime  = ut_time:seconds(),
        icon   = role_util:default_icon(Gender),
        zoneid = ZoneID,
        team   = 0,
        suid   = game_env:get_suid()
    }.

init_attr(RoleID, _Career, _Gender) ->
    #role_attr{
        id    = RoleID,
        buffs = #{},
        power = 0,
        attr  = maps:from_list(cfg_role_level:attrs(1))
    }.

init_site(RoleID, _Career, _Gender) ->
    Village = cfg_game:village(),
    #role_site{
        id  = RoleID,
        cur = #site{
            scene = Village,
            room  = 0,
            coord = scene_util:get_born(Village)
        }
    }.

check_enter(RoleID, Sock, User) ->
    #game_user{gamechan=GameChan, account=Account, roles=RoleIDs} = User,
    ?_check(lists:member(RoleID, RoleIDs), ?ERR_LOGIN_NO_ROLE),
    {ok, {IP, _}} = inet:peername(Sock),
    ensure_not_banned(IP, lists:concat([GameChan, Account]), RoleID),
    ok.

ensure_not_banned(IP, Ac, ID) ->
    {ok, GameBan} = login_server:get_banned(),
    case lists:member(ID, GameBan#game_ban.white) of
        true  ->
            false;
        false ->
            % ?_check(not GameBan#game_ban.all, ?ERR_GAME_MAINTAIN),
            ?_check(
                not lists:member(IP, GameBan#game_ban.ip_addr),
                ?ERR_LOGIN_IP_BANNED
            ),
            ?_check(
                not lists:member(Ac, GameBan#game_ban.account),
                ?ERR_LOGIN_AC_BANNED
            ),
            ?_check(
                not lists:member(ID, GameBan#game_ban.role_id),
                ?ERR_LOGIN_ID_BANNED
            )
    end.

%% 启动角色进程
start_role(RoleID, GatePid, User, Token, IP, SDKArgs) ->
    case role_agent_sup:start_role(RoleID, GatePid) of
        {ok, RolePid} ->
            {ok, RoleName} = role_agent:load(RolePid, User, Token, IP, SDKArgs),
            {ok, RolePid, RoleName, ?LOGIN_NORMAL};
        {error, {already_started, RolePid}} ->
            case catch role_agent:relogin(RolePid, GatePid, Token) of
                {ok, RoleName} ->
                    {ok, RolePid, RoleName, ?LOGIN_RELOGIN};
                {'EXIT', noproc, _} ->
                    start_role(RoleID, GatePid, User, Token, IP, SDKArgs);
                Error ->
                    ?error("start role error: ~p", [Error]),
                    ?err(?ERR_GAME_SYS_ERROR)
            end;
        {error, Reason} ->
            ?error("start role error: ~p", [Reason]),
            ?err(?ERR_GAME_SYS_ERROR)
    end.

kickout_others(User, RoleID) ->
    lists:foreach(fun
        (OtherID) ->
            role:kickout(OtherID, ?ERR_GAME_LOGIN_ELSE)
    end, lists:delete(RoleID, User#game_user.roles)).
