%% @author rong
%% @doc 
-module(combat1v1_robot).

-include("scene.hrl").
-include("enum.hrl").
-include("creep.hrl").
-include("game.hrl").
-include("proto.hrl").
-include("combat1v1.hrl").
-include("faker.hrl").

-export([summon/2]).

summon(Actor, SceneSt) ->
    #scene_st{opts=Opts} = SceneSt,
    case maps:find(robot, Opts) of
        {ok, _DefenderID} ->
            RobotActor = init_actor(Actor, SceneSt),
            scene_actor:set_actor(RobotActor),
            creep_agent:add_ai(RobotActor);
        _ ->
            ignore
    end.

init_actor(Actor, SceneSt) ->
    CreepID = creep_id(Actor#actor.career),
    Coord = lists:last(scene_config:born(SceneSt#scene_st.scene)),
    FakerID = ut_rand:choose(cfg_faker:gender(Actor#actor.gender)),
    #faker{base=Base} = faker:get(FakerID),
    CfgCreep = cfg_creep:find(CreepID),
    Actor#actor{
        uid    = ?SCENE_ROBOT_ID,
        id     = CreepID,
        type   = ?ACTOR_TYPE_ROBOT,
        bctype = CfgCreep#cfg_creep.bctype,
        kind   = CfgCreep#cfg_creep.kind,
        rarity = CfgCreep#cfg_creep.rarity,
        name   = Base#p_role_base.name,
        state  = ?ACTOR_STATE_NORMAL,
        dir    = ut_rand:random(-180, 180),
        etime  = 0,
        born   = Coord, 
        coord  = Coord, 
        dest   = Coord, 
        icon   = role_util:default_icon(Actor#actor.gender),
        level  = max(1, trunc(ut_rand:random(90, 95) / 100 * Actor#actor.level)),
        power  = trunc(ut_rand:random(90, 95) / 100 * Actor#actor.power),
        endcds = #{},
        team   = 0,
        guild  = 0,
        gname  = "",
        marry  = 0,
        mname  = "",
        mtype  = 0,
        group  = 0,
        owner  = 0,
        pkmode = ?PKMODE_PEACE,
        crime  = 0,
        atkrad = CfgCreep#cfg_creep.volume,
        aiid   = creep_util:gen_ai(CreepID),
        aidata = #{},
        aiargs = #{},
        exargs = #{}
    }.

creep_id(?CAREER_SWORDMAN) ->
    30372001;
creep_id(?CAREER_KNIGHT) ->
    30372002.
