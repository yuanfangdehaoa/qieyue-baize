%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(compete_prepare).

-include("activity.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("log.hrl").

%% API
-export([pre_enter/3]).
-export([hook_enter/2]).
-export([hook_leave/2]).
-export([hook_loopsec/2]).
-export([start_battle/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
pre_enter(SceneID, _Args, RoleSt) ->
	?debug("pre_enter-----------------------:~w", [SceneID]),
	ServName = compete_util:get_server_by_scene(SceneID),
	ok = gen_server:call(ServName, {pre_enter, RoleSt#role_st.role}).

hook_enter(Actor, _SceneSt) ->
	compete_server:role_enter(Actor#actor.uid).

hook_leave(Actor, _SceneSt) ->
	compete_server:role_leave(Actor#actor.uid).

%% 循环加经验
hook_loopsec(Secs, _SceneSt) when Secs rem 10 == 0 ->
	IsLocal = cluster:is_local(),
	ExpGain = cfg_compete_misc:find(exp_add, IsLocal),
	RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
	lists:foreach(fun
		(RoleID) ->
			Actor = scene_actor:get_actor(RoleID),
			#actor{pid=RolePid, level=RoleLv} = Actor,
			[{_,ExpAdd}] = game_util:transform_gain(RoleLv, ExpGain),
			role:add_exp(RolePid, ExpAdd, ?LOG_COMPETE_LOOPEXP),
			compete_server:add_exp(RoleID, ExpAdd)
	end, RoleIDs);
hook_loopsec(_Secs, _SceneSt) ->
	ignore.

%% 开始战斗
start_battle({ActID,_Round,SceneID,RoomID,RivalID,Index,FakerID}, RoleSt) ->
	role_skill:refresh(RoleSt),
    Coord = lists:nth(Index, scene_config:born(SceneID)),
    Opts  = #{
		bctype  => ?BCTYPE_SCENE,
		rival   => RivalID,
		index   => Index,
		prepare => RoleSt#role_st.scene,
		act_id  => ActID,
		faker   => FakerID
	},
    scene_change:change(
    	?SCENE_CHANGE_SERVER, SceneID, RoomID, Coord, [], Opts, RoleSt
    ).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
