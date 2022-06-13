%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_handler).

-include("game.hrl").
-include("pay.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("table.hrl").
-include("proto.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 已开放系统
handle(?GAME_SYSLIST, _Tos, RoleSt) ->
    #role_misc{sys_opened=Opened} = role_data:get(?DB_ROLE_MISC),
    {ok, #m_game_syslist_toc{syslist=Opened}, RoleSt};

%% 充值列表
handle(?GAME_PAYLIST, _Tos, RoleSt) ->
    #role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
    PaidList = lists:filter(fun
        (GoodsID) ->
            lists:keymember(GoodsID, #payment.goods_id, Payments)
    end, cfg_recharge:all()),
    ?ucast(#m_game_paylist_toc{paid=PaidList});

%% 充值信息
handle(?GAME_PAYINFO, Tos, RoleSt) ->
    #role_st{role=RoleID, user=User, sdk=SDKArgs} = RoleSt,
    #m_game_payinfo_tos{goods_id=GoodsID} = Tos,
    {ok, OrderID} = order_server:new_order(RoleID),
    GameChan = case sdk:route() of
        {junhai,_} ->
            maps:get("channel_id", SDKArgs,User#game_user.gamechan);
        _ ->
            User#game_user.gamechan
    end,
    ?ucast(#m_game_payinfo_toc{
        goods_id = GoodsID,
        order_id = ut_conv:to_list(OrderID),
        pay_back = sdk:payurl(GameChan)
    });

%% 世界等级
handle(?GAME_WORLDLV, _Tos, RoleSt) ->
    WorldLv = world_level:get_level(),
    ?ucast(#m_game_worldlv_toc{level=WorldLv});

%% 跑马灯
handle(?GAME_MARQUEE, _Tos, RoleSt) ->
    #role_st{user=User, sdk=SDKArgs} = RoleSt,
    GameChan = case sdk:route() of
        {junhai,_} ->
            maps:get("channel_id", SDKArgs,User#game_user.gamechan);
        _ ->
            User#game_user.gamechan
    end,
    List = marquee_manager:get(GameChan),
    ?ucast(#m_game_marquee_toc{list=List});

%% 每个档位当天的充值次数
handle(?GAME_PAYTIMES, _Tos, RoleSt) ->
    GoodsCountL = role_pay:get_all_pay_times(),
    Info = lists:map(fun
        (GoodsID) ->
            Count = case lists:keyfind(GoodsID, 1, GoodsCountL) of
                        {GoodsID, Count0} ->
                            Count0;
                        false ->
                            0
                    end,
            {GoodsID, Count}
%%            {GoodsID, role_count:get_times({?ROLE_COUNT_DAILY_RECHARGE,GoodsID})}
    end, cfg_recharge:all()),
%%    end, cfg_direct_purchase:all()),
    ?ucast(#m_game_paytimes_toc{times = maps:from_list(Info)}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
