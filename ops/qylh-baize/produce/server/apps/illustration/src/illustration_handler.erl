%% @author rong
%% @doc
-module(illustration_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("illustration.hrl").
-include("enum.hrl").
-include("item.hrl").
-include("log.hrl").
-include("msgno.hrl").

-export([handle/3]).
-export([get_power/0]).
-export([get_attr/1]).

handle(?ILLUSTRATION_INFO, _Tos, RoleSt) ->
    #role_illustration{list=List} = role_data:get(?DB_ROLE_ILLUSTRATION),
    ?ucast(#m_illustration_info_toc{list=List});

handle(?ILLUSTRATION_UPSTAR, Tos, RoleSt) ->
    #m_illustration_upstar_tos{id=ID} = Tos,
    #role_illustration{list=List} = RoleIllustration = role_data:get(?DB_ROLE_ILLUSTRATION),
    Illus = case lists:keyfind(ID, #p_illustration.id, List) of
        false -> #p_illustration{id=ID, star=0};
        Illus0 -> Illus0
    end,
    #p_illustration{star=Star} = Illus,
    #cfg_illustration{name=Name, max_star= MaxStar, color=Color} = cfg_illustration:find(ID),
    ?_check(Star < MaxStar, ?ERR_ILLUSTARTION_MAX_STAR),
    #cfg_illustration_star{item=NeedItem, essence=Essence, notify=Notify} = cfg_illustration_star:find(ID, Star+1),
    Cost = if
        Essence =/= [] -> {'OR', NeedItem, Essence};
        true -> NeedItem
    end,
    role_bag:cost(Cost, ?LOG_ILLUSTRATION_UPSTAR, RoleSt),
    Illus2 = Illus#p_illustration{star=Star+1},
    List2 = lists:keystore(ID, #p_illustration.id, List, Illus2),
    role_data:set(RoleIllustration#role_illustration{list=List2}),
    role_attr:recalc(?MODULE, RoleSt),
    role_event:event(?EVENT_ILLUSTRATION_POWER, get_power()),
    Notify andalso begin
        #role_st{role=RoleID, name=RoleName} = RoleSt,
        ?notify(?MSG_ILLUSTRATION_UPSTAR, [{role, RoleID, RoleName}, ut_color:format(Name, Color), Star+1])
    end,
    ?ucast(#m_illustration_upstar_toc{illustration=Illus2});

handle(?ILLUSTRATION_DECOMPOSE, Tos, RoleSt) ->
    #m_illustration_decompose_tos{uid=UIDs} = Tos,
    #role_illustration{list=List} = role_data:get(?DB_ROLE_ILLUSTRATION),
    Num = lists:foldl(fun(UID, Acc) ->
        {ok, #p_item{id=ItemID, num=ItemNum}} = role_bag:get_item(UID),
        #cfg_item{type=Type, effect=Effect} = cfg_item:find(ItemID),
        ?_check(Type == ?ITEM_TYPE_ILLUSTRATION, ?ERR_ILLUSTARTION_DECOMPOSE_TYPE),
        check_max_star(ItemID, List),
        trunc(Effect*ItemNum) + Acc
    end, 0, UIDs),
    Cost = [{cellid, CellID} || CellID <- UIDs],
    Gain = [{?ITEM_ILLUS_ESSENCE, Num}],
    role_bag:deal(Cost, Gain, ?LOG_ILLUSTRATION_DECOMPOSE, RoleSt),
    ?ucast(#m_illustration_decompose_toc{}).

get_attr(_AttrType)->
    #role_illustration{list=List} = role_data:get(?DB_ROLE_ILLUSTRATION),
    TotalAttr = lists:foldl(fun(Illus, Attr) ->
        #p_illustration{id=ID, star=Star} = Illus,
        #cfg_illustration_star{attr=Attr0} = cfg_illustration_star:find(ID, Star),
        mod_attr:add(Attr, Attr0)
    end, #{}, List),
    CombineAttr = lists:foldl(fun(CID, Attr) ->
        #cfg_illustration_combination{illustrations=Needs, attr=Attr0} 
            = cfg_illustration_combination:find(CID),
        HasAll = lists:all(fun(ID) ->
            lists:keymember(ID, #p_illustration.id, List)
        end, Needs),
        if
            HasAll -> mod_attr:add(Attr, Attr0);
            true -> Attr
        end
    end, #{}, cfg_illustration_combination:list()),
    mod_attr:add(TotalAttr, CombineAttr).

get_power() ->
    mod_attr:power(get_attr(?nil)).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_max_star(ID, List) ->
    case lists:keyfind(ID, #p_illustration.id, List) of
        false -> 
            throw(?ERR_ILLUSTARTION_NOT_MAX_STAR);
        #p_illustration{star=Star} -> 
            #cfg_illustration{max_star= MaxStar} = cfg_illustration:find(ID),
            ?_check(Star >= MaxStar, ?ERR_ILLUSTARTION_NOT_MAX_STAR)
    end.
