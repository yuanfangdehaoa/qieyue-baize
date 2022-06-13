%%%=============================================================================
%%% @author z.hua
%%% @doc
%%% 九宫格管理
%%% @end
%%%=============================================================================

-module(scene_grid).

-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([init/1]).
-export([enter/1, enter/2]).
-export([leave/1, leave/2]).
-export([move/3]).
-export([get_actids/2]).
-export([del_actid/3]).
-export([get_around/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(SceneID) ->
    {MaxGX, MaxGY} = ?grid(
        scene_config:width(SceneID) * ?TILE_WIDTH,
        scene_config:height(SceneID) * ?TILE_HEIGHT
    ),
    Grids = [{GX,GY} || GX <- lists:seq(0,MaxGX),
                        GY <- lists:seq(0,MaxGY)],
    init_grids(Grids, MaxGX, MaxGY).

%% 进入九宫格(不通知周围玩家)
enter(Actor) ->
    enter_grid(Actor).

%% 进入九宫格(通知周围玩家)
enter(Actor, SceneSt) ->
    {ok, Around} = enter_grid(Actor),
    notify_someone_enter(Around, Actor, SceneSt).

%% 离开九宫格(不通知周围玩家)
leave(Actor) ->
    leave_grid(Actor).

%% 离开九宫格(通知周围玩家)
leave(Actor, SceneSt) ->
    {ok, Around} = leave_grid(Actor),
    notify_someone_leave(Around, Actor, SceneSt).

%% 移动
move(?nil, _Coord, _SceneSt) ->
    ignore;
move(Actor, Coord, SceneSt) ->
    case ?grid(Actor#actor.coord) == ?grid(Coord) of
        true  -> ok;
        false -> change_grid(Actor, Coord, SceneSt)
    end.

get_actids(Type, Coord) ->
    Grid = get_grid(?grid(Coord)),
    do_get_actids(Type, Grid#grid.around).

del_actid(ActorID, Type, Coord) ->
    Grid = get_grid(?grid(Coord)),
    lists:foreach(fun
        (GridID) ->
            leave_grid(ActorID, Type, GridID, ?BCTYPE_SCENE)
    end, Grid#grid.around).


get_around(GridID) ->
    case get_grid(GridID) of
        ?nil -> [];
        Grid -> Grid#grid.around
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
init_grids([GridID | T], MaxGX, MaxGY) ->
    set_grid(GridID, #grid{around=calc_around(GridID, MaxGX, MaxGY)}),
    init_grids(T, MaxGX, MaxGY);
init_grids([], _MaxGX, _MaxGY) ->
    ok.

% 7 8 9
% 4 5 6
% 1 2 3
calc_around({GX, GY}, MX, MY) ->
    Around0 = #{
        1 => {GX-1, GY-1}, 2 => {GX, GY-1}, 3 => {GX+1, GY-1},
        4 => {GX-1, GY}  , 5 => {GX, GY}  , 6 => {GX+1, GY},
        7 => {GX-1, GY+1}, 8 => {GX, GY+1}, 9 => {GX+1, GY+1}
    },
    Around1 = ?_if(GX == 0,  maps:without([1,4,7], Around0), Around0),
    Around2 = ?_if(GY == 0,  maps:without([1,2,3], Around1), Around1),
    Around3 = ?_if(GX == MX, maps:without([3,6,9], Around2), Around2),
    Around4 = ?_if(GY == MY, maps:without([7,8,9], Around3), Around3),
    maps:values(Around4).

enter_grid(Actor) ->
    #actor{uid=ActorID, type=Type, coord=Coord} = Actor,
    GridID = ?grid(Coord),
    #grid{around=Around, actids=GridActIDs} = get_grid(GridID),
    set_grid(GridID, #grid{
        around = Around,
        actids = GridActIDs#{
            all  => [ActorID | maps:get(all, GridActIDs, [])],
            Type => [ActorID | maps:get(Type, GridActIDs, [])]
        }
    }),

    AllActIDs  = scene_actor:get_actids(),
    AllActIDs1 = AllActIDs#{
        all  => [ActorID | maps:get(all, AllActIDs, [])],
        Type => [ActorID | maps:get(Type, AllActIDs, [])]
    },
    AllActIDs2 = case Actor#actor.bctype of
        ?BCTYPE_GRID  ->
            AllActIDs1;
        ?BCTYPE_SCENE ->
            AllActIDs1#{bc=>[ActorID | maps:get(bc, AllActIDs, [])]}
    end,
    scene_actor:set_actids(AllActIDs2),

    {ok, Around}.

leave_grid(Actor) ->
    #actor{uid=ActorID, type=Type, coord=Coord, bctype=BcType} = Actor,
    leave_grid(ActorID, Type, ?grid(Coord), BcType).

leave_grid(ActorID, Type, GridID, BcType) ->
    #grid{around=Around, actids=GridActIDs} = get_grid(GridID),

    % get的时候需要给一个默认值，否则上线删除离线机器人时会报错
    set_grid(GridID, #grid{
        around = Around,
        actids = GridActIDs#{
            all  => lists:delete(ActorID, maps:get(all, GridActIDs, [])),
            Type => lists:delete(ActorID, maps:get(Type, GridActIDs, []))
        }
    }),

    AllActIDs  = scene_actor:get_actids(),
    AllActIDs1 = AllActIDs#{
        all  => lists:delete(ActorID, maps:get(all, AllActIDs, [])),
        Type => lists:delete(ActorID, maps:get(Type, AllActIDs, []))
    },
    AllActIDs2 = case BcType of
        ?BCTYPE_GRID  ->
            AllActIDs1;
        ?BCTYPE_SCENE ->
            AllActIDs1#{bc=>lists:delete(ActorID, maps:get(bc, AllActIDs1, []))}
    end,


    scene_actor:set_actids(AllActIDs2),
    {ok, Around}.

change_grid(Actor, Coord, SceneSt) ->
    Actor2 = Actor#actor{coord=Coord},
    % 离开旧的九宫格
    {ok, LeaveAround} = leave_grid(Actor),
    % 进入新的九宫格
    {ok, EnterAround} = enter_grid(Actor2),
    Leave = LeaveAround -- EnterAround,
    Enter = EnterAround -- LeaveAround,
    ?_if(?is_role(Actor), notify_scene_update(Actor, Leave, Enter)),
    case Actor#actor.bctype == ?BCTYPE_SCENE of
        true  ->
            ignore;
        false ->
            notify_someone_leave(Leave, Actor, SceneSt),
            notify_someone_enter(Enter, Actor2, SceneSt)
    end.

notify_scene_update(#actor{uid=ActorID}, Leave, Enter) ->
    BC  = scene_actor:get_actids(bc),
    Add = [scene_util:p_actor(A) || A <- do_get_actors(all, Enter),
       A#actor.uid /= ActorID, (not lists:member(A#actor.uid, BC))
    ],
    Del = lists:delete(ActorID, do_get_actids(all, Leave)) -- BC,


    case Add == [] andalso Del == [] of
        true  -> ignore;
        false -> ?ucast(ActorID, #m_scene_update_toc{add=Add, del=Del})
    end.

notify_someone_enter(GridIDs, Actor, SceneSt) ->
    ?bcast(
        get_bc_roles(GridIDs, Actor, SceneSt),
        Actor#actor.uid,
        #m_scene_update_toc{add=[scene_util:p_actor(Actor)]}
    ).

notify_someone_leave(GridIDs, Actor, SceneSt) ->
    ?bcast(
        get_bc_roles(GridIDs, Actor, SceneSt),
        Actor#actor.uid,
        #m_scene_update_toc{del=[Actor#actor.uid]}
    ).

get_bc_roles(GridIDs, Actor, SceneSt) ->
    #scene_st{scene=SceneID} = SceneSt,
    case Actor#actor.bctype of
        ?BCTYPE_GRID  ->
            do_get_actids(?ACTOR_TYPE_ROLE, GridIDs);
        ?BCTYPE_SCENE ->
            #cfg_scene{type=Type} = cfg_scene:find(SceneID),
            if
                Type == ?SCENE_TYPE_ACT  orelse
                Type == ?SCENE_TYPE_BOSS orelse
                Type == ?SCENE_TYPE_DUNGE ->
                    scene_actor:get_actids(?ACTOR_TYPE_ROLE);
                true ->
                    do_get_actids(?ACTOR_TYPE_ROLE, GridIDs)
            end
    end.

do_get_actids(Type, GridIDs) ->
    lists:foldl(fun
        (GridID, Acc) ->
            Grid = get_grid(GridID),
            maps:get(Type, Grid#grid.actids, []) ++ Acc
    end, [], GridIDs).

do_get_actors(Type, GridIDs) ->
    lists:foldl(fun
        (GridID, Acc) ->
            Grid = get_grid(GridID),
            IDs  = maps:get(Type, Grid#grid.actids, []),
            [scene_actor:get_actor(ID) || ID <- IDs] ++ Acc
    end, [], GridIDs).

-define(k_grid, {k_grid, GridID}).
get_grid(GridID) ->
    get(?k_grid).

set_grid(GridID, Grid) ->
    put(?k_grid, Grid).

