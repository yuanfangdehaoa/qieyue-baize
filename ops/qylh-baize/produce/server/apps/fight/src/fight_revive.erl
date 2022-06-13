%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fight_revive).

-include("attr.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([auto/2, auto/3]).
-export([revive/2, revive/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 自动复活
auto(Actor, SceneSt) ->
    #cfg_revive{time=Sec} = cfg_scene:revive(SceneSt#scene_st.scene),
	auto(Actor, Sec, SceneSt).

auto(Actor, 0, SceneSt) ->
	?MODULE:revive({Actor#actor.uid, ?MODULE, revive}, SceneSt);
auto(Actor, Delay, _SceneSt) ->
    fight_timer:add_task(
    	{Actor#actor.uid, ?MODULE, revive}, Delay, ?MODULE, revive
    ).


%% 立即复活
revive({ActorID, _, _}, SceneSt) ->
	Actor = scene_actor:get_actor(ActorID),
	case Actor /= ?nil andalso ?is_death(Actor#actor.state) of
		true  ->
			#scene_st{scene=SceneID} = SceneSt,
		    #cfg_revive{type=Type} = cfg_scene:revive(SceneID),
			revive(Actor, Type, SceneSt);
		false ->
			ignore
	end.

revive(Actor, Type, SceneSt) ->
	#actor{uid=ActorID, coord=Coord, attr=Attr} = Actor,
	Around = scene_util:get_bc_roles(Actor),
	Actor2 = Actor#actor{
		state = ?ACTOR_STATE_NORMAL,
		attr  = ?_setattr(Attr, ?ATTR_HP, ?_attr(Attr, ?ATTR_HPMAX)),
		dest  = Coord
	},
	Actor3 = case Type of
		?REVIVE_TYPE_SITU ->
			Actor2;
		?REVIVE_TYPE_SAFE ->
			Coord2 = scene_hook:get_reborn(Actor, SceneSt),
			scene_grid:move(Actor2, Coord2, SceneSt),
			role:cast(ActorID, {move, Coord2}),
			Actor2#actor{coord=Coord2}
	end,
	fight_timer:del_task({Actor#actor.uid, ?MODULE, revive}),
	% 这里不使用 ?bcast ，避免 scene_change 比 fight_revive 还先发给前端
	[?ucast(RoleID, #m_fight_revive_toc{
		uid  = ActorID,
		type = Type,
		dest = Actor3#actor.coord
    }) || RoleID <- Around],
	scene_actor:set_actor(Actor3),
	scene_hook:hook_revive(Actor3, Type, SceneSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
