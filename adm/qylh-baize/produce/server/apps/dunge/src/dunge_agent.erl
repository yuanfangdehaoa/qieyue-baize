%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_agent).

-include("game.hrl").
-include("dunge.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([init/1]).
-export([loop_events/0]).
-export([loop/0]).
-export([event/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(SceneSt) ->
    #scene_st{dunge=DungeID, stype=SType, opts=Opts} = SceneSt,
    #cfg_dunge{last=Last0, ai_id=AIID} = cfg_dunge:find(DungeID),
    #cfg_dunge_cd{prep=Prep} = cfg_dunge:cd(SType),
    Last = maps:get(dunge_last, Opts, Last0),
    NowSecs = ut_time:seconds(),
    dunge_util:set_state(#dunge_st{
        id    = DungeID,
        aiid  = AIID,
        ptime = NowSecs + Prep,
        wtime = 0,
        roles = [],
        over  = false,
        clear = false,
        stat  = false,
        star  = 0,
        wave  = 0,
        count = #{},
        kill  = #{},
        opts  = #{}
    }),
    case AIID > 0 of
        true  -> ut_btree:init(dunge_ai, cfg_dunge_ai:find(AIID));
        false -> ignore
    end,
    SceneSt#scene_st{stime=NowSecs, etime=NowSecs+Last}.

loop_events() ->
    Events0 = dunge_util:clr_events(),
    Events  = ?_if(Events0 == ?nil, [], Events0),
    lists:foreach(fun
        ({Event, Args}) ->
            run_event(Event, Args)
    end, lists:reverse(Events)).

loop() ->
    #dunge_st{aiid=AIID} = dunge_util:get_state(),
    case AIID > 0 of
        true  -> ut_btree:run(dunge_ai);
        false -> ignore
    end.

event(Event, Args) ->
    #dunge_st{aiid=AIID} = dunge_util:get_state(),
    case AIID > 0 of
        true when Event == pre_leave ->
            run_event(Event, Args);
        true  ->
            dunge_util:add_event(Event, Args);
        false ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
process_event(hook_enter, [Actor]) ->
    ?debug("hook_enter--------------:~w", [Actor#actor.uid]),
    SceneSt  = scene_util:get_state(),
    DungeSt  = #dunge_st{roles=RoleIDs, level=Level1} = dunge_util:get_state(),
    #actor{uid=ActorID, enter=EnterOpts, level=ActorLv} = Actor,
    RoleIDs2 = [ActorID | RoleIDs],
    Level2   = case Level1 == ?nil of
        true  -> maps:get(level, EnterOpts, ActorLv);
        false -> Level1
    end,
    dunge_util:set_state(DungeSt#dunge_st{roles=RoleIDs2, level=Level2}),
    enter_notify(Actor, DungeSt, SceneSt);
process_event(hook_leave, [Actor = #actor{uid=RoleID}]) ->
    #scene_st{stype=SType, dunge=Dunge, floor=Floor} = scene_util:get_state(),
    #dunge_st{clear=IsClear, star=BitStar} = dunge_util:get_state(),
    Times = dunge_util:merge_times(Actor),
    List  = lists:seq(1, Times),
    lists:foreach(fun
        (_) ->
            role_event:event(RoleID, ?EVENT_DUNGE_ENTER, {SType, Dunge, Floor})
    end, List),
    ?debug("hook_leave-------------~w", [{RoleID, IsClear, BitStar, Times}]),
    case IsClear of
        true  ->
            Star = dunge_util:normal_star(BitStar),
            lists:foreach(fun
                (_) ->
                    role_event:event(RoleID, ?EVENT_DUNGE_FLOOR, {SType, Dunge, Floor}),
                    role_event:event(RoleID, ?EVENT_DUNGE_STAR, {SType, Dunge, Floor, Star})
            end, List);
        false ->
            ignore
    end;
process_event(hook_creep_dead, [_Atker, Defer]) ->
    DungeSt  = dunge_util:get_state(),
    #dunge_st{wave=Wave, count=Count, kill=Kill} = DungeSt,
    DungeSt1 = DungeSt#dunge_st{kill=ut_misc:maps_increase(Defer#actor.id, 1, Kill)},
    DungeSt2 = case maps:get(wave, Defer#actor.aiargs, ?nil) == Wave of
        true  -> DungeSt1#dunge_st{count=ut_misc:maps_increase(Wave, -1, Count)};
        false -> DungeSt1
    end,
    dunge_util:set_state(DungeSt2);
process_event(hook_relogin, [Actor]) ->
    SceneSt = scene_util:get_state(),
    DungeSt = dunge_util:get_state(),
    enter_notify(Actor, DungeSt, SceneSt),
    Mod = scene_router:route(SceneSt),
    case erlang:function_exported(Mod, send_info, 2) of
        true  -> Mod:send_info(Actor#actor.uid, SceneSt);
        false -> ignore
    end;
process_event(_Event, _Args) ->
    ok.

enter_notify(Actor, DungeSt, SceneSt) ->
    ?ucast(Actor#actor.uid, #m_dunge_enter_toc{
        stype = SceneSt#scene_st.stype,
        id    = SceneSt#scene_st.dunge,
        ptime = DungeSt#dunge_st.ptime,
        etime = SceneSt#scene_st.etime,
        floor = SceneSt#scene_st.floor
    }).

run_event(Event, Args) ->
    process_event(Event, Args),
    dunge_util:set_event(Event, Args),
    ut_btree:run(dunge_ai, Event).
