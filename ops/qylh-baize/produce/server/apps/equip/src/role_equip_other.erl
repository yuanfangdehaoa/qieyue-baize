%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_equip_other).

-include("table.hrl").
-include("game.hrl").
-include("equip.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("item.hrl").
-include("enum.hrl").
-include("bag.hrl").

%% API
-export([get_attr/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%获取基础属性外的所有属性
get_attr(_)->
    #role_equip{
          smelt             = Smelt
        , strength_suite_id = SSID
        , suites            = Suites
        , equips            = Equips
    } = role_data:get(?DB_ROLE_EQUIP),
    Attr1 = get_equips_attr(Equips),
    #cfg_equip_smelt{attr=Attr} = cfg_equip_smelt:find(Smelt),
    Attr2 = get_strength_suite_attr(SSID),
    Attr3 = get_suites_attr(Suites),
    mod_attr:sum([Attr, Attr1, Attr2, Attr3]).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

%获取强化套装属性
get_strength_suite_attr(SuiteId)->
    case cfg_equip_strength_suite:find(SuiteId) of
        #cfg_equip_strength_suite{attrib=Attr} ->
            Attr;
        _ ->
            #{}
    end.

%获取套装属性
get_suites_attr(Suites)->
    Suite = maps:get(1, Suites, ?nil),
    Suite2 = maps:get(2, Suites, ?nil),
    case Suite == ?nil andalso Suite2 == ?nil of
        true -> #{};
        false -> get_suite(Suite, Suite2)
    end.

get_equip_attr(Slot, Equip, ItemId)->
    #p_equip{
        rare1=RareAttr1,
        rare2=RareAttr2,
        rare3=RareAttr3,
        marriage=Marriage,
        stren_phase=Phase,
        stren_lv=Level,
        stones=Stones,
        cast=CastLevel,
        refine=Refine
    } = Equip,
    Attrib = mod_attr:sum([RareAttr1, RareAttr2, RareAttr3]),
    StrengthId= cfg_equip_strength:find_id({Slot, Phase, Level}),
    {Attrib2, Strong} = case StrengthId == undefined of
        true->
            {Attrib, []};
        false->
            #cfg_equip_strength{attrib=StrAttribs} = cfg_equip_strength:find(StrengthId),
            {mod_attr:add(Attrib, StrAttribs), StrAttribs}
    end,
    AllStoneAttribs = maps:fold(fun
            (Hole, StoneId, StoneAttribs) ->
                case Hole >= 1 andalso Hole =< 6 of
                    true  -> #cfg_stone{attrib=SAttribs} = cfg_stone:find(StoneId);
                    false -> #cfg_spar{attrib=SAttribs} = cfg_spar:find(StoneId)
                end,
                mod_attr:add(StoneAttribs, SAttribs)
        end, #{}, Stones),
    Attrib3 = mod_attr:add(Attrib2, AllStoneAttribs),
    Attrib4 = case Marriage of
        #p_marriage{rare=RareAttr4, husband_id=HusbandID} when HusbandID > 0 ->
            mod_attr:add(Attrib3, RareAttr4);
        _ ->
            Attrib3
    end,
    %铸造属性,
    Attrib5 = mod_attr:add(Attrib4, get_cast_attr(Slot, CastLevel, ItemId, Strong)),
    %强化加成
    StrongPlus = get_strong_plus(Strong),
    %洗练属性
    mod_attr:sum([Attrib5, get_refine_attr(Refine), StrongPlus]).


%获取强化加成
get_strong_plus(Strong)->
    Plus = role_soul:get_strong_plus(),
    lists:foldl(fun 
            ({K, V}, Acc) -> 
                [{K, ut_math:ceil(V*Plus/10000)} | Acc] 
        end, [], Strong).


get_equips_attr(Equips)->
    maps:fold(fun
            (Slot, CellId, Attr) ->
                case role_bag:get_item(CellId) of 
                    {ok, Item} ->
                        #p_item{etime=ETime} = Item,
                        case ETime == 0 orelse ETime > ut_time:seconds() of
                            true ->
                                #p_item{equip=Equip, id=ItemId} = role_equip:get_item(Item),
                                mod_attr:add(Attr, get_equip_attr(Slot, Equip, ItemId));
                            false ->
                                Attr
                        end;
                    _ ->
                        Attr
                end
        end, #{}, Equips).

get_cast_attr(Slot, Level, ItemId, Strong)->
    CfgCast = cfg_equip_cast:find(Slot, Level),
    case CfgCast of
        ?nil -> 
            [];
        #cfg_equip_cast{percent=Per, attr=Attr} ->
            #cfg_equip{base=Base} = cfg_equip:find(ItemId),
            StrongMap = maps:from_list(Strong),
            Attr1 = lists:foldl(fun 
                    ({Key, Value}, Acc) -> 
                        Value2 = ut_math:floor((Value + maps:get(Key, StrongMap, 0)) * Per/10000),
                        [{Key, Value2} | Acc]
                end, [], Base),
            mod_attr:add(Attr, Attr1)
    end.

%获取洗练属性
get_refine_attr(Refine)->
    lists:foldl(fun 
            (#p_refine{attr=Attr, value=Value}, Acc) -> 
                [{Attr, Value} | Acc] 
        end, [], Refine).





get_suite(Suite, Suite2)->
    #suite{active=Active} = Suite,
    case Suite2 == ?nil of
        true ->
            get_suite_attr(Active);
        false ->
            {Attr, HadSuite} = get_suite2(Suite2),
            Attr2 = get_suite_attr_except(Active, HadSuite),
            mod_attr:add(Attr, Attr2)
    end.

%获取套装2的属性，记录已增加属性的对应套装1
get_suite2(Suite2)->
    #suite{active=Active2} = Suite2,
    maps:fold(fun
            (SuiteId, Num, {Attr, SuiteMap}) ->
                #cfg_equip_suite{order=Order, type_id=TypeId, level=Level, attribs=AttrList}
                = cfg_equip_suite:find(SuiteId),
                Attr2 = get_suite_attr2(AttrList, Num),
                Attr3 = mod_attr:add(Attr, Attr2),
                SuiteMap2 = had_suite(SuiteMap, Order, TypeId, Level-1, Num),
                {Attr3, SuiteMap2}
        end, {#{}, #{}}, Active2).

get_suite_attr(Active)->
    maps:fold(fun
            (SuiteId, Num, Attr) ->
                #cfg_equip_suite{attribs=AttrList} = cfg_equip_suite:find(SuiteId),
                Attr2 = get_suite_attr2(AttrList, Num),
                mod_attr:add(Attr, Attr2)
        end, #{}, Active).

get_suite_attr2(AttrList, Num)->
    lists:foldl(fun
        ({Key, Attrs}, Attr) ->
            case Num >= Key of
                true  ->
                    mod_attr:add(Attr, Attrs);
                false ->
                    Attr
            end
    end, #{}, AttrList).

get_suite_attr_except(Active, HadSuite)->
    maps:fold(fun
            (SuiteId, Num, Attr) ->
                #cfg_equip_suite{attribs=AttrList} = cfg_equip_suite:find(SuiteId),
                Num2  = maps:get(SuiteId, HadSuite, 0),
                Attr2 = get_suite_attr_except2(AttrList, Num, Num2),
                mod_attr:add(Attr, Attr2)
        end, #{}, Active).

get_suite_attr_except2(AttrList, Num, Num2)->
    lists:foldl(fun
        ({Key, Attrs}, Attr) ->
            case Key > Num2 andalso Num >= Key of
                true  ->
                    mod_attr:add(Attr, Attrs);
                false ->
                    Attr
            end
    end, #{}, AttrList).

%记录已算过属性的套装
had_suite(HadSuite, Order, TypeId, Level, Num)->
    SuiteId = case TypeId == 1 of 
        true  -> cfg_equip_suite:find_id({TypeId, Order, Level});
        false -> cfg_equip_suite:find_id({TypeId, 0, Level})
    end,
    maps:put(SuiteId, Num, HadSuite).