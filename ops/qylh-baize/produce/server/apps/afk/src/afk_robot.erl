%% @author rong
%% @doc
-module(afk_robot).

-include_lib("stdlib/include/ms_transform.hrl").
-include("table.hrl").
-include("scene.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("game.hrl").
-include("afk.hrl").
-include("creep.hrl").

-export([update_role_pos/1]).
-export([del_robot/1]).
-export([enter/2]).
-export([timeout/1]).
-export([add_new_robot/1]).
-export([init_actor/1]).

% 同步玩家位置到挂机点
update_role_pos(#role_st{role=RoleID}) ->
    case ets:lookup(?ETS_ROBOT, RoleID) of
        [#robot{scene=SceneID, coord=Coord}] ->
            ?debug("update role pos ~w", [RoleID]),
            RoleSite = role_data:get(?DB_ROLE_SITE),
            Site = role_agent:make_site(SceneID, 0, Coord),
            role_data:set(RoleSite#role_site{cur=Site});
        _ ->
            ignore
    end.

del_robot(RoleID) ->
    case ets:lookup(?ETS_ROBOT, RoleID) of
        [#robot{robot_id=RobotID, scene=SceneID, creep=CreepID}] ->
            ets:delete(?ETS_ROBOT, RoleID),
            ?debug("del robot, role_id: ~w, robot_id ~w", [RoleID, RobotID]),
            is_integer(RobotID) andalso creep:del(SceneID, 0, ?MAIN_LINE, RobotID),
            is_integer(RobotID) andalso afk_server:add_new_robot(CreepID);
        _ ->
            ignore
    end.

enter(RoleID, EndTime) ->
    {ok, #role_cache{level=Level}} = role:get_cache(RoleID),
    case find_afk_place(Level) of
        {CreepID, SceneID, Coord} ->
            Robot = #robot{
                role_id=RoleID, etime=EndTime, scene=SceneID,
                creep=CreepID, coord=Coord, robot_id=pendding
            },
            ets:insert(?ETS_ROBOT, Robot),
            add_robot(Robot);
        _ ->
            ignore
    end.

timeout(RoleID) ->
    case ets:lookup(?ETS_ROBOT, RoleID) of
        [#robot{scene=SceneID, creep=CreepID, robot_id=RobotID} = Robot] ->
            ets:insert(?ETS_ROBOT, Robot#robot{robot_id=timeout}),
            % ?debug("timeout del robot, role_id: ~w, robot_id ~w", [RoleID, RobotID]),
            is_integer(RobotID) andalso creep:del(SceneID, 0, ?MAIN_LINE, RobotID),
            is_integer(RobotID) andalso afk_server:add_new_robot(CreepID);
        _ ->
            ignore
    end.

add_new_robot(CreepID) ->
    MS = ets:fun2ms(fun(#robot{creep=C, robot_id=R} = E) when C == CreepID, R == ?nil -> E end),
    AllRobot = ets:select(?ETS_ROBOT, MS),
    case AllRobot =/= [] of
        true ->
            Robot = hd(AllRobot),
            ets:insert(?ETS_ROBOT, Robot#robot{robot_id=pendding}),
            add_robot(Robot);
        false ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
init_actor(RoleID) ->
    {ok, Cache} = role:get_cache(RoleID),
    CreepID = creep_id(Cache#role_cache.career),
    {ok, Mirror} = mirror_manager:get_mirror(RoleID),
    Actor = mirror_util:init_actor(Mirror, CreepID),
    % 过滤位移技能，后端暂时没同步位置
    Skills = maps:remove(201008, maps:remove(101008, Actor#actor.skills)),
    Actor#actor{skills=Skills, aiargs=#{enemy_type => ?ACTOR_TYPE_CREEP}}.

creep_id(?CAREER_SWORDMAN) -> 11001001;
creep_id(?CAREER_KNIGHT)   -> 11001002.

% 确定挂机地点
find_afk_place(Level) ->
    case cfg_afk:find(Level) of
        #cfg_afk{creep=CreepID, show_robot=true} ->
            #cfg_creep{scene=SceneID} = cfg_creep:find(CreepID),
            Creeps = lists:filter(fun({ID, _Coord}) ->
                ID == CreepID
            end, scene_config:creeps(SceneID)),
            case Creeps =/= [] of
                true ->
                    {CreepID, Coord} = ut_rand:choose(Creeps),
                    {CreepID, SceneID, Coord};
                false ->
                    ?error("can not find afk place: ~w", [Level]),
                    ?nil
            end;
        #cfg_afk{show_robot=false} ->
            ?nil;
        _ ->
            ?error("can not find afk place: ~w", [Level]),
            ?nil
    end.

add_robot(Robot) ->
    #robot{role_id=RoleID, scene=SceneID,
        etime=EndTime, creep=CreepID, coord=Coord} = Robot,
    Actor  = init_actor(RoleID),
    case can_add_robot(CreepID) of
        true ->
            spawn(fun() ->
                Actor2 = Actor#actor{etime=EndTime, born=Coord, coord=Coord, dest=Coord},
                [RobotID] = creep:sync_add(SceneID, 0, ?MAIN_LINE, [Actor2]),
                % 可能情况(少概率)
                % 添加完机器人后，发现玩家也上线了
                % 剔除机器人，清除数据
                % 补充机器人
                case role:is_alive(RoleID) of
                    true ->
                        creep:del(SceneID, 0, ?MAIN_LINE, RobotID),
                        ets:delete(?ETS_ROBOT, RoleID),
                        ?debug("found online after add robot, role_id: ~w, robot_id ~w", [RoleID, RobotID]),
                        afk_server:add_new_robot(CreepID);
                    false ->
                        % 暂存玩家离线机器人ID
                        ?debug("add robot, role_id: ~w, robot_id ~w", [RoleID, RobotID]),
                        ets:insert(?ETS_ROBOT, Robot#robot{robot_id=RobotID})
                end
            end);
        false ->
            ets:insert(?ETS_ROBOT, Robot#robot{robot_id=?nil})
    end.

can_add_robot(CreepID) ->
    MS = ets:fun2ms(fun(#robot{creep=C, robot_id=R} = E) when
        C == CreepID,
        (is_integer(R) orelse R == pendding) -> E end),
    ActiveRobots = ets:select(?ETS_ROBOT, MS),
    erlang:length(ActiveRobots) =< 2.
