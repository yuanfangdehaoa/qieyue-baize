%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_pet_dungeai).

-include("attr.hrl").
-include("btree.hrl").
-include("dunge.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([init/1]).
-export([role_enter/1]).
-export([clear/1]).
-export([stat_one/1]).
-export([stat/1]).
-export([is_cryst_dead/1]).
-export([is_monst_dead/1]).
-export([is_box_dead/1]).
-export([is_fail/1]).
-export([update_cryst/1]).
-export([add_drop/1]).
-export([send_info/1]).
-export([send_crypts/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(SceneSt) ->
	#scene_st{scene=SceneID, room=RoomID, dunge=DungeID} = SceneSt,
	#cfg_dunge{level=CreepLv} = cfg_dunge:find(DungeID),
	Crypts  = lists:map(fun
		({CreepID,X,Y,AttrID,AttCoef,DefCoef}) ->
			{CreepID,X,Y,AttrID,CreepLv,AttCoef,DefCoef,#{group=>RoomID}}
	end, cfg_creep_born:find(SceneID)),
	Crypts2 = creep_agent:add(Crypts, SceneSt),
	DungeSt = dunge_util:get_state(),
	dunge_util:set_state(DungeSt#dunge_st{
		level = CreepLv,
		opts  = #{crypts=>Crypts2}
	}),
	?SUCCESS.

role_enter(_SceneSt) ->
	{hook_enter, [Actor]} = dunge_util:get_event(),
	RestTimes = dunge_util:rest_times(Actor),
	DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
	Opts2   = case RestTimes > 0 of
		true  -> ut_misc:maps_increase(drop_key, 1, Opts);
		false -> Opts
	end,
	dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
	?SUCCESS.

clear(SceneSt) ->
	CreepIDs = scene_actor:get_actids(?ACTOR_TYPE_CREEP),
    lists:foreach(fun
        (ActorID) ->
        	Actor = scene_actor:get_actor(ActorID),
        	case Actor /= ?nil andalso ?is_monst(Actor) of
        		true  -> creep_agent:del(Actor, SceneSt);
        		false -> ignore
        	end
    end, CreepIDs).

stat_one(SceneSt) ->
	{hook_over, [RoleID]} = dunge_util:get_event(),
	DungeSt  = #dunge_st{roles=RoleIDs} = dunge_util:get_state(),
	RoleIDs2 = lists:delete(RoleID, RoleIDs),
	DungeSt2 = DungeSt#dunge_st{roles=RoleIDs2},
	dunge_util:set_state(DungeSt2),
	Captain  = team_server:get_captain(SceneSt#scene_st.room),
	do_stat(Captain, RoleID, DungeSt2, SceneSt),
	?SUCCESS.

stat(SceneSt) ->
	DungeSt = #dunge_st{roles=RoleIDs} = dunge_util:get_state(),
	Captain = team_server:get_captain(SceneSt#scene_st.room),
	lists:foreach(fun
		(RoleID) ->
			do_stat(Captain, RoleID, DungeSt, SceneSt)
	end, RoleIDs),
	?SUCCESS.

is_cryst_dead(_SceneSt) ->
	{hook_creep_dead, [_, Actor]} = dunge_util:get_event(),
	#dunge_st{opts=#{crypts:=Crypts}} = dunge_util:get_state(),
	lists:member(Actor#actor.uid, Crypts).

is_monst_dead(_SceneSt) ->
	{hook_creep_dead, [_, Actor]} = dunge_util:get_event(),
	?is_monst(Actor).

is_box_dead(_SceneSt) ->
	{hook_drop, [Actor, _]} = dunge_util:get_event(),
	?is_coll(Actor).

is_fail(_SceneSt) ->
	#dunge_st{opts=#{crypts:=Crypts}} = dunge_util:get_state(),
	Crypts == [].

update_cryst(_SceneSt) ->
	{hook_creep_dead, [_, Actor]} = dunge_util:get_event(),
	DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
	Opts2 = ut_misc:maps_delete(crypts, Actor#actor.uid, Opts),
	dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
	?SUCCESS.

add_drop(_SceneSt) ->
	{hook_drop, [Actor, Drops]} = dunge_util:get_event(),
	Killer  = scene_actor:get_actor(Actor#actor.killer),
	Times   = dunge_util:merge_times(Killer),
	DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
	MyDrop  = maps:get({drop,Actor#actor.killer}, Opts, #{}),
	MyDrop2 = lists:foldl(fun
		(#drop{id=ItemID, num=Num}, Acc) ->
			ut_misc:maps_increase(ItemID, Num*Times, Acc)
	end, MyDrop, Drops),
	dunge_util:set_state(DungeSt#dunge_st{
		opts = maps:put({drop,Actor#actor.killer}, MyDrop2, Opts)
	}),
	?SUCCESS.

send_info(SceneSt) ->
	#dunge_st{roles=RoleIDs} = dunge_util:get_state(),
	lists:foreach(fun
		(RoleID) ->
			dunge_pet:send_info(RoleID, SceneSt)
	end, RoleIDs),
	?SUCCESS.

send_crypts(_SceneSt) ->
	{hook_enter, [Actor]} = dunge_util:get_event(),
	#dunge_st{opts=#{crypts:=CryptIDs}} = dunge_util:get_state(),
	lists:foreach(fun
		(CryptID) ->
			#actor{attr=Attr} = scene_actor:get_actor(CryptID),
			?ucast(Actor#actor.uid, #m_actor_updatehp_toc{
				uid   = CryptID,
				hp    = ?_attr(Attr, ?ATTR_HP),
				hpmax = ?_attr(Attr, ?ATTR_HPMAX)
			})
	end, CryptIDs),
	?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_stat(Captain, RoleID, DungeSt, _SceneSt) ->
	case scene_actor:get_actor(RoleID) of
		?nil  ->
			ignore;
		Actor ->
			#dunge_st{
				id=DungeID, opts=Opts, wave=Wave, clear=IsClear, level=DungeLv
			} = DungeSt,
			IsClear2 = Wave > 1,
			ClrWave  = ?_if(IsClear, cfg_dunge_wave:max(DungeID), Wave-1),
			Drops = maps:get({drop,RoleID}, Opts, #{}),
			case IsClear2 of
				true  ->
					RestTimes  = dunge_util:rest_times(Actor),
					MergeTimes = dunge_util:merge_times(Actor),
					role:route(
						Actor#actor.uid,
						dunge_pet,
						give_reward,
						{ClrWave, Drops, DungeID, DungeLv, Captain, RestTimes, MergeTimes}
					);
				false ->
					dunge_pet:over_notify(
						RoleID, DungeID, IsClear2, ClrWave, Drops, #{}
					)
			end
	end.
