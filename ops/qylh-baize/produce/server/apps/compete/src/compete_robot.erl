%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(compete_robot).

-include("btree.hrl").
-include("creep.hrl").
-include("faker.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([summon/4]).
-export([can_reborn/2]).
-export([is_reborn/2]).
-export([reborn/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
summon(Actor, Index, FakerID, SceneSt) ->
    Robot  = init_actor(Actor, Index, FakerID, SceneSt),
    [RobotID] = creep_agent:add([Robot], SceneSt),
    Robot1 = scene_actor:get_actor(RobotID),
    Robot2 = buff_util:add_buffs(Robot1, [
        304100008, % 先定住3秒
        ?BUFF_ID_COMPETE_BATTLE_LIFE
    ]),
    Robot2.

can_reborn(Actor, _SceneSt) ->
    buff_util:get_value(Actor, ?BUFF_ID_COMPETE_BATTLE_LIFE) > 0.

is_reborn(Actor, _SceneSt) ->
    Life = cfg_compete_misc:find(battle_life, cluster:is_local()),
    buff_util:get_value(Actor, ?BUFF_ID_COMPETE_BATTLE_LIFE) < Life.

reborn(Actor, SceneSt) ->
    #actor{uid=ActorID, exargs=#{rival:=RivalID, attr:=InitAttr}} = Actor,
    ?ucast(RivalID, #m_scene_update_toc{del=[ActorID]}),

    scene_actor:del_actor(Actor#actor.uid),
    creep_agent:del_ai(Actor#actor.uid),
    creep_util:del_event(Actor#actor.uid),

    scene_actor:set_actor(Actor),

    Attr   = creep_attr:calc(Actor#actor{attr=InitAttr}, SceneSt),
    Actor2 = Actor#actor{
        coord    = Actor#actor.born,
        dest     = Actor#actor.born,
        initattr = Attr,
        attr     = Attr,
        endcds   = #{}
    },
    scene_actor:set_actor(Actor2),

    creep_agent:add_ai(Actor2),

    ?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
init_actor(Actor, Index0, FakerID, SceneSt) ->
	Index = ?_if(Index0 == 1, 2, 1),
	Coord = lists:nth(Index, scene_config:born(SceneSt#scene_st.scene)),
    #cfg_faker{gender=Gender, figure=Figure} = cfg_faker:find(FakerID),
    #faker{base=Base} = faker:get(FakerID),
    CreepID = case Gender of
        ?GENDER_MALE   -> 30411001;
        ?GENDER_FEMALE -> 30411002
    end,
    CfgCreep = cfg_creep:find(CreepID),
    Skills2  = maps:filter(fun
        (SkillID, _SkillLv) ->
            #cfg_skill{type=Type} = cfg_skill:find(SkillID),
            Type == ?SKILL_TYPE_ACTIVE
    end, Actor#actor.skills),
    Actor#actor{
        uid    = 0,
        id     = CreepID,
        type   = ?ACTOR_TYPE_ROBOT,
        gender = Gender,
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
        icon   = role_util:default_icon(Gender),
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
        aiargs = #{reborn=>2000},
        exargs = #{rival=>Actor#actor.uid, attr=>Actor#actor.attr},
        threat = #{},
        buffs  = #{},
        skills = Skills2,
        figure = maps:from_list(Figure)
    }.
