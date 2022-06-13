%% @author rong
%% @doc
-module(dunge_soul).

-include("game.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("errno.hrl").
-include("dunge.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("scene.hrl").
-include("log.hrl").

-export([create_opts/2]).
-export([enter_opts/2]).
-export([handle/2]).
-export([summon_boss/1]).
-export([send_info/2]).

-define(SCENE_STYPE, ?SCENE_STYPE_DUNGE_SOUL).
-define(SCENE_ID, 30501).

create_opts(_Entry, _RoleSt) ->
    #role_dunge{misc=AllMisc} = role_data:get(?DB_ROLE_DUNGE),
    Misc = maps:get(?SCENE_STYPE, AllMisc, #{}),
    #{slots => maps:get(slots, Misc, #{})}.

enter_opts(_Entry, _RoleSt) ->
    #role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
    #{level => cfg_dunge_soul_creep_lv:find(Level), group => 1}.

handle(?DUNGE_SOUL_PANEL, RoleSt) ->
    #role_dunge{misc=AllMisc} = role_data:get(?DB_ROLE_DUNGE),
    Misc = maps:get(?SCENE_STYPE, AllMisc, #{}),
    #cfg_dunge_enter{times=MaxTimes} = cfg_dunge:enter(?SCENE_STYPE),
    Options = morph_handler:get_actives(?TRAIN_GOD),
    ?ucast(#m_dunge_soul_panel_toc{
        stype = ?SCENE_STYPE,
        id    = dunge_util:get_dunge(?SCENE_STYPE),
        info  = #{
            "max_times"  => MaxTimes,
            "buy_times"  => role_count:get_scene_buy(?SCENE_STYPE),
            "rest_times" => dunge_util:rest_times(?SCENE_STYPE)
        },
        slots = maps:get(slots, Misc, #{}),
        options = Options
    });

handle({?DUNGE_SOUL_SELECT, Tos}, RoleSt) ->
    #m_dunge_soul_select_tos{slot=Slot, morph_id=MorphID} = Tos,
    #role_dunge{misc=AllMisc} = RoleDunge = role_data:get(?DB_ROLE_DUNGE),
    Misc = maps:get(?SCENE_STYPE, AllMisc, #{}),
    Slots = maps:get(slots, Misc, #{}),
    Options = morph_handler:get_actives(?TRAIN_GOD),
    ?_check(Slot > 0 andalso Slot =< 6, ?ERR_GAME_BAD_ARGS, [?DUNGE_SOUL_SELECT]),
    case MorphID of
        0 ->
            Slots2 = maps:remove(Slot, Slots);
        _ ->
            ?_check(lists:member(MorphID, Options), ?ERR_GAME_BAD_ARGS, [?DUNGE_SOUL_SELECT]),
            Total = cfg_dunge_soul_morph:find(MorphID),
            ?_check(morph_num(Slot, MorphID, Slots) < Total, ?ERR_DUNGE_SOUL_MORPH_LIMIT),
            Slots2 = maps:put(Slot, MorphID, Slots)
    end,

    case RoleSt#role_st.stype == ?SCENE_STYPE of
        true ->
            #role_st{spid=ScenePid} = RoleSt,
            Result = scene:sync_route(ScenePid,
                dunge_soul_dungeai, select_morph, {Slot, MorphID}),
            ?_check(ok == Result, ?ERR_DUNGE_SOUL_ALREADY_START);
        false ->
            ok
    end,

    Misc2 = maps:put(slots, Slots2, Misc),
    AllMisc2 = maps:put(?SCENE_STYPE, Misc2, AllMisc),
    role_data:set(RoleDunge#role_dunge{misc=AllMisc2}),
    ?ucast(#m_dunge_soul_select_toc{slots=Slots2});

handle(?DUNGE_SOUL_START, RoleSt) ->
    ensure_in_dunge(RoleSt),
    #role_st{spid=ScenePid} = RoleSt,
    scene:route(ScenePid, dunge_soul_dungeai, start),
    ?ucast(#m_dunge_soul_start_toc{});

handle({?DUNGE_SOUL_SUMMON, Tos}, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    ensure_in_dunge(RoleSt),
    #role_st{spid=ScenePid} = RoleSt,
    #m_dunge_soul_summon_tos{auto_summon=AutoSummon} = Tos,
    scene:route(ScenePid, dunge_soul_dungeai, config_summon, {RoleID, AutoSummon}),
    ?ucast(#m_game_error_toc{errno=?ERR_DUNGE_SOUL_SUMMON_AUTO_SUCC});

handle({?DUNGE_SWEEP, FloorID, Args}, RoleSt) ->
    #cfg_dunge_sweep{cost=Cost} = cfg_dunge:sweep(?SCENE_STYPE),
    Num = maps:get("boss", Args, 0),
    ?_check(Num >= 0 andalso Num =< cfg_dunge_wave:max(dunge_util:get_dunge(?SCENE_STYPE)),
        ?ERR_GAME_BAD_ARGS, [?DUNGE_SWEEP]),
    {Money, CostNum} = cfg_dunge_soul:summon_cost(),
    Cost2 = [{Money, CostNum*Num}|Cost],
    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    CfgCreeps = total_creeps(RoleLv, Num),
    {ok, Actor} = scene:get_actor(RoleSt#role_st.spid, RoleSt#role_st.role),
    Gain0 = calc_creep_drops(RoleLv, CfgCreeps, [], Actor),
    Gain = merge_gain(Gain0),
    {ok, _, Obtain} = role_bag:deal(Cost2, Gain, ?LOG_DUNGE_SWEEP, RoleSt),
    ?ucast(#m_dunge_sweep_toc{
        stype  = ?SCENE_STYPE,
        id     = dunge_util:get_dunge(?SCENE_STYPE),
        floor  = FloorID,
        reward = Obtain
    }).

summon_boss(RoleSt) ->
    ensure_in_dunge(RoleSt),
    #role_st{spid=ScenePid} = RoleSt,
    Cost = [cfg_dunge_soul:summon_cost()],
    Succ = fun() ->
        scene:route(ScenePid, dunge_soul_dungeai, summon_boss)
    end,
    try
        role_bag:cost(Cost, ?LOG_DUNGE_SOUL_SUMMON, Succ, RoleSt)
    catch
        throw:Err:_ ->
            scene:route(ScenePid, dunge_soul_dungeai, cancel_auto),
            throw(Err)
    end.

send_info(RoleID, SceneSt) ->
    DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
    ?ucast(RoleID, #m_dunge_info_toc{
        stype = SceneSt#scene_st.stype,
        id    = SceneSt#scene_st.dunge,
        info  = #{
            "cur_wave"     => DungeSt#dunge_st.wave,
            "max_wave"     => cfg_dunge_wave:max(SceneSt#scene_st.dunge),
            "prep_time"    => DungeSt#dunge_st.ptime,
            "end_time"     => SceneSt#scene_st.etime,
            "escape_creep" => maps:get(escape_creep, Opts, 0),
            "rest_creep"   => maps:get(rest_creep, Opts, 0),
            "auto_summon"  => maps:get(auto_summon, Opts, 0),
            "has_summon"   => maps:get(has_summon, Opts, 0)
        },
        drops = maps:get(drop, Opts, #{})
    }).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
morph_num(Slot, MorphID, Slots) ->
    Slots2 = maps:without([Slot], Slots),
    length(lists:filter(fun(ID) ->
        ID == MorphID
    end, maps:values(Slots2))).

ensure_in_dunge(RoleSt) ->
    ?_check(RoleSt#role_st.stype == ?SCENE_STYPE, ?ERR_DUNGE_NOT_IN).

total_creeps(RoleLv, BossNum) ->
    Max = cfg_dunge_wave:max(?SCENE_ID),
    CfgCreeps = [begin
        #cfg_dunge_wave{creeps = Creeps} = cfg_dunge_wave:find(?SCENE_ID, Wave, RoleLv),
        [begin
            CreepID = element(1, Creep),
            AttrID = element(4, Creep),
            {CreepID, AttrID}
        end || Creep <- Creeps]
    end || Wave <- lists:seq(1, Max)],
    BossID = element(1, cfg_dunge_soul_boss:find(RoleLv)),
    BossAttrID = element(4, cfg_dunge_soul_boss:find(RoleLv)),
    lists:duplicate(BossNum, {BossID, BossAttrID})
        ++
    lists:flatten(CfgCreeps).

%% 计算怪物掉落
calc_creep_drops(_RoleLv, [], Acc, _Actor) ->
    Acc;
calc_creep_drops(RoleLv, [{CreepID, AttrID}|T], Acc, Actor) ->
    Acc0 = creep_drop:calc(RoleLv, cfg_creep:find(CreepID)),
    {Exp, _} = creep_drop:exp(CreepID, AttrID, RoleLv, Actor),
    Acc2 = [{?ITEM_EXP, Exp}|Acc0] ++ Acc,
    calc_creep_drops(RoleLv, T, Acc2, Actor).

merge_gain(Gain) ->
    GainMap = lists:foldl(fun
        ({ItemID, Num, Bind}, Acc) ->
            ut_misc:maps_increase({ItemID, Bind}, Num, Acc);
        ({ItemID, Num}, Acc) ->
            ut_misc:maps_increase(ItemID, Num, Acc)
    end, #{}, Gain),
    lists:map(fun
        ({{ItemID, Bind}, Num}) ->
            {ItemID, Num, Bind};
        ({ItemID, Num}) ->
            {ItemID, Num}
    end, maps:to_list(GainMap)).
