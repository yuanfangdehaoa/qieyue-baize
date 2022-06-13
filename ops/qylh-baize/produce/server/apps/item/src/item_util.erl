%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(item_util).

-include("attr.hrl").
-include("bag.hrl").
-include("beast.hrl").
-include("equip.hrl").
-include("game.hrl").
-include("item.hrl").
-include("pet.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("baby.hrl").
-include("god_equips.hrl").
-include("mecha.hrl").
-include("totem.hrl").

%% API
-export([new_item/3]).
-export([p_item_base/1]).
-export([p_item/1]).
-export([calc_bind/1]).
-export([item_misc/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
new_item(ItemID, Num, Opts) ->
    Config = #cfg_item{bag=BagID, expire=Expire} = cfg_item:find(ItemID),
    ETime  = ?_if(Expire == 0, 0, ut_time:seconds()+Expire),
    Gender = ut_rand:choose([?GENDER_MALE, ?GENDER_FEMALE]),
    Item0  = #p_item{
        uid    = 0,
        id     = ItemID,
        num    = Num,
        bag    = maps:get(bagid, Opts, BagID),
        bind   = maps:get(bind, Opts, true),
        etime  = maps:get(etime, Opts, ETime),
        gender = maps:get(gender, Opts, Gender),
        score  = 0
    },
    lists:foldl(fun(Fun, Acc) ->
        Fun(Acc, Config, Opts)
    end, Item0, [
        fun make_equip/3,
        fun make_extra/3
    ]).

p_item_base(Item) ->
	#p_item_base{
        uid    = Item#p_item.uid,
        id     = Item#p_item.id,
        num    = Item#p_item.num,
        bag    = Item#p_item.bag,
        bind   = Item#p_item.bind,
        etime  = Item#p_item.etime,
        gender = Item#p_item.gender,
        score  = Item#p_item.score,
        extra  = Item#p_item.extra,
        misc   = item_misc(Item)
	}.

item_misc(Item) ->
    #cfg_item{type=Type} = cfg_item:find(Item#p_item.id),
    if
        Type == ?ITEM_TYPE_PET_EQUIP ->
            #p_equip{stren_phase=Order, stren_lv=Level} = Item#p_item.equip,
            #{"stren_phase"=>Order, "stren_lv"=>Level};
        true ->
            #{}
    end.

p_item(Item) ->
    Item#p_item{
        equip = p_equip(Item#p_item.equip),
        pet   = p_pet(Item#p_item.pet)
    }.

p_equip(?nil) ->
    ?nil;
p_equip(Equip) ->
    Equip1 = Equip#p_equip{
        base  = mod_attr:p_attr(Equip#p_equip.base),
        rare1 = mod_attr:p_attr(Equip#p_equip.rare1),
        rare2 = mod_attr:p_attr(Equip#p_equip.rare2),
        rare3 = mod_attr:p_attr(Equip#p_equip.rare3),
        combine = ?_if(Equip#p_equip.combine == ?nil, [], [p_item(Item) || Item <- Equip#p_equip.combine])
    },
    case Equip#p_equip.marriage of
        ?nil ->
            Equip1;
        Marriage ->
            Equip1#p_equip{
                marriage = Marriage#p_marriage{
                    rare = mod_attr:p_attr(Marriage#p_marriage.rare)
                }
            }
    end.

p_pet(?nil) ->
    ?nil;
p_pet(Pet) ->
    Pet#p_pet{
        base  = mod_attr:p_attr(Pet#p_pet.base),
        rare1 = mod_attr:p_attr(Pet#p_pet.rare1),
        rare2 = mod_attr:p_attr(Pet#p_pet.rare2),
        rare3 = mod_attr:p_attr(Pet#p_pet.rare3)
    }.

calc_bind(Bind) ->
    case Bind of
        0 -> ut_rand:random(1, 100) >= 50;
        1 -> true;
        2 -> false
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
make_equip(Item, CfgItem, Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_EQUIP ->
    #cfg_item{id=ItemID, color=Color} = CfgItem,
    CfgEquip = #cfg_equip{base=Base, rare4=Rare4} = cfg_equip:find(ItemID),
    BaseAttr = mod_attr:to_map(Base),
    {Rare1, Rare2, Rare3} = gen_equip_rare(CfgEquip, Color),
    RareAttr1 = mod_attr:to_map(maps:get(rare1, Opts, Rare1)),
    RareAttr2 = mod_attr:to_map(maps:get(rare2, Opts, Rare2)),
    RareAttr3 = mod_attr:to_map(maps:get(rare3, Opts, Rare3)),
    RareAttr4 = mod_attr:to_map(Rare4),

    Equip = #p_equip{
        base        = BaseAttr,
        rare1       = RareAttr1,
        rare2       = RareAttr2,
        rare3       = RareAttr3,
        stones      = #{},
        stren_phase = 1,
        stren_lv    = 0
    },

    HasMarriage = maps:get(husband_id, Opts, 0) =/= 0
        orelse maps:get(wife_id, Opts, 0) =/= 0,
    case CfgItem#cfg_item.stype of
        ?ITEM_STYPE_LOCK when HasMarriage->
            TotalAttr = mod_attr:sum([BaseAttr, RareAttr1, RareAttr2, RareAttr3, RareAttr4]),
            Equip2 = Equip#p_equip{
                marriage = #p_marriage{
                    husband_id = maps:get(husband_id, Opts, 0),
                    husband    = maps:get(husband, Opts, ""),
                    wife_id    = maps:get(wife_id, Opts, 0),
                    wife       = maps:get(wife, Opts, ""),
                    rare       = RareAttr4
                },
                power    = mod_attr:power(TotalAttr)
            },
            Score = calc_equip_score(TotalAttr, Color, [Base, Rare1, Rare2, Rare3, Rare4]);
        _ ->
            TotalAttr = mod_attr:sum([BaseAttr, RareAttr1, RareAttr2, RareAttr3]),
            Equip2 = Equip#p_equip{
                power = mod_attr:power(TotalAttr)
            },
            Score = calc_equip_score(TotalAttr, Color, [Base, Rare1, Rare2, Rare3])
    end,
    Item#p_item{equip=Equip2, score=Score};
make_equip(Item, CfgItem, Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_EQUIP_BEAST ->
    #cfg_item{id=ItemID} = CfgItem,
    CfgEquip = #cfg_beast_equip{base=Base} = cfg_beast_equip:find(ItemID),
    BaseAttr = mod_attr:to_map(maps:get(base, Opts, Base)),
    {Rare1, Rare2} = gen_beast_rare(CfgEquip),
    RareAttr1 = mod_attr:to_map(Rare1),
    RareAttr2 = mod_attr:to_map(Rare2),
    TotalAttr = mod_attr:sum([BaseAttr, RareAttr1, RareAttr2]),
    Equip = #p_equip{
        base        = BaseAttr,
        rare1       = RareAttr1,
        rare2       = RareAttr2,
        rare3       = #{},
        stones      = #{},
        stren_phase = maps:get(stren_phase, Opts, 0),
        stren_lv    = maps:get(stren_lv, Opts, 1),
        power       = mod_attr:power(TotalAttr)
    },
    Score = calc_beast_score(Base, Rare1, Rare2),
    Item#p_item{equip=Equip, score=Score};
make_equip(Item, CfgItem, Opts) when CfgItem#cfg_item.stype == ?ITEM_STYPE_PET ->
    #cfg_item{id=ItemID, color=Color} = CfgItem,
    CfgEquip = #cfg_pet{base=Base} = cfg_pet:find(ItemID),
    Base2 = gen_pet_base(Base),
    BaseAttr = mod_attr:to_map(maps:get(base, Opts, Base2)),
    {Rare1, Rare2, Rare3} = gen_pet_rare(CfgEquip),
    RareAttr1 = mod_attr:to_map(Rare1),
    RareAttr2 = mod_attr:to_map(Rare2),
    RareAttr3 = mod_attr:to_map(Rare3),
    TotalAttr = mod_attr:sum([BaseAttr, RareAttr1, RareAttr2, RareAttr3]),
    Pet = #p_pet{
        base        = BaseAttr,
        rare1       = RareAttr1,
        rare2       = RareAttr2,
        rare3       = RareAttr3,
        strong      = #{},
        cross       = maps:get(cross, Opts, 0),
        power       = mod_attr:power(TotalAttr)
    },
    Score = calc_pet_score(TotalAttr, Color, [Base2, Rare1, Rare2, Rare3]),
    Item#p_item{pet=Pet, score=Score};
make_equip(Item, CfgItem, _Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_EQUIP_BABY ->
    #cfg_item{id=ItemID, color=Color} = CfgItem,
    #cfg_baby_equip{base=Base} = cfg_baby_equip:find(ItemID),
    BaseAttr = mod_attr:to_map(Base),
    Equip = #p_equip{
        base        = BaseAttr,
        rare1       = #{},
        rare2       = #{},
        rare3       = #{},
        stones      = #{},
        stren_phase = 0,
        stren_lv    = 0,
        power       = mod_attr:power(BaseAttr)
    },
    Item#p_item{score=Color, equip=Equip};
make_equip(Item, CfgItem, _Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_EQUIP_GOD ->
    #cfg_item{id=ItemID, color=Color} = CfgItem,
    #cfg_god_equip{base=Base} = cfg_god_equip:find(ItemID),
    BaseAttr = mod_attr:to_map(Base),
    Equip = #p_equip{
        base        = BaseAttr,
        rare1       = #{},
        rare2       = #{},
        rare3       = #{},
        stones      = #{},
        stren_phase = 0,
        stren_lv    = 0,
        power       = mod_attr:power(BaseAttr)
    },
    Item#p_item{score=Color, equip=Equip};
make_equip(Item, CfgItem, _Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_EQUIP_MECHA ->
    #cfg_item{id=ItemID, color=Color} = CfgItem,
    #cfg_mecha_equip{base=Base} = cfg_mecha_equip:find(ItemID),
    BaseAttr = mod_attr:to_map(Base),
    Equip = #p_equip{
        base        = BaseAttr,
        rare1       = #{},
        rare2       = #{},
        rare3       = #{},
        stones      = #{},
        stren_phase = 0,
        stren_lv    = 0,
        power       = mod_attr:power(BaseAttr)
    },
    Item#p_item{score=Color, equip=Equip};
make_equip(Item, CfgItem, _Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_PET_EQUIP ->
    #cfg_item{id=ItemID, color=Color} = CfgItem,
    CfgEquip = #cfg_pet_equip{base=Base} = cfg_pet_equip:find(ItemID, 1),
    {Rare1, Rare2, Rare3} = gen_pet_equip_rare(CfgEquip, Color),
    BaseAttr  = mod_attr:to_map(Base),
    RareAttr1 = mod_attr:to_map(Rare1),
    RareAttr2 = mod_attr:to_map(Rare2),
    RareAttr3 = mod_attr:to_map(Rare3),
    Equip = #p_equip{
        base        = BaseAttr,
        rare1       = RareAttr1,
        rare2       = RareAttr2,
        rare3       = RareAttr3,
        stones      = #{},
        stren_phase = 1,
        stren_lv    = 0,
        power       = mod_attr:power(BaseAttr)
    },
    Total = mod_attr:sum([BaseAttr, RareAttr1, RareAttr2, RareAttr3]),
    Score = calc_pet_score(Total, Color, [Base, Rare1, Rare2, Rare3]),
    Item#p_item{score=Score, equip=Equip};
make_equip(Item, CfgItem, _Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_ARTI_EQUIP ->
    #cfg_item{id=ItemID, color=Color} = CfgItem,
    #cfg_equip{base=Base, rare1=Rare1, rare2=Rare2, rare3=Rare3} = cfg_equip:find(ItemID),
    BaseAttr  = mod_attr:to_map(Base),
    RareAttr1 = mod_attr:to_map(Rare1),
    RareAttr2 = mod_attr:to_map(Rare2),
    RareAttr3 = mod_attr:to_map(Rare3),
    Equip = #p_equip{
        base        = BaseAttr,
        rare1       = RareAttr1,
        rare2       = RareAttr2,
        rare3       = RareAttr3,
        stones      = #{},
        stren_phase = 0,
        stren_lv    = 0,
        power       = mod_attr:power(BaseAttr)
    },
    Total = mod_attr:sum([BaseAttr, RareAttr1, RareAttr2, RareAttr3]),
    Score = calc_equip_score(Total, Color, [Base, Rare1, Rare2, Rare3]),
    Item#p_item{score=Score, equip=Equip};
make_equip(Item, CfgItem, Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_TOTEMS_EQUIP ->
    #cfg_item{id=ItemID} = CfgItem,
    CfgEquip = #cfg_totem_equip{base=Base} = cfg_totems_equip:find(ItemID),
    BaseAttr = mod_attr:to_map(maps:get(base, Opts, Base)),
    {Rare1, Rare2} = gen_totem_rare(CfgEquip),
    RareAttr1 = mod_attr:to_map(Rare1),
    RareAttr2 = mod_attr:to_map(Rare2),
    TotalAttr = mod_attr:sum([BaseAttr, RareAttr1, RareAttr2]),
    Equip = #p_equip{
        base        = BaseAttr,
        rare1       = RareAttr1,
        rare2       = RareAttr2,
        rare3       = #{},
        stones      = #{},
        stren_phase = maps:get(stren_phase, Opts, 0),
        stren_lv    = maps:get(stren_lv, Opts, 1),
        power       = mod_attr:power(TotalAttr)
    },
    Score = calc_totem_score(Base, Rare1, Rare2),
    Item#p_item{equip=Equip, score=Score};
make_equip(Item, _CfgItem, _Opts) ->
    Item.

make_extra(Item, CfgItem, _Opts) when CfgItem#cfg_item.stype == ?ITEM_STYPE_MAGICCARD ->
    Item#p_item{extra=1};
make_extra(Item, CfgItem, _Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_EQUIP_BEAST ->
    Item#p_item{extra=(Item#p_item.equip)#p_equip.stren_lv};
make_extra(Item, CfgItem, _Opts) when CfgItem#cfg_item.stype == ?ITEM_STYPE_PET ->
    Item#p_item{extra=0};
make_extra(Item, CfgItem, Opts) when CfgItem#cfg_item.stype == ?ITEM_STYPE_SOUL ->
    Item#p_item{extra=maps:get(soul_level, Opts, 1)};
make_extra(Item, CfgItem, _Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_EQUIP_BABY ->
    Item#p_item{extra=0};
make_extra(Item, CfgItem, _Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_EQUIP_GOD ->
    Item#p_item{extra=0};
make_extra(Item, CfgItem, _Opts) when CfgItem#cfg_item.type == ?ITEM_TYPE_EQUIP_MECHA ->
    Item#p_item{extra=0};
make_extra(Item, _CfgItem, _Opts) ->
    Item.

% 计算装备评分
calc_equip_score(Attr, Color, Attrs) ->
    BaseScore = ?_attr(Attr,?ATTR_ATT) * cfg_attr_type:coef(?ATTR_ATT)
              + ?_attr(Attr,?ATTR_WRECK) * cfg_attr_type:coef(?ATTR_WRECK)
              + ?_attr(Attr,?ATTR_HPMAX) * cfg_attr_type:coef(?ATTR_HPMAX)
              + ?_attr(Attr,?ATTR_DEF) * cfg_attr_type:coef(?ATTR_DEF),
    Fun = fun ({Code, Val}, Acc) ->
        QualityList = cfg_equip_score:quality_ratio(Code),
        QualityMap = maps:from_list(QualityList),
        Acc + ut_math:ceil(BaseScore * Val * cfg_equip_score:ratio(Code)/10000)
            + ut_math:ceil(BaseScore * Val * maps:get(Color, QualityMap, 0))
    end,
    Score = lists:foldl(Fun, 0, lists:concat(Attrs)),
    ut_math:ceil(BaseScore + Score).

calc_pet_score(Attr, Color, Attrs)->
    BaseScore = ?_attr(Attr,?ATTR_ATT) * cfg_attr_type:coef(?ATTR_ATT)
              + ?_attr(Attr,?ATTR_WRECK) * cfg_attr_type:coef(?ATTR_WRECK)
              + ?_attr(Attr,?ATTR_HPMAX) * cfg_attr_type:coef(?ATTR_HPMAX)
              + ?_attr(Attr,?ATTR_DEF) * cfg_attr_type:coef(?ATTR_DEF),
    Fun = fun ({Code, Val}, Acc) ->
        QualityList = cfg_pet_score:quality_ratio(Code),
        QualityMap = maps:from_list(QualityList),
        Acc + ut_math:ceil(BaseScore * Val * cfg_pet_score:ratio(Code)/10000)
            + ut_math:ceil(BaseScore * Val * maps:get(Color, QualityMap, 0))
    end,
    Score = lists:foldl(Fun, 0, lists:concat(Attrs)),
    ut_math:ceil(BaseScore + Score).

calc_beast_score(Base, Rare1, Rare2) ->
    Fun = fun ({Code, Val}, Acc) ->
        Acc + round(Val * cfg_beast_equip_score:ratio(Code))
    end,
    Score0 = lists:foldl(Fun, 0, Base),
    Score1 = lists:foldl(Fun, 0, Rare1),
    Score2 = lists:foldl(Fun, 0, Rare2),
    Score0 + Score1 + Score2.

calc_totem_score(Base, Rare1, Rare2) ->
    Fun = fun ({Code, Val}, Acc) ->
        Acc + round(Val * cfg_totems_equip_score:ratio(Code))
          end,
    Score0 = lists:foldl(Fun, 0, Base),
    Score1 = lists:foldl(Fun, 0, Rare1),
    Score2 = lists:foldl(Fun, 0, Rare2),
    Score0 + Score1 + Score2.

%% 生成极品属性
gen_equip_rare(CfgEquip, Color) when Color =< ?COLOR_RED ->
    % 属性总条数
    Num1 = case Color of
        ?COLOR_RED    -> 3;
        ?COLOR_ORANGE -> 2;
        ?COLOR_PURPLE -> 1;
        ?COLOR_BLUE   -> 1;
        _             -> 0
    end,
    #cfg_equip{rare1=Rare1, rare2=Rare2, rare3=_Rare3} = CfgEquip,
    case CfgEquip#cfg_equip.star of
        3 -> % 3星装备，3条紫色属性
            Num2 = min(3, Num1),
            {
                [],
                random_rare(Rare2, Num2),
                []
            };
        2 -> % 2星装备，2条紫色属性
            Num2 = min(2, Num1),
            {
                random_rare(Rare1, Num1-Num2),
                random_rare(Rare2, Num2),
                []
            };
        1 -> % 1星装备，1条紫色属性
            Num2 = min(1, Num1),
            {
                random_rare(Rare1, Num1-Num2),
                random_rare(Rare2, Num2),
                []
            };
        0 -> % 0星装备，0条紫色属性
            {
                random_rare(Rare1, Num1),
                [],
                []
            }
    end;

gen_equip_rare(CfgEquip, _Color) ->
    #cfg_equip{rare2=Rare2, rare3=Rare3} = CfgEquip,
    {
        [],
        random_rare(Rare2, 3),
        random_rare(Rare3, 1)
    }.

gen_beast_rare(CfgEquip) ->
    #cfg_beast_equip{star=Star, rare1=Rare1, rare2=Rare2} = CfgEquip,
    gen_rare(Star, Rare1, Rare2).

gen_totem_rare(CfgEquip) ->
    #cfg_totem_equip{star=Star, rare1=Rare1, rare2=Rare2} = CfgEquip,
    gen_rare(Star, Rare1, Rare2).


gen_rare(Star, Rare1, Rare2) ->
    % 属性总条数
    Num1 = 3,

    case Star of
        3 -> % 3星装备，3条紫色属性
            Num2 = min(3, Num1),
            {
                [],
                random_rare(Rare2, Num2)
            };
        2 -> % 2星装备，2条紫色属性
            Num2 = min(2, Num1),
            {
                random_rare(Rare1, Num1-Num2),
                random_rare(Rare2, Num2)
            };
        1 -> % 1星装备，1条紫色属性
            Num2 = min(1, Num1),
            {
                random_rare(Rare1, Num1-Num2),
                random_rare(Rare2, Num2)
            };
        0 -> % 0星装备，0条紫色属性
            {
                random_rare(Rare1, Num1),
                []
            }
    end.

%生成宠物基础属性
gen_pet_base(Base) ->
  lists:foldl(fun
          ({Key, Min, Max}, List)->
              [{Key, ut_rand:random(Min, Max)} | List]
      end, [], Base).

gen_pet_rare(CfgEquip) ->
    #cfg_pet{count=Count, rare1=Rare1, rare2=Rare2, rare3=Rare3} = CfgEquip,
    {Count1, Count2, Count3} = Count,
    R1 = gen_pet_rare2(Rare1, Count1),
    R2 = gen_pet_rare2(Rare2, Count2),
    R3 = gen_pet_rare2(Rare3, Count3),
    {R1, R2, R3}.

gen_pet_rare2(Rare, Num)->
    Elems = random_rare(Rare, Num),
    lists:foldl(fun
            ({K, Min, Max}, Lists) ->
                [{K, ut_rand:random(Min, Max)} | Lists]
        end, [], Elems).


gen_pet_equip_rare(CfgEquip, Color) when Color =< ?COLOR_RED ->
    #cfg_pet_equip{star=Star, rare1=Rare1, rare2=Rare2} = CfgEquip,
    % 属性总条数
    Num1 = case Color of
        ?COLOR_RED    -> 3;
        ?COLOR_ORANGE -> 2;
        ?COLOR_PURPLE -> 1;
        ?COLOR_BLUE   -> 1;
        _             -> 0
    end,
    case Star of
        3 -> % 3星装备，3条紫色属性
            Num2 = min(3, Num1),
            {
                [],
                random_rare(Rare2, Num2),
                []
            };
        2 -> % 2星装备，2条紫色属性
            Num2 = min(2, Num1),
            {
                random_rare(Rare1, Num1-Num2),
                random_rare(Rare2, Num2),
                []
            };
        1 -> % 1星装备，1条紫色属性
            Num2 = min(1, Num1),
            {
                random_rare(Rare1, Num1-Num2),
                random_rare(Rare2, Num2),
                []
            };
        0 -> % 0星装备，0条紫色属性
            {
                random_rare(Rare1, Num1),
                [],
                []
            }
    end;
gen_pet_equip_rare(CfgEquip, _Color) ->
    #cfg_pet_equip{rare2=Rare2, rare3=Rare3} = CfgEquip,
    {
        [],
        random_rare(Rare2, 3),
        random_rare(Rare3, 1)
    }.

random_rare([], _Num) ->
    [];
random_rare(_Rare, 0) ->
    [];
random_rare(Rare, Num) ->
    ut_rand:weight(Rare, Num, false).
