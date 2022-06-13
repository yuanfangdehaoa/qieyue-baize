%% @author rong
%% @doc
-module(beast_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("beast.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("equip.hrl").
-include("item.hrl").
-include("enum.hrl").
-include("bag.hrl").
-include("msgno.hrl").
-include("skill.hrl").

-export([handle/3, get_attr/1, combine/3]).

handle(?BEAST_LIST, _Tos, RoleSt) ->
    #role_beast{beasts=Beasts, summon_max=SummonMax} = role_data:get(?DB_ROLE_BEAST),
    ?ucast(#m_beast_list_toc{max_summon=SummonMax, list=to_list(maps:values(Beasts))});

handle(?BEAST_ADDSUMMON, _Tos, RoleSt) ->
    #role_st{role=RoleID, name=RoleName} = RoleSt,
    #role_beast{summon_max=SummonMax} = RoleBeast = role_data:get(?DB_ROLE_BEAST),
    Conf = cfg_beast_summon:find(SummonMax+1),
    ?_check(Conf =/= ?nil, ?ERR_BEAST_ADDSUMMON_MAX),
    #cfg_beast_summon{restrict = Restrict, cost = Cost} = Conf,
    #role_info{level = Level} = role_data:get(?DB_ROLE_INFO),
    case Restrict of
        [{level, NeedLv}] when NeedLv > Level ->
            throw({error, ?ERR_BEAST_ADDSUMMON_LEVEL, []});
        _ ->
            ok
    end,
    Fun = fun() ->
        role_data:set(RoleBeast#role_beast{summon_max=SummonMax+1}),
        ?ucast(#m_beast_addsummon_toc{max_summon=SummonMax+1}),
        ?notify(?MSG_BEAST_ADD_SUMMON, [{role, RoleID, RoleName}, SummonMax+1])
    end,
    role_bag:cost(Cost, ?LOG_BEAST_ADDSUMMON, Fun, RoleSt);

handle(?BEAST_EQUIP_LOAD, Tos, RoleSt) ->
    #m_beast_equip_load_tos{id=BeastID, uid=CellID} = Tos,
    Item = check_exist(CellID),
    check_equip_color(BeastID, Item),
    #role_beast{beasts=Beasts} = RoleBeast = role_data:get(?DB_ROLE_BEAST),
    #r_beast{equips=Equips} = Beast = find_beast(BeastID, Beasts),
    #cfg_beast_equip{slot=Slot} = cfg_beast_equip:find(Item#p_item.id),
    case maps:find(Slot, Equips) of
        {ok, OldEquipUID} ->
            role_bag:move(?BAG_ID_BEAST_EQUIP, ?BAG_ID_BEAST, [{OldEquipUID, 1}], RoleSt);
        _ ->
            ignore
    end,
    {ok, _, [Item2]} = role_bag:move(?BAG_ID_BEAST, ?BAG_ID_BEAST_EQUIP, [{CellID,1}], RoleSt),
    Beast2 = Beast#r_beast{equips = maps:put(Slot, Item2#p_item.uid, Equips)},
    RoleBeast2 = RoleBeast#role_beast{beasts=maps:put(BeastID, Beast2, Beasts)},
    role_data:set(RoleBeast2),
    role_event:event(?EVENT_BEAST_LOAD, BeastID),
    ?_if(Beast#r_beast.summon, calc_attr(RoleSt)),
    ?ucast(#m_beast_equip_load_toc{id=BeastID, equip=item_util:p_item(Item2)});

handle(?BEAST_EQUIP_UNLOAD, #m_beast_equip_unload_tos{slot=0}=Tos, RoleSt) ->
    #m_beast_equip_unload_tos{id=BeastID} = Tos,
    #role_beast{beasts=Beasts} = RoleBeast = role_data:get(?DB_ROLE_BEAST),
    Beast  = find_beast(BeastID, Beasts),
    Unload = [{CellID,1} || CellID <- maps:values(Beast#r_beast.equips)],
    role_bag:move(?BAG_ID_BEAST_EQUIP, ?BAG_ID_BEAST, Unload, RoleSt),
    RoleBeast2 = RoleBeast#role_beast{beasts=maps:remove(BeastID, Beasts)},
    role_data:set(RoleBeast2),
    #cfg_beast{skill=Skills} = cfg_beast:find(BeastID),
    ?_if(Beast#r_beast.summon, role_skill:remove(maps:keys(maps:from_list(Skills)), RoleSt)),
    ?_if(Beast#r_beast.summon, calc_attr(RoleSt)),
    ?ucast(#m_beast_equip_unload_toc{id=BeastID, slot=0});

handle(?BEAST_EQUIP_UNLOAD, Tos, RoleSt) ->
    #m_beast_equip_unload_tos{id=BeastID, slot=Slot} = Tos,
    #role_beast{beasts=Beasts} = RoleBeast = role_data:get(?DB_ROLE_BEAST),
    Beast = find_beast(BeastID, Beasts),
    Equips = Beast#r_beast.equips,
    {ok, EquipCellID} = maps:find(Slot, Equips),
    ?_check(EquipCellID =/= error, ?ERR_GAME_BAD_ARGS),
    role_bag:move(?BAG_ID_BEAST_EQUIP, ?BAG_ID_BEAST, [{EquipCellID, 1}], RoleSt),
    Beast2 = Beast#r_beast{equips = maps:remove(Slot, Equips), summon=false},
    RoleBeast2 = RoleBeast#role_beast{beasts=maps:put(BeastID, Beast2, Beasts)},
    role_data:set(RoleBeast2),
    #cfg_beast{skill=Skills} = cfg_beast:find(BeastID),
    ?_if(Beast#r_beast.summon, role_skill:remove(maps:keys(maps:from_list(Skills)), RoleSt)),
    ?_if(Beast#r_beast.summon, calc_attr(RoleSt)),
    ?ucast(#m_beast_equip_unload_toc{id=BeastID, slot=Slot});

handle(?BEAST_SUMMON, Tos, RoleSt) ->
    #role_st{role=RoleID, name=RoleName} = RoleSt,
    #m_beast_summon_tos{id=BeastID} = Tos,
    #role_beast{beasts=Beasts, summon_max=MaxSummon}
        = RoleBeast = role_data:get(?DB_ROLE_BEAST),
    ?_check(summon_num(Beasts) < MaxSummon, ?ERR_BEAST_MAX_SUMMON),
    Beast = find_beast(BeastID, Beasts),
    ?_check(not Beast#r_beast.summon, ?ERR_BEAST_ALREADY_SUMMON),
    #cfg_beast{name=BeastName, skill=Skills, slot=SlotRestrict, color=Color} = cfg_beast:find(BeastID),
    ?_check(length(SlotRestrict)==maps:size(Beast#r_beast.equips), ?ERR_BEAST_SUMMON_NOT_FULL_EQUIP),
    RoleBeast2 = RoleBeast#role_beast{
        beasts=maps:put(BeastID, Beast#r_beast{summon=true}, Beasts)},
    role_data:set(RoleBeast2),
    role_skill:active(maps:keys(maps:from_list(Skills)), RoleSt),
    calc_attr(RoleSt),
    role_event:event(?EVENT_BEAST_SUMMON, BeastID),
    ?ucast(#m_beast_summon_toc{id=BeastID}),
    role_count:get_beast_summon_bc(BeastID) == 0 andalso
        ?notify(?MSG_BEAST_SUMMON, [{role, RoleID, RoleName},
            ut_color:format(BeastName, Color)]),
    role_count:add_beast_summon_bc(BeastID);

handle(?BEAST_UNSUMMON, Tos, RoleSt) ->
    #m_beast_unsummon_tos{id=BeastID} = Tos,
    #role_beast{beasts=Beasts} = RoleBeast = role_data:get(?DB_ROLE_BEAST),
    Beast = find_beast(BeastID, Beasts),
    ?_check(Beast#r_beast.summon, ?ERR_BEAST_NOT_SUMMON),
    #cfg_beast{skill=Skills} = cfg_beast:find(BeastID),
    RoleBeast2 = RoleBeast#role_beast{
        beasts=maps:put(BeastID, Beast#r_beast{summon=false}, Beasts)},
    role_data:set(RoleBeast2),
    role_skill:remove(maps:keys(maps:from_list(Skills)), RoleSt),
    calc_attr(RoleSt),
    ?ucast(#m_beast_unsummon_toc{id=BeastID});

handle(?BEAST_EQUIP_REINFORCE, Tos, RoleSt) ->
    #role_st{role=RoleID, name=RoleName} = RoleSt,
    #m_beast_equip_reinforce_tos{id=BeastID, uid=EquipUID,
        cellids=CellIDs, use_gold=UseGold} = Tos,
    #role_beast{beasts=Beasts} = role_data:get(?DB_ROLE_BEAST),
    Beast = find_beast(BeastID, Beasts),
    ?_check(Beast#r_beast.summon, ?ERR_BEAST_EQUIP_NEED_SUMMON),
    {ok, {Slot, EquipUID}} = find_equip(EquipUID, Beast),
    {ok, #p_item{equip=Equip} = EquipItem} = role_bag:get_item(EquipUID),
    ?_check(cfg_beast_reinforce:find(Slot, Equip#p_equip.stren_lv+1) =/= ?nil,
        ?ERR_BEAST_EQUIP_MAX_LEVEL),
    {Cost, EquipItem2} = reinforce(Slot, EquipItem, CellIDs, UseGold),
    role_bag:cost(Cost, ?LOG_BEAST_EQUIP_REINFORCE, RoleSt),
    role_bag:set_item(EquipItem2),
    calc_attr(RoleSt),
    ?ucast(#m_beast_equip_reinforce_toc{
        id    = BeastID,
        equip = item_util:p_item(EquipItem2)
    }),
    NewStrenLv = EquipItem2#p_item.equip#p_equip.stren_lv,
    judge_reinforce_notify(Equip#p_equip.stren_lv, NewStrenLv) andalso begin
        ItemMaps = maps:put(EquipItem2#p_item.id, 0, #{}),
        ?notify(?MSG_BEAST_EQUIP_REINFORCE, [{role, RoleID, RoleName},
            {item, ItemMaps}, NewStrenLv div 10 * 10])
    end.

get_attr(_AttrType) ->
    #role_beast{beasts=Beasts} = role_data:get(?DB_ROLE_BEAST),
    BeastAll = lists:foldl(fun(Beast, Acc) ->
        #r_beast{id=BeastID, summon=Summon} = Beast,
        case Summon of
            true ->
                #cfg_beast{skill=Skills} = cfg_beast:find(BeastID),
                mod_attr:add(calc_skill_attr(?SKILL_GROUP_BEAST_ALL, Skills), Acc);
            _ ->
                Acc
        end
    end, #{}, maps:values(Beasts)),

    Attr = lists:foldl(fun(Beast, Acc) ->
        #r_beast{id=BeastID, summon=Summon, equips=Equips} = Beast,

        case Summon of
            true ->
                #cfg_beast{attr=BeastAttr, skill=Skills} = cfg_beast:find(BeastID),
                BeastSelf = calc_skill_attr(?SKILL_GROUP_BEAST_SELF, Skills),
                EquipAttr = calc_equip_attr(Equips),
                ReinforceAttr = calc_reinforce_attr(Equips),
                Sum = mod_attr:sum([BeastAttr, EquipAttr, BeastAll, BeastSelf]),
                mod_attr:sum([Acc, mod_attr:calc_part_pro(Sum), ReinforceAttr]);
            _ ->
                Acc
        end
    end, #{}, maps:values(Beasts)),

    Power = mod_attr:power(Attr),
    role_event:event(?EVENT_BEAST_POWER, Power),
    Attr.

% 合成，转化
combine(ItemID, Cost, Bind) ->
    Exp = calc_combine_exp(Cost),
    #cfg_beast_equip{slot=Slot} = cfg_beast_equip:find(ItemID),
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

to_list(Beasts) when is_list(Beasts) ->
    [begin
        Equips = lists:map(fun(EquipUID) ->
            {ok, EquipItem} = role_bag:get_item(EquipUID),
            item_util:p_item(EquipItem)
        end, maps:values(B#r_beast.equips)),
        #p_beast{
            id     = B#r_beast.id,
            equips = Equips,
            summon = B#r_beast.summon
        }
    end||B <- Beasts].

find_beast(BeastID, Beasts) ->
    case maps:get(BeastID, Beasts, undefined) of
        undefined ->
            #r_beast{id = BeastID};
        Beast ->
            Beast
    end.

check_exist(CellID) ->
    case role_bag:get_item(CellID) of
        {ok, TmpItem}->TmpItem;
        Error -> throw(Error)
    end.

check_equip_color(BeastID, Item) ->
    #cfg_beast{slot=SlotRestrict} = cfg_beast:find(BeastID),
    #cfg_item{color=Color} = cfg_item:find(Item#p_item.id),
    #cfg_beast_equip{slot=Slot} = cfg_beast_equip:find(Item#p_item.id),
    case lists:keyfind(Slot, 1, SlotRestrict) of
        {Slot, NeedColor} when Color >= NeedColor ->
            ok;
        _ ->
            throw({error, ?ERR_BEAST_EQUIP_COLOR, []})
    end.

summon_num(Beasts) when is_map(Beasts) ->
    maps:fold(fun(_, #r_beast{summon=Summon}, Acc) ->
        if
            Summon ->
                Acc+1;
            true ->
                Acc
        end
    end, 0, Beasts).

find_equip(EquipUID, Beast) ->
    find_equip_1(EquipUID, maps:to_list(Beast#r_beast.equips)).

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
            C = cfg_beast_reinforce_mul:find(AddExp2) ++ [{cellid, CellID} | Cost];
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
    #cfg_beast_equip{slot=MSlot, exp=MExp} = cfg_beast_equip:find(Material#p_item.id),
    if
        Material#p_item.equip == ?nil ->
            MExp;
        true ->
            #p_item{equip=#p_equip{stren_lv=MStrLv, stren_phase=MCurExp}} = Material,
            case cfg_beast_reinforce:find(MSlot, MStrLv) of
                #cfg_beast_reinforce{total=MTotal} ->
                    MExp + MCurExp + MTotal;
                _ ->
                    MExp + MCurExp
            end
    end.

upgrade_equip(Slot, EquipItem, AddExp) ->
    #p_item{equip=Equip} = EquipItem,
    #p_equip{stren_lv=StrLv, stren_phase=CurExp} = Equip,
    #cfg_beast_reinforce{exp=NeedExp} = cfg_beast_reinforce:find(Slot, StrLv),
    CurExp2 = CurExp+AddExp,
    if
        CurExp2 >= NeedExp ->
            case cfg_beast_reinforce:find(Slot, StrLv+1) of
                undefined ->
                    Equip2 = Equip#p_equip{stren_lv=StrLv, stren_phase=0},
                    {max_lv, update_equip(EquipItem, Equip2)};
                #cfg_beast_reinforce{base=_Base} ->
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
        Add = case cfg_beast_equip:find(Item#p_item.id) of
            #cfg_beast_equip{slot=Slot, exp=BaseExp} ->
                #p_item{equip=#p_equip{stren_lv=StrLv, stren_phase=CurExp}} = Item,
                case cfg_beast_reinforce:find(Slot, StrLv) of
                    #cfg_beast_reinforce{total=Total} ->
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
        #cfg_beast_equip{slot=Slot} = cfg_beast_equip:find(EquipID),
        #cfg_beast_reinforce{base=Base} = cfg_beast_reinforce:find(Slot, Equip#p_equip.stren_lv),
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
