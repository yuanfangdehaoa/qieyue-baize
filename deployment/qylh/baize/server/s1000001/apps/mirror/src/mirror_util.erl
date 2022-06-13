%% @author rong
%% @doc
-module(mirror_util).

-include("scene.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("creep.hrl").
-include("proto.hrl").

-export([init_actor/2]).

init_actor(Mirror, CreepID) when is_record(Mirror, mirror) ->
    CfgCreep = cfg_creep:find(CreepID),
    #actor{
        uid    = Mirror#mirror.id,
        id     = CreepID,
        type   = ?ACTOR_TYPE_ROBOT,
        bctype = CfgCreep#cfg_creep.bctype,
        kind   = CfgCreep#cfg_creep.kind,
        rarity = CfgCreep#cfg_creep.rarity,
        name   = Mirror#mirror.name,
        state  = ?ACTOR_STATE_NORMAL,
        dir    = ut_rand:random(-180, 180),
        etime  = 0,
        buffs  = Mirror#mirror.buffs,
        skills = Mirror#mirror.skills,
        endcds = #{},
        attr   = Mirror#mirror.attr,
        power  = Mirror#mirror.power,
        level  = Mirror#mirror.level,
        career = Mirror#mirror.career,
        gender = Mirror#mirror.gender,
        viplv  = Mirror#mirror.viplv,
        figure = Mirror#mirror.figure,
        team   = 0,
        guild  = Mirror#mirror.guild,
        gname  = Mirror#mirror.gname,
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
        exargs = #{},
        suid   = game_env:get_suid(),
        zoneid = 0
    };
init_actor(Arena, CreepID) when is_record(Arena, p_arena) ->
    CfgCreep = cfg_creep:find(CreepID),
    #actor{
        uid    = Arena#p_arena.id,
        id     = CreepID,
        type   = ?ACTOR_TYPE_ROBOT,
        bctype = CfgCreep#cfg_creep.bctype,
        kind   = CfgCreep#cfg_creep.kind,
        rarity = CfgCreep#cfg_creep.rarity,
        name   = Arena#p_arena.name,
        state  = ?ACTOR_STATE_NORMAL,
        dir    = ut_rand:random(-180, 180),
        etime  = 0,
        buffs  = #{},
        skills = #{},
        endcds = #{},
        attrid = Arena#p_arena.creep,
        atcoef = 10000,
        dfcoef = 10000,
        power  = Arena#p_arena.power,
        level  = Arena#p_arena.rank,
        career = Arena#p_arena.career,
        gender = Arena#p_arena.gender,
        viplv  = 0,
        figure = Arena#p_arena.figure,
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
        exargs = #{},
        threat = #{},
        suid   = game_env:get_suid(),
        zoneid = 0
    }.
