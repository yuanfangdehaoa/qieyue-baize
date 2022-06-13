%% @author rong
%% @doc 
-module(dunge_soul_dungeai).

-include("scene.hrl").
-include("game.hrl").
-include("btree.hrl").
-include("enum.hrl").
-include("dunge.hrl").
-include("fight.hrl").
-include("proto.hrl").
-include("errno.hrl").
-include("creep.hrl").
-include("msgno.hrl").
-include("item.hrl").
-include("role.hrl").

-export([summon_morph/1]).
-export([notify_msg/1]).
-export([start/1]).
-export([start_wave/1]).
-export([is_boss_clear/1]).
-export([reduce_rest_creep/1]).
-export([add_escape_creep/1]).
-export([is_max_escape/1]).
-export([update_drop/1]).
-export([stat/1]).
-export([select_morph/2]).
-export([config_summon/2]).
-export([auto_summon/1]).
-export([cancel_auto/1]).
-export([summon_boss/1]).

summon_morph(SceneSt) ->
    #scene_st{opts=Opts} = SceneSt,
    Slots = maps:get(slots, Opts, #{}),
    lists:foreach(fun({Slot, MorphID}) ->
        add_morph(Slot, MorphID, SceneSt)
    end, maps:to_list(Slots)),
    ?SUCCESS.

notify_msg(_SceneSt) ->
    {hook_enter, [#actor{uid=RoleID}]} = dunge_util:get_event(),
    ?notify([RoleID], ?MSG_DUNGE_SOUL_START, []),
    ?SUCCESS.

start(SceneSt) ->
    start_wave(SceneSt),
    auto_summon(SceneSt).

start_wave(SceneSt) ->
    case dunge_aiwave:is_over(SceneSt) of
        true ->
            #dunge_st{opts=Opts} = DungeSt = dunge_util:get_state(),
            Opts2 = maps:merge(Opts, #{has_summon => 0}),
            dunge_util:set_state(DungeSt#dunge_st{ptime=0, opts=Opts2}),
            Waypoint = [#p_coord{x=X,y=Y} || {X, Y} <- cfg_dunge_soul:waypoint()],
            dunge_aiwave:summon(#{waypoint => Waypoint}, SceneSt),
            update_creep_num(SceneSt);
        false ->
            ignore
    end,
    ?SUCCESS.

is_boss_clear(_SceneSt) ->
    #dunge_st{opts=Opts} = dunge_util:get_state(),
    maps:get(rest_creep, Opts, 0) =< 0.

reduce_rest_creep(SceneSt) ->
    #dunge_st{roles=[RoleID], opts=Opts} = DungeSt = dunge_util:get_state(),
    RestCreep = maps:get(rest_creep, Opts, 0),
    Opts2 = maps:merge(Opts, #{
        rest_creep => max(RestCreep-1, 0)
    }),
    dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
    dunge_soul:send_info(RoleID, SceneSt),
    ?SUCCESS.

add_escape_creep(SceneSt) ->
    #dunge_st{roles=[RoleID], opts=Opts} = DungeSt = dunge_util:get_state(),
    Escape = maps:get(escape_creep, Opts, 0),
    Opts2 = maps:merge(Opts, #{
        escape_creep => Escape + 1
    }),
    dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
    dunge_soul:send_info(RoleID, SceneSt),
    ?SUCCESS.

is_max_escape(_SceneSt) ->
    #dunge_st{opts=Opts} = dunge_util:get_state(),
    Escape = maps:get(escape_creep, Opts, 0),
    Escape >= cfg_dunge_soul:escape().

update_drop(SceneSt) ->
    % 更新掉落统计
    DungeSt = #dunge_st{roles=[RoleID], opts=Opts} = dunge_util:get_state(),
    {hook_drop, [Defer, Drops]} = dunge_util:get_event(),
    Opts2 = drop_stat(Defer, Drops, Opts),
    dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
    dunge_soul:send_info(RoleID, SceneSt),
    ?SUCCESS.

stat(SceneSt) ->
    DungeSt = dunge_util:get_state(),
    #dunge_st{clear=IsClear, roles=[RoleID], opts=Opts} = DungeSt,
    ?ucast(RoleID, #m_dunge_over_toc{
        stype  = SceneSt#scene_st.stype,
        id     = SceneSt#scene_st.dunge,
        clear  = IsClear,
        reward = maps:get(drop, Opts, #{})
    }),
    ?SUCCESS.

select_morph({Slot, MorphID}, SceneSt) ->
    #dunge_st{ptime=PTime} = dunge_util:get_state(),
    case PTime > 0 of
        true ->
            case erlang:get({slot, Slot}) of
                UID0 when is_integer(UID0) ->
                    creep_agent:del(UID0, SceneSt);
                _ ->
                    ignore
            end,
            MorphID > 0 andalso add_morph(Slot, MorphID, SceneSt),
            ok;
        false ->
            ignore
    end.

config_summon({RoleID, AutoSummon}, SceneSt) ->
    DungeSt = #dunge_st{opts=Opts, ptime=PTime} = dunge_util:get_state(),
    HasSummon = maps:get(has_summon, Opts, 0),
    Opts2 = maps:merge(Opts, #{
        auto_summon => AutoSummon
    }),
    dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
    dunge_soul:send_info(RoleID, SceneSt),
    case {HasSummon, PTime} of
        {1, _} ->
            ok;
        {_, PTime} when PTime > 0 ->
            ok;
        {0, 0} ->
            role:route(RoleID, dunge_soul, summon_boss),
            ok
    end.

auto_summon(_SceneSt) ->
    #dunge_st{roles=[RoleID], opts=Opts} = dunge_util:get_state(),
    HasSummon = maps:get(has_summon, Opts, 0) == 1,
    AutoSummon = maps:get(auto_summon, Opts, 0) == 1,
    case AutoSummon andalso not HasSummon of
        true ->
            role:route(RoleID, dunge_soul, summon_boss),
            ?SUCCESS;
        false ->
            ?FAILURE
    end.

cancel_auto(SceneSt) ->
    DungeSt = #dunge_st{roles=[RoleID], opts=Opts} = dunge_util:get_state(),
    Opts2 = maps:merge(Opts, #{
        auto_summon => 0
    }),
    dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
    dunge_soul:send_info(RoleID, SceneSt).

summon_boss(SceneSt) ->
    DungeSt = #dunge_st{roles=[RoleID], level=CreepLv, opts=Opts} = dunge_util:get_state(),
    case maps:get(has_summon, Opts, 0) of
        0 ->
            Boss = cfg_dunge_soul_boss:find(CreepLv),
            Waypoint = [#p_coord{x=X,y=Y} || {X, Y} <- cfg_dunge_soul:waypoint()],
            dunge_creep:summon([Boss], #{waypoint => Waypoint}, SceneSt),
            #cfg_creep{name=Name} = cfg_creep:find(element(1, Boss)),
            ?notify([RoleID], ?MSG_DUNGE_SOUL_SUMMON_BOSS, [Name]),
            RestCreep = maps:get(rest_creep, Opts, 0),
            Opts2 = maps:merge(Opts, #{
                has_summon  => 1, 
                rest_creep  => RestCreep+1
            }),
            dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
            dunge_soul:send_info(RoleID, SceneSt);
        1 ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 掉落统计
drop_stat(Actor, Drops, Opts)->
    #dunge_st{roles=[RoleID]} = dunge_util:get_state(),
    {ok, #role_cache{name=RoleName}} = role:get_cache(RoleID),
    DropStat  = maps:get(drop, Opts, #{}),
    DropStat2 = lists:foldl(fun
        (#drop{id=ItemID, num=Num}, Acc) ->
            case cfg_item:find(ItemID) of
                #cfg_item{color=?COLOR_RED} ->
                    ?notify(?MSG_DUNGE_SOUL_DROP, [
                        {role, RoleID, RoleName},
                        Actor#actor.name,
                        {item, #{ItemID=>Num}}
                    ]);
                _ ->
                    ignore
            end,
            ut_misc:maps_increase(ItemID, Num, Acc)
    end, DropStat, Drops),
    maps:put(drop, DropStat2, Opts).

update_creep_num(#scene_st{dunge=DungeID}=SceneSt) ->
    #dunge_st{roles=[RoleID], wave=Wave, level=CreepLv, opts=Opts} 
        = DungeSt = dunge_util:get_state(),
    #cfg_dunge_wave{creeps=Creeps} = cfg_dunge_wave:find(DungeID, Wave, CreepLv),
    Opts2 = maps:merge(Opts, #{
        rest_creep => length(Creeps)
    }),
    dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
    dunge_soul:send_info(RoleID, SceneSt).

add_morph(Slot, MorphID, SceneSt) ->
    #dunge_st{roles=[RoleID], level=Level} = dunge_util:get_state(),
    {CreepID, AttrID, AttCoef, DefCoef} = cfg_dunge_soul_morph:creep(MorphID),
    {Slot, X, Y} = lists:keyfind(Slot, 1, cfg_dunge_soul:slot()),
    Opts = #{aiargs => #{enemy_type => ?ACTOR_TYPE_CREEP}, owner => RoleID, group => 1},
    Creep = {CreepID, X, Y, AttrID, Level, AttCoef, DefCoef, Opts},
    [UID] = creep_agent:add([Creep], SceneSt),
    erlang:put({slot, Slot}, UID).
