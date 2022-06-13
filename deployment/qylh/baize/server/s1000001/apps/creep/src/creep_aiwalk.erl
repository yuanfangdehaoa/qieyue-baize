%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(creep_aiwalk).

-include("btree.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("proto.hrl").

%% API
-export([dest/5]).
-export([path/3, path/4, path/5]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 找到朝 Dest 移动 Move 像素的点
dest(towards, Actor, Dest, {move, Move}, SceneSt) ->
	towards_finding(Actor#actor.coord, Dest, Move, SceneSt);
%% 找到朝 Dest 移动至离 Dest Offset 像素
dest(towards, Actor, Dest, {offset, Offset}, SceneSt) ->
	Dist = scene_util:calc_distance(Actor#actor.coord, Dest),
    Move = Dist - Offset,
    towards_finding(Actor#actor.coord, Dest, Move, SceneSt);
%% 找到背离 Coord Move 像素的点
dest(away, Actor, Coord, Move, SceneSt) ->
    #p_coord{x=X1, y=Y1} = Actor#actor.coord,
    #p_coord{x=X2, y=Y2} = Coord,
    Dist = scene_util:calc_distance(Actor#actor.coord, Coord),
	X3 = X1 + (X1 - X2) * Move / Dist,
    Y3 = Y1 + (Y1 - Y2) * Move / Dist,
    #p_coord{
        x = scene_util:x_astrict(SceneSt#scene_st.scene, X3),
        y = scene_util:y_astrict(SceneSt#scene_st.scene, Y3)
    };
%% 在半径为 Radius 的圆上随机找一个点
dest(around, Actor, ?nil, Radius, SceneSt) ->
    #p_coord{x=X1, y=Y1} = Actor#actor.coord,
    Radian = ut_rand:random(-180,180) * math:pi() / 180,
    X2 = X1 + Radius * math:cos(Radian),
    Y2 = Y1 + Radius * math:sin(Radian),
    #p_coord{
        x = scene_util:x_astrict(SceneSt#scene_st.scene, X2),
        y = scene_util:y_astrict(SceneSt#scene_st.scene, Y2)
    }.

%% 寻路
path(Actor, Dest, SceneSt) ->
    path(Actor, Dest, scene_path_stupid, 1000, SceneSt).

path(Actor, Dest, Mod, SceneSt) ->
    path(Actor, Dest, Mod, 1000, SceneSt).

path(Actor, Dest, Mod, Step, SceneSt = #scene_st{scene=SceneID}) ->
    case Mod:find(SceneID, Actor#actor.coord, Dest, Step) of
        {ok, []}   ->
            ?SUCCESS;
        {ok, Path} ->
            path_found(Actor, Dest, Path, SceneSt);
        false ->
            ?FAILURE
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 找出 Coord1, Coord2 之间，离 Coord1 Offset 像素的坐标
towards_finding(Coord1, Coord2, Offset, SceneSt) ->
	Dist = scene_util:calc_distance(Coord1, Coord2),
	#p_coord{x=X1, y=Y1} = Coord1,
    #p_coord{x=X2, y=Y2} = Coord2,
    X3 = X1 + (X2 - X1) * Offset / Dist,
    Y3 = Y1 + (Y2 - Y1) * Offset / Dist,
    #p_coord{
        x = scene_util:x_astrict(SceneSt#scene_st.scene, X3),
        y = scene_util:y_astrict(SceneSt#scene_st.scene, Y3)
    }.

path_found(Actor, Dest, Path, _SceneSt) ->
    #actor{uid=ActorID, coord=Coord, aidata=AIData} = Actor,
    AIData2 = maps:put(path, Path, AIData),
    Dir     = scene_util:calc_degree(Coord, Dest),
    Actor2  = Actor#actor{dir=Dir, dest=Dest, aidata=AIData2},
    scene_actor:set_actor(Actor2),
    ?bcast(
        scene_util:get_bc_roles(Actor),
        #m_scene_dest_toc{uid=ActorID, dest=Dest, dir=Dir, state=0}
    ),
    ?RUNNING.