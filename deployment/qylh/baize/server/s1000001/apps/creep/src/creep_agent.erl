%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(creep_agent).

-include("creep.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([init/1]).
-export([loop/1]).
-export([add/2]).
-export([del/2]).
-export([clear/1, clear/2]).
-export([event/3]).
-export([add_ai/1]).
-export([del_ai/1]).

-define(airef(ActorID), {creep_ai, ActorID}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(SceneID) ->
    #cfg_scene{type=Type} = cfg_scene:find(SceneID),
    case Type == ?SCENE_TYPE_CITY orelse Type == ?SCENE_TYPE_FIELD of
        true  ->
            lists:foreach(fun
                ({CreepID, Coord}) ->
                    init_actor(CreepID, Coord, #{})
            end, scene_config:creeps(SceneID));
        false ->
            lists:foreach(fun
                ({CreepID, Coord}) ->
                    #cfg_creep{auto=Auto} = cfg_creep:find(CreepID),
                    ?_if(Auto, init_actor(CreepID, Coord, #{}))
            end, scene_config:creeps(SceneID))
    end.
% init(_) ->
%     ignore.

loop(SceneSt) ->
    Events0 = creep_util:clr_events(),
    Events  = ?_if(Events0 == ?nil, [], Events0),
    lists:foreach(fun
        ({ActorID, Event, Args}) ->
            case scene_actor:get_actor(ActorID) of
                Actor when is_record(Actor, actor), Actor#actor.aiid > 0 ->
                    case Event == hook_clear of
                        true  ->
                            creep_ai:disappear(Actor, SceneSt);
                        false ->
                            creep_util:set_event(ActorID, Event, Args),
                            ut_btree:run(?airef(ActorID), Event)
                    end;
                _ ->
                    ignore
            end
    end, lists:reverse(Events)),

    Now = ut_time:seconds(),

    Actors1 = lists:filtermap(fun
        ({{k_actor,_}, Actor=#actor{etime=ETime}}) ->
            case is_integer(ETime) andalso ETime > 0 andalso Now >= ETime of
                true  ->
                    creep_agent:event(Actor, hook_timeout, ?nil),
                    del(Actor#actor.uid, SceneSt),
                    false;
                false ->
                    case cfg_creep:find(Actor#actor.id) of
                        #cfg_creep{reborn=Reborn} ->
                            case Reborn == 0 andalso Actor#actor.state == ?ACTOR_STATE_DEATH of
                                true  ->
                                    creep_ai:disappear(Actor, SceneSt),
                                    false;
                                false ->
                                    {true, Actor}
                            end;
                        _ ->
                            false
                    end
            end;
        (_) ->
            false
    end, get()),
    % 一次最多跑30个ai
    {Monsters, Others} = lists:partition(fun
        (Actor) ->
            Actor#actor.type == ?CREEP_RARITY_COMM
    end, Actors1),
    Monsters1 = lists:reverse(lists:keysort(#actor.prior, Monsters)),
    Monsters2 = lists:sublist(Monsters1, 30),
    lists:foreach(fun
        (#actor{uid=ActorID, aiid=AIID}) ->
            ?_if(AIID > 0, ut_btree:run(?airef(ActorID)))
    end, Others++Monsters2).


add(Creeps, SceneSt) ->
    do_add(Creeps, SceneSt, []).

%% 删除指定怪物
del(Creeps, SceneSt) when is_list(Creeps) ->
    [del(Creep, SceneSt) || Creep <- Creeps];
del(ActorID, SceneSt) when is_integer(ActorID) ->
    case scene_actor:get_actor(ActorID) of
        ?nil  -> ignore;
        Actor -> do_delete(Actor, SceneSt)
    end;
del(Actor, SceneSt) ->
    do_delete(Actor, SceneSt).


%% 清除所有怪(直接删掉，不走掉落流程)
clear(SceneSt) ->
    [do_delete(Actor, SceneSt) || {{k_actor,_}, Actor} <- get(), ?is_creep(Actor)].

%% 清除所有怪(会触发掉落流程)
clear(Killer, SceneSt) ->
    [begin
        Actor2 = Actor#actor{killer=Killer},
        do_delete(Actor2, SceneSt)
    end || {{k_actor,_}, Actor} <- get(), ?is_creep(Actor)].

%% 事件触发时，在下一个tick再执行对应的逻辑，以避免行为树之间互相循环调用
event(Actor, Event, Args) ->
    #actor{uid=ActorID, aiid=AIID} = Actor,
    case AIID > 0 of
        true  -> creep_util:add_event(ActorID, Event, Args);
        false -> ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_add([{CreepID, Coord} | T], SceneSt, Acc) when is_record(Coord, p_coord) ->
    Actor = init_actor(CreepID, Coord, #{}),
    do_add(T, SceneSt, [Actor#actor.uid | Acc]);

do_add([{CreepID, X, Y} | T], SceneSt, Acc) when is_integer(X) ->
    Coord = #p_coord{x=X, y=Y},
    Actor = init_actor(CreepID, Coord, #{}),
    do_add(T, SceneSt, [Actor#actor.uid | Acc]);

do_add([{CreepID, Coord, Opts} | T], SceneSt, Acc) when is_record(Coord, p_coord) ->
    Actor = init_actor(CreepID, Coord, Opts),
    do_add(T, SceneSt, [Actor#actor.uid | Acc]);

do_add([{CreepID, X, Y, Opts} | T], SceneSt, Acc) when is_integer(X) ->
    Coord = #p_coord{x=X, y=Y},
    Actor = init_actor(CreepID, Coord, Opts),
    do_add(T, SceneSt, [Actor#actor.uid | Acc]);

do_add([{CreepID, X, Y, AttrID, worldlv, AttCoef, DefCoef} | T], SceneSt, Acc) ->
    CreepLv = world_level:get_level(),
    Coord = #p_coord{x=X, y=Y},
    Actor = init_actor(CreepID, Coord, AttrID, CreepLv, AttCoef, DefCoef, #{}),
    do_add(T, SceneSt, [Actor#actor.uid | Acc]);

do_add([{CreepID, X, Y, AttrID, worldlv, AttCoef, DefCoef, Opts} | T], SceneSt, Acc) ->
    CreepLv = world_level:get_level(),
    Coord = #p_coord{x=X, y=Y},
    Actor = init_actor(CreepID, Coord, AttrID, CreepLv, AttCoef, DefCoef, Opts),
    do_add(T, SceneSt, [Actor#actor.uid | Acc]);

do_add([{CreepID, X, Y, AttrID, creeplv, AttCoef, DefCoef} | T], SceneSt, Acc) ->
    #cfg_creep{level=CreepLv} = cfg_creep:find(CreepID),
    Coord = #p_coord{x=X, y=Y},
    Actor = init_actor(CreepID, Coord, AttrID, CreepLv, AttCoef, DefCoef, #{}),
    do_add(T, SceneSt, [Actor#actor.uid | Acc]);

do_add([{CreepID, X, Y, AttrID, creeplv, AttCoef, DefCoef, Opts} | T], SceneSt, Acc) ->
    #cfg_creep{level=CreepLv} = cfg_creep:find(CreepID),
    Coord = #p_coord{x=X, y=Y},
    Actor = init_actor(CreepID, Coord, AttrID, CreepLv, AttCoef, DefCoef, Opts),
    do_add(T, SceneSt, [Actor#actor.uid | Acc]);

do_add([{CreepID, X, Y, AttrID, CreepLv, AttCoef, DefCoef} | T], SceneSt, Acc) ->
    Coord = #p_coord{x=X, y=Y},
    Actor = init_actor(CreepID, Coord, AttrID, CreepLv, AttCoef, DefCoef, #{}),
    do_add(T, SceneSt, [Actor#actor.uid | Acc]);

do_add([{CreepID, X, Y, AttrID, CreepLv, AttCoef, DefCoef, Opts} | T], SceneSt, Acc) ->
    Coord = #p_coord{x=X, y=Y},
    Actor = init_actor(CreepID, Coord, AttrID, CreepLv, AttCoef, DefCoef, Opts),
    do_add(T, SceneSt, [Actor#actor.uid | Acc]);

do_add([Actor | T], SceneSt, Acc) ->
    Actor2 = Actor#actor{uid=scene_actor:get_autoid()},
    scene_actor:set_actor(Actor2),
    add_ai(Actor2),
    do_add(T, SceneSt, [Actor2#actor.uid | Acc]);

do_add([], _SceneSt, Acc) ->
    lists:reverse(Acc).



init_actor(CreepID, Coord, Opts) ->
    #cfg_creep{level=CreepLv} = cfg_creep:find(CreepID),
    init_actor(CreepID, Coord, CreepID, CreepLv, ?PER_10000, ?PER_10000, Opts).

init_actor(CreepID, Coord, AttrID, CreepLv, AttCoef, DefCoef, Opts) ->
    ActorID  = scene_actor:get_autoid(),
    CfgCreep = cfg_creep:find(CreepID),
    Millis  = ut_time:milliseconds(),
    Skills2 = lists:foldl(fun
        (SkillID, Acc) ->
            #cfg_skill_level{cd=CD} = cfg_skill_level:find(SkillID, 1),
            maps:put(SkillID, Millis+CD, Acc)
    end, #{}, CfgCreep#cfg_creep.skills2),
    AIArgs1 = maps:get(aiargs, Opts, #{}),
    AIArgs2 = maps:merge(#{reborn=>CfgCreep#cfg_creep.reborn}, AIArgs1),
    SceneSt = scene_util:get_state(),
    ETime = case maps:find(etime, Opts) of
        {ok,N} ->
            N;
        error  ->
            Last = case cfg_creep:aiargs(CreepID) of
                ?nil -> 0;
                Args -> proplists:get_value(last, Args, 0)
            end,
            ?_if(Last == 0, 0, ut_time:seconds() + Last)
    end,
    Actor = #actor{
        uid    = ActorID,
        id     = CreepID,
        type   = ?ACTOR_TYPE_CREEP,
        bctype = CfgCreep#cfg_creep.bctype,
        spid   = self(),
        scene  = SceneSt#scene_st.scene,
        room   = SceneSt#scene_st.room,
        dunge  = SceneSt#scene_st.dunge,
        floor  = SceneSt#scene_st.floor,
        line   = SceneSt#scene_st.line,
        kind   = CfgCreep#cfg_creep.kind,
        rarity = CfgCreep#cfg_creep.rarity,
        name   = maps:get(name, Opts, CfgCreep#cfg_creep.name),
        state  = ?nil,
        dir    = ut_rand:random(-180, 180),
        born   = Coord,
        coord  = Coord,
        dest   = Coord,
        etime  = ETime,
        buffs  = #{},
        skills = Skills2,
        endcds = #{},
        level  = CreepLv,
        team   = maps:get(team, Opts, 0),
        guild  = maps:get(guild, Opts, 0),
        group  = maps:get(group, Opts, 0),
        owner  = maps:get(owner, Opts, 0),
        pkmode = maps:get(pkmode, Opts, ?PKMODE_PEACE),
        aiid   = creep_util:gen_ai(CreepID),
        aiargs = AIArgs2,
        aidata = #{},
        threat = #{},
        enemy  = 0,
        atkrad = CfgCreep#cfg_creep.volume,
        attrid = AttrID,
        atcoef = AttCoef,
        dfcoef = DefCoef,
        center = maps:get(center, Opts, born),
        exargs = maps:get(exargs, Opts, #{})
    },
    scene_actor:set_actor(Actor),
    add_ai(Actor),
    Actor.

add_ai(Actor) ->
    #actor{uid=ActorID, aiid=AIID} = Actor,
    case AIID > 0 of
        true  -> ut_btree:init(?airef(ActorID), cfg_creep_ai:find(AIID));
        false -> ignore
    end.

del_ai(ActorID) ->
    ut_btree:del(?airef(ActorID)).

do_delete(Actor=#actor{state=State}, SceneSt) ->
    case is_integer(State) andalso ?is_death(State) of
        true  ->
            ignore;
        false ->
            creep_ai:die(Actor, true, SceneSt),
            creep_agent:event(Actor, hook_clear, ?nil)
    end.
