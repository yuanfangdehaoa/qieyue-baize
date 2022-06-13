%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fight_filter).

-include("boss.hrl").
-include("game.hrl").
-include("creep.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").

%% API
-export([check_injure/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 是否可被攻击
check_injure(Atker, Defer, SceneSt) ->
    check_injure_by_state(Atker, Defer, SceneSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_injure_by_state(Atker, Defer, SceneSt) ->
    if
        Defer == ?nil ->
            ?err(?ERR_SCENE_NO_ACTOR);
        Defer#actor.state == ?nil ->
            ?err(?ERR_FIGHT_DEFER_DEAD);
        ?is_death(Defer#actor.state) ->
            ?err(?ERR_FIGHT_DEFER_DEAD);
        ?is_unbeat(Defer#actor.state) ->
            ?err(?ERR_FIGHT_DEFER_UNBEAT);
        ?is_afk(Defer) ->
            ?err(?ERR_FIGHT_DEFER_UNBEAT);
        true ->
            check_injure_by_group(Atker, Defer, SceneSt)
    end.

check_injure_by_group(Atker, Defer, SceneSt) ->
    if
        Atker#actor.group == Defer#actor.group,
        Atker#actor.group /= 0 ->
            ?err(?ERR_FIGHT_IN_SAME_GROUP);
        true ->
            check_injure_by_type(Atker, Defer, SceneSt)
    end.

check_injure_by_type(Atker, Defer, SceneSt) ->
    if
        ?is_role(Atker), ?is_role(Defer) ->
            check_injure_by_r2r(Atker, Defer, SceneSt);
        ?is_role(Atker), ?is_creep(Defer) ->
            check_injure_by_r2c(Atker, Defer, SceneSt);
        ?is_creep(Atker), ?is_role(Defer) ->
            check_injure_by_c2r(Atker, Defer, SceneSt);
        true ->
            ok
    end.

%% 人打人
check_injure_by_r2r(Atker, Defer, SceneSt) ->
    #scene_st{scene=SceneID} = SceneSt,
    NewbieLv = cfg_game:newbie(),
    if
        Atker#actor.level < NewbieLv ->
            ?err(?ERR_FIGHT_YOU_ARE_NEWBIE);
        Defer#actor.level < NewbieLv ->
            ?err(?ERR_FIGHT_PEER_IS_NEWBIE);
        true ->
            case scene_util:is_safe(SceneID, Atker#actor.coord) of
                true  ->
                    ?err(?ERR_FIGHT_YOU_ARE_IN_SAFE);
                false ->
                    case scene_util:is_safe(SceneID, Defer#actor.coord) of
                        true  ->
                            ?err(?ERR_FIGHT_PEER_IS_IN_SAFE);
                        false ->
                            check_injure_by_pkmode(Atker, Defer, SceneSt)
                    end
            end
    end.

check_injure_by_pkmode(Atker, Defer, SceneSt) ->
    % GrayCrime = cfg_game:gray_crime(),
    RealWhole = cfg_scene:whole(SceneSt#scene_st.scene),
    if
        % 和平模式
        Atker#actor.pkmode == ?PKMODE_PEACE ->
            ?err(?ERR_FIGHT_PEACE_MODE);
        % 强制模式
        Atker#actor.pkmode == ?PKMODE_ALLY,
        Atker#actor.guild > 0,
        Atker#actor.guild == Defer#actor.guild ->
            ?err(?ERR_FIGHT_IN_SAME_GUILD);
        Atker#actor.pkmode == ?PKMODE_ALLY,
        Atker#actor.team > 0,
        Atker#actor.team == Defer#actor.team ->
            ?err(?ERR_FIGHT_IN_SAME_TEAM);
        % % 队伍模式
        % Atker#actor.pkmode == ?PKMODE_TEAM,
        % Atker#actor.team > 0,
        % Atker#actor.team == Defer#actor.team ->
        %     ?err(?ERR_FIGHT_IN_SAME_TEAM);
        % % 帮派模式
        % Atker#actor.pkmode == ?PKMODE_GUILD,
        % Atker#actor.guild > 0,
        % Atker#actor.guild == Defer#actor.guild ->
        %     ?err(?ERR_FIGHT_IN_SAME_GUILD);
        % % 善恶模式
        % Atker#actor.pkmode == ?PKMODE_JUST,
        % Defer#actor.crime < GrayCrime ->
        %     ?err(?ERR_FIGHT_LOW_CRIME);
        % 全体模式下也不能攻击队友
        Atker#actor.pkmode == ?PKMODE_WHOLE,
        (not RealWhole),
        Atker#actor.team > 0,
        Atker#actor.team == Defer#actor.team ->
            ?err(?ERR_FIGHT_IN_SAME_TEAM);
        % 跨服模式
        Atker#actor.pkmode == ?PKMODE_CROSS,
        Atker#actor.suid == Defer#actor.suid ->
            ?err(?ERR_FIGHT_IN_SAME_SERVER);
        % 敌对模式
        Atker#actor.pkmode == ?PKMODE_ENEMY ->
            case lists:member(Defer#actor.suid, Atker#actor.hostile) of
                true  -> ok;
                false -> ?err(?ERR_FIGHT_IN_SAME_SERVER)
            end;
        true ->
            ok
    end.

%% 人打怪
check_injure_by_r2c(Atker, Defer, SceneSt) ->
    if
        not ?is_monst(Defer) ->
            ?err(?ERR_FIGHT_DEFER_UNBEAT);
        ?is_hunt(Defer) ->
            % 只有自己可以攻击寻宝怪
            case Atker#actor.uid == Defer#actor.owner of
                true  -> ok;
                false -> ?err(?ERR_FIGHT_NOT_YOUR_HUNT)
            end;
        ?is_boss(Defer) ->
            % 疲劳状态下不能攻击Boss
            case boss_server:is_tired(Atker, SceneSt) of
                true  -> ?err(?ERR_FIGHT_BOSS_TIRED);
                false -> ok
            end;
        ?is_timeboss(Defer) ->
            % 疲劳状态下不能攻击Boss
            case timeboss_server:is_tired(Atker, SceneSt) of
                true  -> ?err(?ERR_FIGHT_BOSS_TIRED);
                false -> ok
            end;
        ?is_siegeboss(Defer) ->
            % 疲劳状态下不能攻击Boss
            case siegewar_server:is_tired(Atker, SceneSt) of
                true  -> ?err(?ERR_FIGHT_BOSS_TIRED);
                false -> ok
            end;
        ?is_cgw_statue(Defer) ->
            case guild_crosswar:can_attack_statue(SceneSt) of
                true  -> ok;
                false -> ?err(?ERR_FIGHT_CGW_CRYSTAL_FIRST)
            end;
        true ->
            ok
    end.

%% 怪打人
check_injure_by_c2r(Atker, Defer, SceneSt) ->
    if
        ?is_boss(Atker) ->
            % 不能攻击疲劳状态下的玩家
            case boss_server:is_tired(Defer, SceneSt) of
                true  -> ?err(?ERR_FIGHT_BOSS_TIRED);
                false -> ok
            end;
        ?is_timeboss(Atker) ->
            % 不能攻击疲劳状态下的玩家
            case timeboss_server:is_tired(Defer, SceneSt) of
                true  -> ?err(?ERR_FIGHT_BOSS_TIRED);
                false -> ok
            end;
        ?is_siegeboss(Atker) ->
            % 不能攻击疲劳状态下的玩家
            case siegewar_server:is_tired(Defer, SceneSt) of
                true  -> ?err(?ERR_FIGHT_BOSS_TIRED);
                false -> ok
            end;
        true ->
            ok
    end.
