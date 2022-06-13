%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(buff_util).

-include("attr.hrl").
-include("buff.hrl").
-include("creep.hrl").
-include("scene.hrl").
-include("game.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([add_buffs/2, add_buffs/3, add_buffs/4, add_buffs/5]).
-export([del_buffs/2, del_buffs/3, del_buffs/4]).
-export([had_buff/2]).
-export([had_effect/2]).
-export([get_buff/2]).
-export([get_value/2, get_value/3]).
-export([notify_buff_update/5]).
-export([notify_attr_update/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 新增 buff
-spec add_buffs(Actor, Buffs, STime, Sync) -> Return when
	Actor  :: #actor{},
	Buffs  :: [BuffID | {BuffID, Opts}],
		BuffID :: integer(),
		Opts   :: map(), % 定制 buff 的值
	STime  :: integer(), % buff 开始时间戳
	Sync   :: boolean(), % 是否同步到 buff_timer
	Return :: #actor{}.
%%-----------------------------------------------
add_buffs(Actor, Buffs) ->
	add_buffs(Actor, Buffs, ut_time:seconds(), true, true).

add_buffs(Actor, Buffs, STime) ->
	add_buffs(Actor, Buffs, STime, true, true).

add_buffs(Actor, Buffs, STime, Sync) ->
	add_buffs(Actor, Buffs, STime, Sync, true).

add_buffs(Actor, Buffs, STime, Sync, Save) ->
	Actor2 = lists:foldl(fun
		({BuffID, Opts}, Acc) ->
			add_buff(Acc, BuffID, STime, Opts, Sync);
		(BuffID, Acc) ->
			add_buff(Acc, BuffID, STime, #{}, Sync)
	end, Actor, Buffs),
	?_if(Save, scene_actor:set_actor(Actor2)),
	Actor2.

%%-----------------------------------------------
%% @doc 删除 buff
-spec del_buffs(#actor{}, [BuffID :: integer()], boolean(), boolean()) ->
	#actor{}.
%%-----------------------------------------------
del_buffs(Actor, BuffIDs) ->
	del_buffs(Actor, BuffIDs, true, true).

del_buffs(Actor, BuffIDs, Sync) ->
	del_buffs(Actor, BuffIDs, Sync, true).

del_buffs(Actor, BuffIDs, Sync, Save) ->
	Actor2 = lists:foldl(fun
		(BuffID, Acc) ->
			del_buff(Acc, BuffID, Sync)
	end, Actor, BuffIDs),
	?_if(Save, scene_actor:set_actor(Actor2)),
	Actor2.


had_buff(Actor, BuffID) when is_record(Actor, actor) ->
	lists:keymember(BuffID, #p_buff.id, maps:values(Actor#actor.buffs));
had_buff(Buffs, BuffID) when is_map(Buffs) ->
	lists:keymember(BuffID, #p_buff.id, maps:values(Buffs));
had_buff(BuffList, BuffID) when is_list(BuffList) ->
	lists:keymember(BuffID, #p_buff.id, BuffList).

had_effect(Actor, Effect) when is_record(Actor, actor) ->
	lists:keymember(Effect, #p_buff.eff, maps:values(Actor#actor.buffs));
had_effect(Buffs, Effect) when is_map(Buffs) ->
	lists:keymember(Effect, #p_buff.eff, maps:values(Buffs));
had_effect(BuffList, Effect) ->
	lists:keymember(Effect, #p_buff.eff, BuffList).


get_buff(Actor, BuffID) ->
	case lists:keyfind(BuffID, #p_buff.id, maps:values(Actor#actor.buffs)) of
		false -> ?nil;
		Buff  -> Buff
	end.

get_value(Actor, BuffID) ->
	get_value(Actor, BuffID, 0).

get_value(Actor, BuffID, Default) ->
	#cfg_buff{group=Group} = cfg_buff:find(BuffID),
	Buff = maps:get(Group, Actor#actor.buffs, ?nil),
	?_if(Buff == ?nil, Default, Buff#p_buff.value).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
add_buff(Actor, BuffID, STime, Opts, Sync) ->
	CfgBuff = #cfg_buff{type=Type} = cfg_buff:find(BuffID),
	case Type == ?BUFF_TYPE_NEGATIVE andalso ?is_immune(Actor#actor.state) of
		true  -> Actor;
		false -> do_add_buff(Actor, CfgBuff, STime, Opts, Sync)
	end.

do_add_buff(Actor, CfgBuff, STime, Opts, Sync) ->
	#cfg_buff{group=Group, lap=Lap, effect=Effect, show=Show, notify=Notify} = CfgBuff,
	NewBuff = new_buff(CfgBuff, Actor, STime, Opts),
	IsCover = maps:get(cover, Opts, false),
	Actor1  = case maps:find(Group, Actor#actor.buffs) of
		{ok, OldBuff} when IsCover ->
			rep_buff(Actor, OldBuff, NewBuff, STime, Sync, Show);
		{ok, OldBuff} ->
			{LapType, LapLast, LapAttr, LapVal} = Lap,
			IfRep = if_replace(LapType, OldBuff, NewBuff),
			NewBuff1 = ?_if(IfRep, NewBuff, OldBuff),
			NewBuff2 = NewBuff1#p_buff{
				etime = calc_etime(?_if(IfRep, new, LapLast), OldBuff, NewBuff),
				attrs = calc_attrs(?_if(IfRep, new, LapAttr), OldBuff, NewBuff),
				value = calc_value(?_if(IfRep, new, LapVal), OldBuff, NewBuff)
			},
			rep_buff(Actor, OldBuff, NewBuff2, STime, Sync, Show);
		_ ->
			add_buff2(Actor, NewBuff, STime, Sync, Show)
	end,
	Actor2 = scene_actor:recalc_attr(Actor1),
	?_if(Effect == ?BUFF_EFFECT_ATTR, scene_actor:update_afk_rank(Actor2)),
	?_if(Notify, notify_attr_update(Effect, Actor2)),
	Actor2.

rep_buff(Actor, OldBuff, NewBuff, STime, Sync, Show) ->
	Actor1 = case OldBuff == ?nil of
		true  -> Actor;
		false -> del_buff(Actor, OldBuff#p_buff.id, Sync)
	end,
	add_buff2(Actor1, NewBuff, STime, Sync, Show).

add_buff2(Actor, Buff, STime, Sync, Show) ->
	#actor{uid=ActorID, buffs=Buffs} = Actor,
	?_if(Sync, buff_timer:add(ActorID, Buff, STime)),

	?_if(
		scene_util:in_scene(),
		notify_buff_update(Show, Actor, [Buff], [], [])
	),
	Actor#actor{
		buffs = maps:put(Buff#p_buff.group, Buff, Buffs)
	}.

%% 删除buff
del_buff(Actor, BuffID, Sync) ->
	#actor{uid=ActorID, buffs=Buffs} = Actor,
	BuffList = maps:values(Buffs),
	case lists:keymember(BuffID, #p_buff.id, BuffList) of
		true  ->
			Buffs2 = maps:filter(fun
				(_Group, Buff) ->
					Buff#p_buff.id /= BuffID
			end, Buffs),
			Actor2  = Actor#actor{buffs=Buffs2},
			CfgBuff = cfg_buff:find(BuffID),
			#cfg_buff{group=Group, effect=Effect, show=Show, notify=Notify} = CfgBuff,
			OldBuff = maps:get(Group, Buffs),
			?_if(Sync, buff_timer:del(ActorID, Group)),
			notify_buff_update(Show, Actor, [], [OldBuff#p_buff.id], []),
			buff_effect:cancel(Effect, Actor2, OldBuff, false),
			Actor3 = scene_actor:get_actor(ActorID),
			Actor4 = scene_actor:recalc_attr(Actor3),
			?_if(Effect == ?BUFF_EFFECT_ATTR, scene_actor:update_afk_rank(Actor4)),
			?_if(Notify, notify_attr_update(Effect, Actor4)),
			Actor4;
		false ->
			Actor
	end.

% 使用旧buff
if_replace(never, _OldBuff, _NewBuff) ->
	false;
% 使用新buff
if_replace(always, _OldBuff, _NewBuff) ->
	true;
% 等级高时替换
if_replace(level, OldBuff, NewBuff) ->
	#cfg_buff{level=OldLv} = cfg_buff:find(OldBuff#p_buff.id),
	#cfg_buff{level=NewLv} = cfg_buff:find(NewBuff#p_buff.id),
	NewLv > OldLv;
% 时间长时替换
if_replace(last, OldBuff, NewBuff) ->
	NewBuff#p_buff.etime > OldBuff#p_buff.etime;
% id不同时替换
if_replace(diffid, OldBuff, NewBuff) ->
	NewBuff#p_buff.id /= OldBuff#p_buff.id.

calc_etime(old, OldBuff, _NewBuff) ->
	OldBuff#p_buff.etime;
calc_etime(new, _OldBuff, NewBuff) ->
	NewBuff#p_buff.etime;
calc_etime(add, OldBuff, NewBuff) ->
	#cfg_buff{last=Last} = cfg_buff:find(NewBuff#p_buff.id),
	OldBuff#p_buff.etime + Last div 1000.

calc_attrs(old, OldBuff, _NewBuff) ->
	OldBuff#p_buff.attrs;
calc_attrs(new, _OldBuff, NewBuff) ->
	NewBuff#p_buff.attrs;
calc_attrs(add, OldBuff, NewBuff) ->
	Attr = mod_attr:add(OldBuff#p_buff.attrs, NewBuff#p_buff.attrs),
	mod_attr:to_list(Attr).

calc_value(old, OldBuff, _NewBuff) ->
	OldBuff#p_buff.value;
calc_value(new, _OldBuff, NewBuff) ->
	NewBuff#p_buff.value;
calc_value(add, OldBuff, NewBuff) ->
	#cfg_buff{value=Val} = cfg_buff:find(NewBuff#p_buff.id),
	OldBuff#p_buff.value + Val.

new_buff(CfgBuff, Actor, STime, Opts) ->
	#cfg_buff{last=Last0, attrs=Attrs, effect=Effect} = CfgBuff,
	Last  = maps:get(last, Opts, Last0) div 1000,
	Value = maps:get(value, Opts, fix_value(Effect, Actor, CfgBuff)),
	ETime = maps:get(etime, Opts, ?_if(Last == 0, 0, STime+Last)),
	#p_buff{
		id     = CfgBuff#cfg_buff.id,
		type   = CfgBuff#cfg_buff.type,
		origin = Value,
		value  = Value,
		eff    = Effect,
		etime  = ETime,
		attrs  = Attrs,
		group  = CfgBuff#cfg_buff.group
	}.

% 机甲护盾
fix_value(?BUFF_EFFECT_MECHA_SHIELD, Actor, _CfgBuff) ->
	HpMax  = ?_attr(Actor#actor.attr, ?ATTR_HPMAX),
	Shield = ?_attr(Actor#actor.attr, ?ATTR_MECHA_SHIELD),
	round(HpMax * Shield / ?PER_10000);
% 夺城战boss护盾
fix_value(?BUFF_EFFECT_SHIELD, Actor, CfgBuff) when ?is_siegeboss(Actor) ->
	#cfg_creep{guard=Guard} = cfg_creep:find(Actor#actor.id),
	ActorIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
	RoleNum  = length([begin
		Role = scene_actor:get_actor(ActorID),
		scene_util:is_nearby(Actor, Role, Guard)
	end || ActorID <- ActorIDs]),
	CfgBuff#cfg_buff.value + cfg_game:siegeboss_shield_num() * RoleNum;
% 限时boss护盾
fix_value(?BUFF_EFFECT_SHIELD, Actor, CfgBuff) when ?is_timeboss(Actor) ->
	RoleNum = length(scene_actor:get_actids(?ACTOR_TYPE_ROLE)),
	CfgBuff#cfg_buff.value + cfg_game:timeboss_shield_num() * RoleNum;
% 护盾
fix_value(?BUFF_EFFECT_SHIELD, Actor, CfgBuff) ->
	HpMax = ?_attr(Actor#actor.attr, ?ATTR_HPMAX),
	#cfg_buff{value=Value} = CfgBuff,
	round(HpMax * ?_per(Value));
fix_value(_Effect, _Actor, CfgBuff) ->
	CfgBuff#cfg_buff.value.

notify_buff_update(true, Actor, Add, Del, Chg) ->
	Toc = #m_buff_update_toc{
		uid = Actor#actor.uid,
		add = [B#p_buff{attrs=[]} || B <- Add],
		chg = [B#p_buff{attrs=[]} || B <- Chg],
		del = Del
	},
	?bcast(scene_util:get_bc_roles(Actor), Toc);
notify_buff_update(false, _Actor, _Add, _Del, _Chg) ->
	ignore.

notify_attr_update(?BUFF_EFFECT_ATTR, Actor) when ?is_role(Actor) ->
	notify_attr_update(Actor);
notify_attr_update(_Effect, _Actor) ->
	ignore.

notify_attr_update(Actor) ->
	#actor{uid=ActorID, coord=Coord, buffattr=Attr} = Actor,
	?ucast(ActorID, #m_role_upattr_toc{
		attr  = mod_attr:p_attr(Attr),
		power = mod_attr:power(Attr)
	}),

	?bcast(
		scene_util:get_bc_actids(?ACTOR_TYPE_ROLE, Coord),
		ActorID,
		#m_actor_update_toc{
			uid   = ActorID,
			upint = #{
				"attr.speed" => ?_attr(Attr, ?ATTR_SPEED),
				"hp"    => ?_attr(Attr, ?ATTR_HP),
				"hpmax" => ?_attr(Attr, ?ATTR_HPMAX)
			}
	    }
	).