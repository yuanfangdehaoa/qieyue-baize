%% @author rong
%% @doc
-module(mecha_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("mecha.hrl").
-include("msgno.hrl").
-include("item.hrl").
-include("enum.hrl").
-include("bag.hrl").
-include("scene.hrl").

-define(ACTIVE_STAR, 9).

-export([handle/3]).
-export([get_attr/1]).
-export([check_state/2]).

handle(?MECHA_LIST, _Tos, RoleSt) ->
    #role_mecha{mechas=Mechas, use_id=UseID} = role_data:get(?DB_ROLE_MECHA),
    ?ucast(#m_mecha_list_toc{mechas=maps:values(Mechas), use_id=UseID});

handle(?MECHA_UPSTAR, Tos, RoleSt) ->
    #role_st{role=RoleID, name=RoleName} = RoleSt,
    #m_mecha_upstar_tos{id=ID} = Tos,
    #p_mecha{star=Star1} = Mecha = get_mecha(ID),
    MaxStar = cfg_mecha_star:max(ID),
    ?_check(Mecha#p_mecha.star < MaxStar, ?ERR_MECHA_MAX_STAR),
    #cfg_mecha_star{cost=Cost} = cfg_mecha_star:find(ID, Star1),
    role_bag:cost(Cost, ?LOG_MECHA_UPSTAR, RoleSt),
    Star2  = Star1 + 1,
    Mecha2 = Mecha#p_mecha{star=Star2},
    save_mecha(Mecha2),
    upgrade_skill(Mecha2, RoleSt),
    role_attr:recalc(?MODULE, RoleSt),
    #cfg_mecha{name=MechaName, color=Color} = cfg_mecha:find(ID),
    ?ucast(#m_mecha_upstar_toc{mecha=Mecha2}),
    Star2 == ?ACTIVE_STAR andalso begin
        case scene:sync_route(RoleSt#role_st.spid, ?MODULE, check_state, RoleSt#role_st.role) of
            ok ->
                handle(?MECHA_SELECT, #m_mecha_select_tos{id=ID}, RoleSt);
            _ ->
                ignore
        end,
        ?notify(?MSG_MECHA_ACTIVE, [{role,RoleID,RoleName}, ut_color:format(MechaName, Color)])
    end,
    Star2 >= 18 andalso Star2 rem ?ACTIVE_STAR == 0 andalso
        ?notify(?MSG_MECHA_UPSTAR, [{role,RoleID,RoleName}, ut_color:format(MechaName, Color), (Star2 div ?ACTIVE_STAR) - 1]);

handle(?MECHA_UPGRADE, Tos, RoleSt) ->
    #m_mecha_upgrade_tos{id=ID, item_id=ItemID} = Tos,
    #p_mecha{star=Star, level=Level, exp=Exp} = Mecha = get_mecha(ID),
    #cfg_item{stype=SType, effect=ExpAdd} = cfg_item:find(ItemID),
    ?_check(SType == ?ITEM_STYPE_MECHA_EXP, ?ERR_GAME_BAD_ARGS),
    ?_check(Level < cfg_mecha_upgrade:max(ID), ?ERR_MECHA_MAX_LEVEL),
    ?_check(is_active(Star), ?ERR_MECHA_NOT_ACTIVE),
    role_bag:cost([{ItemID,1}], ?LOG_MECHA_UPGRADE, RoleSt),
    Mecha1 = Mecha#p_mecha{exp=Exp+ExpAdd},
    Mecha2 = maybe_upgrade(Mecha1, RoleSt),
    save_mecha(Mecha2),
    role_attr:recalc(?MODULE, RoleSt),
    ?ucast(#m_mecha_upgrade_toc{mecha=Mecha2});

handle(?MECHA_SELECT, Tos, RoleSt) ->
    #m_mecha_select_tos{id=ID} = Tos,
    #role_mecha{mechas=Mechas, use_id=UseID} = RoleMecha = role_data:get(?DB_ROLE_MECHA),
    ?_check(ID =/= UseID, ?ERR_MECHA_ALREADY_IN_USE),
    ok = scene:sync_route(RoleSt#role_st.spid, ?MODULE, check_state, RoleSt#role_st.role),
    case maps:find(ID, Mechas) of
        {ok, Mecha} ->
            ?_check(is_active(Mecha#p_mecha.star), ?ERR_MECHA_NOT_ACTIVE);
        _ ->
            Mecha = ?nil,
            throw(?err(?ERR_MECHA_NOT_ACTIVE))
    end,
    PreMecha = maps:get(UseID, Mechas, ?nil),
    role_data:set(RoleMecha#role_mecha{use_id=ID}),
    replace_skill(Mecha, PreMecha, RoleSt),
    ?ucast(#m_mecha_select_toc{id=ID});

%获取装备列表
handle(?MECHA_EQUIP, Tos, RoleSt)->
    #m_mecha_equip_tos{id=ID} = Tos,
    #role_mecha{equips=TypeEquips} = role_data:get(?DB_ROLE_MECHA),
    Equips = maps:get(ID, TypeEquips, #{}),
    Items = maps:fold(fun
            (_, CellId, Lists) ->
                {ok, Item} = role_bag:get_item(CellId),
                [item_util:p_item(Item) | Lists]
        end, [], Equips),
    Slots = #{},
    {ok, #m_mecha_equip_toc{id=ID, equips=Items, slots=Slots}, RoleSt};

%穿戴装备
handle(?MECHA_EQUIP_PUTON, Tos, RoleSt)->
    #m_mecha_equip_puton_tos{id=ID, uid=UId} = Tos,
    {ok, Item} = role_bag:get_item(UId),
    #p_item{id=ItemID} = Item,
    #cfg_mecha_equip{slot=Slot, mecha_id=MechaID} = cfg_mecha_equip:find(ItemID),
    ?_check(ID == MechaID orelse MechaID == 0, ?ERR_MECHA_CANNOT_PUTON),
    RoleMecha = #role_mecha{equips=TypeEquips, mechas=Mechas} = role_data:get(?DB_ROLE_MECHA),
    Equips = maps:get(ID, TypeEquips, #{}),
    OldUId = maps:get(Slot, Equips, 0),
    Mecha = maps:get(ID, Mechas, ?nil),
    ?_check(Mecha /= ?nil, ?ERR_MECHA_NOT_ACTIVE),
    check_slot(ID, Slot, Mecha),
    {ok, _, [NewItem]} = role_bag:move(?BAG_ID_MECHA, ?BAG_ID_MECHA_EQUIP, [{UId,1}], RoleSt),
    %原部位有装备
    NewItem4 = case OldUId > 0 of
        true ->
            {ok, OldItem} = role_bag:get_item(OldUId),
            #p_item{extra=Level} = OldItem,
            role_bag:move(?BAG_ID_MECHA_EQUIP, ?BAG_ID_MECHA, [{OldUId, 1}], RoleSt),
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
    TypeEquips2 = maps:put(ID, Equips2, TypeEquips),
    role_data:set(RoleMecha#role_mecha{equips=TypeEquips2}),
    role_attr:recalc(mecha_handler, RoleSt),
    role_event:notify(?EVENT_MECHA_EQUIP, TypeEquips2, RoleSt),
    ?ucast(#m_mecha_equip_toc{id=ID, equips=[item_util:p_item(NewItem4)]}),
    {ok, #m_mecha_equip_puton_toc{slot=Slot, id=ID}, RoleSt};

%装备强化
handle(?MECHA_EQUIP_UPLEVEL, Tos, RoleSt)->
    #m_mecha_equip_uplevel_tos{slot=Slot, id=ID} = Tos,
    #role_mecha{equips=TypeEquips} = role_data:get(?DB_ROLE_MECHA),
    Equips = maps:get(ID, TypeEquips, #{}),
    UId = maps:get(Slot, Equips, 0),
    ?_check(UId > 0, ?ERR_BABY_NO_EQUIP_PUTON),
    {ok, Item} = role_bag:get_item(UId),
    #p_item{extra=OldLevel} = Item,
    #cfg_mecha_equip_level{cost=Cost} = cfg_mecha_equip_level:find(Slot, OldLevel),
    ?_check(length(Cost) > 0, ?ERR_BABY_EQUIP_MAX_LEVEL),
    role_bag:cost(Cost, ?LOG_GOD_EQUIP_UPLEVEL, RoleSt),
    Item2 = Item#p_item{extra=OldLevel+1},
    #p_item{equip=Equip} = Item2,
    Power = calc_power(Item2),
    Equip2 = Equip#p_equip{power=Power},
    Item3 = Item2#p_item{equip=Equip2},
    role_bag:set_item(Item3),
    role_attr:recalc(mecha_handler, RoleSt),
    ?ucast(#m_mecha_equip_toc{id=ID, equips=[item_util:p_item(Item3)]}),
    {ok, #m_mecha_equip_uplevel_toc{slot=Slot, id=ID}, RoleSt};


%装备分解
handle(?MECHA_EQUIP_DECOMPOSE, Tos, RoleSt)->
    #m_mecha_equip_decompose_tos{uid=UIds} = Tos,
    {Costs, Gains} = lists:foldl(fun
            (UId, {Acc1, Acc2}) ->
                {ok, Item} = role_bag:get_item(UId),
                #p_item{id=ItemID} = Item,
                 #cfg_mecha_equip{gain=Gain} = cfg_mecha_equip:find(ItemID),
                 {[{cellid, UId}|Acc1], lists:merge(Gain, Acc2)}
        end, {[], []}, UIds),
    role_bag:deal(Costs, Gains, ?LOG_GOD_EQUIP_DECOMPOSE, RoleSt),
    {ok, #m_mecha_equip_decompose_toc{}, RoleSt}.


get_attr(_AttrType) ->
    #role_mecha{mechas=Mechas, equips=AllEquips} = role_data:get(?DB_ROLE_MECHA),
    Sum1 = maps:fold(fun
            (_K, Equips, Acc)->
                mod_attr:sum([Acc, get_equips_attr(Equips)])
        end, #{}, AllEquips),
    Sum2 = maps:fold(fun(_, Mecha, Acc) ->
        #p_mecha{id=ID, star=Star, level=Level} = Mecha,
        #cfg_mecha_star{attrs=StarAttr} = cfg_mecha_star:find(ID, Star),
        case is_active(Star) of
            true ->
                #cfg_mecha_upgrade{attrs=UpGradeAttr} = cfg_mecha_upgrade:find(ID, Level);
            false ->
                UpGradeAttr = #{}
        end,
        mod_attr:sum([StarAttr, UpGradeAttr, Acc])
    end, #{}, Mechas),

    Attr  = mod_attr:sum([Sum1, Sum2]),
    Power = mod_attr:power(Attr),
    role_event:event(?EVENT_MECHA_POWER, Power),
    Attr.

check_state(RoleID, _SceneSt) ->
    Actor = scene_actor:get_actor(RoleID),
    ?_check(not ?is_mechamorph(Actor#actor.state), ?ERR_MECHA_IN_MORPH),
    ok.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_mecha(ID) ->
    #role_mecha{mechas=Mechas} = role_data:get(?DB_ROLE_MECHA),
    case maps:find(ID, Mechas) of
        {ok, Mecha0} -> Mecha0;
        _ -> #p_mecha{id=ID, star=0, level=1, exp=0}
    end.

save_mecha(Mecha) ->
    #role_mecha{mechas=Mechas} = RoleMecha = role_data:get(?DB_ROLE_MECHA),
    RoleMecha2 = RoleMecha#role_mecha{mechas=maps:put(Mecha#p_mecha.id, Mecha, Mechas)},
    role_data:set(RoleMecha2).

is_active(Star) ->
    Star >= ?ACTIVE_STAR.

maybe_upgrade(Mecha, RoleSt) ->
    #p_mecha{id=ID, level=Level, exp=Exp} = Mecha,
    #cfg_mecha_upgrade{exp=MaxExp} = cfg_mecha_upgrade:find(ID, Level),
    case Exp >= MaxExp of
        true  ->
            case Level >= cfg_mecha_upgrade:max(ID) of
                true  ->
                    Mecha;
                false ->
                    Level2 = Level + 1,
                    Mecha2 = Mecha#p_mecha{level=Level2, exp=Exp-MaxExp},
                    maybe_upgrade(Mecha2, RoleSt)
            end;
        false ->
            Mecha
    end.

calc_power(Item)->
    #p_item{id=ItemID, extra=Level, equip=Equip} = Item,
    #cfg_mecha_equip{slot=Slot} = cfg_mecha_equip:find(ItemID),
    #cfg_mecha_equip_level{attr=Attr} = cfg_mecha_equip_level:find(Slot, Level),
    StrongAttr = mod_attr:to_map(Attr),
    #p_equip{base=BaseAttr} = Equip,
    mod_attr:power(mod_attr:sum([BaseAttr, StrongAttr])).

check_slot(ID, Slot, Mecha)->
    #cfg_mecha_equip_open{open=Open} = cfg_mecha_equip_open:find(ID, Slot),
    case Open of
        {star, Star} ->
            ?_check(Mecha#p_mecha.star >= Star, ?ERR_MECHA_STAR_NOT_ENOUGH);
        _ ->
            ignore
    end.

get_equips_attr(Equips)->
    maps:fold(fun
            (_K, UId, Acc) ->
                {ok, Item} = role_bag:get_item(UId),
                #p_item{id=ItemID, extra=Level, equip=Equip} = Item,
                #p_equip{base=Base} = Equip,
                #cfg_mecha_equip{slot=Slot} = cfg_mecha_equip:find(ItemID),
                #cfg_mecha_equip_level{attr=Attr} = cfg_mecha_equip_level:find(Slot, Level),
                mod_attr:sum([Acc, Base, mod_attr:to_map(Attr)])
        end, #{}, Equips).

upgrade_skill(Mecha, RoleSt) ->
    #role_mecha{use_id=UseID} = role_data:get(?DB_ROLE_MECHA),
    if
        Mecha#p_mecha.id == UseID ->
            #cfg_mecha_star{skill=OldSkills} = cfg_mecha_star:find(Mecha#p_mecha.id, Mecha#p_mecha.star-1),
            role_skill:remove(OldSkills, RoleSt),
            #cfg_mecha_star{skill=NewSkills} = cfg_mecha_star:find(Mecha#p_mecha.id, Mecha#p_mecha.star),
            role_skill:active(NewSkills, RoleSt);
        true ->
            ignore
    end.

replace_skill(Mecha, PreMecha, RoleSt) ->
    case PreMecha of
        ?nil -> ignore;
        _ ->
            #cfg_mecha_star{skill=OldSkills} = cfg_mecha_star:find(PreMecha#p_mecha.id, PreMecha#p_mecha.star),
            role_skill:remove(OldSkills, RoleSt)
    end,
    #cfg_mecha_star{skill=Skills} = cfg_mecha_star:find(Mecha#p_mecha.id, Mecha#p_mecha.star),
    role_skill:active(Skills, RoleSt),
    PreMecha =/= ?nil andalso role_skill:set_skills_cd(Skills, RoleSt).
