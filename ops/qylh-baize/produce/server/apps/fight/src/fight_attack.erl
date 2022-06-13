%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fight_attack).

-include("buff.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("fight.hrl").
-include("skill.hrl").
-include("scene.hrl").
-include("creep.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("msgno.hrl").
-include("proto.hrl").

%% API
-export([start/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start(Attack, SceneSt) when Attack#attack.major == 0 ->
    bc_result(Attack, ?nil, [], SceneSt),
    ok;
start(Attack, SceneSt) ->
    Atker = scene_actor:get_actor(Attack#attack.atker),
    check_attack(Atker, Attack, SceneSt),
    Major = get_major(Atker#actor.uid, Attack#attack.unit, Attack#attack.major),
    check_injure(Atker, Major, Attack, SceneSt),
    Defers = fight_select:select(Atker, Major, Attack, SceneSt),
    Fight  = #fight{atker=Atker, atk_attr=#{}, major_id=Attack#attack.major},
    #skill{aim=Aim} = Attack#attack.skill,
    Fight2 = if
        Aim == ?SKILL_AIM_SELF;
        Aim == ?SKILL_AIM_ALLY ->
            fight_skill:assist(Defers, Fight, Attack, SceneSt);
        true ->
            fight_skill:attack(Defers, Fight, Attack, SceneSt)
    end,
    #fight{atker=Atker2, damages=Damages, results=Results} = Fight2,
    Atker3 = Atker2#actor{dir=Attack#attack.dir},
    scene_actor:set_actor(Atker3),
    bc_result(Attack, Atker3#actor.coord, Damages, SceneSt),
    hook_fight(Results, SceneSt),
    ok.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_attack(Atker, Attack, _SceneSt) ->
    ?_check(Atker /= ?nil, ?ERR_SCENE_NO_ACTOR),
    #skill{id=SkillID} = Attack#attack.skill,
    #cfg_skill{ctrl=Controllable} = cfg_skill:find(SkillID),
    ok = fight_util:check_action(Atker, Controllable).

check_injure(_Atker, _Major, Attack, _SceneSt) when (Attack#attack.skill)#skill.aim == ?SKILL_AIM_SELF ->
    ok;
check_injure(Atker, ?nil, Attack, _SceneSt) ->
    #attack{coord=Coord, skill=#skill{dist=Dist}} = Attack,
    InArea = scene_util:is_nearby(Atker#actor.coord, Coord, Dist+300),
    ?_check(InArea, ?ERR_FIGHT_NOT_IN_AREA);
check_injure(Atker, Major, Attack, SceneSt) when Attack#attack.unit == ?ATTACK_UNIT_PET ->
    #skill{id=SkillID} = Attack#attack.skill,
    case role_pet:check_skill(SkillID) of
        true  -> ?_check(?is_petmorph(Atker#actor.state), ?ERR_FIGHT_SKILL_NOT_SUPERM);
        false -> ok
    end,
    ok = fight_filter:check_injure(Atker, Major, SceneSt);
check_injure(Atker, Major, Attack, SceneSt) ->
    ok = fight_filter:check_injure(Atker, Major, SceneSt),
    Dist2  = case ?is_creep(Atker) of
        true  -> Atker#actor.atkrad;
        false -> (Attack#attack.skill)#skill.dist
    end,
    InArea = scene_util:is_nearby(Atker, Major, Dist2+600),
    ?_check(InArea, ?ERR_FIGHT_NOT_IN_AREA).

bc_result(Attack, AtkerCoord, Damages, SceneSt) ->
    Toc = #m_fight_attack_toc{
        atkid = Attack#attack.atker,
        unit  = Attack#attack.unit,
        skill = (Attack#attack.skill)#skill.id,
        level = (Attack#attack.skill)#skill.level,
        cd    = Attack#attack.endcd,
        dir   = Attack#attack.dir,
        dmgs1 = lists:reverse([fight_util:p_damage(Dmg) || Dmg <- Damages]),
        seq   = Attack#attack.seq,
        combo = 0,
        coord = AtkerCoord
    },
    case Damages == [] of
        true  ->
            ?ucast(Attack#attack.atker, Toc);
        false ->
            Around = case ?is_dunge_scene(SceneSt) of
                true  ->
                    #cfg_dunge{type=DungeType} = cfg_dunge:find(SceneSt#scene_st.dunge),
                    case DungeType == ?DUNGE_TYPE_GUILD of
                        true  ->
                            calc_around(Damages);
                        false ->
                            scene_actor:get_actids(?ACTOR_TYPE_ROLE)
                    end;
                false ->
                    calc_around(Damages)
            end,
            [?ucast(RoleID, Toc) || RoleID <- Around]
    end.

calc_around(Damages) ->
    All = lists:foldl(fun
        (#damage{coord=Coord, bctype=BcType}, Acc) ->
            Around = case BcType of
                ?BCTYPE_GRID  ->
                    scene_actor:get_actids(?ACTOR_TYPE_ROLE, Coord);
                ?BCTYPE_SCENE ->
                    scene_actor:get_actids(?ACTOR_TYPE_ROLE)
            end,
            Around ++ Acc
    end, [], Damages),
    lists:usort(All).

hook_fight([{Atker, Defer0, Damage} | T], SceneSt) ->
    #damage{value=DmgVal, hp=NewHp} = Damage,
    try
        scene_hook:hook_fight(Atker, Defer0, DmgVal, SceneSt),
        % 副本结束时会直接清掉场景中的怪，所以这里重新获取一下actor
        Defer = scene_actor:get_actor(Defer0#actor.uid),
        case ?is_creep(Defer) orelse ?is_faker(Defer) of
            true  -> creep_agent:event(Defer, hook_injure, {Atker,DmgVal,NewHp});
            false -> ignore
        end,
        case scene_actor:get_actor(Defer0#actor.uid) of
            ?nil  ->
                ok;
            Defer ->
                case ?is_death(Defer#actor.state) of
                    true when ?is_creep(Defer) ->
                        creep_ai:die(Defer, SceneSt);
                    true when ?is_robot(Defer) ->
                        creep_ai:die(Defer, SceneSt);
                    true when ?is_role(Defer) ->
                        scene_hook:hook_role_dead(Atker, Defer, SceneSt),
                        scene_hook:hook_dead_notify(Atker, Defer, SceneSt),
                        ?_if(?is_role(Atker), dead_tv(Atker, Defer, SceneSt));
                    _ ->
                        ignore
                end
        end

    catch Class:Reason:Stacktrace ->
        ?error("hook fight error: ~w", [{Class, Reason, Stacktrace}])
    end,
    hook_fight(T, SceneSt);
hook_fight([], _SceneSt) ->
    ok.

get_major(_AtkID, _Unit, ?nil) ->
    ?nil;
get_major(AtkID, Unit, MajorID) ->
    Major = scene_actor:get_actor(MajorID),
    case Major == ?nil of
        true  ->
            ?_if(
                Unit == ?ATTACK_UNIT_ROLE,
                ?ucast(AtkID, #m_game_error_toc{
                    errno = ?ERR_SCENE_NO_ACTOR,
                    args  = [ut_conv:to_list(MajorID)]
                })
            ),
            ?nil;
        false ->
            case ?is_death(Major#actor.state) of
                true  ->
                    ?_if(
                        Unit == ?ATTACK_UNIT_ROLE,
                        ?ucast(AtkID, #m_game_error_toc{
                            errno = ?ERR_SCENE_NO_ACTOR,
                            args  = [ut_conv:to_list(MajorID)]
                        })
                    ),
                    ?nil;
                false ->
                    Major
            end
    end.

dead_tv(Atker, Defer, SceneSt) ->
    #scene_st{scene=SceneID, type=SceneType} = SceneSt,
    #actor{uid=AtkID, name=AtkName, guild=AtkGuild, gname=AtkGName, gpost=AtkGPost} = Atker,
    #actor{uid=DefID, name=DefName, guild=DefGuild, gname=DefGName, gpost=DefGPost} = Defer,
    if
        (SceneType == ?SCENE_TYPE_FIELD orelse SceneType == ?SCENE_TYPE_BOSS),
        AtkGuild > 0, DefGuild > 0,
        (DefGPost == ?GUILD_POST_CHIEF orelse DefGPost == ?GUILD_POST_VICE) ->
            #cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
            ?notify(?MSG_GUILD_KILL, [
                AtkGName,
                cfg_guild_post:find(AtkGPost),
                {role,AtkID,AtkName},
                SceneName,
                DefGName,
                cfg_guild_post:find(DefGPost),
                {role,DefID,DefName}
            ]);
        true ->
            ignore
    end.