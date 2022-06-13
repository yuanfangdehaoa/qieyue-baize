%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(activity_hook).

-include("activity.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("msgno.hrl").
-include("proto.hrl").

%% API
-export([hook_ready/1]).
-export([hook_start/1]).
-export([hook_stop/1]).
-export([hook_post/1]).
-export([get_entry/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_ready(Activity) ->
	do_hook(Activity, hook_ready).

hook_start(Activity = #activity{id=ActID}) ->
	#cfg_activity{name=Name, msgno=MsgNo} = cfg_activity:find(ActID),
	?_if(MsgNo == ?MSG_ACTIVITY_START, ?notify(?MSG_ACTIVITY_START, [Name])),
	do_hook(Activity, hook_start).

hook_stop(Activity = #activity{id=ActID}) ->
	#cfg_activity{name=Name, msgno=MsgNo} = cfg_activity:find(ActID),
	?_if(MsgNo == ?MSG_ACTIVITY_START, ?notify(?MSG_ACTIVITY_STOP, [Name])),
	do_hook(Activity, hook_stop).

hook_post(Activity) ->
	do_hook(Activity, hook_post).

get_entry(ActID, SceneID, RoleSt) ->
	#cfg_activity{group=Group} = cfg_activity:find(ActID),
	#cfg_scene{stype=SType} = cfg_scene:find(SceneID),

	case route(Group) of
		?nil ->
			?nil;
		Mod  ->
			code:ensure_loaded(Mod),
			Entry = case erlang:function_exported(Mod, get_entry, 3) of
				true  -> Mod:get_entry(ActID, SceneID, RoleSt);
				false -> #{}
			end,
			#entry{
				scene = maps:get(scene, Entry, SceneID),
				stype = SType,
				dunge = 0,
				floor = 0,
				room  = maps:get(room, Entry, 0),
				coord = maps:get(coord, Entry, scene_util:get_born(SceneID)),
				opts  = maps:get(opts, Entry, #{})
			}
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
route(?ACTIVITY_GROUP_GUILDWAR) ->
	guild_war_server;
route(?ACTIVITY_GROUP_MELEE) ->
	melee_war;
route(?ACTIVITY_GROUP_CANDYROOM) ->
	candyroom;
route(?ACTIVITY_GROUP_GUILDHOUSE)->
	guild_house;
route(?ACTIVITY_GROUP_GUILDGUARD)->
	guild_guard;
route(?ACTIVITY_GROUP_WEDDINGPARTY)->
	wedding_party;
route(?ACTIVITY_GROUP_COMBAT1V1)->
	combat1v1;
route(?ACTIVITY_GROUP_WARRIOR)->
	warrior_server;
route(?ACTIVITY_GROUP_COMPETE) ->
	compete_server;
route(?ACTIVITY_GROUP_TIMEBOSS) ->
	timeboss_server;
route(?ACTIVITY_GROUP_SIEGEWAR) ->
	siegewar_server;
route(?ACTIVITY_GROUP_THRONE) ->
	throne_server;
route(?ACTIVITY_GROUP_CGW) ->
	guild_crosswar;
route(?ACTIVITY_GROUP_FISSURE) ->
	boss_server;
route(?ACTIVITY_GROUP_CLUSTER) ->
	cluster_center;
route(_ActID) ->
	?nil.

in_same_node(ActType) ->
	case ActType of
		?ACTIVITY_TYPE_LOCAL  -> cluster:is_local();
		?ACTIVITY_TYPE_CROSS  -> cluster:is_cross();
		?ACTIVITY_TYPE_CENTER -> cluster:is_center()
	end.

do_hook(Activity, Func) ->
	#activity{id=ActID, group=Group, type=Type} = Activity,
	case route(Group) of
		?nil ->
			ignore;
		Mod  ->
		    code:ensure_loaded(Mod),
		    case in_same_node(Type) of
		    	true  ->
					?debug("~w: ~w", [Func, ActID]),
		    		case erlang:function_exported(Mod, Func, 1) of
		    			true  -> Mod:Func(ActID);
		    			false -> ignore
		    		end;
		    	false ->
		    		ignore
		    end,
			case erlang:function_exported(Mod, Func, 2) of
				true  -> Mod:Func(game_env:get_type(), ActID);
				false -> ignore
			end
	end,
	case cluster:is_local() of
		true ->
			case erlang:function_exported(activity_stat, Func, 1) of
    			true  -> activity_stat:Func(ActID);
    			false -> ignore
    		end;
    	false ->
    		ignore
    end.
