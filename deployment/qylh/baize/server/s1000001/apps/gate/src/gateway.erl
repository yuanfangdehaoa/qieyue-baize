%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(gateway).

-include("game.hrl").
-include("scene.hrl").

%% API
-export([decode/1]).
-export([encode/1]).
-export([send/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 解包
-spec decode(binary()) ->
    {
    	ok,
    	ModID :: integer(),
    	MsgID :: integer(),
    	Tos   :: tuple()
    }.
%%-----------------------------------------------
decode(<<MsgID:32, Bin/binary>>) ->
    {ok, ModID, Tos} = proto:decode(MsgID, Bin),
    {ok, ModID, MsgID, Tos}.


%%-----------------------------------------------
%% @doc 封包
-spec encode(tuple()) ->
    {ok, binary()}.
%%-----------------------------------------------
encode(Toc) ->
    proto:encode(element(1, Toc), Toc).


%%-----------------------------------------------
%% @doc 发送数据
-spec send(pid() | integer(), tuple()) ->
    no_return().
%%-----------------------------------------------
send(GatePid, Toc) when is_pid(GatePid) ->
    gen_server:cast(GatePid, {send,Toc});
send(RoleID, Toc) when is_integer(RoleID) ->
    case scene_util:in_scene() of
        true  ->
            case scene_actor:get_actor(RoleID) of
                ?nil  -> ignore;
                Actor -> role:cast(Actor#actor.pid, {send,Toc})
            end;
        false ->
            role:cast(RoleID, {send,Toc})
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
