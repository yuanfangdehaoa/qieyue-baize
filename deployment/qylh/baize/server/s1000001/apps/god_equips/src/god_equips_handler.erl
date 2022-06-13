%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(god_equips_handler).

-include("game.hrl").
-include("proto.hrl").
-include("msgno.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("table.hrl").
-include("god_equips.hrl").
-include("role.hrl").
-include("item.hrl").
-include("bag.hrl").
-include("enum.hrl").
-include("morph.hrl").

%% API
-export([handle/3]).
-export([get_attr/1]).
-export([hook_login/1]).
-export([notify/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_login(_RoleSt)->
	role_event:listen(?EVENT_DUNGE, ?MODULE, notify),
	role_event:listen(?EVENT_MORPH_STAR, ?MODULE, notify).

notify(Event, Args, RoleSt)->
	case Event of
		?EVENT_MORPH_STAR ->
			case Args of
				{?TRAIN_GOD, _, Star} ->
					case Star >= 9 of
						true ->
							Slots = get_slots(),
							?ucast(#m_god_equip_toc{slots=Slots});
						false ->
							ignore
					end;
				_ ->
					ignore
			end;
		?EVENT_DUNGE ->
			case Args of
				{?SCENE_STYPE_DUNGE_GOD, _, _, _}->
					Slots = get_slots(),
					?ucast(#m_god_equip_toc{slots=Slots});
				_ ->
					ignore
			end;
		_ ->
			ignore
	end.

%获取装备列表
handle(?GOD_EQUIP, _Tos, RoleSt)->
	#role_god_equips{equips=Equips} = role_data:get(?DB_ROLE_GOD_EQUIPS),
	Items = maps:fold(fun
			(_, CellId, Lists) ->
				{ok, Item} = role_bag:get_item(CellId),
				[item_util:p_item(Item) | Lists]
		end, [], Equips),
	Slots = get_slots(),
	{ok, #m_god_equip_toc{equips=Items, slots=Slots}, RoleSt};

%穿戴装备
handle(?GOD_EQUIP_PUTON, Tos, RoleSt)->
	#m_god_equip_puton_tos{uid=UId} = Tos,
	{ok, Item} = role_bag:get_item(UId),
	#p_item{id=ItemID} = Item,
	#cfg_god_equip{slot=Slot} = cfg_god_equip:find(ItemID),
	check_slot_open(Slot),
	RoleGodEquips = #role_god_equips{equips=Equips} = role_data:get(?DB_ROLE_GOD_EQUIPS),
	OldUId = maps:get(Slot, Equips, 0),
	{ok, _, [NewItem]} = role_bag:move(?BAG_ID_GOD, ?BAG_ID_GOD_EQUIP, [{UId,1}], RoleSt),
	%原部位有装备
	NewItem4 = case OldUId > 0 of
		true ->
			{ok, OldItem} = role_bag:get_item(OldUId),
			#p_item{extra=Level} = OldItem,
			role_bag:move(?BAG_ID_GOD_EQUIP, ?BAG_ID_GOD, [{OldUId, 1}], RoleSt),
			OldItem2 = OldItem#p_item{extra=0},
			#p_item{equip=OldEquip} = OldItem2,
			OldPower = calc_power(OldItem2),
			OldEquip2 = OldEquip#p_equip{power=OldPower},
			OldItem3 = OldItem2#p_item{equip=OldEquip2},
			role_bag:set_item(OldItem3),
			NewItem2 = NewItem#p_item{extra=Level},
			#p_item{equip=Equip} = NewItem2,
			Power = calc_power(NewItem2),
			Equip2 = Equip#p_equip{power=Power},
			NewItem3 = NewItem2#p_item{equip=Equip2},
			role_bag:set_item(NewItem3),
			NewItem3;
		false->
			NewItem
	end,
	Equips2 = maps:put(Slot, NewItem4#p_item.uid, Equips),
	role_data:set(RoleGodEquips#role_god_equips{equips=Equips2}),
	role_attr:recalc(god_equips_handler, RoleSt),
	?ucast(#m_god_equip_toc{equips=[item_util:p_item(NewItem4)]}),
	{ok, #m_god_equip_puton_toc{slot=Slot}, RoleSt};

%装备强化
handle(?GOD_EQUIP_UPLEVEL, Tos, RoleSt)->
	#m_god_equip_uplevel_tos{slot=Slot} = Tos,
	#role_god_equips{equips=Equips} = role_data:get(?DB_ROLE_GOD_EQUIPS),
	UId = maps:get(Slot, Equips, 0),
	?_check(UId > 0, ?ERR_BABY_NO_EQUIP_PUTON),
	{ok, Item} = role_bag:get_item(UId),
	#p_item{extra=OldLevel} = Item,
    #cfg_god_equip_level{cost=Cost} = cfg_god_equip_level:find(Slot, OldLevel),
    ?_check(length(Cost) > 0, ?ERR_BABY_EQUIP_MAX_LEVEL),
    role_bag:cost(Cost, ?LOG_GOD_EQUIP_UPLEVEL, RoleSt),
    Item2 = Item#p_item{extra=OldLevel+1},
    #p_item{equip=Equip} = Item2,
    Power = calc_power(Item2),
    Equip2 = Equip#p_equip{power=Power},
    Item3 = Item2#p_item{equip=Equip2},
    role_bag:set_item(Item3),
    role_attr:recalc(god_equips_handler, RoleSt),
    ?ucast(#m_god_equip_toc{equips=[item_util:p_item(Item3)]}),
	{ok, #m_god_equip_uplevel_toc{slot=Slot}, RoleSt};


%装备分解
handle(?GOD_EQUIP_DECOMPOSE, Tos, RoleSt)->
	#m_god_equip_decompose_tos{uid=UIds} = Tos,
	{Costs, Gains} = lists:foldl(fun 
			(UId, {Acc1, Acc2}) -> 
				{ok, Item} = role_bag:get_item(UId),
				#p_item{id=ItemID} = Item,
				 #cfg_god_equip{gain=Gain} = cfg_god_equip:find(ItemID),
				 {[{cellid, UId}|Acc1], lists:merge(Gain, Acc2)}
		end, {[], []}, UIds),
	role_bag:deal(Costs, Gains, ?LOG_GOD_EQUIP_DECOMPOSE, RoleSt),
	{ok, #m_god_equip_decompose_toc{}, RoleSt}.

%计算属性
 get_attr(_)->
 	#role_god_equips{equips=Equips} = role_data:get(?DB_ROLE_GOD_EQUIPS),
 	maps:fold(fun 
 			(_K, UId, Acc) -> 
 				{ok, Item} = role_bag:get_item(UId),
 				#p_item{id=ItemID, extra=Level, equip=Equip} = Item,
 				#p_equip{base=Base} = Equip,
                #cfg_god_equip{slot=Slot} = cfg_god_equip:find(ItemID),
                #cfg_god_equip_level{attr=Attr} = cfg_god_equip_level:find(Slot, Level),
                mod_attr:sum([Acc, Base, mod_attr:to_map(Attr)])
 		end, #{}, Equips).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
calc_power(Item)->
	#p_item{id=ItemID, extra=Level, equip=Equip} = Item,
	#cfg_god_equip{slot=Slot} = cfg_god_equip:find(ItemID),
	#cfg_god_equip_level{attr=Attr} = cfg_god_equip_level:find(Slot, Level),
	StrongAttr = mod_attr:to_map(Attr),
	#p_equip{base=BaseAttr} = Equip, 
	mod_attr:power(mod_attr:sum([BaseAttr, StrongAttr])).

%检查部位开放
check_slot_open(Slot)->
	?_check(get_slot_state(Slot) == 0, ?ERR_MAGICCARD_GATE_NOT_OPEN).

get_slot_state(Slot)->
	#cfg_god_equip_open{open=Open} = cfg_god_equip_open:find(Slot),
	case Open of
		{dunge, Wave} ->
			#dunge_god{max_wave=MaxWave} = role_data:get(?DB_DUNGE_GOD),
			case MaxWave >= Wave of
				true  -> 0;
				false -> 1
			end;
		{own, Color, Count} ->
			Actives = morph_handler:get_actives(?TRAIN_GOD),
			Count2 = lists:foldl(fun 
					(MorphID, Acc) -> 
						#cfg_morph{color=Color2} = cfg_god_morph:find(MorphID),
						case Color2 >= Color of
							true  -> Acc + 1;
							false -> Acc
						end
				end, 0, Actives),
			case Count2 >= Count of
				true  -> 0;
				false -> 1
			end;
		_ ->
			0
	end.

%获取部位状态
get_slots()->
	Slots = cfg_god_equip_open:slots(),
	lists:foldl(fun 
			(Slot, Acc)  -> 
				maps:put(Slot, get_slot_state(Slot), Acc)
		end, #{}, Slots).

