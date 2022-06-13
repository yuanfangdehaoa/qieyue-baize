%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_drop).

-include("creep.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([drop_exp/3]).
-export([drop_item/4]).
-export([can_drop/3]).
-export([p_drop/1, p_drop/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
drop_exp(Exp, Coef, RoleSt) ->
    role_bag:gain([{?ITEM_EXP,Exp}, {?ITEM_EXPCOEF,Coef}], ?LOG_CREEP_DROP, RoleSt),
    role_vip:add_expool(Exp).

drop_item(Creep, Drops, IsDummy, RoleSt) ->
	{Gain, Drops2} = filter_drop_item(Drops, Creep, [], []),
    ?_if(IsDummy andalso Drops2 /= [], ?ucast(#m_scene_drop_toc{
        drops = [p_drop(Drop) || Drop <- Drops2]
    })),
    {ok, Obtain} = role_bag:gain(Gain, ?LOG_CREEP_DROP, ?nil, RoleSt, true),

    lists:foldl(fun
        (Item, Index) when is_record(Item, p_item), Index =< length(Drops2) ->
            Drop = lists:nth(Index, Drops2),
            scene_hook:hook_pickup(Drop, Item, RoleSt),
            Index+1;
        (_, Index) ->
            Index+1
    end, 1, Obtain).

can_drop(Limits, ItemID, CreepLv) ->
    check_can_drop(Limits, ItemID, CreepLv).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
filter_drop_item([], _Creep, Gain, Drops) ->
    {Gain, Drops};
filter_drop_item([Drop | T], Creep, Gain, Drops) ->
    #drop{id=ItemID, num=Num, opts=Opts} = Drop,
    Limits = cfg_drop_limit:find(ItemID),
    case check_can_drop(Limits, ItemID, Creep#actor.level) of
        true  ->
            Gain2  = [{ItemID, Num, Opts} | Gain],
            Drops2 = [Drop | Drops],
            filter_drop_item(T, Creep, Gain2, Drops2);
        false ->
            filter_drop_item(T, Creep, Gain, Drops)
    end.

check_can_drop([], _ItemID, _CreepLv) ->
    true;
check_can_drop([{task, TaskID} | T], ItemID, CreepLv) ->
    case role_task:is_accept(TaskID) of
        true  -> check_can_drop(T, ItemID, CreepLv);
        false -> false
    end;
check_can_drop([{creep_lv, Level} | T], ItemID, CreepLv) ->
    case CreepLv >= Level of
        true  -> check_can_drop(T, ItemID, CreepLv);
        false -> false
    end;
check_can_drop([{wake_grid, NeedStep, MinGrid, MaxGrid} | T], ItemID, CreepLv) ->
    #role_wake{step=Step, grid=Grid} = role_data:get(?DB_ROLE_WAKE),
    case Step == NeedStep andalso MinGrid =< Grid andalso Grid =< MaxGrid of
        true  -> check_can_drop(T, ItemID, CreepLv);
        false -> false
    end;
check_can_drop([{afk_limit, _} | T], ItemID, CreepLv) ->
    check_can_drop(T, ItemID, CreepLv).

p_drop(Drop) ->
    #cfg_creep{mode=Mode} = cfg_creep:find(Drop#drop.creep),
    p_drop(Drop, Mode).

p_drop(Drop, Mode) ->
    #p_drop{
        id    = Drop#drop.id,
        num   = Drop#drop.num,
        coord = Drop#drop.coord,
        from  = Drop#drop.owner,
        mode  = Mode
    }.
