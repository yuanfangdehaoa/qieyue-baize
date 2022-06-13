%% @author rong
%% @doc
-module(yunying_lottery).

-include("yunying.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("mall.hrl").
-include("role.hrl").
-include("vip.hrl").
-include("errno.hrl").
-include("msgno.hrl").
-include("enum.hrl").
-include("log.hrl").

-export([hook_reset/3, handle/2, add_progress/4]).

hook_reset(_NowDoW, _NowHour, _RoleSt) ->
    RoleYYLottery = role_data:get(?DB_ROLE_YY_LOTTERY),
    Acts2 = maps:filter(fun(ActID, _) -> 
        case ActID > 0 of
            true ->
                Mod = yunying_util:cfg_act_mod(ActID),
                #cfg_yunying{clear=Clear} = Mod:find(ActID),
                case proplists:get_value(daily, Clear) of
                    Hour when is_integer(Hour) -> false;
                    _ -> true
                end;
            false ->
                false
        end
    end, RoleYYLottery#role_yy_lottery.acts),
    role_data:set(RoleYYLottery#role_yy_lottery{acts=Acts2}).

handle(#m_yunying_lottery_info_tos{act_id=ActID}, RoleSt) ->
    ?_check(yunying:is_start(ActID), ?ERR_YUNYING_NOT_START),
    YYLottery = get_lottery(ActID),
    ?ucast(#m_yunying_lottery_info_toc{
        act_id=ActID, items=YYLottery#yy_lottery.items, crack=total_times(YYLottery#yy_lottery.times),
        free_crack=free_crack(ActID), free_refresh=free_refresh(ActID)});

handle(#m_yunying_lottery_do_tos{act_id=ActID, pos=Pos}, RoleSt) ->
    ?_check(yunying:is_start(ActID), ?ERR_YUNYING_NOT_START),
    #yy_lottery{times=Times, items=Items} = YYLottery = get_lottery(ActID),
    case Pos of
        0 ->
            LotteryItems = lists:filter(fun({_Pos, Item}) ->
                Item#p_yy_lottery_item.reward_id == 0
            end, maps:to_list(Items)),
            ?_check(length(LotteryItems) > 0, ?ERR_YUNYING_LOTTERY_FETECH_ALL);
        _ ->
            Len = maps:size(Items),
            ?_check(Pos >= 0 andalso Pos =< Len, ?ERR_GAME_BAD_ARGS, [?YUNYING_LOTTERY_DO]),
            #p_yy_lottery_item{reward_id=RewardID0} = Item = maps:get(Pos, Items),
            ?_check(RewardID0 == 0, ?ERR_YUNYING_LOTTERY_ALREADY_FETCH),
            LotteryItems = [{Pos, Item}]
    end,
    {ok, RewardIds, YYLottery2, LotteryItems2} = do_lottery(ActID, LotteryItems, YYLottery, [], []),
    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{type=Type, reqs=Reqs} = Mod:find(ActID),
    Gain = to_gain(RewardIds),
    Cost = to_cost(Reqs, Times, length(RewardIds)),
    Succ = fun() ->
        #role_yy_lottery{acts=Acts} = RoleYYLottery = role_data:get(?DB_ROLE_YY_LOTTERY),
        Acts2 = maps:put(ActID, YYLottery2, Acts),
        role_data:set(RoleYYLottery#role_yy_lottery{acts=Acts2}),
        ?ucast(#m_yunying_lottery_do_toc{
            act_id=ActID, items=maps:from_list(LotteryItems2),
            crack=total_times(YYLottery2#yy_lottery.times),
            free_crack=free_crack(ActID), free_refresh=free_refresh(ActID)
        }),
        after_lottery(ActID, RewardIds, RoleSt),
        role_event:event(?EVENT_YY_LOTTERY, {ActID, length(RewardIds)})
    end,
    role_bag:deal(Cost, Gain, 1700*1000+Type, Succ, RoleSt);

handle(#m_yunying_lottery_refresh_tos{act_id=ActID}, RoleSt) ->
    ?_check(yunying:is_start(ActID), ?ERR_YUNYING_NOT_START),
    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{type=Type, reqs=Reqs} = Mod:find(ActID),
    #yy_lottery{free_refresh=FreeRefresh, items=Items} = YYLottery = get_lottery(ActID),
    FreeTimes = proplists:get_value(free_refresh, Reqs, 0),
    IsAllOpen = lists:all(fun(#p_yy_lottery_item{reward_id=RewardID}) ->
        RewardID =/= 0 end, maps:values(Items)),
    case IsAllOpen of
        true ->
            Cost = [],
            FreeRefresh2 = FreeRefresh;
        false ->
            case FreeTimes > FreeRefresh of
                true ->
                    Cost = [],
                    FreeRefresh2 = FreeRefresh+1;
                false ->
                    Cost = proplists:get_value(refresh, Reqs),
                    FreeRefresh2 = FreeRefresh
            end
    end,
    Succ = fun() ->
        YYLottery2 = refresh_yylottery(YYLottery),
        YYLottery3 = YYLottery2#yy_lottery{free_refresh=FreeRefresh2},
        #role_yy_lottery{acts=Acts} = RoleYYLottery = role_data:get(?DB_ROLE_YY_LOTTERY),
        Acts2 = maps:put(ActID, YYLottery3, Acts),
        role_data:set(RoleYYLottery#role_yy_lottery{acts=Acts2}),
        ?ucast(#m_yunying_lottery_refresh_toc{act_id=ActID,
            items=YYLottery3#yy_lottery.items, free_refresh=free_refresh(ActID)})
    end,
    role_bag:cost(Cost, 1700*1000+Type, Succ, RoleSt);

handle(#m_yunying_lottery_draw_tos{act_id=ActID, times=Count}, RoleSt) ->
    ?_check(yunying:is_start(ActID), ?ERR_YUNYING_NOT_START),
    #yy_lottery{times=Times} = YYLottery = get_lottery(ActID),
    {ok, RewardIds, YYLottery2} = draw_lottery(ActID, YYLottery, Count, []),
    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{type=Type, reqs=Reqs} = Mod:find(ActID),
    Gain = to_gain(RewardIds),
    Cost = to_cost(Reqs, Times, Count),
    Succ = fun() ->
        #role_yy_lottery{acts=Acts} = RoleYYLottery = role_data:get(?DB_ROLE_YY_LOTTERY),
        Acts2 = maps:put(ActID, YYLottery2, Acts),
        role_data:set(RoleYYLottery#role_yy_lottery{acts=Acts2}),
        ?ucast(#m_yunying_lottery_draw_toc{act_id=ActID, reward_ids=RewardIds}),
        after_lottery(ActID, RewardIds, RoleSt),
        role_event:event(?EVENT_YY_LOTTERY, {ActID, length(RewardIds)})
    end,
    role_bag:deal(Cost, Gain, 1700*1000+Type, Succ, RoleSt);

handle(#m_yunying_lotoinfo_tos{act_id=ActID}, RoleSt) ->
    ?_check(yunying:is_start(ActID), ?ERR_YUNYING_NOT_START),
    #yy_lottery{extra=Extra, rewards=Hits} = get_lottery(ActID),
    Round = maps:get(round, Extra, 1),
    Progress = maps:get(progress, Extra, 0),
    ?ucast(#m_yunying_lotoinfo_toc{
        act_id   = ActID,
        round    = Round,
        progress = Progress,
        hits     = Hits
    });

handle(#m_yunying_loto_tos{act_id=ActID}, RoleSt) ->
    ?_check(yunying:is_start(ActID), ?ERR_YUNYING_NOT_START),
    #yy_lottery{rewards=Rewards, extra=Extra} = YYLottery = get_lottery(ActID),
    Progress = maps:get(progress, Extra, 0),
    Group = maps:get(group, Extra, 1),

    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{type=Type, reqs=Reqs} = Mod:find(ActID),
    Cost = proplists:get_value(cost_progress, Reqs),
    ?_check(Progress >= Cost, ?ERR_YUNYING_LOTTERY_NOT_ENOUGH_PRO),
    Total = length(cfg_yunying_lottery_rewards:ids(ActID, Group, world_level:get_level())),
    ?_check(length(Rewards) < Total, ?ERR_YUNYING_LOTTERY_NO_REWARD),

    {ok, RewardId, YYLottery2} = lotto(ActID, YYLottery, Cost),
    Gain = to_gain([RewardId]),
    Succ = fun() ->
        #role_yy_lottery{acts=Acts} = RoleYYLottery = role_data:get(?DB_ROLE_YY_LOTTERY),
        Progress2 = maps:get(progress, YYLottery2#yy_lottery.extra),
        Acts2 = maps:put(ActID, YYLottery2, Acts),
        role_data:set(RoleYYLottery#role_yy_lottery{acts=Acts2}),
        ?ucast(#m_yunying_loto_toc{act_id=ActID, hit=RewardId, progress=Progress2}),
        after_lottery(ActID, [RewardId], RoleSt)
    end,
    role_bag:gain(Gain, 1700*1000+Type, Succ, RoleSt);

% 云购
handle(#m_yunying_shop_info_tos{act_id=ActID}, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    ?_check(yunying:is_start(ActID), ?ERR_YUNYING_NOT_START),
    {ok, ShopList, Logs} = yunying_shop_manager:get_info(ActID, RoleID),
    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{reqs=Reqs} = Mod:find(ActID),
    RewardHour = proplists:get_value(reward_hour, Reqs),
    UnlimitSec = proplists:get_value(unlimit_seconds, Reqs),
    RewardTime = ut_time:datetime_to_seconds({ut_time:date(), {RewardHour, 0, 0}}),
    ?ucast(#m_yunying_shop_info_toc{
        act_id      = ActID,
        list        = ShopList,
        logs        = Logs,
        reward_time = RewardTime,
        unlimit_sec = UnlimitSec
    });

handle(#m_yunying_shop_buy_tos{act_id=ActID, shop_id=ShopID, num=Num}, RoleSt) ->
    #role_st{role=RoleID, name=RoleName} = RoleSt,
    ?_check(yunying:is_start(ActID), ?ERR_YUNYING_NOT_START),
    YYLottery = get_lottery(ActID),
    #cfg_yunying_lottery_shop{category=Group} = cfg_yunying_lottery_shop:find(ActID, ShopID),

    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{type=Type, reqs=Reqs} = Mod:find(ActID),
    CostList1 = proplists:get_value(cost, Reqs),
    CostList2 = proplists:get_value(Group, CostList1),
    Cost = proplists:get_value(Num, CostList2, ?nil),
    ?_check(Cost =/= ?nil, ?ERR_GAME_BAD_ARGS, [?YUNYING_SHOP_BUY]),

    RewardHour = proplists:get_value(reward_hour, Reqs),
    RewardTime = ut_time:datetime_to_seconds({ut_time:date(), {RewardHour, 0, 0}}),
    ?_check(ut_time:seconds() < RewardTime, ?ERR_YUNYING_SHOP_ALREADY_REWARD),
 
    {ok, RewardIds, YYLottery2} = shop_buy(ActID, YYLottery, Group, Num, []),
    Gain = to_gain(RewardIds),
    Succ = fun() ->
        #role_info{suid=SUID} = role_data:get(?DB_ROLE_INFO),
        BroadcastIds = need_broadcast_rewards(RewardIds),
        {ok, Shop, NewLogs} = yunying_shop_manager:buy(RoleID, ActID, ShopID, 
            Num, RoleName, SUID, BroadcastIds),
        #role_yy_lottery{acts=Acts} = RoleYYLottery = role_data:get(?DB_ROLE_YY_LOTTERY),
        Acts2 = maps:put(ActID, YYLottery2, Acts),
        role_data:set(RoleYYLottery#role_yy_lottery{acts=Acts2}),
        ?ucast(#m_yunying_shop_buy_toc{act_id=ActID, shop=Shop, logs=NewLogs}),
        after_lottery(ActID, RewardIds, RoleSt)
    end,
    role_bag:deal([Cost], Gain, 1700*1000+Type, Succ, RoleSt);

handle(#m_yunying_shop_reward_log_tos{act_id=ActID}, RoleSt) ->
    ?_check(yunying:is_start(ActID), ?ERR_YUNYING_NOT_START),
    Logs = yunying_shop_manager:get_reward_logs(ActID),
    ?ucast(#m_yunying_shop_reward_log_toc{act_id=ActID, logs=Logs}).

add_progress(Log, Obtain, Gold, RoleSt) ->
    Num = case lists:member(Log, [?LOG_VIP_MCARD_BUY, ?LOG_VIP_INVEST_BUY]) of
        true  ->
            Gold*2;
        false ->
            if
                Log == ?LOG_VIP_ACTIVE ->
                    #cfg_vip_card{goods=GoodsID} = cfg_vip_card:find(4),
                    #cfg_mall{price=Cost} = cfg_mall:find(GoodsID),
                    Gold2 = proplists:get_value(?ITEM_GOLD, Cost),
                    case Gold == Gold2 of
                        true  -> Gold*2;
                        false -> Gold
                    end;
                Log == ?LOG_MALL_BUY ->
                    #cfg_vip_card{item=ItemID} = cfg_vip_card:find(4),
                    case lists:keymember(ItemID, #p_item.id, Obtain) of
                        true  -> Gold*2;
                        false -> Gold
                    end;
                true ->
                    Gold
            end
    end,
    [begin
        #yy_lottery{extra=Extra} = YYLottery = get_lottery(ActID),
        Mod = yunying_util:cfg_act_mod(ActID),
        #cfg_yunying{reqs=Reqs} = Mod:find(ActID),
        Max = proplists:get_value(max_progress, Reqs, 0),
        Progress0 = maps:get(progress, Extra, 0),
        Progress = min(Max, Num+Progress0),
        Extra2 = maps:put(progress, Progress, Extra),
        #role_yy_lottery{acts=Acts} = RoleYYLottery = role_data:get(?DB_ROLE_YY_LOTTERY),
        Acts2 = maps:put(ActID, YYLottery#yy_lottery{extra=Extra2}, Acts),
        role_data:set(RoleYYLottery#role_yy_lottery{acts=Acts2}),
        ?ucast(#m_yunying_loto_progress_toc{act_id=ActID, progress=Progress})
    end || ActID <- lotto_acts()].

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_lottery(ActID) when ActID > 0 ->
    #role_yy_lottery{acts=Acts} = RoleYYLottery = role_data:get(?DB_ROLE_YY_LOTTERY),
    case maps:find(ActID, Acts) of
        {ok, YYLottery} ->
            YYLottery;
        error ->
            YYLottery = refresh_yylottery(#yy_lottery{}),
            Acts2 = maps:put(ActID, YYLottery, Acts),
            role_data:set(RoleYYLottery#role_yy_lottery{acts=Acts2}),
            YYLottery
    end;
get_lottery(ActID) ->
    throw(?err(?ERR_GAME_BAD_ARGS, [?YUNYING_LOTTERY_INFO, ActID])).

refresh_yylottery(YYLottery) ->
    #yy_lottery{times=Times, bonus=HasBonus, items=Items} = YYLottery,
    TotalTimes = total_times(Times),
    IsFirstTime = maps:size(Items) == 0,
    YYLottery#yy_lottery{bonus=TotalTimes>=8, items=refresh_items(TotalTimes, HasBonus, IsFirstTime)}.

refresh_items(Times, HasBonus, IsFirstTime) ->
    Prob = if
        IsFirstTime -> 0;
        Times >= 8 andalso not HasBonus -> 100;
        true -> 72
    end,
    Random = ut_rand:random(1, 100),
    HasGroup2 = Prob >= Random,
    Items = if
        HasGroup2 ->
            [#p_yy_lottery_item{group=2, reward_id=0}|
                lists:duplicate(7, #p_yy_lottery_item{group=1, reward_id=0})];
        true -> lists:duplicate(8, #p_yy_lottery_item{group=1, reward_id=0})
    end,
    maps:from_list(lists:zip(lists:seq(1, 8), ut_rand:shuffle(Items))).

do_lottery(_ActID, [], YYLottery, RewardIDs, LotteryItems) ->
    {ok, RewardIDs, YYLottery, LotteryItems};
do_lottery(ActID, [{Pos, Item}|T], YYLottery, RewardIDs0, LotteryItems) ->
    #p_yy_lottery_item{group=Group} = Item,
    Pool = lottery_pool(ActID, Group, YYLottery),
    RewardID = ut_rand:weight(Pool),
    #yy_lottery{times=Times, items=Items, rewards=Rewards} = YYLottery,
    Item2 = Item#p_yy_lottery_item{reward_id=RewardID},
    YYLottery2 = YYLottery#yy_lottery{
        times   = ut_misc:maps_increase(Group, 1, Times),
        items   = maps:put(Pos, Item2, Items),
        rewards = [RewardID|Rewards]
    },
    do_lottery(ActID, T, YYLottery2, [RewardID|RewardIDs0], [{Pos, Item2}|LotteryItems]).

lottery_pool(ActID, Group, #yy_lottery{rewards=Rewards, times=Times0}) ->
    Ids = cfg_yunying_lottery_rewards:ids(ActID, Group, world_level:get_level()),
    Times = maps:get(Group, Times0, 0) + 1,
    {_, Pools} = lists:foldl(fun(Id, {Flag, Acc}) ->
        case Flag of
            false ->
                #cfg_yunying_lottery_rewards{prob=Prob, absolute=Absolute} = cfg_yunying_lottery_rewards:find(Id),
                {Min, Max, Plus, Weight} = Prob,
                Weight2 = case Times >= Min of
                    true ->
                        case Times =< Max of
                            true ->
                                case not lists:member(Id, Rewards) of
                                    true  -> Weight + Plus;
                                    false -> 0
                                end;
                            false ->
                                Weight
                        end;
                    false ->
                        0
                end,
                case Weight2 > 0 of
                    true ->
                        case Absolute > 0 andalso Times == Absolute of
                            true  -> {true, [{Id, Weight2}]};
                            false -> {Flag, [{Id, Weight2}|Acc]}
                        end;
                    false -> 
                        {Flag, Acc}
                end;
            true ->
                {true, Acc}
        end
    end, {false, []}, Ids),
    Pools.

draw_lottery(_ActID, YYLottery, 0, RewardIds) ->
    {ok, RewardIds, YYLottery};
draw_lottery(ActID, YYLottery, Count, RewardIDs0) ->
    #yy_lottery{times=Times, rewards=Rewards} = YYLottery,
    Group = calc_group(ActID, Times),
    Pool = lottery_pool(ActID, Group, YYLottery),
    RewardID = ut_rand:weight(Pool),
    YYLottery2 = YYLottery#yy_lottery{
        times   = ut_misc:maps_increase(Group, 1, Times),
        rewards = [RewardID|Rewards]
    },
    draw_lottery(ActID, YYLottery2, Count-1, [RewardID|RewardIDs0]).

lotto(ActID, YYLottery, CostProgress) ->
    #yy_lottery{times=Times, rewards=Rewards, extra=Extra} = YYLottery,
    Group = maps:get(round, Extra, 1),
    Pool = lottery_pool(ActID, Group, YYLottery),
    RewardID = ut_rand:weight(Pool),
    Extra2 = ut_misc:maps_increase(progress, -CostProgress, Extra),
    RewardIDs = [RewardID|Rewards],
    Count = length(RewardIDs),
    Total = length(cfg_yunying_lottery_rewards:ids(ActID, Group, world_level:get_level())),
    HasNextRound = cfg_yunying_lottery_rewards:ids(ActID, Group+1, world_level:get_level()) =/= [],
    Extra3 = case Count == Total of
        true ->
            case HasNextRound of
                true -> ut_misc:maps_increase(round, 1, Extra2);
                false -> maps:put(round, Group, Extra2)
            end;
        false ->
            maps:put(round, Group, Extra2)
    end,
    YYLottery2 = YYLottery#yy_lottery{
        times   = ut_misc:maps_increase(Group, 1, Times),
        rewards = ?_if(Count == Total andalso HasNextRound, [], RewardIDs),
        extra   = Extra3
    },
    {ok, RewardID, YYLottery2}.

shop_buy(_ActID, YYLottery, _Group, 0, RewardIds) ->
    {ok, RewardIds, YYLottery};
shop_buy(ActID, YYLottery, Group, Count, RewardIDs0) ->
    #yy_lottery{times=Times, rewards=Rewards} = YYLottery,
    Pool = lottery_pool(ActID, Group, YYLottery),
    RewardID = ut_rand:weight(Pool),
    YYLottery2 = YYLottery#yy_lottery{
        times   = ut_misc:maps_increase(Group, 1, Times),
        rewards = [RewardID|Rewards]
    },
    shop_buy(ActID, YYLottery2, Group, Count-1, [RewardID|RewardIDs0]).

to_gain(RewardIds) ->
    lists:flatten([begin
        #cfg_yunying_lottery_rewards{rewards=Rewards} = cfg_yunying_lottery_rewards:find(RewardId),
        Rewards
    end || RewardId <- RewardIds]).

to_cost(Reqs, Times, Count) ->
    TotalTimes = total_times(Times),
    [Cost] = proplists:get_value(cost, Reqs),
    Free = proplists:get_value(free, Reqs, 0),
    case TotalTimes > Free of
        true ->
            lists:duplicate(Count, Cost);
        false ->
            FreeTimes = max(0, Free-TotalTimes),
            lists:duplicate(max(0, Count-FreeTimes), Cost)
    end.

free_crack(ActID) ->
    #yy_lottery{times=Times} = get_lottery(ActID),
    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{reqs=Reqs} = Mod:find(ActID),
    Free = proplists:get_value(free, Reqs, 0),
    max(0, Free-total_times(Times)).

free_refresh(ActID) ->
    #yy_lottery{free_refresh=FreeRefresh, items=Items} = get_lottery(ActID),
    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{reqs=Reqs} = Mod:find(ActID),
    FreeTimes = proplists:get_value(free_refresh, Reqs, 0),
    IsAllOpen = lists:all(fun(#p_yy_lottery_item{reward_id=RewardID}) ->
        RewardID =/= 0 end, maps:values(Items)),
    case IsAllOpen of
        true ->
            1;
        false ->
            max(0, FreeTimes-FreeRefresh)
    end.

after_lottery(ActID, RewardIDs, RoleSt) ->
    lists:foreach(fun(RewardID) ->
        #cfg_yunying_lottery_rewards{rewards=Rewards, is_broadcast=BroadCast,
            is_all=IsAll} = cfg_yunying_lottery_rewards:find(RewardID),
        {ItemId, Num} = format_rewards(hd(Rewards)),
        %全服记录
        case IsAll == 1 of
            true ->
                Log = #p_yy_log{
                    role_id   = RoleSt#role_st.role,
                    role_name = RoleSt#role_st.name,
                    item_id   = ItemId,
                    item_num  = Num
                },
                game_logger:add_log({yunying_logs, ActID}, Log),
                ?ucast(#m_yunying_logs_update_toc{act_id=ActID, log=Log});
            false ->
                ignore
        end,
        %广播
        case BroadCast > 0 of
            true ->
                Mod = yunying_util:cfg_act_mod(ActID),
                #cfg_yunying{name=YYName} = Mod:find(ActID),
                Panel = Mod:panel(ActID),
                ItemMap = maps:put(ItemId, Num, #{}),
                MsgNo = if
                    BroadCast == 1 -> ?MSG_YUNYING_LOTTERY;
                    true -> BroadCast
                end,
                ?notify(MsgNo, [
                    {role, RoleSt#role_st.role, RoleSt#role_st.name},
                    YYName,
                    {item, ItemMap},
                    Panel
                ]);
            false ->
                ignore
        end
    end, RewardIDs).

format_rewards(Reward)->
    #role_info{career=Career} = role_data:get(?DB_ROLE_INFO),
    {ItemId2, Num2} = case Reward of
        {ItemId, Num} ->
            {ItemId, Num};
        {ItemId, Num, _Opts} ->
            {ItemId, Num}
    end,
    ItemId3 = case is_list(ItemId2) of
        true  -> lists:nth(Career, ItemId2);
        false -> ItemId2
    end,
    {ItemId3, Num2}.

total_times(Times) ->
    lists:sum(maps:values(Times)).

calc_group(ActID, Times) ->
    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{reqs=Reqs} = Mod:find(ActID),
    Groups0 = proplists:get_value(groups, Reqs),
    Total = total_times(Times) + 1,
    Groups = lists:reverse(lists:sort(Groups0)),
    calc_group_1(Total, Groups).

calc_group_1(_Total, []) ->
    no_group;
calc_group_1(Total, [H|T]) ->
    Rem = Total rem H,
    if
        Rem == 0 -> H;
        true -> calc_group_1(Total, T)
    end.

lotto_acts() ->
    % 定死750类型为转盘
    lists:filter(fun(ActID) ->
        yunying:is_start(ActID)
    end, cfg_yunying:type(750) ++ cfg_festival:type(750)).

need_broadcast_rewards(RewardIds) ->
    lists:filter(fun(RewardID) ->
        #cfg_yunying_lottery_rewards{is_broadcast=BroadCast} = cfg_yunying_lottery_rewards:find(RewardID),
        BroadCast > 0
    end, RewardIds).
