%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_bag).

-include("bag.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("vip.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").

%% API
-export([init/1]).
-export([hook_login/1]).
-export([gen_cellid/1]).
-export([cost/3, cost/4, cost/5]).
-export([gain/3, gain/4, gain/5]).
-export([deal/4, deal/5, deal/6]).
-export([move/4]).
-export([expend_to_maps/1]).
-export([obtain_to_maps/1]).
-export([dirty_deal/5]).
-export([new/1]).
-export([open/3]).
-export([get_item/1]).
-export([set_item/1]).
-export([get_items/1, get_items/2]).
-export([get_money/1]).
-export([get_num/1, get_num/2]).
-export([get_empty/1]).
-export([get_bagitems/1, get_bagitems/2]).
-export([multiple/2]).

-export_type([cost/0]).
-export_type([gain/0]).

-type cost() :: {cellid, CellID :: integer()}
      		  | {cellid, CellID :: integer(), Num :: integer()}
      		  | {ItemID :: integer(), Num :: integer()}.

-type gain() :: {ItemID :: integer(), Num :: integer()}
     		  | {ItemID :: integer(), Num :: integer(), Opts :: map()}
    		  | #p_item{}.
% Opts 参数用来定制道具属性：
%     绑定属性: key=bind,  val=true | false
%     过期时间: key=etime, val=TimeStamp
%     极品属性: key=rare,  val=[{AttrCode, AttrVal}]

-type expend() :: [#p_item{} | {MoneyID :: integer(), Num :: integer()}].
-type obtain() :: [#p_item{} | {MoneyID :: integer(), Num :: integer()}].

%% Count Key
-define(ckey(BagID, ItemID, Bind), {BagID, ItemID, Bind}).
%% Group Key
-define(gkey(BagID, ItemID, Bind), {BagID, ItemID, Bind}).

-define(DIG_ITEM , 1000000).
-define(LIMIT_MONEY, [?ITEM_GOLD, ?ITEM_BGOLD]).
-define(LIMIT_LOG(Log), (
    Log /= ?LOG_PAY andalso
    Log /= ?LOG_PAY_REFUND andalso
    Log /= ?LOG_YUNYING_100 andalso
    Log /= ?LOG_VIP_PURCHASE
)).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 初始化背包
init(RoleID) ->
    RoleBag = #role_bag{
        id     = RoleID,
        count  = #{},
        group  = #{},
        cells  = init_cells(),
        items  = #{},
        money  = maps:from_list(cfg_game:init_money()),
        exceed = #{}
    },
    role_data:set(RoleBag).

hook_login(RoleSt) ->
    RoleBag0 = role_data:get(?DB_ROLE_BAG),
    RoleBag = login_init(RoleBag0),
    RoleBag2 = expand_rune_bag(RoleBag),
    role_data:set(RoleBag2),
    #role_bag{items=Items} = RoleBag2,
    NowSecs = ut_time:seconds(),
    maps:fold(fun
        (_, Item, _) ->
            maybe_expire(Item, NowSecs, RoleSt)
    end, ok, Items).

login_init(RoleBag) ->
    Newells =
        lists:foldl(fun
                        (BagID, CellsAcc) ->
                            case maps:is_key(BagID, CellsAcc) of
                                true ->
                                    CellsAcc;
                                false ->
                                    #cfg_bag{open=Opened} = cfg_bag:find(BagID),
                                    Cell  = #cell{opened=0, used=[], unused=[]},
                                    Cell2 = open_cell(BagID, Cell, Opened),
                                    maps:put(BagID, Cell2, CellsAcc)
                            end
                    end, RoleBag#role_bag.cells, cfg_bag:bags()),
    RoleBag#role_bag{cells = Newells}.

expand_rune_bag(RoleBag) ->
    BagIDList = [?BAG_ID_RUNE, ?BAG_ID_ARTIFACT],
    Fun =
        fun(BagID, RoleBagAcc) ->
            #role_bag{cells = Cells} = RoleBagAcc,
            Cell  = maps:get(BagID, Cells),
            #cfg_bag{open = Max} = cfg_bag:find(BagID),
            case Max > Cell#cell.opened of
                true ->
                    Cell2 = open_cell(BagID, Cell, Max - Cell#cell.opened),
                    Cells2 = maps:put(BagID, Cell2, Cells),
                    RoleBagAcc#role_bag{cells = Cells2};
                false ->
                    RoleBagAcc
            end
        end,
    lists:foldl(Fun, RoleBag, BagIDList).

%%-----------------------------------------------
%% @doc 生成背包格子id
%% 背包id + 序列号
-spec gen_cellid(integer()) ->
    integer().
%%-----------------------------------------------
gen_cellid(BagID) ->
    BagID * ?DIG_ITEM + 1.

%%-----------------------------------------------
%% @doc 消耗道具
%% 错误是通过 throw 抛出来的
%% 详见 deal/5
-spec cost([cost()], integer(), function(), #role_st{}, boolean()) ->
	{ok, expend()} | {ok, expend(), any()} | error().
%%-----------------------------------------------
cost(Cost, Log, RoleSt) ->
    cost(Cost, Log, ?nil, RoleSt, false).

cost(Cost, Log, Succ, RoleSt) ->
	cost(Cost, Log, Succ, RoleSt, false).

cost(Cost, Log, Succ, RoleSt, IsRetRaw) ->
    Result = deal(Cost, [], Log, Succ, RoleSt, IsRetRaw),
    erlang:delete_element(3, Result).


%%-----------------------------------------------
%% @doc 获得道具
%% 错误是通过 throw 抛出来的
%% 详见 deal/5
-spec gain([gain()], integer(), function(), #role_st{}, boolean()) ->
	{ok, obtain()} | {ok, obtain(), any()} | error().
%%-----------------------------------------------
gain(Gain, Log, RoleSt) ->
    gain(Gain, Log, ?nil, RoleSt, false).

gain(Gain, Log, Succ, RoleSt) ->
	gain(Gain, Log, Succ, RoleSt, false).

gain(Gain, Log, Succ, RoleSt, IsRetRaw) ->
    Result = deal([], Gain, Log, Succ, RoleSt, IsRetRaw),
    erlang:delete_element(2, Result).


%%-----------------------------------------------
%% @doc 消耗道具并获得道具
-spec deal(Cost, Gain, Log, Succ, RoleSt, RetRaw) -> Return when
	Cost   :: [cost()]
		    | {'OR', Cost1 :: [cost()], Cost2 :: [cost()]},
	Gain   :: [gain()],
	Log    :: integer(),
	Succ   :: undefined | function(),
	RoleSt :: #role_st{},
    RetRaw :: boolean(),

	Return :: error()
            | {ok, expend(), obtain()}
            | {ok, expend(), obtain(), any()}.
%%-----------------------------------------------
deal(Cost, Gain, Log, RoleSt) ->
	deal(Cost, Gain, Log, ?nil, RoleSt).

deal(Cost, Gain, Log, Succ, RoleSt) ->
    deal(Cost, Gain, Log, Succ, RoleSt, false).

deal([], [], _Log, ?nil, _RoleSt, IsRetRaw) ->
    case IsRetRaw of
        true  -> {ok, [], []};
        false -> {ok, #{}, #{}}
    end;
deal([], [], _Log, Succ, _RoleSt, IsRetRaw) ->
    Deal   = #deal{expend=[], obtain=[]},
    Result = if
        is_function(Succ, 1) -> Succ(Deal);
        is_function(Succ, 0) -> Succ();
        true -> no_result
    end,
    deal_result([], [], Result, IsRetRaw);
deal(Cost, Gain, Log, Succ, RoleSt, IsRetRaw) ->
    RoleBag  = role_data:get(?DB_ROLE_BAG),
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    Monitor  = role_data:get(?DB_ROLE_MONITOR),
    {ok, Deal} = try_deal(Cost, Gain, Log, RoleBag, RoleInfo, Monitor),
    Result = if
        is_function(Succ, 1) -> Succ(Deal);
        is_function(Succ, 0) -> Succ();
        true -> no_result
    end,
    role_data:set(Deal#deal.rolebag),
    role_data:set(Deal#deal.roleinfo),
    role_data:set(Deal#deal.monitor),
    try
        post_deal(Deal, RoleSt),
        deal_result(Deal#deal.expend, Deal#deal.obtain, Result, IsRetRaw)
    catch Class:Reason:Stacktrace ->
        ?stacktrace(Class, Reason, Stacktrace),
        throw(?err(?ERR_GAME_SYS_ERROR))
    end.


dirty_deal(RoleID, Cost, Gain, Log, Succ) ->
    [RoleBag]  = db:dirty_read(?DB_ROLE_BAG, RoleID),
    [RoleInfo] = db:dirty_read(?DB_ROLE_INFO, RoleID),
    [Monitor]  = db:dirty_read(?DB_ROLE_MONITOR, RoleID),
    {ok, Deal} = try_deal(Cost, Gain, Log, RoleBag, RoleInfo, Monitor),
    Result = if
        is_function(Succ, 1) -> Succ(Deal);
        is_function(Succ, 0) -> Succ();
        true -> no_result
    end,
    db:dirty_write(Deal#deal.rolebag),
    db:dirty_write(Deal#deal.roleinfo),
    db:dirty_write(Deal#deal.monitor),
    #deal{expend=Expend, obtain=Obtain} = Deal,
    case Result == no_result of
        true  -> {ok, Expend, Obtain};
        false -> {ok, Expend, Obtain, Result}
    end.

expend_to_maps(Expend) ->
    to_maps(Expend).

obtain_to_maps(Obtain) ->
    to_maps(Obtain).


%%-----------------------------------------------
%% @doc 将 CellID 道具移动到 BagID 中
-spec move(
    SrcBag :: integer(),
    DstBag :: integer(),
    [{CellID :: integer(), Num :: integer()}],
    RoleSt :: #role_st{}
) ->
    {ok, [#p_item{}], [#p_item{}]} | error().
%%-----------------------------------------------
move(SrcBag, DstBag, Move, RoleSt) ->
    {ok, Deal} = try_move(DstBag, Move),
    #deal{rolebag=RoleBag, update=Update} = Deal,
    role_data:set(RoleBag),

    #cfg_bag{type=SrcType} = cfg_bag:find(SrcBag),
    case SrcType == ?BAG_TYPE_DUMMY of
        true  ->
            ignore;
        false ->
            Update1 = Update#update{add=[]},
            Deal1   = Deal#deal{log=?LOG_BAG_STORE, update=Update1},
            process_update(Deal1, RoleSt)
    end,
    #cfg_bag{type=DstType} = cfg_bag:find(DstBag),
    case DstType == ?BAG_TYPE_DUMMY of
        true  ->
            ignore;
        false ->
            Update2 = Update#update{del=[]},
            Deal2   = Deal#deal{log=?LOG_BAG_FETCH, update=Update2},
            process_update(Deal2, RoleSt)
    end,
    process_expend(Deal, RoleSt),
    process_obtain(Deal, RoleSt),
    #deal{expend=Expend, obtain=Obtain} = Deal,
    {ok, Expend, Obtain}.

new(BagID) ->
    Cell = #cell{opened=0, used=[], unused=[]},
    #cfg_bag{open=Opened} = cfg_bag:find(BagID),
    open_cell(BagID, Cell, Opened).


%%-----------------------------------------------
%% @doc 开启格子
-spec open(integer(), #cell{}, integer()) ->
    #cell{}.
%%-----------------------------------------------
open(BagID, Cell, Num) ->
    open_cell(BagID, Cell, Num).


%%-----------------------------------------------
%% @doc 获取道具
-spec get_item(integer()) ->
	{ok, #p_item{}} | error().
%%-----------------------------------------------
get_item(CellID) ->
	RoleBag = role_data:get(?DB_ROLE_BAG),
	do_get_item(RoleBag, CellID).


%%-----------------------------------------------
%% @doc 更新道具
-spec set_item(#p_item{}) ->
    no_return().
%%-----------------------------------------------
set_item(Item) ->
    RoleBag = #role_bag{items=Items} = role_data:get(?DB_ROLE_BAG),
    case maps:is_key(Item#p_item.uid, Items) of
        true  ->
            Items2 = maps:put(Item#p_item.uid, Item, Items),
            role_data:set(RoleBag#role_bag{items=Items2});
        false ->
            ignore
    end.


%%-----------------------------------------------
%% @doc 根据 ItemID 获取道具
-spec get_items(integer()) ->
    [#p_item{}].
%%-----------------------------------------------
get_items(ItemID) ->
    #role_bag{group=Group, items=Items} = role_data:get(?DB_ROLE_BAG),
    #cfg_item{bag=BagID} = cfg_item:find(ItemID),
    CellIDs = maps:get(?gkey(BagID,ItemID,true), Group, [])
           ++ maps:get(?gkey(BagID,ItemID,false), Group, []),
    [maps:get(CellID, Items) || CellID <- CellIDs].

get_items(ItemID, IsBind) ->
    #role_bag{group=Group, items=Items} = role_data:get(?DB_ROLE_BAG),
    #cfg_item{bag=BagID} = cfg_item:find(ItemID),
    CellIDs = maps:get(?gkey(BagID, ItemID, IsBind), Group, []),
    [maps:get(CellID, Items) || CellID <- CellIDs].


%%-----------------------------------------------
%% @doc 获取货币数量
-spec get_money(integer()) ->
    integer().
%%-----------------------------------------------
get_money(ItemID) ->
    #role_bag{money=Money} = role_data:get(?DB_ROLE_BAG),
    maps:get(ItemID, Money, 0).


%%-----------------------------------------------
%% @doc 根据 ItemID 获取背包中的道具数量
-spec get_num(integer(), boolean()) ->
	integer().
%%-----------------------------------------------
get_num(ItemID) ->
	RoleBag = role_data:get(?DB_ROLE_BAG),
	do_get_num(RoleBag, ItemID).

get_num(ItemID, IsBind) ->
	#role_bag{count=Count} = role_data:get(?DB_ROLE_BAG),
	#cfg_item{bag=BagID} = cfg_item:find(ItemID),
	maps:get(?ckey(BagID,ItemID,IsBind), Count, 0).


%%-----------------------------------------------
%% @doc 获取背包空格子数
-spec get_empty(integer()) ->
    integer().
%%-----------------------------------------------
get_empty(BagID) ->
    #role_bag{cells=Cells} = role_data:get(?DB_ROLE_BAG),
    Cell = maps:get(BagID, Cells),
    length(Cell#cell.unused).


get_bagitems(BagID) ->
    RoleBag = role_data:get(?DB_ROLE_BAG),
    get_bagitems(RoleBag, BagID).

get_bagitems(RoleBag, BagID) ->
    #role_bag{cells=Cells, items=Items} = RoleBag,
    #cell{used=CellIDs} = maps:get(BagID, Cells),
    maps:with(CellIDs, Items).


multiple(ItemList, Multi) ->
    [begin
        case Item of
            {cellid, CellID, Num} ->
                {cellid, CellID, Num*Multi};
            {ItemID, Num} ->
                {ItemID, Num*Multi};
            {ItemID, Num, Opts} ->
                {ItemID, Num*Multi, Opts};
            Item when is_record(Item, p_item) ->
                Item#p_item{num=Item#p_item.num*Multi}
        end
    end || Item <- ItemList].

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
init_cells() ->
	lists:foldl(fun
        (BagID, Acc) ->
            #cfg_bag{open=Opened} = cfg_bag:find(BagID),
            Cell  = #cell{opened=0, used=[], unused=[]},
            Cell2 = open_cell(BagID, Cell, Opened),
            maps:put(BagID, Cell2, Acc)
    end, #{}, cfg_bag:bags()).

open_cell(BagID, Cell, Num) ->
    ID  = gen_cellid(BagID),
    Min = ID + Cell#cell.opened,
    Max = Min + Num - 1,
    Cell#cell{
        opened = Cell#cell.opened + Num,
        unused = Cell#cell.unused ++ lists:seq(Min, Max)
    }.

use_cell(Cells, BagID, CellID) ->
    Cell0 = maps:get(BagID, Cells),
    Cell1 = Cell0#cell{
        used   = [CellID | Cell0#cell.used],
        unused = lists:delete(CellID, Cell0#cell.unused)
    },
    maps:put(BagID, Cell1, Cells).

free_cell(Cells, BagID, CellID) ->
    Cell0 = maps:get(BagID, Cells),
    Cell1 = Cell0#cell{
        used   = lists:delete(CellID, Cell0#cell.used),
        unused = [CellID | Cell0#cell.unused]
    },
    maps:put(BagID, Cell1, Cells).


try_deal(Cost, Gain, Log, RoleBag, RoleInfo, Monitor) ->
    Deal0 = #deal{
        rolebag   = RoleBag,
        roleinfo  = RoleInfo,
        monitor   = Monitor,
        log       = Log,
        expend    = [],
        obtain    = [],
        exceed    = #{},
        update    = #update{},
        alert     = [],
        exception = #{}
    },
    {ok, Deal1} = deal_cost(Cost, Deal0),
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    {ok, Deal2} = deal_gain(Gain, Deal1),
    cache_role_level(RoleInfo, Deal2#deal.roleinfo),
    {ok, Deal2}.

deal_cost({'OR', Cost1, Cost2}, Deal) ->
    try
        try_del(Cost1, Deal)
    catch _:_ ->
        try_del(Cost2, Deal)
    end;
deal_cost(Cost, Deal) ->
    try_del(Cost, Deal).

try_del([{cellid, CellID, Num} | T], Deal) when Num >= 0 ->
    {ok, Deal2} = reduce_by_cellid(CellID, Num, Deal),
    try_del(T, Deal2);
try_del([{cellid, CellID} | T], Deal) ->
    {ok, Deal2} = remove_by_cellid(CellID, Deal),
    try_del(T, Deal2);
try_del([{ItemID, Num} | T], Deal) when Num >= 0 ->
    #cfg_item{type=Type} = cfg_item:find(ItemID),
    {ok, Deal2} = case Type == ?ITEM_TYPE_MONEY of
        true  -> reduce_money(ItemID, Num, Deal);
        false -> reduce_by_itemid(ItemID, Num, Deal)
    end,
    try_del(T, Deal2);
try_del([], Deal) ->
    {ok, Deal}.

reduce_by_cellid(CellID, Num, Deal) ->
    {ok, Item} = do_get_item(Deal#deal.rolebag, CellID),
    reduce_item(Item, Num, Deal).

remove_by_cellid(CellID, Deal) ->
    {ok, Item} = do_get_item(Deal#deal.rolebag, CellID),
    remove_item(Item, Deal).

reduce_by_itemid(ItemID, NeedNum, Deal) ->
	HadNum = do_get_num(Deal#deal.rolebag, ItemID),
    case HadNum >= NeedNum of
        true  ->
        	#cfg_item{bag=BagID} = cfg_item:find(ItemID),
        	#role_bag{group=Group} = Deal#deal.rolebag,
            CellIDs1 = maps:get(?gkey(BagID,ItemID,true), Group, []),
            CellIDs2 = maps:get(?gkey(BagID,ItemID,false), Group, []),
            CellIDs  = CellIDs1 ++ CellIDs2,
            reduce_by_cellids(NeedNum, CellIDs, Deal);
        false ->
            {ok, NeedNum2, Deal2} = reduce_voucher(ItemID, HadNum, NeedNum, Deal),
            reduce_by_itemid(ItemID, NeedNum2, Deal2)
    end.

reduce_by_cellids(0, _, Deal) ->
    {ok, Deal};
reduce_by_cellids(NeedNum, [CellID | T], Deal) ->
    {ok, Item} = do_get_item(Deal#deal.rolebag, CellID),
    NeedNum2 = NeedNum - Item#p_item.num,
    if
        NeedNum2 <  0 ->
            reduce_item(Item, NeedNum, Deal);
        NeedNum2 == 0 ->
            remove_item(Item, Deal);
        NeedNum2 >  0 ->
            {ok, Deal2} = remove_item(Item, Deal),
            reduce_by_cellids(NeedNum2, T, Deal2)
    end.

reduce_item(Item, NeedNum, Deal) when Item#p_item.num > NeedNum ->
    #p_item{uid=CellID, num=HadNum} = Item,
    HadNum2 = HadNum - NeedNum,
    Item2   = Item#p_item{num=HadNum2},

    #deal{rolebag=RoleBag, expend=Expend, update=Update} = Deal,
    #role_bag{count=Count, items=Items} = RoleBag,

	RoleBag2 = RoleBag#role_bag{
        count = update_bag_count(Item, -NeedNum, Count),
        items = maps:put(CellID, Item2, Items)
    },
    Deal2 = Deal#deal{
        rolebag = RoleBag2,
        expend  = [Item#p_item{num=NeedNum} | Expend],
        update  = update_chg(Update, CellID, HadNum2)
    },
    {ok, Deal2};
reduce_item(Item, NeedNum, Deal) when Item#p_item.num == NeedNum ->
    remove_item(Item, Deal);
reduce_item(Item, NeedNum, Deal) ->
    not_enough(Deal#deal.log, Item#p_item.id, NeedNum).

remove_item(Item, Deal) ->
    #p_item{uid=CellID, num=HadNum, bag=BagID} = Item,

    #deal{rolebag=RoleBag, expend=Expend, update=Update} = Deal,
    #role_bag{count=Count, group=Group, cells=Cells, items=Items} = RoleBag,

    RoleBag2 = RoleBag#role_bag{
        count = update_bag_count(Item, -HadNum, Count),
        group = update_bag_group(Item, CellID, Group, maps_delete),
        cells = free_cell(Cells, BagID, CellID),
        items = maps:remove(CellID, Items)
    },
    Deal2 = Deal#deal{
        rolebag = RoleBag2,
        expend  = [Item | Expend],
        update  = update_del(Update, CellID)
    },
    {ok, Deal2}.

%% 扣经验
reduce_money(?ITEM_EXP, NeedExp, Deal) ->
    #deal{roleinfo=RoleInfo, expend=Expend, update=Update, log=Log} = Deal,
    #role_info{exp=OldExp} = RoleInfo,
    ?_if(OldExp < NeedExp, not_enough(Log, ?ITEM_EXP, NeedExp)),

    NewExp = OldExp - NeedExp,
    Deal2  = Deal#deal{
        roleinfo = RoleInfo#role_info{exp=NewExp},
        expend   = update_expend(Expend, ?ITEM_EXP, NeedExp),
        update   = update_money(Update, ?ITEM_EXP, NewExp)
    },
    {ok, Deal2};
%% 扣钱
reduce_money(ItemID, NeedNum, Deal) ->
    #deal{rolebag=RoleBag, expend=Expend, update=Update} = Deal,
    #role_bag{money=Money} = RoleBag,
    HadNum = maps:get(ItemID, Money, 0),
    case HadNum < 0 of
        true  ->
            ?fatal("money(~w) num less than zero", [ItemID]),
            throw(?err(?ERR_GAME_SYS_ERROR));
        false ->
            ignore
    end,
    case HadNum >= NeedNum of
        true  ->
            HadNum2  = HadNum - NeedNum,
            RoleBag2 = RoleBag#role_bag{
                money = maps:put(ItemID, HadNum2, Money)
            },
            Deal2 = Deal#deal{
                rolebag = RoleBag2,
                expend  = update_expend(Expend, ItemID, NeedNum),
                update  = update_money(Update, ItemID, HadNum2)
            },
            {ok, Deal2};
        false when ItemID == ?ITEM_BGOLD ->
            reduce_unbind_money(?ITEM_BGOLD, ?ITEM_GOLD, NeedNum, Deal);
        false when ItemID == ?ITEM_BCOIN ->
            reduce_unbind_money(?ITEM_BCOIN, ?ITEM_COIN, NeedNum, Deal);
        false ->
            {ok, NeedNum2, Deal2} = reduce_voucher(ItemID, HadNum, NeedNum, Deal),
            reduce_money(ItemID, NeedNum2, Deal2)
    end.

reduce_unbind_money(MoneyBind, MoneyUnbind, NeedNum, Deal) ->
    #deal{rolebag=RoleBag, expend=Expend, update=Update, log=Log} = Deal,
    #role_bag{money=Money} = RoleBag,
    HadBind   = maps:get(MoneyBind, Money, 0),
    HadUnbind = maps:get(MoneyUnbind, Money, 0),
    ?_check(HadBind+HadUnbind >= NeedNum, not_enough(Log, MoneyBind, NeedNum)),

    DelUnbind  = NeedNum - HadBind,
    HadBind2   = 0,
    HadUnbind2 = HadUnbind - DelUnbind,
    Money1 = maps:put(MoneyBind, HadBind2, Money),
    Money2 = maps:put(MoneyUnbind, HadUnbind2, Money1),

    RoleBag2 = RoleBag#role_bag{money=Money2},
    Expend1  = update_expend(Expend, MoneyBind, HadBind),
    Expend2  = update_expend(Expend1, MoneyUnbind, DelUnbind),
    Update1  = update_money(Update, MoneyBind, HadBind2),
    Update2  = update_money(Update1, MoneyUnbind, HadUnbind2),
    {ok, Deal#deal{rolebag=RoleBag2, expend=Expend2, update=Update2}}.

reduce_voucher(ItemID, HadNum, NeedNum, Deal) ->
    case cfg_voucher:find(ItemID) of
        {MoneyID, MoneyNum, OffsetNum} ->
            % MoneyNum 个 MoneyID 可抵销 OffsetNum 个 ItemID
            CanOffset = (HadNum div OffsetNum) * OffsetNum,
            NeedMoney = ((NeedNum - CanOffset) div OffsetNum) * MoneyNum,
            {ok, Deal2} = reduce_money(MoneyID, NeedMoney, Deal),
            {ok, CanOffset, Deal2};
        ?nil ->
            not_enough(Deal#deal.log, ItemID, NeedNum)
    end.


deal_gain(Gain, Deal) ->
    try
        try_add(Gain, Deal)
    catch
        throw:{error, ?ERR_BAG_NO_SPACE, Args}:_ ->
            case cfg_mail_auto:find(Deal#deal.log) of
                ?nil ->
                    throw(?err(?ERR_BAG_NO_SPACE, Args));
                Desc ->
                    RoleID = role_util:get_id(),
                    ?ucast(RoleID, #m_game_error_toc{
                        errno = ?ERR_BAG_SEND_MAIL,
                        args  = Args
                    }),
                    {Title, Text} = cfg_mail:find(?MAIL_BAG_FULL),
                    Text2  = io_lib:format(Text, [Desc]),
                    {ok, Obtain} = mail:send(RoleID, Title, Text2, Gain),
                    {ok, Deal#deal{obtain=Obtain}}
            end;
        throw:{error, Errno, Args}:_ ->
            throw(?err(Errno, Args));
        Class:Reason:Stacktrace ->
            ?stacktrace(Class, Reason, Stacktrace),
            ?error("deal gain error: ~p", [{Deal#deal.log, Gain}]),
            throw(?err(?ERR_GAME_SYS_ERROR))
    end.

try_add([{ItemID, Num} | T], Deal) when is_integer(ItemID), Num >= 0 ->
    {ok, Deal2} = add_item(ItemID, Num, #{}, Deal),
    try_add(T, Deal2);
try_add([{ItemIDs, Num} | T], Deal) when is_list(ItemIDs), Num >= 0 ->
    #role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
    ItemID = lists:nth(Gender, ItemIDs),
    {ok, Deal2} = add_item(ItemID, Num, #{}, Deal),
    try_add(T, Deal2);
try_add([{ItemIDs, Num, Opts} | T], Deal) when is_list(ItemIDs), Num >= 0 ->
    #role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
    ItemID = lists:nth(Gender, ItemIDs),
    Opts2  = case is_integer(Opts) of
        true  -> #{bind=>item_util:calc_bind(Opts)};
        false -> Opts
    end,
    {ok, Deal2} = add_item(ItemID, Num, Opts2, Deal),
    try_add(T, Deal2);
try_add([{ItemID, Num, Opts} | T], Deal) when is_integer(ItemID), Num >= 0 ->
    Opts2 = case is_integer(Opts) of
        true  -> #{bind=>item_util:calc_bind(Opts)};
        false -> Opts
    end,
    {ok, Deal2} = add_item(ItemID, Num, Opts2, Deal),
    try_add(T, Deal2);
try_add([Item | T], Deal) when is_record(Item, p_item), Item#p_item.num >= 0 ->
    {ok, Deal2} = add_item(Item, Deal),
    try_add(T, Deal2);
try_add([], Deal) ->
    {ok, Deal}.


add_item(ItemID, AddNum, Opts, Deal) ->
    case item_monitor:monitor(ItemID, AddNum, Deal) of
        {exception, Deal2} ->
            % 已经超出阀值的就不给获得
            Exception = ut_misc:maps_increase(ItemID, AddNum, Deal2#deal.exception),
            {ok, Deal2#deal{exception=Exception}};
        {_Ret, Deal2} ->
            #cfg_item{type=Type} = cfg_item:find(ItemID),
            case Type == ?ITEM_TYPE_MONEY of
                true  -> add_money(ItemID, AddNum, Deal2);
                false -> add_item(item_util:new_item(ItemID, AddNum, Opts), Deal2)
            end
    end.

add_item(Item, Deal) ->
    #p_item{bag=BagID, id=ItemID, num=Num, bind=Bind} = Item,
    #cfg_item{stype=SType, lap=Lap} = cfg_item:find(ItemID),
    case SType == ?ITEM_STYPE_LEVEL_GIFT of
        true  ->
            #role_info{level=RoleLv} = Deal#deal.roleinfo,
            Gain = item_effect:calc_lvgift_reward(ItemID, Num, RoleLv),
            try_add(Gain, Deal);
        false ->
            check_add(Item, Lap, Deal#deal.rolebag),
            #role_bag{group=Group} = Deal#deal.rolebag,
            case maps:find(?gkey(BagID,ItemID,Bind), Group) of
                {ok, CellIDs} ->
                    add_to_old(CellIDs, Item, Lap, Deal);
                error ->
                    add_to_new(Item, Lap, Deal)
            end
    end.

check_add(Item, Lap, RoleBag) ->
    #p_item{id=ItemID, num=AddNum, bag=BagID, bind=Bind} = Item,
    #role_bag{cells=Cells, count=Count} = RoleBag,
    #cell{unused=Unused} = maps:get(BagID, Cells),
    % 剩余空格子数
    Rem = length(Unused),
    case Lap == 0 of
        true  ->
            case maps:is_key(?ckey(BagID,ItemID,Bind), Count) of
                true  -> ok;
                false -> ?_check(Rem > 0, ?ERR_BAG_NO_SPACE, [BagID])
            end;
        false ->
            % 已有数量
            Had = maps:get(?ckey(BagID, ItemID, Bind), Count, 0),
            % 可容纳数量
            Cap = case Had rem Lap of
                0 -> Rem * Lap;
                N -> (Lap - N) + Rem * Lap
            end,
            ?_check(Cap >= AddNum, ?ERR_BAG_NO_SPACE, [BagID])
    end.

% 添加完毕
add_to_old(_CellIDs, AddItem, _Lap, Deal) when AddItem#p_item.num == 0 ->
    {ok, Deal};
% 已达叠加数量上限
add_to_old([], AddItem, Lap, Deal) ->
    add_to_new(AddItem, Lap, Deal);
% 叠加数量没有限制
add_to_old([CellID | _], AddItem, 0, Deal) ->
    #deal{rolebag=RoleBag, obtain=Obtain, update=Update} = Deal,
    #role_bag{count=Count, items=Items} = RoleBag,
    HadItem  = #p_item{num=HadNum} = maps:get(CellID, Items),
    HadNum2  = HadNum + AddItem#p_item.num,

    RoleBag2 = RoleBag#role_bag{
        count = update_bag_count(HadItem, AddItem#p_item.num, Count),
        items = maps:put(CellID, HadItem#p_item{num=HadNum2}, Items)
    },
    Deal2 = Deal#deal{
        rolebag = RoleBag2,
        obtain  = [HadItem#p_item{num=AddItem#p_item.num} | Obtain],
        update  = update_chg(Update, CellID, HadNum2)
    },
    {ok, Deal2};
% 叠加数量有限制
add_to_old([CellID | T], AddItem, Lap, Deal) ->
    #deal{rolebag=RoleBag, obtain=Obtain, update=Update} = Deal,
    #role_bag{count=Count, items=Items} = RoleBag,
    HadItem = #p_item{num=HadNum} = maps:get(CellID, Items),
    case HadNum >= Lap of
        true  ->
            add_to_old(T, AddItem, Lap, Deal);
        false ->
            AddNum  = min(Lap-HadNum, AddItem#p_item.num),
            HadNum2 = HadNum + AddNum,

            AddItem2 = AddItem#p_item{num=AddItem#p_item.num-AddNum},

            RoleBag2 = RoleBag#role_bag{
                count = update_bag_count(HadItem, AddNum, Count),
                items = maps:put(CellID, HadItem#p_item{num=HadNum2}, Items)
            },
            Deal2 = Deal#deal{
                rolebag = RoleBag2,
                obtain  = [HadItem#p_item{num=AddNum} | Obtain],
                update  = update_chg(Update, CellID, HadNum2)
            },
            add_to_old(T, AddItem2, Lap, Deal2)
    end.

add_to_new(AddItem, _Lap, Deal) when AddItem#p_item.num == 0 ->
    {ok, Deal};
add_to_new(AddItem, Lap, Deal) ->
    #p_item{num=AddNum, bag=BagID} = AddItem,

    #deal{rolebag=RoleBag, obtain=Obtain, update=Update} = Deal,
    #role_bag{count=Count, group=Group, cells=Cells, items=Items} = RoleBag,

    #cell{unused=[CellID | _]} = maps:get(BagID, Cells),
    NewNum  = ?_if(Lap == 0, AddNum, min(AddNum, Lap)),
    NewItem = AddItem#p_item{uid=CellID, num=NewNum},

    AddItem2 = AddItem#p_item{num=AddNum-NewNum},

    RoleBag2 = RoleBag#role_bag{
        count = update_bag_count(NewItem, NewNum, Count),
        group = update_bag_group(NewItem, CellID, Group, maps_append),
        cells = use_cell(Cells, BagID, CellID),
        items = maps:put(CellID, NewItem, Items)
    },
    Deal2 = Deal#deal{
        rolebag = RoleBag2,
        obtain  = [NewItem | Obtain],
        update  = update_add(Update, NewItem)
    },
    add_to_new(AddItem2, Lap, Deal2).


%% 升级
add_money(?ITEM_LEVEL, AddLv, Deal) ->
	#deal{roleinfo=RoleInfo, obtain=Obtain, update=Update} = Deal,
    RoleInfo2 = #role_info{level=NewLv} = role_level:add_level(AddLv, RoleInfo),
    Deal2 = Deal#deal{
        roleinfo = RoleInfo2,
        obtain   = update_obtain(Obtain, ?ITEM_LEVEL, AddLv),
        update   = update_money(Update, ?ITEM_LEVEL, NewLv)
    },
    {ok, Deal2};
%% 加经验
add_money(?ITEM_EXP, AddExp0, Deal) ->
    #deal{roleinfo=RoleInfo, obtain=Obtain, update=Update} = Deal,
    AddExp = ut_math:ceil(AddExp0),
    RoleInfo2 = role_level:add_exp(AddExp, RoleInfo),
    #role_info{level=OldLv} = RoleInfo,
    #role_info{level=NewLv, exp=NewExp} = RoleInfo2,

    Obtain1 = case NewLv > OldLv of
        true  -> update_obtain(Obtain, ?ITEM_LEVEL, NewLv-OldLv);
        false -> Obtain
    end,
    Obtain2 = update_obtain(Obtain1, ?ITEM_EXP, AddExp),

    Update1 = case NewLv > OldLv of
        true  -> update_money(Update, ?ITEM_LEVEL, NewLv);
        false -> Update
    end,
    Update2 = update_money(Update1, ?ITEM_EXP, NewExp),
    Update3 = update_money(Update2, ?ITEM_EXPADD, AddExp),
    {ok, Deal#deal{roleinfo=RoleInfo2, obtain=Obtain2, update=Update3}};
%% 根据自身等级加经验
add_money(?ITEM_PLAYER_EXP, Coef, Deal) ->
    #role_info{level=RoleLv} = Deal#deal.roleinfo,
    #cfg_exp_acti_base{role_exp=RoleExp} = cfg_exp_acti_base:find(RoleLv),
    add_money(?ITEM_EXP, trunc(Coef * RoleExp), Deal);
%% 根据世界等级加经验
add_money(?ITEM_WORLDLV_EXP, Coef, Deal) ->
    WorldLv = world_level:get_level(),
    #cfg_exp_acti_base{world_exp=WorldExp} = cfg_exp_acti_base:find(WorldLv),
    add_money(?ITEM_EXP, trunc(Coef * WorldExp), Deal);
% 经验系数
add_money(?ITEM_EXPCOEF, Coef, Deal) ->
    Update2 = update_money(Deal#deal.update, ?ITEM_EXPCOEF, Coef),
    {ok, Deal#deal{update=Update2}};
% 周活跃
add_money(?ITEM_WEEKLY_ACT, _Num, Deal) ->
    {ok, Deal};
add_money(ItemID, Num, Deal) ->
    case ?LIMIT_LOG(Deal#deal.log) andalso lists:member(ItemID, ?LIMIT_MONEY) of
        true  ->
            MaxGain = gain_limit(ItemID),
            HadGain = role_count:get_item_gain(ItemID),
            NewGain = HadGain + Num,
            if
                HadGain > MaxGain ->
                    gain_exceed(ItemID, Num, Deal);
                NewGain > MaxGain ->
                    RealGain  = MaxGain - HadGain,
                    ExceedNum = Num - RealGain,
                    {ok, Deal2} = do_add_money(ItemID, RealGain, Deal),
                    gain_exceed(ItemID, ExceedNum, Deal2);
                true ->
                    do_add_money(ItemID, Num, Deal)
            end;
        false ->
            do_add_money(ItemID, Num, Deal)
    end.

gain_exceed(ItemID, Num, Deal) ->
    RoleBag  = #role_bag{exceed=Exceed} = Deal#deal.rolebag,
    Exceed2  = ut_misc:maps_increase(ItemID, Num, Exceed),
    RoleBag2 = RoleBag#role_bag{exceed=Exceed2},
    Deal1 = Deal#deal{rolebag=RoleBag2},
    Deal2 = case maps:get(ItemID, Exceed, 0) > 0 of
        true  -> Deal1; % 原来已经超过，说明不是第1次
        false -> Deal1#deal{exceed=maps:put(ItemID, Num, Deal#deal.exceed)}
    end,
    {ok, Deal2}.

gain_limit(?ITEM_GOLD) ->
    VipLv = role_vip:get_level(),
    #cfg_vip_level{gold=Max} = cfg_vip_level:find(VipLv),
    Max;
gain_limit(?ITEM_BGOLD) ->
    VipLv = role_vip:get_level(),
    #cfg_vip_level{bgold=Max} = cfg_vip_level:find(VipLv),
    Max.

do_add_money(ItemID, AddNum, Deal) ->
    #deal{rolebag=RoleBag, obtain=Obtain, update=Update} = Deal,
    #role_bag{money=Money} = RoleBag,
    HadNum   = maps:get(ItemID, Money, 0),
    HadNum2  = HadNum + AddNum,
    RoleBag2 = RoleBag#role_bag{
        money = maps:put(ItemID, HadNum2, Money)
    },
    Deal2 = Deal#deal{
        rolebag = RoleBag2,
        obtain  = update_obtain(Obtain, ItemID, AddNum),
        update  = update_money(Update, ItemID, HadNum2)
    },
    {ok, Deal2}.

update_bag_count(Item, Incr, Count) ->
    #p_item{id=ItemID, bag=BagID, bind=Bind} = Item,
    ut_misc:maps_increase(?ckey(BagID, ItemID, Bind), Incr, Count).

update_bag_group(Item, CellID, Group, Fun) ->
    #p_item{id=ItemID, bag=BagID, bind=Bind} = Item,
    ut_misc:Fun(?gkey(BagID, ItemID, Bind), CellID, Group).

do_get_item(RoleBag, CellID) ->
	case maps:find(CellID, RoleBag#role_bag.items) of
        {ok, Item} ->
            {ok, Item};
        error ->
            ?err(?ERR_ITEM_NOT_EXIST)
    end.

do_get_num(RoleBag, ItemID) ->
	#cfg_item{bag=BagID} = cfg_item:find(ItemID),
	#role_bag{count=Count} = RoleBag,
	maps:get(?ckey(BagID,ItemID,true), Count, 0) +
    maps:get(?ckey(BagID,ItemID,false), Count, 0).

not_enough(Log, ItemID, NeedNum) ->
    Errno = if
        Log == ?LOG_TASK_SUBMIT ->
            ?ERR_TASK_ITEM_NOT_ENOUGH;
        Log == ?LOG_ILLUSTRATION_UPSTAR ->
            ?ERR_ILLUSTARTION_ITEM_NOT_ENOUGH;
        true ->
            ?ERR_ITEM_NOT_ENOUGH
    end,
    throw(?err(Errno, [ItemID, NeedNum])).


update_add(Update, NewItem) ->
    Update#update{
        add = [item_util:p_item_base(NewItem) | Update#update.add]
    }.

update_del(Update, CellID) ->
    Update#update{
        del = [CellID | Update#update.del]
    }.

update_chg(Update, CellID, NewNum) ->
    Update#update{
        chg = maps:put(CellID, NewNum, Update#update.chg)
    }.

update_money(Update, MoneyID, NewNum) ->
    Update#update{
        money = maps:put(MoneyID, ut_math:floor(NewNum), Update#update.money)
    }.

update_obtain(Obtain, ItemID, Add) ->
    case proplists:get_value(ItemID, Obtain) of
        ?nil -> [{ItemID, Add} | Obtain];
        Old  -> lists:keystore(ItemID, 1, Obtain, {ItemID,Old+Add})
    end.

update_expend(Expend, ItemID, Add) ->
    case proplists:get_value(ItemID, Expend) of
        ?nil -> [{ItemID, Add} | Expend];
        Old  -> lists:keystore(ItemID, 1, Expend, {ItemID,Old+Add})
    end.

post_deal(Deal, RoleSt) ->
    process_money(Deal, RoleSt),
    process_level(Deal, RoleSt),
    process_vipexp(Deal, RoleSt),
    process_event(Deal, RoleSt),
    process_log(Deal, RoleSt),
    process_update(Deal, RoleSt),
    process_obtain(Deal, RoleSt),
    process_expend(Deal, RoleSt),
    ok.

process_money(Deal, RoleSt) ->
    case ?LIMIT_LOG(Deal#deal.log) of
        true  ->
            lists:foreach(fun
                (MoneyID) ->
                    case proplists:get_value(MoneyID, Deal#deal.obtain) of
                        ?nil -> ignore;
                        Num  -> role_count:add_item_gain(MoneyID, Num)
                    end
            end, ?LIMIT_MONEY),
            maps:fold(fun
                (MoneyID, Num, _Acc) ->
                    {Title, Text} = cfg_mail:find(?MAIL_MONEY_EXCEED_NOTIFY),
                    #cfg_item{name=Name} = cfg_item:find(MoneyID),
                    Title2 = io_lib:format(Title, [Name]),
                    Text2  = io_lib:format(Text, [Name, Num]),
                    mail:send(RoleSt#role_st.role, Title2, Text2, [])
            end, ok, Deal#deal.exceed);
        false ->
            ignore
    end,
    ok.

process_level(Deal, RoleSt) ->
    #deal{obtain=Obtain, log=Log} = Deal,
    case proplists:get_value(?ITEM_LEVEL, Obtain) of
        ?nil  ->
            ignore;
        AddLv ->
            role:cast(self(), {upgrade, AddLv}),
            #role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
            AddExp = proplists:get_value(?ITEM_EXP, Obtain, 0),
            log_api:levelup(Level, AddExp, Log, RoleSt)
    end.

process_vipexp(Deal, RoleSt) ->
    #deal{expend=Expend, obtain=Obtain, log=Log} = Deal,
    Exclude = [0, ?LOG_MARKET_DEAL, ?LOG_MARKET_BUY, ?LOG_MARRIAGE_PROPOSAL, ?LOG_YUNYING_100],
    case (not lists:member(Log, Exclude)) of
        true  ->
            case proplists:get_value(?ITEM_GOLD, Expend) of
                ?nil ->
                    ignore;
                Gold ->
%%                    role_vip:add_exp(Gold, RoleSt),
                    yunying_lottery:add_progress(Log, Obtain, Gold, RoleSt)
            end;
        false ->
            ignore
    end.

process_event(Deal, _RoleSt) ->
    lists:foreach(fun
        ({ItemID, Num}) ->
            role_event:event(?EVENT_ITEM, {ItemID, Num});
        (#p_item{id=ItemID, num=Num}) ->
            role_event:event(?EVENT_ITEM, {ItemID, Num})
    end, Deal#deal.obtain).

process_log(Deal, RoleSt) ->
    #deal{expend=Expend, obtain=Obtain, log=Log} = Deal,
    log_api:log_deal(to_maps(Expend), to_maps(Obtain), Log, RoleSt),
    log_api:item_monitor(Deal#deal.alert, RoleSt),
    log_api:upload_exception(Deal#deal.exception, Log, RoleSt).

process_update(Deal, RoleSt) ->
    #deal{update=Update, log=Log} = Deal,
    #update{add=Add, del=Del, chg=Chg, money=Money} = Update,
    Notify = Log /= ?LOG_ITEM_SELL andalso
             (Add /= [] orelse Del /= [] orelse Chg /= #{}),
    case Notify of
        true  ->
            ?ucast(#m_bag_update_toc{
                add = Add,
                del = Del,
                chg = Chg,
                way = Log
            });
        false ->
            ignore
    end,
    case Money /= #{} of
        true  ->
            ?ucast(#m_role_update_toc{
                money = Money,
                way   = Log
            });
        false ->
            ignore
    end.

process_obtain(Deal, RoleSt) ->
    #role_st{gpid=GuildPid, role=RoleID} = RoleSt,
    NowSecs = ut_time:seconds(),
    lists:foreach(fun
        (#p_item{id=ItemID, num=Num}) when ItemID== ?ITEM_DICE_RANDOM orelse ItemID == ?ITEM_DICE_FIXED ->
            yunying_richman:add_dice(Num, Deal#deal.log, RoleSt);
        (Item) when is_record(Item, p_item) ->
            maybe_expire(Item, NowSecs, RoleSt);
        ({?ITEM_CONTRIB, Num}) ->
            ?_if(is_pid(GuildPid), guild_agent:add_ctrb(GuildPid, RoleID, Num));
        ({?ITEM_GUILD_FUND, Num}) ->
            ?_if(is_pid(GuildPid), guild_agent:add_fund(GuildPid, Num));
        ({?ITEM_TALENT, Num}) ->
            role_talent:add_talent(Num, RoleSt);
        ({?ITEM_MEDAL, Num}) ->
            siegewar_handler:add_medal(Num, RoleSt);
        (_) ->
            ignore
    end, Deal#deal.obtain).

process_expend(Deal, _RoleSt=#role_st{role=RoleID}) ->
    lists:foreach(fun
        (#p_item{uid=CellID, etime=ETime}) when ETime > 0 ->
            role_timer:del_task({RoleID, ?MODULE, CellID});
        ({?ITEM_GOLD, Num}) ->
            IgnoreList = [
                ?LOG_MARKET_SALE,
                ?LOG_MARKET_DEAL,
                ?LOG_MARKET_REMOVE,
                ?LOG_MARKET_BUY,
                ?LOG_MARRIAGE_STEP,
                ?LOG_MARRIAGE_PROPOSAL,
                ?LOG_MARRIAGE_SUCC,
                ?LOG_MARRIAGE_RING,
                ?LOG_MARRIAGE_RING_REPLACE,
                ?LOG_YUNYING_100
            ],
            case lists:member(Deal#deal.log, IgnoreList) of
                true  -> ignore;
                false -> role_event:event(?EVENT_CONSUME, Num)
            end;
        (#p_item{id=ItemID}) ->
            TaskID = cfg_task_item:find(ItemID),
            ?_if(TaskID > 0, role_event:event(?EVENT_ITEM, {ItemID, 0}));
        (_) ->
            ignore
    end, Deal#deal.expend).

maybe_expire(Item, NowSecs, RoleSt=#role_st{role=RoleID}) ->
    Last = Item#p_item.etime - NowSecs,
    case Last > 0 of
        true  ->
            Ref = {RoleID, ?MODULE, Item#p_item.uid},
            role_timer:add_task(Ref, Last, 0, role_hook, ?nil, hook_expire);
        false ->
            ?_if(Item#p_item.etime > 0,
                role_hook:hook_expire({?nil,?nil,Item#p_item.uid}, RoleSt))
    end.

to_maps(List) ->
    lists:foldl(fun
        ({ItemID, Num}, Acc) ->
            ut_misc:maps_increase(ItemID, Num, Acc);
        (#p_item{id=ItemID, num=Num}, Acc) ->
            ut_misc:maps_increase(ItemID, Num, Acc)
    end, #{}, List).

try_move(DstBag, Move) ->
    Deal = #deal{
        rolebag = role_data:get(?DB_ROLE_BAG),
        log     = 0,
        expend  = [],
        obtain  = [],
        update  = #update{}
    },
    Cost = [{cellid,CellID,Num} || {CellID,Num} <- Move],
    {ok, Deal1} = deal_cost(Cost, Deal),
    Gain = [Item#p_item{bag=DstBag} || Item <- Deal1#deal.expend],
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    {ok, Deal2} = deal_gain(Gain, Deal1),
    cache_role_level(RoleInfo, Deal2#deal.roleinfo),
    {ok, Deal2}.

deal_result(Expend, Obtain0, Result, IsRetRaw) ->
    % 剔除经验升级，方便道具展示用途
    case IsRetRaw of
        true  ->
            Expend2 = lists:reverse(Expend),
            Obtain = lists:keydelete(?ITEM_LEVEL, 1, Obtain0),
            Obtain2 = lists:reverse(Obtain);
        false ->
            Expend2 = to_maps(Expend),
            Obtain2 = maps:remove(?ITEM_LEVEL, to_maps(Obtain0))
    end,
    case Result == no_result of
        true  -> {ok, Expend2, Obtain2};
        false -> {ok, Expend2, Obtain2, Result}
    end.


cache_role_level(#role_info{id = RoleID, level = Level}, #role_info{level = Level2}) ->
    case Level =/= Level2 of
        true ->
            role_cache:update(RoleID, [{#role_cache.level, erlang:max(Level, Level2) }]);
        false ->
            igore
    end;

cache_role_level(_, _) ->
    igore.