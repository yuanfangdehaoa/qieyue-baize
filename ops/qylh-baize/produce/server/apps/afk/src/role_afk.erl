%% @author rong
%% @doc
-module(role_afk).

-include("afk.hrl").
-include("attr.hrl").
-include("creep.hrl").
-include("game.hrl").
-include("table.hrl").
-include("role.hrl").
-include("proto.hrl").
-include("log.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("bag.hrl").
-include("item.hrl").

-export([hook_login/1, hook_logout/1, check_add_time/1, add_time/2]).
-export([settle/2, is_open/1, effect/2]).

hook_login(RoleSt) ->
    #role_afk{time=Time} = AFK = role_data:get(?DB_ROLE_AFK),
    case Time > 0 of
        true ->
            afk_server:login(RoleSt),
            #role_info{logout=Logout} = role_data:get(?DB_ROLE_INFO),
            #role_escort{end_time=EscortTime} = role_data:get(?DB_ROLE_ESCORT),
            Now = ut_time:seconds(),
            StartTime = max(Logout + cfg_game:afk_logout(), EscortTime),
            OfflineTime = Now - StartTime,
            case OfflineTime > 0 of
                true ->
                    Time2 = max(0, Time - OfflineTime),
                    role_data:set(AFK#role_afk{time=Time2}),
                    CalcTime = Time - Time2,
                    calc_settle(Logout, CalcTime, RoleSt);
                false ->
                    ignore
            end;
        false ->
            ignore
    end.

hook_logout(RoleSt) ->
    #role_afk{time=Time} = role_data:get(?DB_ROLE_AFK),
    case Time > 0 of
        true ->
            #role_escort{end_time=EscortEnd} = role_data:get(role_escort),
            afk_server:logout(RoleSt#role_st.role, ut_time:seconds(), EscortEnd, Time);
        false ->
            ignore
    end.

check_add_time(RoleSt) ->
    #role_afk{time=Time} = role_data:get(?DB_ROLE_AFK),
    ?_check(Time < cfg_game:afk_max_time(), ?ERR_AFK_MAX_TIME),
    ?_check(is_open(RoleSt), ?ERR_ITEM_LEVEL_LIMIT).

is_open(_RoleSt) ->
    #role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
    cfg_afk:find(Level) =/= ?nil.

add_time(Add, RoleSt) ->
    #role_afk{time=Time} = AFK = role_data:get(?DB_ROLE_AFK),
    MaxTime = min(cfg_game:afk_max_time(), Time+Add),
    role_data:set(AFK#role_afk{time=MaxTime}),
    ?ucast(#m_afk_info_toc{time = MaxTime}),
    mirror_manager:update_mirror(RoleSt).

settle({AfkTime, CreepID, Exp, Drops}, RoleSt) ->
    #role_info{level=OldLevel} = role_data:get(?DB_ROLE_INFO),
    {Equips, Items} = calc_afk_drops(CreepID, Drops),
    {ok, Obtain1} = role_bag:gain([{?ITEM_EXP, Exp}], ?LOG_AFK_REWARD, RoleSt),
    {ok, Obtain2} = role_bag:gain(Items, ?LOG_AFK_REWARD, RoleSt),
    {SmeltOld, SmeltNew} = role_equip:smelt_items(Equips, RoleSt),
    update_gain_counter(?ITEM_EXP, Exp),
    lists:foreach(fun
        ({ItemID, ItemNum}) ->
            update_gain_counter(ItemID, ItemNum)
    end, Equips),
    maps:fold(fun
        (ItemID, ItemNum, _) ->
            update_gain_counter(ItemID, ItemNum)
    end, ok, Obtain2),
    Smelts = role_bag:obtain_to_maps(Equips),

    #role_info{level=NewLevel} = role_data:get(?DB_ROLE_INFO),
    DiffLv = NewLevel-OldLevel,
    ?ucast(#m_afk_settle_toc{
        afk_time  = AfkTime,
        rewards   = maps:put(?ITEM_LEVEL, DiffLv, maps:merge(Obtain1, Obtain2)),
        smelt_old = SmeltOld,
        smelt_new = SmeltNew,
        smelts    = Smelts
    }).

%% 挂机效率(用于离线挂机榜)
effect(RoleLv, Attr) ->
    case cfg_afk:find(RoleLv) of
        #cfg_afk{exp=StdExp, fight=StdFight} ->
            Effect = calc_afk_effect(Attr, StdFight),
            Coef1  = ?_attrper(Attr, ?ATTR_EXP_PER, 0),
            Coef2  = ?_per( world_level:exp_coef(RoleLv) ),
            round(Effect * StdExp * (1 + Coef1 + Coef2));
        _ ->
            0
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
% 计算玩家收益
calc_settle(LogoutTime, AfkTime, _RoleSt) ->
    #role_info{id=RoleID, level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    CfgAfk = cfg_afk:find(RoleLv),
    #cfg_afk{creep=CreepID, exp=StdExp, atk=StdAtk, fight=StdFight} = CfgAfk,
    #role_attr{attr=Attr, buffs=Buffs} = role_data:get(?DB_ROLE_ATTR),
    % 挂机时长(分)
    Minute = ut_math:ceil(AfkTime / 60),
    % 挂机效率
    Effect = calc_afk_effect(Attr, StdFight),
    % 挂机经验
    ExpPer = ?_attr(Attr, ?ATTR_EXP_PER, 0),
    % 经验药水
    #p_buff{attrs=Attrs1, etime=ETime1} = get_exp_buff(5, Buffs),

    ExpPer1 = proplists:get_value(?ATTR_EXP_PER, Attrs1, 0),
    ExpTime = Minute
        + ?_per(ExpPer - ExpPer1) * Minute
        + ?_per(ExpPer1) * min(max(0, ut_math:ceil((ETime1-LogoutTime)/60)), Minute),
    Exp = ut_math:floor(StdExp * Effect * ExpTime),
    % 打怪数量
    Num = ut_math:floor(StdAtk * Minute),
    spawn(fun() ->
        Drops = calc_creep_drops(Num, RoleLv, cfg_creep:find(CreepID), []),
        role:route(RoleID, ?MODULE, settle, {AfkTime, CreepID, Exp, Drops})
    end).

get_exp_buff(Group, Buffs) ->
    maps:get(Group, Buffs, #p_buff{value=0, etime=0}).

%% 挂机效率
calc_afk_effect(Attr, StdFight) ->
    Power = mod_attr:power(Attr, damage),
    1.125 * min(math:pow((Power/StdFight), 0.6), 1.3).


%% 计算怪物掉落
calc_creep_drops(0, _RoleLv, _CfgCreep, Acc) ->
    Acc;
calc_creep_drops(Num, RoleLv, CfgCreep, Acc) ->
    Acc2 = creep_drop:calc(RoleLv, CfgCreep) ++ Acc,
    calc_creep_drops(Num-1, RoleLv, CfgCreep, Acc2).

%% 挂机掉落
calc_afk_drops(CreepID, Drops) ->
    #cfg_creep{level=CreepLv} = cfg_creep:find(CreepID),
    EmptyNum = role_bag:get_empty(?BAG_ID_MAIN),
    {_, _, Equips, Items} = lists:foldl(fun
        (Drop, Acc) ->
            calc_afk_drops2(Drop, CreepLv, Acc)
    end, {EmptyNum, #{}, [], []}, Drops),
    {Equips, Items}.

calc_afk_drops2(Drop, CreepLv, Acc) ->
    {AccEmpty, AccCnt, AccEquips, AccItems} = Acc,
    ItemID  = element(1, Drop),
    ItemNum = element(2, Drop),
    Limits  = cfg_drop_limit:find(ItemID),
    case role_drop:can_drop(Limits, ItemID, CreepLv) of
        true  ->
            LimNum = proplists:get_value(afk_limit, Limits, 0),
            case LimNum == 0 of
                true  ->
                    DropNum = ItemNum,
                    AccCnt2 = AccCnt;
                false ->
                    HadGain = case maps:find(ItemID, AccCnt) of
                        {ok,N} -> N;
                        error  -> role_count:get_afk_item_gain(ItemID)
                    end,
                    DropNum = min(ItemNum, max(0, LimNum - HadGain)),
                    AccCnt2 = case DropNum == 0 of
                        true  -> AccCnt;
                        false -> maps:put(ItemID, HadGain+DropNum, AccCnt)
                    end
            end,

            case DropNum > 0 of
                true  ->
                    Drop2 = setelement(2, Drop, DropNum),
                    #cfg_item{type=ItemType} = cfg_item:find(ItemID),
                    case ItemType of
                        ?ITEM_TYPE_MONEY ->
                            {AccEmpty, AccCnt2, AccEquips, [Drop2|AccItems]};
                        ?ITEM_TYPE_EQUIP ->
                            {AccEmpty, AccCnt2, [{ItemID,DropNum}|AccEquips], AccItems};
                        _ when AccEmpty > 0 ->
                            {AccEmpty-1, AccCnt2, AccEquips, [Drop2|AccItems]};
                        _ ->
                            Acc
                    end;
                false ->
                    Acc
            end;
        false ->
            Acc
    end.

update_gain_counter(ItemID, ItemNum) ->
    Limits = cfg_drop_limit:find(ItemID),
    case proplists:is_defined(afk_limit, Limits) of
        true  -> role_count:add_afk_item_gain(ItemID, ItemNum);
        false -> ignore
    end.
