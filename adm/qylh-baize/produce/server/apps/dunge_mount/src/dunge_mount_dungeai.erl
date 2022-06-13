%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_mount_dungeai).

-include("attr.hrl").
-include("btree.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([is_boss_born/1]).
-export([is_boss_dead/1]).
-export([mark_boss/1]).
-export([stat/1]).
-export([is_lastone/1]).
-export([weaken_boss/1]).
-export([weaken_creep/1]).
-export([slience_boss/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
is_boss_born(_SceneSt) ->
	{hook_born, [Actor]} = dunge_util:get_event(),
	Actor#actor.rarity == ?CREEP_RARITY_BOSS2.

is_boss_dead(_SceneSt) ->
	{hook_creep_dead, [_Atker, Defer]} = dunge_util:get_event(),
	Defer#actor.rarity == ?CREEP_RARITY_BOSS2.

%% 标记Boss
mark_boss(_SceneSt) ->
	{hook_born, [Actor]} = dunge_util:get_event(),
	DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
	?debug("mark_boss----------------"),
	Opts2   = maps:put(boss, Actor#actor.uid, Opts),
	dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
	?SUCCESS.

%% 发放奖励
stat(SceneSt) ->
	DungeSt = dunge_util:get_state(),
	#dunge_st{clear=IsClear, roles=[RoleID], used=TimeUsed} = DungeSt,
	case IsClear of
		true  ->
			NewStar = if
				TimeUsed =< 60 * 1 -> ?STAR3;
				TimeUsed =< 60 * 2 -> ?STAR2;
				TimeUsed =< 60 * 5 -> ?STAR1
			end,
			DungeSt2 = DungeSt#dunge_st{star=NewStar},
			dunge_util:set_state(DungeSt2),
			role:route(RoleID, dunge_mount, stat, DungeSt2);
		false ->
			?ucast(RoleID, #m_dunge_over_toc{
    			stype = SceneSt#scene_st.stype,
    			id    = SceneSt#scene_st.dunge,
    			clear = false
    		})
	end,
	?SUCCESS.

%%--------------------------
%% 进阶副本(火)
%%--------------------------
%% 是不是最后一只怪
is_lastone(_SceneSt) ->
	#dunge_st{wave=Wave, count=Count} = dunge_util:get_state(),
	maps:get(Wave, Count, 0) == 1.

%% 削弱Boss
weaken_boss(_SceneSt) ->
	?debug("---------:~ts", ["削弱boss"]),
	#dunge_st{opts=Opts} = dunge_util:get_state(),
	ActorID = maps:get(boss, Opts, 0),
	case scene_actor:get_actor(ActorID) of
		?nil  ->
			?FAILURE;
		Actor ->
			Att   = ?_attr(Actor#actor.attr, ?ATTR_ATT),
			Attr2 = ?_setattr(Actor#actor.attr, ?ATTR_ATT, round(Att*0.5)),
			scene_actor:set_actor(Actor#actor{attr=Attr2}),
			?SUCCESS
	end.

%%--------------------------
%% 进阶副本(山)
%%--------------------------
%% 削弱小怪
weaken_creep(_SceneSt) ->
	#dunge_st{roles=[RoleID]} = dunge_util:get_state(),
	ActorIDs = scene_actor:get_actids(?ACTOR_TYPE_CREEP),
	?debug("---------:~ts=>~w", ["削弱小怪", ActorIDs]),
	lists:foreach(fun
		(ActorID) ->
			Actor = #actor{attr=Attr} = scene_actor:get_actor(ActorID),
			Attr1 = ?_setattr(Attr, ?ATTR_HP, round(?_attr(Attr,?ATTR_HP)/2)),
			Attr2 = ?_setattr(Attr1, ?ATTR_DEF, ?_attr(Attr1,?ATTR_DEF)/2),
			scene_actor:set_actor(Actor#actor{attr=Attr2}),
			?ucast(RoleID, #m_actor_update_toc{
                uid   = ActorID,
                upint = #{"hp"=>?_attr(Attr2,?ATTR_HP)}
            })
	end, ActorIDs),
	?SUCCESS.

%%--------------------------
%% 进阶副本(竜)
%%--------------------------
%% 沉默Boss
slience_boss(_SceneSt) ->
	{hook_creep_dead, [_Atker, Defer]} = dunge_util:get_event(),
	case ?is_elite(Defer) of
		true  ->
			?debug("---------:~ts", ["沉默Boss"]),
			#dunge_st{opts=Opts} = dunge_util:get_state(),
			ActorID = maps:get(boss, Opts, 0),
			case scene_actor:get_actor(ActorID) of
				?nil  ->
					?FAILURE;
				Actor ->
					buff_util:add_buffs(Actor, [220410001]),
					?SUCCESS
			end;
		false ->
			?FAILURE
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
