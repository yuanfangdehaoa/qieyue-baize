%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_god_creepai).

-include("attr.hrl").
-include("btree.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([send_info/2]).
-export([guard/2]).
-export([walkto_end/2]).
-export([escape/2]).
-export([update_barrier/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
send_info(_Actor, SceneSt) ->
    #dunge_st{roles=[RoleID]} = dunge_util:get_state(),
    dunge_god:send_info(RoleID, SceneSt),
    ?SUCCESS.

guard(Actor, _SceneSt) ->
    #dunge_st{opts=Opts} = dunge_util:get_state(),
    Barriers = maps:get(barriers, Opts, []),
    case Barriers == [] of
        true  ->
            ?FAILURE;
        false ->
            Actor2 = Actor#actor{enemy=hd(Barriers)},
            scene_actor:set_actor(Actor2),
            ?SUCCESS
    end.

walkto_end(Actor, SceneSt) ->
    #actor{state=State, aiargs=AIArgs, aidata=AIData, coord=Coord} = Actor,
    case ?is_death(State) of
        true  ->
            ?FAILURE;
        false ->
            Dest = maps:get(dest, AIArgs),
            case maps:is_key(path, AIData) of
                true  ->
                    case creep_ai:move(Actor, 5, SceneSt) == ?RUNNING of
                        true  -> ?RUNNING;
                        false -> walkto_end3(Actor, Dest, SceneSt)
                    end;
                false ->
                    case scene_util:is_nearby(Coord, Dest, 20) of
                        true  -> ?SUCCESS;
                        false -> walkto_end2(Actor, Dest, SceneSt)
                    end
            end
    end.

escape(Actor, _SceneSt) ->
    dunge_agent:event(hook_creep_escape, Actor),
    dunge_agent:event(hook_creep_dead, [?nil, Actor]),
    ?SUCCESS.

update_barrier(Actor, _SceneSt) ->
    #dunge_st{roles=[RoleID]} = dunge_util:get_state(),
    #actor{uid=ActorID, attr=Attr} = Actor,
    ?ucast(RoleID, #m_actor_updatehp_toc{
        uid   = ActorID,
        hp    = ?_attr(Attr,?ATTR_HP),
        hpmax = ?_attr(Attr,?ATTR_HPMAX)
    }),
    ?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
walkto_end2(Actor, Dest, SceneSt) ->
    case creep_aipath:find(Actor, Dest, SceneSt) of
        ?FAILURE ->
            % ?debug("~ts", ["找不到路"]),
            ?SUCCESS;
        ?SUCCESS ->
            % ?debug("~ts ~w", ["走到路点1", Dest]),
            ?SUCCESS;
        ?RUNNING ->
            Actor1 = scene_actor:get_actor(Actor#actor.uid),
            creep_ai:move(Actor1, 5, SceneSt)
    end.

walkto_end3(Actor, Dest, _SceneSt) ->
    case scene_util:is_nearby(Actor#actor.coord, Dest, 20) of
        true  -> ?SUCCESS;
        false -> ?FAILURE
    end.