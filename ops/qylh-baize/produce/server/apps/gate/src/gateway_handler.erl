%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(gateway_handler).

-include("game.hrl").
-include("gate.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([handle/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 心跳包
handle(_ModID, ?GAME_HEART, _Tos, GateSt) ->
    {ok, #m_game_heart_toc{}, GateSt};

%% 服务器时间
handle(_ModID, ?GAME_TIME, _Tos, GateSt) ->
    Millis = ut_time:milliseconds(),
    TZone  = ut_time:timezone(),
    {ok, #m_game_time_toc{time=Millis, tz=TZone}, GateSt};

%% 游戏挂起(前端调用摄像头等)
handle(_ModID, ?GAME_SUSPEND, _Tos, GateSt) ->
    #gate_st{heart=OldRef, sock=Sock} = GateSt,
    ut_misc:cancel_timer(OldRef),
    NewRef = gateway_agent:ensure_connect(suspend),
    {ok, [{recv_cnt, NewCnt}]} = inet:getstat(Sock, [recv_cnt]),
    {ok, GateSt#gate_st{recv1=NewCnt, heart=NewRef}};

%% 游戏唤醒
handle(_ModID, ?GAME_AWAKE, _Tos, GateSt) ->
    #gate_st{heart=OldRef, sock=Sock} = GateSt,
    ut_misc:cancel_timer(OldRef),
    NewRef = gateway_agent:ensure_connect(),
    {ok, [{recv_cnt, NewCnt}]} = inet:getstat(Sock, [recv_cnt]),
    {ok, GateSt#gate_st{heart=NewRef, recv1=NewCnt}};

%% 客户端错误
handle(_ModID, ?GAME_CLIENTERROR, Tos, GateSt) ->
    #m_game_clienterror_tos{error=ErrStr} = Tos,
    #gate_st{role=RoleID, name=RoleName} = GateSt,
    Action = #{error => ut_conv:to_binary(ErrStr)},
    role_logger:log(?ROLELOG_CLIENT_ERROR, Action, RoleID, RoleName),
    {ok, GateSt};

%% 前端端时间同步
handle(_ModID, ?GAME_CLIENTTIME, _Tos, GateSt) ->
    {ok, GateSt};

%% 新手地图资源
handle(_ModID, ?GAME_NEWBIE_SCENE, _Tos, GateSt) ->
    ResID = cfg_game:newbie_scene(),
    {ok, #m_game_newbie_scene_toc{res_id=ResID}, GateSt};

%% GM 指令
handle(_ModID, ?GAME_CHEAT, Tos, GateSt) ->
    Msg = {pt, game_cheat, ?GAME_CHEAT, Tos},
    gen_server:cast(GateSt#gate_st.rpid, Msg);

%% 登录
handle(?LOGIN, MsgID, Tos, GateSt) ->
    login_handler:handle(MsgID, Tos, GateSt);

%% 协议转发
handle(ModID, MsgID, Tos, GateSt = #gate_st{state=?ST_NORMAL}) ->
    Mod = gateway_router:route(ModID),
    Msg = {pt, Mod, MsgID, Tos},
    gen_server:cast(GateSt#gate_st.rpid, Msg),
    check_spite_args(Mod, MsgID, Tos);

handle(_ModID, MsgID, Tos, _GateSt) ->
    ?error("unhandle package: ~w ~p", [MsgID, Tos]),
    throw(?err(?ERR_GAME_BAD_PKG)).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_spite_args(scene_handler, _MsgID, _Tos) ->
    ignore;
check_spite_args(Mod, MsgID, Tos) when is_tuple(Tos) ->
    case lists:any(
        fun(Arg) when is_integer(Arg) ->
            Arg < 0;
            (_) ->
                false
        end, erlang:tuple_to_list(Tos)
    ) of
        true ->
            ?error("spite package: ~w ~w ~p", [Mod, MsgID, Tos]);
        false ->
            ignore
    end;

check_spite_args(_Mod, _MsgID, _Tos) ->
    ignore.