-ifndef(BAG_HRL).
-define(BAG_HRL, ok).

%% 背包类型
-define(BAG_TYPE_REAL , 1). % 实际背包
-define(BAG_TYPE_DEPOT, 2). % 仓库
-define(BAG_TYPE_DUMMY, 3). % 虚拟背包

%% 背包id
-define(BAG_ID_MAIN       , 101). % 主背包
-define(BAG_ID_SOUL       , 102). % 圣痕背包
-define(BAG_ID_RUNE       , 103). % 符文背包
-define(BAG_ID_BEAST      , 104). % 神兽背包
-define(BAG_ID_PET        , 105). % 宠物背包
-define(BAG_ID_BABY       , 106). % 子女背包
-define(BAG_ID_ILLUS      , 107). % 图鉴背包
-define(BAG_ID_GOD        , 108). % 神灵背包
-define(BAG_ID_MECHA      , 109). % 机甲背包
-define(BAG_ID_PET_EQUIP  , 110). % 机甲背包
-define(BAG_ID_DEPOT      , 201). % 主仓库
-define(BAG_ID_HUNT       , 202). % 寻宝仓库
-define(BAG_ID_BEAST_EQUIP, 301). % 神兽穿戴背包
-define(BAG_ID_EQUIP      , 302). % 装备穿戴背包
-define(BAG_ID_PET_ASSIST , 303). % 宠物助战背包
-define(BAG_ID_RUNE_EQUIP , 304). % 符文穿戴背包
-define(BAG_ID_SOUL_EQUIP , 305). % 圣痕穿戴背包
-define(BAG_ID_BABY_EQUIP , 306). % 子女穿戴背包
-define(BAG_ID_GOD_EQUIP  , 308). % 神灵穿戴背包
-define(BAG_ID_MECHA_EQUIP, 309). % 机甲穿戴背包
-define(BAG_ID_PET_LOAD_EQUIP, 310). % 宠物装备穿戴背包
-define(BAG_ID_ARTIFACT, 401). % 神器背包
-define(BAG_ID_TOTEM, 402). % 图腾背包
-define(BAG_ID_TOTEM_EQUIP, 403). % 图腾穿戴背包


% 背包格子信息
-record(cell, {
      opened :: integer() % 已开启的格子数
    , used   :: list()    % 已使用的格子
    , unused :: list()    % 未使用的格子
}).

-record(deal, {
      rolebag   % #role_bag{}
    , roleinfo  % #role_info{}
    , monitor   % #role_monitor{}
    , log
    , expend    % [#p_item]
    , obtain    % [#p_item]
    , exceed    % key=ItemID, val=Num
    , update
    , alert     % 报警 [RuleID]
    , exception % 异常扣留下来的道具
}).

-record(update, {
      add   = []
    , del   = []
    , chg   = #{}
    , money = #{}
}).

-record(cfg_bag, {
      id
    , name
    , type % 类型(1=背包,2=虚拟背包(如身上的装备等))
    , cap  % 格子总数
    , open % 已开启格子数
    , cost % 开启消耗
}).

-endif.