%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(item_effect).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("item.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("bag.hrl").

%% API
-export([effect/6]).
-export([calc_lvgift_reward/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 升级丹
effect(?ITEM_STYPE_LEVEL, _ItemID, LvAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_LEVEL, LvAdd*Num}]};
%% 固定经验丹
effect(?ITEM_STYPE_EXP, _ItemID, ExpAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_EXP, ExpAdd*Num}]};
%% 经验直升丹
effect(?ITEM_STYPE_EXP2, _ItemID, {LvLim, ExpAdd}, Num, _Args, _RoleSt) ->
    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    LvAdd = min(Num, max(0, LvLim - RoleLv)),
    if
        LvAdd == Num ->
            {gain, [{?ITEM_LEVEL, LvAdd}]};
        LvAdd > 0 ->
            {gain, [{?ITEM_LEVEL, LvAdd}, {?ITEM_EXP, (Num-LvAdd)*ExpAdd}]};
        true ->
            {gain, [{?ITEM_EXP, ExpAdd*Num}]}
    end;
%% 等级经验丹
effect(?ITEM_STYPE_EXP3, _ItemID, {Coef, MinExp}, Num, _Args, _RoleSt) ->
    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    ExpAdd = max(round(cfg_role_level:exp(RoleLv)*Coef*Num), MinExp),
    {gain, [{?ITEM_EXP, ExpAdd}]};
%% 等级经验丹
effect(?ITEM_STYPE_EXP4, _ItemID, Coef, Num, _Args, _RoleSt) ->
    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    #cfg_exp_acti_base{role_exp=Exp} = cfg_exp_acti_base:find(RoleLv),
    ExpAdd = round(Exp * Coef * Num),
    {gain, [{?ITEM_EXP, ExpAdd}]};
%% 元宝卡
effect(?ITEM_STYPE_GOLD, _ItemID, GoldAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_GOLD, GoldAdd*Num}]};
%% 绑定元宝卡
effect(?ITEM_STYPE_BGOLD, _ItemID, BGoldAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_BGOLD, BGoldAdd*Num}]};
%% 金币卡
effect(?ITEM_STYPE_COIN, _ItemID, CoinAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_COIN, CoinAdd*Num}]};
%% 绑定金币卡
effect(?ITEM_STYPE_BCOIN, _ItemID, BCoinAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_BCOIN, BCoinAdd*Num}]};
%% 声望卡
effect(?ITEM_STYPE_FAME, _ItemID, FameAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_FAME, FameAdd*Num}]};
%% 荣誉卡
effect(?ITEM_STYPE_HONOR, _ItemID, HonorAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_HONOR, HonorAdd*Num}]};
%% 功勋卡
effect(?ITEM_STYPE_FEAT, _ItemID, FeatAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_FEAT, FeatAdd*Num}]};
%% 威望卡
effect(?ITEM_STYPE_MANA, _ItemID, ManaAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_MANA, ManaAdd*Num}]};
%% 威望卡
effect(?ITEM_STYPE_CTRB, _ItemID, ContribAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_CONTRIB, ContribAdd*Num}]};
%% 图鉴精华卡
effect(?ITEM_STYPE_ILLUS_ESSENCE, _ItemID, Add, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_ILLUS_ESSENCE, Add*Num}]};
%% 经验卡
effect(?ITEM_STYPE_EXP_CARD, _ItemID, BuffID, Num, _Args, RoleSt) ->
    {func, fun() -> buff:add(lists:duplicate(Num, BuffID), RoleSt) end};
%% vip卡
effect(?ITEM_STYPE_VIP_CARD, _ItemID, CardID, _Num, _Args, RoleSt) ->
    {func, fun() -> role_vip:active(CardID, RoleSt) end};
% 礼包
effect(?ITEM_STYPE_GIFT, ItemID, _Eff, Num, Args, RoleSt) ->
    #cfg_item_gift{type=Type} = cfg_item_gift:find(ItemID),
    open_gift(Type, ItemID, Num, Args, RoleSt);
% 等级礼包
effect(?ITEM_STYPE_LEVEL_GIFT, ItemID, _Eff, Num, Args, RoleSt) ->
    #cfg_item_gift{type=Type} = cfg_item_gift:find(ItemID),
    open_gift(Type, ItemID, Num, Args, RoleSt);
% 星力
effect(?ITEM_STYPE_MC_HUNT, _ItemID, McHuntAdd, Num, _Args, _RoleSt) ->
    {gain, [{?ITEM_MC_HUNT, McHuntAdd*Num}]};
% 挂机卡
effect(?ITEM_STYPE_AFK, _ItemID, AfkAdd, Num, _Args, RoleSt) ->
    role_afk:check_add_time(RoleSt),
    {func, fun() -> role_afk:add_time(trunc(AfkAdd*Num*3600), RoleSt) end};
%宠物蛋
effect(?ITEM_STYPE_PET_EGG, ItemID, _Eff, Num, Args, RoleSt)->
    #cfg_item_gift{type=Type} = cfg_item_gift:find(ItemID),
    {deal, Gain, CostAdd, Fun, RoleSt} = open_gift(Type, ItemID, Num, Args, RoleSt),
    Fun2 = fun(Deal)->
            role_pet:add_egg_records(ItemID, Deal#deal.obtain, RoleSt),
            Fun(Deal)
        end,
    {deal, Gain, CostAdd, Fun2, RoleSt};
% 世界boss疲劳
effect(?ITEM_STYPE_BOSS_TIRED, _ItemID, TiredRed, _Num, _Args, RoleSt) ->
    {func, fun() ->
        #role_st{role=RoleID, spid=ScenePid} = RoleSt,
        Msg = {RoleID, ?BUFF_ID_WORLD_BOSS_KILL_TIRED, TiredRed},
        ok  = scene:sync_route(ScenePid, boss_server, red_tired, Msg)
    end};
% 异兽boss疲劳
effect(?ITEM_STYPE_BEAST_TIRED, _ItemID, TiredRed, _Num, _Args, RoleSt) ->
    {func, fun() ->
        #role_st{role=RoleID, spid=ScenePid} = RoleSt,
        Msg = {RoleID, ?BUFF_ID_BEAST_BOSS_KILL_TIRED, TiredRed},
        ok  = scene:sync_route(ScenePid, boss_server, red_tired, Msg)
    end};
% 购买副本次数
effect(?ITEM_STYPE_DUNGE_BUY, _ItemID, SType, Num, _Args, _RoleSt) ->
    {func, fun() -> role_count:add_scene_itemadd(SType, Num) end};
% 魂卡礼包
effect(?ITEM_STYPE_MC_GIFT, _ItemID, _Eff, Num, Args, RoleSt) ->
    #dunge_magic{clear_floor=Floor} = role_data:get(?DB_DUNGE_MAGIC),
    Gain = cfg_magic_card_gift:gain(Floor),
    [{ItemID, Num1}|_T] = Gain,
    #cfg_item_gift{type=Type} = cfg_item_gift:find(ItemID),
    open_gift(Type, ItemID, Num1*Num, Args, RoleSt);
% 充值卡
effect(?ITEM_STYPE_PAY_CARD, _ItemID, GoodsID, _Num, _Args, RoleSt) ->
    {post, fun() ->
        {ok, OrderID} = order_server:new_order(RoleSt#role_st.role),
        Price = cfg_recharge:price(GoodsID),
        role_pay:pay(#{
            sdk_order  => OrderID,
            app_order  => OrderID,
            role_id    => RoleSt#role_st.role,
            goods_id   => GoodsID,
            total_fee  => Price,
            pay_type   => 1,
            game_gold  => 0,
            extra_gold => 0,
            is_real    => false
        }, RoleSt)
    end};
% 婚礼烟花
effect(?ITEM_STYPE_FIREWORK, ItemID, _Add, Num, _Args, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID, scene=Scene, name=RoleName} = RoleSt,
    ?_check(Scene == wedding_util:scene(), ?ERR_WEDDING_NOT_IN_PARTY),
    {func, fun() ->
        Msg = {use_firework, RoleID, RoleName, ItemID, Num},
        scene:route(ScenePid, wedding_party, handle, Msg)
    end};
% buff
effect(?ITEM_STYPE_BUFF, _ItemID, Buffs, _Num, _Args, RoleSt) ->
    {func, fun() -> buff:add(tuple_to_list(Buffs), RoleSt) end};

%宠物精华卡
effect(?ITEM_STYPE_PETJH, _ItemID, PetCream, Num, _Args, _RoleSt)->
	{gain, [{?ITEM_PET_CREAM, PetCream*Num}]};

%子女激活
effect(?ITEM_STYPE_BABY_BORN, _ItemID, Gender, _Num, _Args, RoleSt) ->
    {func, fun() -> baby_handler:full_progress(Gender, RoleSt) end};

%% bt版充值卡
effect(?ITEM_STYPE_BT_FIRSTPAY, _ItemID, GoodsID, _Num, _Args, RoleSt) ->
    {post, fun() ->
        {ok, OrderID} = order_server:new_order(RoleSt#role_st.role),
        Price = cfg_recharge:price(GoodsID),
        role_pay:pay(#{
            sdk_order  => OrderID,
            app_order  => OrderID,
            role_id    => RoleSt#role_st.role,
            goods_id   => GoodsID,
            total_fee  => Price,
            pay_type   => 1,
            game_gold  => 0,
            extra_gold => 0,
            is_real    => false
        }, RoleSt),
        firstpay_handler:notify(?EVENT_PAY, 1, RoleSt)
    end};

% 未定义
effect(_SType, _ItemID, _Effect, _Num, _Args, _RoleSt) ->
    throw(?err(?ERR_ITEM_CANNOT_USE)).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
% 随机礼包
open_gift(?GIFT_TYPE_FIXED, ItemID, Num, _Args, RoleSt) ->
    #cfg_item_gift{reward=Rewards, currency=Currency, cost=Cost} = cfg_item_gift:find(ItemID),
    Gains = Rewards++Currency,
    Gains2 = lists:flatten(lists:duplicate(Num, Gains)),
    Cost2 = lists:flatten(lists:duplicate(Num, Cost)),
    {deal, Gains2, Cost2, fun(Deal) -> after_open_gift(ItemID, Deal, RoleSt) end, RoleSt};
% 选择礼包
open_gift(?GIFT_TYPE_RANDOM, ItemID, Num, _Args, RoleSt) ->
    #cfg_item_gift{reward=Rewards, currency=Currency, cost=Cost} = cfg_item_gift:find(ItemID),
    [OpenNum, IsEliminate, Weights] = Rewards,
    TotalRewards = lists:foldl(fun(_, Acc) ->
        OpenNum2 = case OpenNum of
            _ when is_integer(OpenNum) ->
                OpenNum;
            _ ->
                ut_rand:weight(OpenNum, 2)
        end,
        Rewards2 = ut_rand:weight(Weights, 2, OpenNum2, IsEliminate /= 0),
        Rewards2 ++ Acc
    end, [], lists:seq(1, Num)),
    Gains = lists:flatten(lists:duplicate(Num, Currency)) ++ TotalRewards,
    Cost2 = lists:flatten(lists:duplicate(Num, Cost)),
    {deal, Gains, Cost2, fun(Deal) -> after_open_gift(ItemID, Deal, RoleSt) end, RoleSt};
% 固定礼包
open_gift(?GIFT_TYPE_SELECT, ItemID, Num, Args, RoleSt) ->
    #cfg_item_gift{reward=Rewards, cost=Cost} = cfg_item_gift:find(ItemID),
    ?_check(length(Args) > 0, ?ERR_ITEM_GIFT_SELECT),
    SelectID = hd(Args),
    Select = find_select_gift(SelectID, Rewards),
    ?_check(Select =/= false, ?ERR_GAME_BAD_ARGS),
    Gains = lists:flatten(lists:duplicate(Num, Select)),
    Cost2 = lists:flatten(lists:duplicate(Num, Cost)),
    {deal, Gains, Cost2, fun(Deal) -> after_open_gift(ItemID, Deal, RoleSt) end, RoleSt};
% 元宝多选礼包
open_gift(?GIFT_TYPE_GOLD_Multiple, ItemID, _Num, Args, RoleSt) ->
    #cfg_item_gift{mul=Mul} = cfg_item_gift:find(ItemID),
    SelectID = hd(Args),
    ?_check(lists:member(SelectID, Mul), ?ERR_GAME_BAD_ARGS),
    #cfg_item_gift{type=Type} = cfg_item_gift:find(SelectID),
    open_gift(Type, SelectID, 1, [], RoleSt);
% 掉落礼包
open_gift(?GIFT_TYPE_DROP, ItemID, Num, _Args, RoleSt) ->
    #cfg_item_gift{reward=Drops, currency=Currency, cost=Cost} = cfg_item_gift:find(ItemID),
    #role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
    TotalRewards = lists:foldl(fun(_, Acc) ->
        creep_drop:calc(Level, Drops) ++ Acc
    end, [], lists:seq(1, Num)),
    Gains = lists:flatten(lists:duplicate(Num, Currency)) ++ TotalRewards,
    Cost2 = lists:flatten(lists:duplicate(Num, Cost)),
    {deal, Gains, Cost2, fun(Deal) -> after_open_gift(ItemID, Deal, RoleSt) end, RoleSt};
% 等级礼包
open_gift(?GIFT_TYPE_LEVEL, ItemID, Num, _Args, RoleSt) ->
    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    Gain = calc_lvgift_reward(ItemID, Num, RoleLv),
    {deal, Gain, [], ?nil, RoleSt}.

after_open_gift(ItemID, Deal, RoleSt) ->
    #cfg_item_gift{notice=Notice} = cfg_item_gift:find(ItemID),
    Obtain = role_bag:obtain_to_maps(Deal#deal.obtain),
    maps:fold(fun(I, _, Acc) ->
        case lists:member(I, Notice) of
            true ->
                #cfg_item{name=ItemName, color=Color} = cfg_item:find(I),
                RoleName = RoleSt#role_st.name,
                #cfg_item{name=GiftmName, color=Color1} = cfg_item:find(ItemID),
                ?notify(?MSG_ITEM_GIFT_GAIN, [
                    {color, RoleName, ?COLOR_GREEN},
                    {color, GiftmName, Color1},
                    {color, ItemName, Color}
                ]),
                Acc;
            false ->
                Acc
        end
    end, [], Obtain),
    {ok, Obtain}.

find_select_gift(_, []) ->
    false;
find_select_gift(SelectID, [H|T]) ->
    R = erlang:element(1, H),
    case R of
        _ when is_list(R) ->
            case lists:member(SelectID, R) of
                true -> H;
                false -> find_select_gift(SelectID, T)
            end;
        _ when is_integer(R) ->
            case R == SelectID of
                true -> H;
                false -> find_select_gift(SelectID, T)
            end
    end.

calc_lvgift_reward(ItemID, Num, RoleLv) ->
    #cfg_item_gift{reward=Rewards} = cfg_item_gift:find(ItemID),
    Gain = lists:foldl(fun
        ({MinLv, MaxLv, LvRewards}, Acc) ->
            case RoleLv >= MinLv andalso RoleLv =< MaxLv of
                true  -> LvRewards ++ Acc;
                false -> Acc
            end
    end, [], Rewards),
    role_bag:multiple(Gain, Num).
