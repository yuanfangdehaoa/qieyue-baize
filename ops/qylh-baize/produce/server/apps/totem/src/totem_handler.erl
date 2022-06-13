%% @author rong
%% @doc
-module(totem_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("totem.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("equip.hrl").
-include("item.hrl").
-include("enum.hrl").
-include("bag.hrl").
-include("msgno.hrl").
-include("skill.hrl").
%%-compile([nowarn_export_all]).

-export([handle/3, get_attr/1, combine/3]).

handle(?TOTEM_LIST, _Tos, RoleSt) ->
    #role_totem{totems=Totems, summon_max=SummonMax} = role_data:get(?DB_ROLE_TOTEM),
    ?ucast(#m_totem_list_toc{max_summon=SummonMax, list=to_list(maps:values(Totems))});

handle(?TOTEM_ADDSUMMON, _Tos, RoleSt) ->
%%    #role_st{role=RoleID, name=RoleName} = RoleSt,
    #role_totem{summon_max=SummonMax} = RoleTotem = role_data:get(?DB_ROLE_TOTEM),
    Conf = cfg_totems_summon:find(SummonMax+1),
    ?_check(Conf =/= ?nil, ?ERR_TOTEMS_ADDSUMMON_MAX),
    #cfg_totem_summon{restrict = Restrict, cost = Cost} = Conf,
    #role_info{level = Level} = role_data:get(?DB_ROLE_INFO),
    case Restrict of
        [{level, NeedLv}] when NeedLv > Level ->
            throw({error, ?ERR_TOTEMS_ADDSUMMON_LEVEL, []});
        _ ->
            ok
    end,
    Fun = fun() ->
        role_data:set(RoleTotem#role_totem{summon_max=SummonMax+1}),
        ?ucast(#m_totem_addsummon_toc{max_summon=SummonMax+1})
%%        ?notify(?MSG_TOTEMS_ADD_SUMMON, [{role, RoleID, RoleName}, SummonMax+1])
    end,
    role_bag:cost(Cost, ?LOG_TOTEM_ADDSUMMON, Fun, RoleSt);

handle(?TOTEM_EQUIP_LOAD, Tos, RoleSt) ->
    #m_totem_equip_load_tos{id=TotemID, uid=CellID} = Tos,
    Item = check_exist(CellID),
    check_equip_color(TotemID, Item),
    #role_totem{totems=Totems} = RoleTotem = role_data:get(?DB_ROLE_TOTEM),
    #r_totem{equips=Equips} = Totem = find_totem(TotemID, Totems),
    #cfg_totem_equip{slot=Slot} = cfg_totems_equip:find(Item#p_item.id),
    case maps:find(Slot, Equips) of
        {ok, OldEquipUID} ->
            role_bag:move(?BAG_ID_TOTEM_EQUIP, ?BAG_ID_TOTEM, [{OldEquipUID, 1}], RoleSt);
        _ ->
            ignore
    end,
    {ok, _, [Item2]} = role_bag:move(?BAG_ID_TOTEM, ?BAG_ID_TOTEM_EQUIP, [{CellID,1}], RoleSt),
    Totem2 = Totem#r_totem{equips = maps:put(Slot, Item2#p_item.uid, Equips)},
    RoleTotem2 = RoleTotem#role_totem{totems=maps:put(TotemID, Totem2, Totems)},
    role_data:set(RoleTotem2),
    role_event:event(?EVENT_TOTEMS_LOAD, TotemID),
    ?_if(Totem#r_totem.summon, calc_attr(RoleSt)),
    ?ucast(#m_totem_equip_load_toc{id=TotemID, equip=item_util:p_item(Item2)});

handle(?TOTEM_EQUIP_UNLOAD, #m_totem_equip_unload_tos{slot=0}=Tos, RoleSt) ->
    #m_totem_equip_unload_tos{id=TotemID} = Tos,
    #role_totem{totems=Totems} = RoleTotem = role_data:get(?DB_ROLE_TOTEM),
    Totem  = find_totem(TotemID, Totems),
    Unload = [{CellID,1} || CellID <- maps:values(Totem#r_totem.equips)],
    role_bag:move(?BAG_ID_TOTEM_EQUIP, ?BAG_ID_TOTEM, Unload, RoleSt),
    RoleTotem2 = RoleTotem#role_totem{totems=maps:remove(TotemID, Totems)},
    role_data:set(RoleTotem2),
    #cfg_totem{skill=Skills} = cfg_totems:find(TotemID),
    ?_if(Totem#r_totem.summon, role_skill:remove(maps:keys(maps:from_list(Skills)), RoleSt)),
    ?_if(Totem#r_totem.summon, calc_attr(RoleSt)),
    ?ucast(#m_totem_equip_unload_toc{id=TotemID, slot=0});

handle(?TOTEM_EQUIP_UNLOAD, Tos, RoleSt) ->
    #m_totem_equip_unload_tos{id=TotemID, slot=Slot} = Tos,
    #role_totem{totems=Totems} = RoleTotem = role_data:get(?DB_ROLE_TOTEM),
    Totem = find_totem(TotemID, Totems),
    Equips = Totem#r_totem.equips,
    {ok, EquipCellID} = maps:find(Slot, Equips),
    ?_check(EquipCellID =/= error, ?ERR_GAME_BAD_ARGS),
    role_bag:move(?BAG_ID_TOTEM_EQUIP, ?BAG_ID_TOTEM, [{EquipCellID, 1}], RoleSt),
    Totem2 = Totem#r_totem{equips = maps:remove(Slot, Equips), summon=false},
    RoleTotem2 = RoleTotem#role_totem{totems=maps:put(TotemID, Totem2, Totems)},
    role_data:set(RoleTotem2),
    #cfg_totem{skill=Skills} = cfg_totems:find(TotemID),
    ?_if(Totem#r_totem.summon, role_skill:remove(maps:keys(maps:from_list(Skills)), RoleSt)),
    ?_if(Totem#r_totem.summon, calc_attr(RoleSt)),
    ?ucast(#m_totem_equip_unload_toc{id=TotemID, slot=Slot});

handle(?TOTEM_SUMMON, Tos, RoleSt) ->
    #role_st{role=RoleID, name=RoleName} = RoleSt,
    #m_totem_summon_tos{id=TotemID} = Tos,
    #role_totem{totems=Totems, summon_max=MaxSummon}
        = RoleTotem = role_data:get(?DB_ROLE_TOTEM),
    ?_check(summon_num(Totems) < MaxSummon, ?ERR_TOTEMS_MAX_SUMMON),
    Totem = find_totem(TotemID, Totems),
    ?_check(not Totem#r_totem.summon, ?ERR_TOTEMS_ALREADY_SUMMON),
    #cfg_totem{name=TotemName, skill=Skills, slot=SlotRestrict, color=Color} = cfg_totems:find(TotemID),
    ?_check(length(SlotRestrict)==maps:size(Totem#r_totem.equips), ?ERR_TOTEMS_SUMMON_NOT_FULL_EQUIP),
    RoleTotem2 = RoleTotem#role_totem{
        totems=maps:put(TotemID, Totem#r_totem{summon=true}, Totems)},
    role_data:set(RoleTotem2),
    role_skill:active(maps:keys(maps:from_list(Skills)), RoleSt),
    calc_attr(RoleSt),
    role_event:event(?EVENT_TOTEMS_SUMMON, TotemID),
    ?ucast(#m_totem_summon_toc{id=TotemID}),
    role_count:get_totem_summon_bc(TotemID) == 0 andalso ?notify(?MSG_TOTEMS_SUMMON, [{role, RoleID, RoleName}, ut_color:format(TotemName, Color)]),
    role_count:add_totem_summon_bc(TotemID);

handle(?TOTEM_UNSUMMON, Tos, RoleSt) ->
    #m_totem_unsummon_tos{id=TotemID} = Tos,
    #role_totem{totems=Totems} = RoleTotem = role_data:get(?DB_ROLE_TOTEM),
    Totem = find_totem(TotemID, Totems),
    ?_check(Totem#r_totem.summon, ?ERR_TOTEMS_NOT_SUMMON),
    #cfg_totem{skill=Skills} = cfg_totems:find(TotemID),
    RoleTotem2 = RoleTotem#role_totem{
        totems=maps:put(TotemID, Totem#r_totem{summon=false}, Totems)},
    role_data:set(RoleTotem2),
    role_skill:remove(maps:keys(maps:from_list(Skills)), RoleSt),
    calc_attr(RoleSt),
    ?ucast(#m_totem_unsummon_toc{id=TotemID});

handle(?TOTEM_EQUIP_REINFORCE, Tos, RoleSt) ->
    #role_st{role=RoleID, name=RoleName} = RoleSt,
    #m_totem_equip_reinforce_tos{id=TotemID, uid=EquipUID,
        cellids=CellIDs, use_gold=UseGold} = Tos,
    #role_totem{totems=Totems} = role_data:get(?DB_ROLE_TOTEM),
    Totem = find_totem(TotemID, Totems),
    ?_check(Totem#r_totem.summon, ?ERR_TOTEMS_EQUIP_NEED_SUMMON),
    {ok, {Slot, EquipUID}} = find_equip(EquipUID, Totem),
    {ok, #p_item{equip=Equip} = EquipItem} = role_bag:get_item(EquipUID),
    ?_check(cfg_totems_reinforce:find(Slot, Equip#p_equip.stren_lv+1) =/= ?nil,
        ?ERR_TOTEMS_EQUIP_MAX_LEVEL),
    {Cost, EquipItem2} = reinforce(Slot, EquipItem, CellIDs, UseGold),
    role_bag:cost(Cost, ?LOG_TOTEM_EQUIP_REINFORCE, RoleSt),
    role_bag:set_item(EquipItem2),
    calc_attr(RoleSt),
    ?ucast(#m_totem_equip_reinforce_toc{
        id    = TotemID,
        equip = item_util:p_item(EquipItem2)
    }),
    NewStrenLv = EquipItem2#p_item.equip#p_equip.stren_lv,
    judge_reinforce_notify(Equip#p_equip.stren_lv, NewStrenLv) andalso begin
        ItemMaps = maps:put(EquipItem2#p_item.id, 0, #{}),
        ?notify(?MSG_TOTEMS_EQUIP_REINFORCE, [{role, RoleID, RoleName}, {item, ItemMaps}, NewStrenLv div 10 * 10])
    end.

get_attr(_AttrType) ->
    #role_totem{totems=Totems} = role_data:get(?DB_ROLE_TOTEM),
    TotemAll = lists:foldl(fun(Totem, Acc) ->
        #r_totem{id=TotemID, summon=Summon} = Totem,
        case Summon of
            true ->
                #cfg_totem{skill=Skills} = cfg_totems:find(TotemID),
                mod_attr:add(calc_skill_attr(?SKILL_GROUP_TOTEM_ALL, Skills), Acc);
            _ ->
                Acc
        end
    end, #{}, maps:values(Totems)),

    Attr = lists:foldl(fun(Totem, Acc) ->
        #r_totem{id=TotemID, summon=Summon, equips=Equips} = Totem,

        case Summon of
            true ->
                #cfg_totem{attr=TotemAttr, skill=Skills} = cfg_totems:find(TotemID),
                TotemSelf = calc_skill_attr(?SKILL_GROUP_TOTEM_SELF, Skills),
                EquipAttr = calc_equip_attr(Equips),
                ReinforceAttr = calc_reinforce_attr(Equips),
                Sum = mod_attr:sum([TotemAttr, EquipAttr, TotemAll, TotemSelf]),
                mod_attr:sum([Acc, mod_attr:calc_part_pro(Sum), ReinforceAttr]);
            _ ->
                Acc
        end
    end, #{}, maps:values(Totems)),

    _Power = mod_attr:power(Attr),
%%    role_event:event(?EVENT_TOTEMS_POWER, Power),
    Attr.

% 合成，转化
combine(ItemID, Cost, Bind) ->
    Exp = calc_combine_exp(Cost),
    #cfg_totem_equip{slot=Slot} = cfg_totems_equip:find(ItemID),
    Item = item_util:new_item(ItemID, 1, #{}),
    {_, #p_item{equip=Equip}} = upgrade_equip(Slot, Item, Exp),
    [item_util:new_item(ItemID, 1, #{
        stren_lv    => Equip#p_equip.stren_lv,
        stren_phase => Equip#p_equip.stren_phase,
        base        => maps:to_list(Equip#p_equip.base),
        bind        => Bind
    })].

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

to_list(Totems) when is_list(Totems) ->
    [begin
        Equips = lists:map(fun(EquipUID) ->
            {ok, EquipItem} = role_bag:get_item(EquipUID),
            item_util:p_item(EquipItem)
        end, maps:values(B#r_totem.equips)),
        #p_totem{
            id     = B#r_totem.id,
            equips = Equips,
            summon = B#r_totem.summon
        }
    end||B <- Totems].

find_totem(TotemID, Totems) ->
    case maps:get(TotemID, Totems, undefined) of
        undefined ->
            #r_totem{id = TotemID};
        Totem ->
            Totem
    end.

check_exist(CellID) ->
    case role_bag:get_item(CellID) of
        {ok, TmpItem}->TmpItem;
        Error -> throw(Error)
    end.

check_equip_color(TotemID, Item) ->
    #cfg_totem{slot=SlotRestrict} = cfg_totems:find(TotemID),
    #cfg_item{color=Color} = cfg_item:find(Item#p_item.id),
    #cfg_totem_equip{slot=Slot} = cfg_totems_equip:find(Item#p_item.id),
    case lists:keyfind(Slot, 1, SlotRestrict) of
        {Slot, NeedColor} when Color >= NeedColor ->
            ok;
        _ ->
            throw({error, ?ERR_TOTEMS_EQUIP_COLOR, []})
    end.

summon_num(Totems) when is_map(Totems) ->
    maps:fold(fun(_, #r_totem{summon=Summon}, Acc) ->
        if
            Summon ->
                Acc+1;
            true ->
                Acc
        end
    end, 0, Totems).

find_equip(EquipUID, Totem) ->
    find_equip_1(EquipUID, maps:to_list(Totem#r_totem.equips)).

find_equip_1(_, []) ->
    throw({error, ?ERR_ITEM_NOT_EXIST, []});
find_equip_1(EquipUID, [{_, EquipUID}=Found|_]) ->
    {ok, Found};
find_equip_1(EquipUID, [_|T]) ->
    find_equip_1(EquipUID, T).

% 强化
reinforce(Slot, EquipItem, [CellID|T], UseGold) ->
    reinforce(Slot, EquipItem, [CellID|T], UseGold, []).

reinforce(_Slot, EquipItem, [], _UseGold, Cost) ->
    {Cost, EquipItem};
reinforce(Slot, EquipItem, [CellID|T], UseGold, Cost) ->
    Material = check_exist(CellID),
    AddExp = calc_exp(Material),
    CanUseGold = calc_use_gold(Material, UseGold),
    if
        CanUseGold ->
            AddExp2 = AddExp * 5,
            C = cfg_totems_reinforce_mul:find(AddExp2) ++ [{cellid, CellID} | Cost];
        true ->
            AddExp2 = AddExp,
            C = [{cellid, CellID} | Cost]
    end,
    {Result, EquipItem2} = upgrade_equip(Slot, EquipItem, AddExp2),
    case Result of
        max_lv ->
            {C, EquipItem2};
        _ ->
            reinforce(Slot, EquipItem2, T, UseGold, C)
    end.

calc_use_gold(Item, UseGold) ->
    #p_item{equip = Equip} = Item,
    UseGold andalso
        (Equip == ?nil orelse
            (Equip#p_equip.stren_lv == 0 andalso Equip#p_equip.stren_phase == 0)).

calc_exp(Material) ->
    #cfg_totem_equip{slot=MSlot, exp=MExp} = cfg_totems_equip:find(Material#p_item.id),
    if
        Material#p_item.equip == ?nil ->
            MExp;
        true ->
            #p_item{equip=#p_equip{stren_lv=MStrLv, stren_phase=MCurExp}} = Material,
            case cfg_totems_reinforce:find(MSlot, MStrLv) of
                #cfg_totem_reinforce{total=MTotal} ->
                    MExp + MCurExp + MTotal;
                _ ->
                    MExp + MCurExp
            end
    end.

upgrade_equip(Slot, EquipItem, AddExp) ->
    #p_item{equip=Equip} = EquipItem,
    #p_equip{stren_lv=StrLv, stren_phase=CurExp} = Equip,
    #cfg_totem_reinforce{exp=NeedExp} = cfg_totems_reinforce:find(Slot, StrLv),
    CurExp2 = CurExp+AddExp,
    if
        CurExp2 >= NeedExp ->
            case cfg_totems_reinforce:find(Slot, StrLv+1) of
                undefined ->
                    Equip2 = Equip#p_equip{stren_lv=StrLv, stren_phase=0},
                    {max_lv, update_equip(EquipItem, Equip2)};
                #cfg_totem_reinforce{base=_Base} ->
                    Equip2 = Equip#p_equip{stren_lv=StrLv+1,
                        stren_phase=CurExp2-NeedExp},
                    upgrade_equip(Slot, update_equip(EquipItem, Equip2), 0)
            end;
        true ->
            Equip2 = Equip#p_equip{stren_phase=CurExp2},
            {continue, EquipItem#p_item{equip=Equip2}}
    end.

calc_attr(RoleSt) ->
    role_attr:recalc(?MODULE, RoleSt).

% 需要同步extra字段
update_equip(Item, Equip) ->
    Item#p_item{extra=Equip#p_equip.stren_lv, equip=Equip}.

calc_combine_exp(Cost) ->
    lists:foldl(fun({cellid, UID, _}, Acc) ->
        {ok, Item} = role_bag:get_item(UID),
        Add = case cfg_totems_equip:find(Item#p_item.id) of
            #cfg_totem_equip{slot=Slot, exp=BaseExp} ->
                #p_item{equip=#p_equip{stren_lv=StrLv, stren_phase=CurExp}} = Item,
                case cfg_totems_reinforce:find(Slot, StrLv) of
                    #cfg_totem_reinforce{total=Total} ->
                        CurExp + Total + BaseExp;
                    _ ->
                        CurExp + BaseExp
                end;
            _ ->
                0
        end,
        Acc + Add
    end, 0, Cost).

judge_reinforce_notify(OldLv, NewLv) ->
    LvList = lists:seq(10, 100, 10),
    PassNum = fun(List) ->
        lists:foldl(fun(N, Acc) ->
            if
                N >= 0 -> Acc+1;
                true -> Acc
            end
        end, 0, List)
    end,
    PassList = fun(N) ->
        [N-P || P <- LvList]
    end,
    PassNum(PassList(NewLv)) > PassNum(PassList(OldLv)).

calc_equip_attr(Equips) ->
    lists:foldl(fun(EquipUID, AccE) ->
        {ok, #p_item{equip=Equip}} = role_bag:get_item(EquipUID),
        mod_attr:sum([
            AccE,
            Equip#p_equip.base,
            Equip#p_equip.rare1,
            Equip#p_equip.rare2,
            Equip#p_equip.rare3
        ])
    end, #{}, maps:values(Equips)).

calc_reinforce_attr(Equips) ->
    lists:foldl(fun(EquipUID, AccE) ->
        {ok, #p_item{id=EquipID, equip=Equip}} = role_bag:get_item(EquipUID),
        #cfg_totem_equip{slot=Slot} = cfg_totems_equip:find(EquipID),
        #cfg_totem_reinforce{base=Base} = cfg_totems_reinforce:find(Slot, Equip#p_equip.stren_lv),
        mod_attr:add(AccE, Base)
    end, #{}, maps:values(Equips)).

calc_skill_attr(Group, Skills) ->
    lists:foldl(fun({SkillID, Level}, Acc1) ->
        case cfg_skill:find(SkillID) of
            #cfg_skill{group=Group} ->
                #cfg_skill_level{attrs=Attr} = cfg_skill_level:find(SkillID, Level),
                mod_attr:add(Attr, Acc1);
            _ ->
                Acc1
        end
    end, #{}, Skills).
