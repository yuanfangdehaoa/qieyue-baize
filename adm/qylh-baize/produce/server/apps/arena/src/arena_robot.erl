%% @author rong
%% @doc
-module(arena_robot).

-include("proto.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("creep.hrl").
-include("game.hrl").
-include("table.hrl").

-export([summon/1]).

summon(SceneSt) ->
    #scene_st{opts=Opts} = SceneSt,
    Defender = maps:get(defender, Opts),
    Actor = init_actor(Defender),
    scene_actor:set_actor(Actor),
    creep_agent:add_ai(Actor).

init_actor(Defender) ->
    CreepID = creep_id(Defender),
    Coord = lists:last(scene_config:born(cfg_arena:dunge_id())),
    Actor = case Defender of
        #p_arena{creep=CreepID0} when is_integer(CreepID0), CreepID0 > 0 ->
            mirror_util:init_actor(Defender, CreepID);
        #p_arena{id=RoleID} ->
            {ok, Mirror} = mirror_manager:get_mirror(RoleID),
            mirror_util:init_actor(Mirror, CreepID)
    end,
    Actor#actor{born = Coord, coord = Coord, dest = Coord}.

creep_id(#p_arena{creep=CreepID}) when is_integer(CreepID), CreepID > 0 ->
    30371001;
creep_id(#p_arena{career=?CAREER_SWORDMAN}) ->
    30371002;
creep_id(#p_arena{career=?CAREER_KNIGHT}) ->
    30371003.
