%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(gateway_agent).

-behaviour(gen_server).

-include("game.hrl").
-include("gate.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/4]).
-export([ensure_connect/0, ensure_connect/1]).

-define(PACKET, 4).
-define(ACTIVE, 100).

% 最多容忍多少次非法数据包
-define(MAX_BADPKG, 5).
% 每5秒发多少个包视为正常
-define(STD_RECV, 250).
% 最多容忍连续多少次快速发包
-define(MAX_FASTER, 5).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link(Ref, Sock, Trans, Opts) ->
    gen_server:start_link(?MODULE, {Ref, Sock, Trans, Opts}, []).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({Ref, Sock, Trans, _Opts}) ->
    process_flag(trap_exit, true),
    Trans:setopts(Sock, [
        {packet, ?PACKET},
        {active, ?ACTIVE},
        {nodelay, true},
        {delay_send, false}
    ]),
    self() ! {start, Ref},
    case inet:peername(Sock) of
        {ok, {IP, _}} ->
            {ok, #gate_st{
                gpid  = self(),
                trans = Trans,
                sock  = Sock,
                ip    = IP,
                state = ?ST_VERIFY,
                recv1 = 0,
                recv2 = 0,
                error = 0,
                fast  = 0
            }};
        {error, Err} ->
            {stop, {shutdown, Err}}
    end.


handle_call(Req, _From, GateSt) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, GateSt}.


%% 发送数据
handle_cast({send, Toc}, GateSt) ->
    send_to_client(Toc, GateSt),
    {noreply, GateSt};

handle_cast(Msg, GateSt) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, GateSt}.


%% 处理数据包
handle_info({tcp, _, Bin}, GateSt) ->
    {ok, ModID, MsgID, Tos} = gateway:decode(Bin),
    gateway_tracer:trace(GateSt#gate_st.role, Tos),
    try gateway_handler:handle(ModID, MsgID, Tos, GateSt) of
        {ok, Toc, GateSt2} ->
            send_to_client(Toc, GateSt2),
            {noreply, GateSt2};
        {ok, GateSt2} ->
            {noreply, GateSt2};
        {stop, Reason, GateSt2} ->
            {stop, Reason, GateSt2};
        _ ->
            {noreply, GateSt}
    catch
        throw:{error, ?ERR_GAME_BAD_PKG, Args}:_ ->
            send_error(?ERR_GAME_BAD_PKG, Args, GateSt),
            ErrTimes = GateSt#gate_st.error + 1,
            case ErrTimes >= ?MAX_BADPKG of
                true  ->
                    {stop, {shutdown,?ERR_GAME_BAD_PKG}, GateSt};
                false ->
                    {noreply, GateSt#gate_st{error=ErrTimes}}
            end;
        throw:{error, Errno, Args}:_ ->
            send_error(Errno, Args, GateSt),
            {noreply, GateSt};
        error:{badmatch, {error, Errno, Args}}:_ ->
            send_error(Errno, Args, GateSt),
            {noreply, GateSt};
        Class:Reason:Stacktrace ->
            ?stacktrace(Class, Reason, Stacktrace),
            {stop, Reason, GateSt}
    end;

handle_info({tcp_passive, Sock}, GateSt) ->
    #gate_st{trans=Trans} = GateSt,
    Trans:setopts(Sock, [{active,?ACTIVE}]),
    {noreply, GateSt};

%% 检测发包速率
handle_info(ensure_steady, GateSt) ->
    ensure_steady(),
    #gate_st{sock=Sock, recv2=OldCnt, fast=ErrFast} = GateSt,
    {ok, [{recv_cnt, NewCnt}]} = inet:getstat(Sock, [recv_cnt]),
    RcvCnt = NewCnt - OldCnt,
    if
        RcvCnt >= ?STD_RECV * 2.0 ->
            send_error(?ERR_GAME_TOO_FAST, [], GateSt),
            {stop, {shutdown, too_fast}, GateSt};
        RcvCnt >= ?STD_RECV * 1.5 ->
            maybe_too_fast(ErrFast+2, NewCnt, GateSt);
        RcvCnt > ?STD_RECV ->
            maybe_too_fast(ErrFast+1, NewCnt, GateSt);
        true ->
            {noreply, GateSt#gate_st{fast=0, recv2=NewCnt}}
    end;

%% 检测心跳包
handle_info(ensure_connect, GateSt) ->
    #gate_st{sock=Sock, recv1=OldCnt} = GateSt,
    {ok, [{recv_cnt, NewCnt}]} = inet:getstat(Sock, [recv_cnt]),
    case NewCnt == OldCnt of
        true ->
            send_error(?ERR_GAME_NO_HEART, [], GateSt),
            {stop, {shutdown, no_heart}, GateSt};
        false ->
            TRef = ensure_connect(),
            {noreply, GateSt#gate_st{recv1=NewCnt, heart=TRef}}
    end;

%% 5分钟后未开始游戏则断开链接
handle_info(ensure_playing, GateSt = #gate_st{state=?ST_NORMAL}) ->
    {noreply, GateSt};
handle_info(ensure_playing, GateSt) ->
    send_error(?ERR_GAME_NOT_LOGIN, [], GateSt),
    {stop, {shutdown, not_login}, GateSt};

%% 开启网关
handle_info({start, Ref}, GateSt) ->
    ok = ranch:accept_ack(Ref),
    ensure_playing(),
    ensure_steady(),
    TRef = ensure_connect(),
    {noreply, GateSt#gate_st{heart=TRef}};

%% 客户端断开连接
handle_info({tcp_closed, _Sock}, GateSt) ->
    {stop, normal, GateSt};

%% 踢掉玩家
handle_info({'EXIT', _, {kickout, Errno}}, GateSt) ->
    send_error(Errno, [], GateSt),
    {stop, {shutdown, {kickout, Errno}}, GateSt};

%% 角色进程挂掉
handle_info({'EXIT', _, Reason}, GateSt) ->
    send_error(?ERR_GAME_SYS_ERROR, [], GateSt),
    {stop, Reason, GateSt};

handle_info({inet_reply, _Sock, ok}, State) ->
    {noreply, State};

handle_info({inet_reply, _Sock, Result}, State) ->
    ?error("socket error:~w", [Result]),
    {stop, normal, State};

handle_info(Info, GateSt) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, GateSt}.


terminate(Reason, GateSt) ->
    #gate_st{role=RoleID, ip=IP, trans=Trans, sock=Sock} = GateSt,
    Code = logout_code(Reason),
    ?_if(Code == ?LOGOUT_TOOFAST, mail:send(RoleID, ?MAIL_GAME_TOO_FAST)),
    ?_if(RoleID /= ?nil, log_api:logout(RoleID, IP, Code)),
    ?debug("gateway terminate:~p", [{RoleID, Reason}]),
    Trans:close(Sock),
    ok.

code_change(_OldVsn, GateSt, _Extra) ->
    {ok, GateSt}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
ensure_connect() ->
    ensure_connect(normal).

ensure_connect(ClientSt) ->
    Time = case ClientSt of
        normal  -> timer:seconds(20);
        suspend -> timer:minutes(5)
    end,
    erlang:send_after(Time, self(), ensure_connect).

ensure_playing() ->
    erlang:send_after(timer:minutes(5), self(), ensure_playing).

ensure_steady() ->
    erlang:send_after(timer:seconds(5), self(), ensure_steady).

maybe_too_fast(ErrFast, RcvCnt, GateSt) ->
    case ErrFast >= ?MAX_FASTER of
        true  ->
            send_error(?ERR_GAME_TOO_FAST, [], GateSt),
            {stop, {shutdown, too_fast}, GateSt};
        false ->
            {noreply, GateSt#gate_st{fast=ErrFast, recv2=RcvCnt}}
    end.

send_error(Errno, Args, GateSt) ->
    Toc = #m_game_error_toc{errno=Errno, args=Args},
    send_to_client(Toc, GateSt).

send_to_client(Data, #gate_st{role=RoleID, sock=Sock}) ->
    gateway_tracer:trace(RoleID, Data),
    case is_binary(Data) of
        true  ->
            erlang:port_command(Sock, Data, []);
        false ->
            {ok, Bin} = gateway:encode(Data),
            erlang:port_command(Sock, Bin, [])
    end.


logout_code(Reason) ->
    case Reason of
        normal   -> ?LOGOUT_NORMAL;
        shutdown -> ?LOGOUT_NORMAL;
        {shutdown, {kickout, ?ERR_GAME_LOGIN_ELSE}}   -> ?LOGOUT_RELOGIN;
        {shutdown, {kickout, ?ERR_GAME_KICKOUT}}      -> ?LOGOUT_KICKOUT;
        {shutdown, {kickout, ?ERR_GAME_KICKOUT_FCM}}  -> ?LOGOUT_FCM;
        {shutdown, {kickout, ?ERR_GAME_KICKOUT_FCM2}} -> ?LOGOUT_FCM;
        {shutdown, too_fast} -> ?LOGOUT_TOOFAST;
        {shutdown, no_heart} -> ?LOGOUT_NOHREAT;
        _ -> ?LOGOUT_UNKNOWN
    end.