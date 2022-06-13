%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_equip).

-include("table.hrl").
-include("game.hrl").
-include("equip.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("item.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("bag.hrl").
-include("msgno.hrl").

%% API
-export([
    get_item_base/1,
    get_equip_strength/1,
    send_item_toc/2,
    calc_power/2,
    check_maked/3,
    is_suite_maked/2,
    get_attr/1,
    get_item/1,
    puton_ring/3,
    hook_expire/2,
    smelt/2,
    smelt_items/2,
    has_fairy/1
]).

-export([is_compose_succ/1]).
-export([update_compose_count/2]).
-export([is_composed/1]).
-export([putoff_nocalc/2]).
-export([puton_nocalc/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_expire(Item, RoleSt) ->
    case Item#p_item.bag == ?BAG_ID_EQUIP of
        true  ->
            role_attr:recalc(role_equip, RoleSt);
        false ->
            ignore
    end.

%获取基础属性
get_attr(?ATTR_TYPE_WEAPON)->
    #role_equip{equips = Equips} = role_data:get(?DB_ROLE_EQUIP),
    Equips2 = maps:with([1001, 1002], Equips),
    get_equips_attr(Equips2);
get_attr(?ATTR_TYPE_ARMOR)->
    #role_equip{equips = Equips} = role_data:get(?DB_ROLE_EQUIP),
    Equips2 = maps:with([1006, 1007, 1008, 1009, 1010], Equips),
    get_equips_attr(Equips2);
get_attr(?ATTR_TYPE_JEWEL)->
    #role_equip{equips = Equips} = role_data:get(?DB_ROLE_EQUIP),
    Equips2 = maps:with([1003, 1004, 1005], Equips),
    get_equips_attr(Equips2);
get_attr(_)->
    #role_equip{equips=Equips} = role_data:get(?DB_ROLE_EQUIP),
    Equips2 = maps:with([1011, 1012, 1013], Equips),
    get_equips_attr(Equips2).


%获取装备 return:#p_item
get_item_base(Slot)->
    #role_equip{equips = Equips} = role_data:get(?DB_ROLE_EQUIP),
    CellId = maps:get(Slot, Equips, 0),
    case role_bag:get_item(CellId) of
        {ok,E} -> get_item(E);
        _  -> ?nil
    end.

%获取强化 return:#equip_strength
get_equip_strength(Slot)->
    #role_equip{strengths = Strengths} = role_data:get(?DB_ROLE_EQUIP),
    case maps:find(Slot, Strengths) of
        {ok, E} -> E;
        error -> #equip_strength{phase=1,level=0,bless_value=0}
    end.

get_item(Item)->
    #p_item{id=ItemId, equip=Equip} = Item,
    #cfg_equip{slot=Slot} = cfg_equip:find(ItemId),
    #role_equip{stones=Stones, casts=Casts, refine=Refine, suites=Suites} = role_data:get(?DB_ROLE_EQUIP),
    SlotStones = maps:get(Slot, Stones, #{}),
    Equip2 = calc_strength(Slot, Equip, ItemId),
    Equip3 = Equip2#p_equip{
        stones = SlotStones,
        suite  = get_active_suite(Slot, Suites),
        refine = get_refine(Slot, Refine),
        cast   = get_cast(Slot, Casts)
    },
    Item2 = Item#p_item{equip=Equip3},
    role_bag:set_item(Item2),
    Item2.


%计算战力
%Equip:#p_equip
calc_power(Slot, Equip)->
    #p_equip{base=BaseAttr, rare1=RareAttr1, rare2=RareAttr2, rare3=RareAttr3, stren_phase=Phase, stren_lv=Level, stones=Stones} = Equip,
    Attrib = mod_attr:sum([BaseAttr, RareAttr1, RareAttr2, RareAttr3]),
    StrengthId= cfg_equip_strength:find_id({Slot, Phase, Level}),
    case StrengthId == undefined of
        true->
            Attrib2 = Attrib;
        false->
            #cfg_equip_strength{attrib=StrAttribs} = cfg_equip_strength:find(StrengthId),
            Attrib2 = mod_attr:add(Attrib, StrAttribs)
    end,
    AllStoneAttribs = maps:fold(fun
            (_K, StoneId, StoneAttribs) ->
                #cfg_stone{attrib=SAttribs} = cfg_stone:find(StoneId),
                mod_attr:add(StoneAttribs, SAttribs)
        end, #{}, Stones),
    Attrib3 = mod_attr:add(Attrib2, AllStoneAttribs),
    Power = mod_attr:power(Attrib3),
    Equip#p_equip{power=Power}.


%检查套装是否已制作
check_maked(Suites, Slot, Level)->
    maps:fold(fun
            (K, #suite{maked=Maked}, Sum) ->
                case K >= Level of
                    true->
                        ?_check(lists:member(Slot, Maked)==false, ?ERR_EQUIP_SLOT_IS_MAKED);
                    false->ignor
                end,
                Sum + 0
        end, 0, Suites).

%套装是否已制作
is_suite_maked(Slot, Level)->
    #role_equip{suites=Suites} = role_data:get(?DB_ROLE_EQUIP),
    is_suite_maked2(maps:to_list(Suites), Slot, Level).

is_suite_maked2([], _Slot, _Level)->
    false;
is_suite_maked2([{K, #suite{maked=Maked}}|Suites], Slot, Level)->
    case K >= Level of
        true  ->
            case lists:member(Slot, Maked) of
                true  -> true;
                false -> is_suite_maked2(Suites, Slot, Level)
            end;
        false ->
            is_suite_maked2(Suites, Slot, Level)
    end.

%熔炼
smelt_items(ItemIds, RoleSt)->
	RoleEquip = #role_equip{smelt=Smelt, smelt_exp=SmeltExp} = role_data:get(?DB_ROLE_EQUIP),
	?_check(cfg_equip_smelt:find(Smelt+1) /= ?nil, ?ERR_EQUIP_SMELT_MAX_LEVEL),
	AddExp = lists:foldl(fun
			({ItemId, Num}, Acc)->
				 Acc + cfg_equip:smelt_exp(ItemId)*Num
		end, 0, ItemIds),
	VipLv = role_vip:get_level(),
	Percent = cfg_vip_rights:find(?VIP_RIGHTS_15, VipLv, 0)/10000,
	SmeltExp2 = SmeltExp + ceil(AddExp * (1 + Percent)),
	{Smelt2, Exp} = smelt_up(Smelt, SmeltExp2),
	role_data:set(RoleEquip#role_equip{smelt=Smelt2, smelt_exp=Exp}),
	role_attr:recalc(role_equip, RoleSt),
	{Smelt, Smelt2}.

%熔炼{吞噬前等级，吞噬后等级，吞噬后经验}
smelt(UIds, RoleSt)->
	RoleEquip = #role_equip{smelt=Smelt, smelt_exp=SmeltExp} = role_data:get(?DB_ROLE_EQUIP),
	?_check(cfg_equip_smelt:find(Smelt+1) /= ?nil, ?ERR_EQUIP_SMELT_MAX_LEVEL),
	{Cost, AddExp} = lists:foldl(fun
			(CellId, {CostList, Exp})->
				 CostList2 = CostList ++ [{cellid, CellId}],
				 {ok, #p_item{id=ItemId, num=Num}} = role_bag:get_item(CellId),
                 #cfg_item{type=Type, stype=SType, effect=Effect} = cfg_item:find(ItemId),
                 Exp2 = case Type == ?ITEM_TYPE_EQUIP of
                    true  ->
                        Exp + cfg_equip:smelt_exp(ItemId);
                    false ->
                        case SType == ?ITEM_STYPE_BAG_EXP of
                            true  -> Exp + Effect*Num;
                            false -> throw(?err(?ERR_EQUIP_SMELT_COST_WRONG))
                        end
                 end,
				 {CostList2, Exp2}
		end, {[], 0}, UIds),
	role_bag:cost(Cost, ?LOG_EQUIP_SMELT, RoleSt),
	VipLv = role_vip:get_level(),
	Percent = cfg_vip_rights:find(?VIP_RIGHTS_15, VipLv, 0)/10000,
	SmeltExp2 = SmeltExp + ceil(AddExp * (1 + Percent)),
	{Smelt2, Exp} = smelt_up(Smelt, SmeltExp2),
	role_data:set(RoleEquip#role_equip{smelt=Smelt2, smelt_exp=Exp}),
	role_attr:recalc(role_equip, RoleSt),
	role_event:event(?EVENT_EQUIP_SMELT, {length(UIds), Smelt2}),
	{Smelt, Smelt2, Exp}.

%更新道具属性到客户端
send_item_toc(Item, RoleSt)->
    ?ucast(#m_equip_update_equip_toc{item=item_util:p_item(Item)}).

%获取合成次数
is_compose_succ(Compose)->
    case Compose of
        {Key, MaxCount} ->
            #role_compose{counts=Counts} = role_data:get(?DB_ROLE_COMPOSE),
            Count = maps:get(Key, Counts, 0),
            {Count+1 >= MaxCount, Count};
        _ ->
            {false, 0}
    end.

%更新次数
update_compose_count(Compose, Count)->
    case Compose of
        {Key, _} ->
            RoleCompose = #role_compose{counts=Counts, keys=Keys} = role_data:get(?DB_ROLE_COMPOSE),
            Counts2 = maps:put(Key, Count, Counts),
            Keys2 = case lists:member(Key, Keys) of
                true  -> Keys;
                false -> [Key | Keys]
            end,
            role_data:set(RoleCompose#role_compose{counts=Counts2, keys=Keys2});
        _ ->
            igonre
    end.

%是否合成过
is_composed(Compose)->
    case Compose of
        {Key, _} ->
            #role_compose{keys=Keys} = role_data:get(?DB_ROLE_COMPOSE),
            lists:member(Key, Keys);
        _ ->
            false
    end.

has_fairy(FairyType)->
    #role_equip{equips=Equips} = role_data:get(?DB_ROLE_EQUIP),
    case maps:find(?ITEM_STYPE_FAIRY, Equips) of
        {ok, CellID} ->
            NowSecs = ut_time:seconds(),
            case role_bag:get_item(CellID) of
                {ok, Item} when Item#p_item.etime >= NowSecs ->
                    #cfg_item{effect=CfgType} = cfg_item:find(Item#p_item.id),
                    FairyType == CfgType;
                _ ->
                    false
            end;
        error ->
            false
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

%继承强化，宝石等
calc_strength(Slot, Equip, ItemId)->
    #cfg_equip{order=Order} = cfg_equip:find(ItemId),
    #cfg_item{color=Color} = cfg_item:find(ItemId),
    LimitId = cfg_equip_strength_limit:find_id({Slot, Order, Color}),
    %继承强化等级
    case cfg_equip_strength_limit:find(LimitId) of
        #cfg_equip_strength_limit{max_phase=MaxPhase}->
            #equip_strength{phase=Phase, level=Level} = role_equip:get_equip_strength(Slot),
            case MaxPhase > Phase of
                true->
                    Equip#p_equip{stren_phase=Phase, stren_lv=Level};
                false->
                    Equip#p_equip{stren_phase=MaxPhase-1, stren_lv=10}
            end;
        _->
            Equip
    end.

%获得套装
get_active_suite(Slot, Suites)->
    {_, Suite} = maps:fold(fun
            (Level, #suite{active=Active, maked=Maked}, {OldLevel, ActvieSuite}) ->
                Keys = maps:keys(Active),
                case length(Keys) > 0 of
                    true ->
                        %[SuiteId|_T] = Keys,
                        %#cfg_equip_suite{slots=Slots} = cfg_equip_suite:find(SuiteId),
                        case lists:member(Slot, Maked) of
                            true ->
                                case Level > OldLevel of
                                    true  -> {Level, Active};
                                    false -> {OldLevel, ActvieSuite}
                                end;
                            false ->
                                {OldLevel, ActvieSuite}
                        end;
                    false->
                       {OldLevel, ActvieSuite}
                end
        end, {0, #{}}, Suites),
    Suite.

%火的洗练
get_refine(Slot, RefineMaps)->
    case maps:get(Slot, RefineMaps, ?nil) of
        ?nil -> [];
        #p_refine_slot{holes=Holes} -> maps:values(Holes)
    end.

% %获得铸造
get_cast(Slot, Casts)->
    case maps:get(Slot, Casts, ?nil) of
        ?nil -> 0;
        #equip_cast{cast=Cast} -> Cast
    end.


get_equips_attr(Equips)->
    maps:fold(fun
            (_Slot, CellId, Attr) ->
                case role_bag:get_item(CellId) of
                    {ok, Item} ->
                        #p_item{etime=ETime} = Item,
                        case ETime == 0 orelse ETime > ut_time:seconds() of
                            true ->
                                #p_item{equip=Equip} = get_item(Item),
                                #p_equip{base=Base} = Equip,
                                mod_attr:add(Attr, Base);
                            false ->
                                Attr
                        end;
                    _ ->
                        Attr
                end
        end, #{}, Equips).


puton_ring(RingID, Opts, RoleSt) ->
    RoleEquip = role_data:get(?DB_ROLE_EQUIP),
    #role_equip{equips=Equips} = RoleEquip,
    #cfg_equip{slot = Slot} = cfg_equip:find(RingID),
    OldCellId = maps:get(Slot, Equips, 0),
    Gain = [{RingID, 1, Opts}],
    Cost = ?_if(OldCellId > 0, [{cellid, OldCellId}], []),
    Succ = fun(#deal{obtain=[NewItem]}) ->
        Equips2 = maps:put(Slot, NewItem#p_item.uid, Equips),
        role_data:set(RoleEquip#role_equip{equips = Equips2}),
        Item = role_equip:get_item(NewItem),
        ?ucast(#m_equip_list_toc{equips = [item_util:p_item(Item)]}),
        ?ucast(#m_equip_puton_toc{slot=Slot})
    end,
    role_bag:deal(Cost, Gain, ?LOG_MARRIAGE_RING_REPLACE, Succ, RoleSt),
    role_attr:recalc(role_equip, RoleSt).

%脱下，不计算强化和套装退回，用于戒指手镯合成
putoff_nocalc(Slot, RoleSt)->
    RoleEquip = #role_equip{equips=Equips} = role_data:get(?DB_ROLE_EQUIP),
    CellId = maps:get(Slot, Equips, 0),
    case CellId == 0 of
        true ->
            false;
        false ->
            Equips2 = maps:remove(Slot, Equips),
            role_data:set(RoleEquip#role_equip{equips = Equips2}),
            role_bag:move(?BAG_ID_EQUIP, ?BAG_ID_MAIN, [{CellId, 1}], RoleSt),
            true
    end.

%穿戴，不计算强化和套装退回，用于戒指手镯合成
puton_nocalc(Slot, CellID, RoleSt)->
    RoleEquip = #role_equip{equips=Equips} = role_data:get(?DB_ROLE_EQUIP),
    {ok, _, [NewItem]} = role_bag:move(?BAG_ID_MAIN, ?BAG_ID_EQUIP, [{CellID, 1}], RoleSt),
    Equips2 = maps:put(Slot, NewItem#p_item.uid, Equips),
    role_data:set(RoleEquip#role_equip{equips = Equips2}),
    Item = get_item(NewItem),
    ?ucast(#m_equip_list_toc{equips = [item_util:p_item(Item)]}).

%熔炼升级
smelt_up(Smelt, Exp)->
	NextSmelt = Smelt + 1,
	case cfg_equip_smelt:find(NextSmelt) of
		#cfg_equip_smelt{exp=NeedExp} ->
			case Exp >= NeedExp of
				true  ->
					notify_smelt(NextSmelt),
					smelt_up(NextSmelt, Exp-NeedExp);
				false ->
					{Smelt, Exp}
			end;
		_->
			{Smelt, Exp}
	end.

%熔炼公告
notify_smelt(Smelt)->
	case Smelt > 0 andalso Smelt rem 50 of
		0 ->
            #role_info{id=RoleID, name=Name} = role_data:get(?DB_ROLE_INFO),
			?notify(?MSG_EQUIP_SMELT_NOTICE, [
                {role, RoleID, Name},
				{color, Smelt, ?COLOR_RED}
            ]);
		_ ->
			igonre
	end.
