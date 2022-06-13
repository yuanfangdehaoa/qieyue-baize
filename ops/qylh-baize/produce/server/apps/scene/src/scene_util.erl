%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_util).

-include("attr.hrl").
-include("buff.hrl").
-include("creep.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([reg_name/3]).
-export([get_state/0]).
-export([set_state/1]).
-export([kickout/1, kickout/2]).
-export([stop/1]).
-export([is_same_node/1]).
-export([is_local/1]).
-export([in_scene/0]).
-export([bc_to_scene/1]).
-export([bc_to_grid/2]).
-export([get_bc_roles/1]).
-export([get_bc_actids/1, get_bc_actids/2]).
-export([x_astrict/2]).
-export([y_astrict/2]).
-export([get_born/1]).
-export([get_reborn/1]).
-export([is_safe/2]).
-export([is_nearby/2, is_nearby/3]).
-export([walkable/2, walkable/3]).
-export([calc_degree/2]).
-export([calc_radian/2]).
-export([calc_distance/2]).
-export([calc_fly_cost/0]).
-export([p_line/1]).
-export([p_actor/1]).
-export([filter_buffs/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
reg_name(SceneID, RoomID, LineID) ->
    game_util:reg_name("scene", [SceneID, RoomID, LineID]).

-define(k_scene_state, scene_state).
get_state() ->
    get(?k_scene_state).

set_state(SceneSt) ->
    put(?k_scene_state, SceneSt).

%% 将玩家踢出场景
kickout(SceneSt) ->
    RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
    kickout(RoleIDs, SceneSt).

kickout(RoleIDs, SceneSt) ->
    lists:foreach(fun
        (RoleID) ->
            case scene_role:leave(RoleID, SceneSt) of
                {ok, Actor} ->
                    role_agent:kickscene(Actor#actor.pid, Actor);
                _ ->
                    ignore
            end
    end, RoleIDs).

%% 关闭场景
stop(Reason) ->
    erlang:send(self(), {stop, Reason}).

%% 是否同节点
is_same_node(SceneID) ->
    #cfg_scene{kind=Kind} = cfg_scene:find(SceneID),
    case Kind of
        ?SCENE_KIND_LOCAL -> cluster:is_local();
        ?SCENE_KIND_CROSS -> cluster:is_cross()
    end.

%% 是否本服地图
is_local(SceneID) ->
    #cfg_scene{kind=Kind} = cfg_scene:find(SceneID),
    Kind == ?SCENE_KIND_LOCAL.

%% 是否在场景中
in_scene() ->
    is_record(get_state(), scene_st).

%% 全场景广播
bc_to_scene(Toc) ->
    ?bcast(scene_actor:get_actids(?ACTOR_TYPE_ROLE), Toc).

%% 九宫格广播
bc_to_grid(Coord, Toc) ->
    ?bcast(scene_actor:get_actids(?ACTOR_TYPE_ROLE, Coord), Toc).

%% Actor 需要广播给哪些玩家
get_bc_roles(Actor) ->
    case Actor#actor.bctype of
        ?BCTYPE_GRID  ->
            scene_actor:get_actids(?ACTOR_TYPE_ROLE, Actor#actor.coord);
        ?BCTYPE_SCENE ->
            scene_actor:get_actids(?ACTOR_TYPE_ROLE)
    end.

%% 哪些 ActorID 需要广播给前端
get_bc_actids(Type) ->
    ActIDs = scene_actor:get_actids(bc)
          ++ scene_actor:get_actids(Type),
    lists:usort(ActIDs).

get_bc_actids(Type, Coord) ->
    ActIDs = scene_actor:get_actids(bc)
          ++ scene_actor:get_actids(Type, Coord),
    lists:usort(ActIDs).

%% 将坐标点限制在合法范围内
x_astrict(SceneID, X) ->
    min(scene_config:width(SceneID)*?TILE_WIDTH, max(0, X)).

y_astrict(SceneID, Y) ->
    min(scene_config:height(SceneID)*?TILE_HEIGHT, max(0, Y)).

%%-----------------------------------------------
%% @doc 获取出生点
-spec get_born(integer()) ->
    #p_coord{}.
%%-----------------------------------------------
get_born(SceneID) ->
    ut_rand:choose( scene_config:born(SceneID) ).


%%-----------------------------------------------
%% @doc 获取复活点
-spec get_reborn(integer()) ->
    #p_coord{}.
%%-----------------------------------------------
get_reborn(SceneID) ->
    ut_rand:choose( scene_config:reborn(SceneID) ).


%%-----------------------------------------------
%% @doc 是否安全区域
-spec is_safe(integer(), #p_coord{}) ->
    boolean().
%%-----------------------------------------------
is_safe(SceneID, Coord) ->
    #cfg_scene{safe=IsSafe} = cfg_scene:find(SceneID),
    case IsSafe of
        true  ->
            true;
        false ->
            {TX, TY} = ?tile(Coord),
            scene_config:is_safe(SceneID, TX, TY)
    end.


%%-----------------------------------------------
%% @doc 是否在附近
%% 在 Radius 范围内则返回 true
-spec is_nearby(#p_coord{} | #actor{}, #p_coord{} | #actor{}, integer()) ->
    boolean().
%%-----------------------------------------------
is_nearby(Coord1, Coord2) when is_record(Coord1, p_coord) ->
    is_nearby2(Coord1, Coord2, 450);
is_nearby(Actor1, Actor2) ->
    is_nearby2(Actor1#actor.coord, Actor2#actor.coord, 450).

is_nearby(Coord1, Coord2, Radius) when is_record(Coord1, p_coord) ->
    is_nearby2(Coord1, Coord2, Radius);
is_nearby(Actor1, Actor2, Radius) ->
    is_nearby2(Actor1#actor.coord, Actor2#actor.coord, Radius).


%%-----------------------------------------------
%% @doc 是否可走
-spec walkable(integer(), #p_coord{}) ->
    boolean().

-spec walkable(integer(), integer(), integer()) ->
    boolean().
%%-----------------------------------------------
walkable(SceneID, #p_coord{x=X, y=Y}) ->
    walkable(SceneID, X, Y).

walkable(SceneID, X, Y) ->
    {TX, TY} = ?tile(X, Y),
    scene_config:walkable(SceneID, TX, TY).


%%-----------------------------------------------
%% @doc 计算两个坐标间的角度(与 Y 轴的夹角)
-spec calc_degree(#p_coord{}, #p_coord{}) ->
    integer().
%%-----------------------------------------------
calc_degree(Coord1, Coord2) ->
    #p_coord{x=X1, y=Y1} = Coord1,
    #p_coord{x=X2, y=Y2} = Coord2,
    Degree = math:atan2(Y2-Y1, X2-X1) * 180 / math:pi(),
    ut_math:ceil(90 - Degree).


%%-----------------------------------------------
%% @doc 计算两个坐标间的弧度(与 Y 轴的夹角)
-spec calc_radian(#p_coord{}, #p_coord{}) ->
    integer().
%%-----------------------------------------------
calc_radian(Coord1, Coord2) ->
    #p_coord{x=X1, y=Y1} = Coord1,
    #p_coord{x=X2, y=Y2} = Coord2,
    math:pi() / 2 - math:atan2(Y2-Y1, X2-X1).


%%-----------------------------------------------
%% @doc 计算两个坐标间的距离
-spec calc_distance(#p_coord{}, #p_coord{}) ->
    number().
%%-----------------------------------------------
calc_distance(Coord1, Coord2) ->
    #p_coord{x=X1, y=Y1} = Coord1,
    #p_coord{x=X2, y=Y2} = Coord2,
    trunc(math:sqrt((X2-X1)*(X2-X1) + (Y2-Y1)*(Y2-Y1))).


%%-----------------------------------------------
%% @doc 计算使用小飞鞋的消耗
%%-----------------------------------------------
calc_fly_cost() ->
    VipLv = role_vip:get_level(),
    case cfg_vip_rights:find(?VIP_RIGHTS_FREE_FLY, VipLv, 0) == 1 of
        true  -> [];
        false -> [{?ITEM_SHOES, 1}]
    end.


p_line(Line) ->
    #p_line{
        id  = Line#line.id,
        num = Line#line.num
    }.

p_actor(Actor) when is_record(Actor, actor) ->
    PActor = #p_actor{
        uid   = Actor#actor.uid,
        name  = Actor#actor.name,
        type  = Actor#actor.type,
        coord = Actor#actor.coord,
        state = Actor#actor.state
    },
    case Actor#actor.type of
        ?ACTOR_TYPE_ROLE  ->
            PActor#p_actor{role=p_role(Actor)};
        ?ACTOR_TYPE_CREEP ->
            PActor#p_actor{creep=p_creep(Actor)};
        ?ACTOR_TYPE_DROP  ->
            PActor#p_actor{drop=p_drop(Actor)};
        ?ACTOR_TYPE_ROBOT  ->
            PActor#p_actor{role=p_role(Actor)}
    end;
p_actor(Actors) when is_list(Actors) ->
    lists:filtermap(fun
        (Actor) when is_record(Actor, actor) ->
            {true, p_actor(Actor)};
        (Actor) ->
            ?error("not actor: ~p", [Actor]),
            false
    end, Actors).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
p_role(Actor = #actor{attr=Attr, exargs=ExArgs}) ->
    ExKeys = ["melee_score"],
    #p_role{
        career = Actor#actor.career,
        gender = Actor#actor.gender,
        level  = Actor#actor.level,
        viplv  = Actor#actor.viplv,
        figure = Actor#actor.figure,
        guild  = Actor#actor.guild,
        gname  = Actor#actor.gname,
        hp     = ?_attr(Attr, ?ATTR_HP),
        hpmax  = ?_attr(Attr, ?ATTR_HPMAX),
        speed  = ?_attr(Attr, ?ATTR_SPEED),
        buffs  = filter_buffs(maps:values(Actor#actor.buffs)),
        power  = Actor#actor.power,
        pkmode = Actor#actor.pkmode,
        crime  = Actor#actor.crime,
        dir    = Actor#actor.dir,
        dest   = Actor#actor.dest,
        group  = Actor#actor.group,
        team   = Actor#actor.team,
        marry  = Actor#actor.marry,
        mname  = Actor#actor.mname,
        mtype  = Actor#actor.mtype,
        suid   = Actor#actor.suid,
        zoneid = Actor#actor.zoneid,
        ext    = maps:with(ExKeys, ExArgs),
        icon   = Actor#actor.icon
    }.

p_creep(Actor) ->
    #actor{buffs=Buffs, attr=Attr, exargs=ExArgs} = Actor,
    ExKeys = if
        Actor#actor.kind == ?CREEP_KIND_TOMB ->
            ["boss_reborn"];
        Actor#actor.rarity == ?CREEP_RARITY_BOSS ->
            ["belong_role", "belong_team"];
        Actor#actor.rarity == ?CREEP_RARITY_GUARD ->
            ["fission_id", "fission_x", "fission_y"];
        Actor#actor.rarity == ?CREEP_RARITY_BOMB ->
            ["disappear"];
        true ->
            []
    end,
    #p_creep{
        id    = Actor#actor.id,
        owner = Actor#actor.owner,
        hp    = ?_attr(Attr, ?ATTR_HP),
        hpmax = ?_attr(Attr, ?ATTR_HPMAX),
        speed = ?_attr(Attr, ?ATTR_SPEED),
        buffs = filter_buffs(maps:values(Buffs)),
        dir   = Actor#actor.dir,
        dest  = Actor#actor.dest,
        group = Actor#actor.group,
        level = Actor#actor.level,
        ext   = maps:with(ExKeys, ExArgs)
    }.

p_drop(Actor) ->
    #{drop:=Drop, unlock:=Unlock} = Actor#actor.exargs,
    #cfg_creep{mode=Mode} = cfg_creep:find(Drop#drop.creep),
    #p_drop{
        id     = Actor#actor.id,
        num    = Actor#actor.num,
        from   = Actor#actor.owner,
        mode   = Mode,
        belong = Drop#drop.belong,
        unlock = Unlock
    }.

filter_buffs(Buffs) ->
    lists:filtermap(fun
        (Buff) ->
            CfgBuff = cfg_buff:find(Buff#p_buff.id),
            case CfgBuff#cfg_buff.show == true of
                true  -> {true, Buff#p_buff{attrs=[]}};
                false -> false
            end
    end, Buffs).

is_nearby2(Coord1, Coord2, Radius) ->
    case ?tile(Coord1) == ?tile(Coord2) of
        true  ->
            true;
        false ->
            #p_coord{x=X1, y=Y1} = Coord1,
            #p_coord{x=X2, y=Y2} = Coord2,
            DiffX = X2 - X1,
            DiffY = Y2 - Y1,
            trunc(DiffX*DiffX + DiffY*DiffY) =< trunc(Radius*Radius)
    end.
