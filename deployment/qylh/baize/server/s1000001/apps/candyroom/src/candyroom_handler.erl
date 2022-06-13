%% @author rong
%% @doc
-module(candyroom_handler).

-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("scene.hrl").
-include("enum.hrl").

-export([handle/3]).

handle(?CANDYROOM_BUY, Tos, RoleSt) ->
    #role_st{role=RoleID, spid=SPid} = RoleSt,
    #m_candyroom_buy_tos{num = Num} = Tos,
    BuyTimes = scene:sync_route(SPid, candyroom, get_buy_times, RoleID),
    ?_check(BuyTimes + Num =< cfg_candyroom:buy_time(), ?ERR_CANDYROOM_NO_BUY_TIMES),
    Cost = [{Item, N*Num} || {Item, N} <- [cfg_candyroom:buy_cost()]],
    Succ = fun() ->
        #role_st{spid=ScenePid, role=RoleID} = RoleSt,
        scene:route(ScenePid, candyroom, handle, {buy, RoleID, Num})
    end,
    role_bag:cost(Cost, ?LOG_CANDYROOM_BUY, Succ, RoleSt);

handle(_, Tos, RoleSt) ->
    #role_st{scene=SceneID, spid=ScenePid, role=RoleID} = RoleSt,
    case cfg_scene:find(SceneID) of
        #cfg_scene{stype=?SCENE_STYPE_CANDYROOM} ->
            scene:route(ScenePid, candyroom, handle, {Tos, RoleID});
        _ ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
