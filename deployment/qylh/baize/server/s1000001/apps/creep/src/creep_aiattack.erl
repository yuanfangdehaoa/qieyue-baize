%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(creep_aiattack).

-include("btree.hrl").
-include("creep.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([prepare/1]).
-export([attack/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
prepare(Actor) when ?is_silent(Actor#actor.state) ->
    0;
prepare(Actor) ->
    #actor{id=CreepID, endcds=EndCDs, atkcd=AtkCD, skills=Skills} = Actor,
    NowMillis = ut_time:milliseconds(),
    case NowMillis >= AtkCD of
        true  ->
            #cfg_creep{skills1=Skills1, skills2=Skills2} = cfg_creep:find(CreepID),
            case is_map(Skills) andalso maps:size(Skills) > 0 of
                true  ->
                	SkillList = lists:reverse( maps:keys(Skills) ),
                    select_boss_skill(SkillList, EndCDs, NowMillis);
                false ->
                    SkillID = select_boss_skill(Skills2, EndCDs, NowMillis),
                    case SkillID == 0 of
                        true  -> select_normal_skill(Skills1);
                        false -> SkillID
                    end
            end;
        false ->
            0
    end.


attack(Actor, _Enemy, _SkillID, _SceneSt) when ?is_silent(Actor#actor.state) ->
    % ?debug("~ts:~w", ["被沉默了", Actor#actor.id]),
    ?FAILURE;
attack(Actor, Enemy, SkillID, _SceneSt) when ?is_robot(Actor), ?is_afk(Actor) ->
    % ?debug("~ts:~w", ["攻击", {Actor#actor.id, SkillID}]),
    Skill = fight_util:make_skill(SkillID, 1),
    #actor{id=CreepID, coord=Coord1, endcds=EndCDs} = Actor,
    CfgCreep = cfg_creep:find(CreepID),
    #cfg_creep{atklag=AtkLag, volume=Volume} = CfgCreep,
    #actor{uid=EnemyID, coord=Coord2} = Enemy,
    #cfg_skill_level{play=PlayCD} = cfg_skill_level:find(SkillID, 1),
    #skill{cd=SkillCD, dist=Dist} = Skill,

    Attack = #attack{
        atker = Actor#actor.uid,
        major = EnemyID,
        unit  = ?ATTACK_UNIT_ROLE,
        skill = Skill#skill{dist=Dist+Volume},
        dir   = scene_util:calc_degree(Coord1, Coord2),
        endcd = 0,
        seq   = 0
    },
    Toc = #m_fight_attack_toc{
        atkid = Attack#attack.atker,
        unit  = Attack#attack.unit,
        skill = (Attack#attack.skill)#skill.id,
        level = (Attack#attack.skill)#skill.level,
        cd    = Attack#attack.endcd,
        dir   = Attack#attack.dir,
        dmgs1 = [],
        combo = 0,
        dmgs2 = [],
        seq   = Attack#attack.seq
    },
    scene_util:bc_to_grid(Actor#actor.coord, Toc),
    Millis  = ut_time:milliseconds(),
    AtkCD   = ?_if(PlayCD > 0, PlayCD+Millis, AtkLag+Millis),
    EndCDs2 = maps:put(SkillID, SkillCD+Millis, EndCDs),
    Actor2  = Actor#actor{atkcd=AtkCD, endcds=EndCDs2},
    scene_actor:set_actor(Actor2),
    ?SUCCESS;
attack(Actor, Enemy, SkillID, SceneSt) ->
    % ?debug(?is_robot(Actor), "~ts:~w", ["攻击", {Actor#actor.id, SkillID}]),
    Attack = make_attack(Actor, Enemy, SkillID),
	case catch fight_attack:start(Attack, SceneSt) of
        ok ->
        	case scene_actor:get_actor(Actor#actor.uid) of
        		?nil   ->
        			?FAILURE;
        		Actor1 ->
        			post_attack(Actor1, Attack, SceneSt),
                    ?SUCCESS
        	end;
        _R ->
            % ?debug("~ts:~p", ["攻击失败", _R]),
            ?FAILURE
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
select_boss_skill([SkillID | T], EndCDs, NowMillis) ->
    #cfg_skill{type=Type, group=Group} = cfg_skill:find(SkillID),
    case Type == ?SKILL_TYPE_ACTIVE of
        true when Group == ?SKILL_GROUP_NORMAL;
                  Group == ?SKILL_GROUP_WAKE;
                  Group == ?SKILL_GROUP_OTHER ->
            EndMillis = maps:get(SkillID, EndCDs, 0),
            case NowMillis >= EndMillis of
                true  -> SkillID;
                false -> select_boss_skill(T, EndCDs, NowMillis)
            end;
        _ ->
            select_boss_skill(T, EndCDs, NowMillis)
    end;
select_boss_skill([], _EndCDs, _NowMillis) ->
    0.

select_normal_skill([]) ->
    0;
select_normal_skill(SkillWtList) ->
    ut_rand:weight(SkillWtList).

make_attack(Actor, Enemy, SkillID) ->
    Skill  = fight_util:make_skill(SkillID, 1),
	Attack = #attack{
        atker = Actor#actor.uid,
        unit  = ?ATTACK_UNIT_CREEP,
        skill = Skill,
        endcd = 0,
        seq   = 0,
        time  = ut_time:milliseconds()
    },
    case Enemy == ?nil of
        true  ->
            Major = case Skill#skill.aim == ?SKILL_AIM_SELF of
                true  -> Actor#actor.uid;
                false -> ?nil
            end,
            Attack#attack{major=Major, dir=Actor#actor.dir};
        false ->
            #actor{uid=EnemyID, coord=Coord2} = Enemy,
            Dir = scene_util:calc_degree(Actor#actor.coord, Coord2),
            Attack#attack{major=EnemyID, dir=Dir}
    end.

post_attack(Actor, Attack, _SceneSt) ->
	#actor{id=CreepID, coord=Coord1, endcds=EndCDs} = Actor,
	#cfg_creep{atklag=AtkLag} = cfg_creep:find(CreepID),
	#skill{id=SkillID, cd=SkillCD} = Attack#attack.skill,
	#cfg_skill_level{play=PlayCD} = cfg_skill_level:find(SkillID, 1),
    Millis  = ut_time:milliseconds(),
    AtkCD   = ?_if(PlayCD > 0, PlayCD+Millis, AtkLag+Millis),
    EndCDs2 = maps:put(SkillID, SkillCD+Millis, EndCDs),
    Actor2  = Actor#actor{atkcd=AtkCD, endcds=EndCDs2, dest=Coord1},
    scene_actor:set_actor(Actor2),
    Actor2.