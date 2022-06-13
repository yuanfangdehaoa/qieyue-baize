%% @author rong
%% @doc
-module(dunge_soul_creepai).

-include("dunge.hrl").
-include("game.hrl").
-include("btree.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("msgno.hrl").
-include("creep.hrl").

%% API
-export([notify_msg/2]).
-export([walk_to_end/2]).
-export([escape/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
notify_msg(Actor, _SceneSt) ->
    case ?is_elite(Actor) of
        true ->
            #cfg_creep{name=Name} = cfg_creep:find(Actor#actor.id),
            ?notify(scene_actor:get_actids(?ACTOR_TYPE_ROLE),
                ?MSG_DUNGE_SOUL_BOSS_BORN, [Name]);
        false ->
            ignore
    end,
    ?SUCCESS.

walk_to_end(Actor, SceneSt) ->
    #actor{aiargs = AIArgs} = Actor,
    WayPoints = maps:get(waypoint, AIArgs, []),
    IsDeath = ?is_death(Actor#actor.state),
    case {IsDeath, WayPoints} of
        {true, _} ->
            ?FAILURE;
        {false, []} ->
            % ?debug("~ts", ["走完"]),
            ?SUCCESS;
        {false, [Dest|T]} ->
            case creep_aipath:find(Actor, Dest, SceneSt) of
                ?FAILURE ->
                    % ?debug("~ts", ["找不到路"]),
                    ?SUCCESS;
                ?SUCCESS ->
                    % ?debug("~ts ~w", ["走到路点1", Dest]),
                    AIArgs2 = maps:put(waypoint, T, AIArgs),
                    walk_to_end(Actor#actor{aiargs = AIArgs2}, SceneSt);
                ?RUNNING ->
                    Actor1 = scene_actor:get_actor(Actor#actor.uid),
                    case creep_ai:move(Actor1, 9999, SceneSt) of
                        ?RUNNING -> ?RUNNING;
                        ?FAILURE -> ?RUNNING;
                        _ ->
                            % ?debug("~ts ~w", ["走到路点2", Dest]),
                            Actor2  = scene_actor:get_actor(Actor#actor.uid),
                            AIArgs2 = maps:put(waypoint, T, AIArgs),
                            walk_to_end(Actor2#actor{aiargs = AIArgs2}, SceneSt)
                    end
            end
    end.

escape(Actor, _SceneSt) ->
    % 删除的怪不会触发hook_creep_dead
    dunge_agent:event(hook_creep_escape, Actor),
    dunge_agent:event(hook_creep_dead, [?nil, Actor]),
    ?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------