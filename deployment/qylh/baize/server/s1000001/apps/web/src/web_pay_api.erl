%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(web_pay_api).

-include("game.hrl").
-include("errno.hrl").

%% API
-export([pay/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
pay(Req) ->
    Fields = [
        {sdk_order, fun web_util:string/2},
        {app_order, fun web_util:string/2},
        {role_id, int},
        {goods_id, fun web_util:string/2},
        {total_fee, fun web_util:double/2},
        {pay_type, int},
        {game_gold, int},
        {extra_gold, int}
    ],
    Params = cowboy_req:match_qs(Fields, Req),
    #{role_id:=RoleID, goods_id:=GoodsID, total_fee:=TotalFee} = Params,
    web_util:validate_sign([RoleID, GoodsID, TotalFee], Req),
    ?debug("-------------pay:~w", [RoleID]),
    ?_check(role:is_exist(RoleID), ?ERR_LOGIN_NO_ROLE),
    % ?_check(order_server:is_order(AppOrder), ?ERR_GAME_NO_ORDER),
    Params2 = maps:put(is_real, true, Params),
    ?debug("-------------pay:~p", [Params2]),
    role:route(RoleID, role_pay, pay, Params2, Params2),
    web_reply:ok(Req).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
