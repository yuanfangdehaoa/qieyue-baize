%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_pool).

-include("game.hrl").
-include("scene.hrl").

-behaviour(poolboy_worker).

%% API
-export([start_link/1]).
-export([bc_to_gate/2]).
-export([bc_to_role/2]).
-export([loop/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link(Args) ->
    Pid = spawn_link(?MODULE, loop, [Args]),
    {ok, Pid}.

%%-----------------------------------------------
%% @doc 广播到网关进程
-spec bc_to_gate(list(), tuple()) ->
    no_return().
%%-----------------------------------------------
bc_to_gate([], _Toc) ->
    ok;
bc_to_gate(RoleIDs, Toc) ->
    SendTo = conv2pids(RoleIDs),
    poolboy:transaction(?MODULE, fun(Worker) ->
        Worker ! {bc_to_gate, SendTo, Toc}
    end).


%%-----------------------------------------------
%% @doc 广播到角色进程
-spec bc_to_role(list(), any()) ->
    no_return().
%%-----------------------------------------------
bc_to_role([], _Msg) ->
    ok;
bc_to_role(RoleIDs, Msg) ->
    SendTo = conv2pids(RoleIDs),
    poolboy:transaction(?MODULE, fun(Worker) ->
        Worker ! {bc_to_role, SendTo, Msg}
    end).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
loop(Args) ->
    receive
        {bc_to_gate, RoleIDs, Toc} ->
            {ok, Bin} = gateway:encode(Toc),
            [?ucast(RoleID, Bin) || RoleID <- RoleIDs];
        {bc_to_role, RoleIDs, Msg} ->
            [role:cast(RoleID, Msg) || RoleID <- RoleIDs];
        Other ->
        	?error("unhandle info: ~p", [Other])
    end,
    ?MODULE:loop(Args).

conv2pids(RoleIDs) ->
    case scene_util:in_scene() of
        true  ->
            lists:filtermap(fun
                (RoleID) ->
                    case scene_actor:get_actor(RoleID) of
                        ?nil  ->
                            false;
                        Actor ->
                            case Actor#actor.pid of
                                ?nil -> false;
                                Pid  -> {true, Pid}
                            end
                    end
            end, RoleIDs);
        false ->
            RoleIDs
    end.
