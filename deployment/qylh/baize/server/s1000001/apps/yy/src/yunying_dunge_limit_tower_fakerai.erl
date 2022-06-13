%% @author rong
%% @doc
-module(yunying_dunge_limit_tower_fakerai).

-include("btree.hrl").
-include("creep.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("proto.hrl").

%% API
-export([born/2]).
-export([move/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
born(Actor, SceneSt) ->
    creep_ai:born(Actor#actor{center=self}, SceneSt).

move(Actor, SceneSt) ->
    #actor{id=CreepID, coord=Coord1} = Actor,
    #cfg_creep{guard=Guard} = cfg_creep:find(CreepID),
    AIArgs = cfg_creep:aiargs(CreepID),
    #dunge_st{wave=Wave} = dunge_util:get_state(),
    case lists:keyfind(Wave, 1, AIArgs) of
        {_, X, Y} ->
            Coord2 = #p_coord{x=X, y=Y},
            case scene_util:is_nearby(Coord1, Coord2, Guard) of
                true  ->
                    ?SUCCESS;
                false ->
                    do_move(Actor, Coord2, SceneSt)
            end;
        false ->
            ?FAILURE
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_move(Actor, Dest, SceneSt) ->
    case creep_ai:move(Actor, 5, SceneSt) of
        ?FAILURE ->
            #scene_st{scene=SceneID} = SceneSt,
            #actor{uid=ActorID, coord=Coord} = Actor,
            case scene_path_stupid:find(SceneID, Coord, Dest) of
                {ok, Path} ->
                    creep_aipath:found(Actor, Dest, Path, SceneSt),
                    Actor2 = scene_actor:get_actor(ActorID),
                    creep_ai:move(Actor2, 5, SceneSt);
                false ->
                    ?FAILURE
            end;
        Result ->
            Result
    end.