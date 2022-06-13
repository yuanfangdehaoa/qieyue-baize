%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(buff_effect).

-include("attr.hrl").
-include("buff.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([trigger/2]).
-export([expired/2]).
%% Internal API
-export([cancel/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% buff 生效
trigger({ActorID, Group}, SceneSt) ->
	case scene_actor:get_actor(ActorID) of
		?nil  ->
			ignore;
		Actor ->
			case maps:find(Group, Actor#actor.buffs) of
				{ok, Buff} ->
					effect(Buff#p_buff.eff, Actor, Buff);
				error ->
					?error("trigger nonexist buff: ~w", [
						{SceneSt#scene_st.scene, ActorID, Group}
					])
			end
	end.

%% buff 过期
expired({ActorID, Group}, SceneSt) ->
	case scene_actor:get_actor(ActorID) of
		?nil  ->
			ignore;
		Actor ->
			case maps:find(Group, Actor#actor.buffs) of
				{ok, Buff} ->
					cancel(Buff#p_buff.eff, Actor, Buff, true),
					Actor1 = scene_actor:get_actor(ActorID),
					Actor2 = buff_util:del_buffs(Actor1, [Buff#p_buff.id]),
					scene_actor:set_actor(Actor2);
				error ->
					?error("cancel nonexist buff: ~w", [
						{SceneSt#scene_st.scene, ActorID, Group}
					])
			end
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 无敌
effect(?BUFF_EFFECT_UNBEAT, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_UNBEAT)},
	scene_actor:set_actor(Actor2);
%% 眩晕
effect(?BUFF_EFFECT_DIZZY, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_DIZZY)},
	scene_actor:coll_stop(Actor2, true);
%% 沉默
effect(?BUFF_EFFECT_SILENT, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_SILENT)},
	scene_actor:coll_stop(Actor2, true);
%% 混乱
effect(?BUFF_EFFECT_CHAOS, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_CHAOS)},
	scene_actor:coll_stop(Actor2, true);
%% 定身
effect(?BUFF_EFFECT_IMMOB, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_IMMOB)},
	scene_actor:coll_stop(Actor2, true);
%% 麻痹
effect(?BUFF_EFFECT_PALSY, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_PALSY)},
	scene_actor:coll_stop(Actor2, true);
%% 掉落衰减
effect(?BUFF_EFFECT_DECAY, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_DECAY)},
	scene_actor:set_actor(Actor2);
%% 护盾
effect(?BUFF_EFFECT_SHIELD, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_SHIELD)},
	scene_actor:set_actor(Actor2);
%% 宠物变身
effect(?BUFF_EFFECT_PET_MORPH, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_PET_MORPH)},
	scene_actor:set_actor(Actor2);
%% 吸血
effect(?BUFF_EFFECT_LEECH, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_LEECH)},
	scene_actor:set_actor(Actor2);
%% 占用
effect(?BUFF_EFFECT_OCCUPY, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_OCCUPY)},
	scene_actor:set_actor(Actor2);
%% 不屈
effect(?BUFF_EFFECT_UNYIELD, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_UNYIELD)},
	scene_actor:set_actor(Actor2);
%% 减速
effect(?BUFF_EFFECT_SLOW, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_SLOW)},
	scene_actor:set_actor(Actor2);
%% 雷*攻潮
effect(?BUFF_EFFECT_LEI_GC, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_LEI_GC)},
	scene_actor:set_actor(Actor2);
%% 冰*铠甲
effect(?BUFF_EFFECT_BING_KJ, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_BING_KJ)},
	scene_actor:set_actor(Actor2);
%% 幽*攻潮
effect(?BUFF_EFFECT_YOU_GC, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_YOU_GC)},
	scene_actor:set_actor(Actor2);
%% 幻*灵闪
effect(?BUFF_EFFECT_HUAN_LS, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_HUAN_LS)},
	scene_actor:set_actor(Actor2);
%% 净化
effect(?BUFF_EFFECT_PURIFY, Actor, _Buff) ->
	Actor2 = purify(Actor, maps:values(Actor#actor.buffs), -1),
	scene_actor:set_actor(Actor2);
%% 坐骑技能回血
effect(?BUFF_EFFECT_HEAL2, Actor, _Buff) when (not ?is_death(Actor#actor.state)) ->
	#actor{level=Level, attr=Attr} = Actor,
	#{?ATTR_HPMAX:=HpMax, ?ATTR_HP:=OldHp} = Attr,
	HpAdd  = round(Level * 100),
	NewHp  = min(HpMax, OldHp+HpAdd),
	Actor2 = Actor#actor{attr=?_setattr(Attr, ?ATTR_HP, NewHp)},
	scene_actor:set_actor(Actor2),
	?_if(NewHp > OldHp, scene_actor:notify_hp(Actor2, HpAdd, ?HEAL_TYPE_SKILL));
%% 回血
effect(?BUFF_EFFECT_HEAL, Actor, Buff) when not ?is_death(Actor#actor.state) ->
	#cfg_buff{vtype=VType} = cfg_buff:find(Buff#p_buff.id),
	Attr  = #{?ATTR_HP:=Hp, ?ATTR_HPMAX:=HpMax} = Actor#actor.attr,
	HpAdd = case VType of
		?BUFF_VTYPE_ABS ->
			Buff#p_buff.value;
		?BUFF_VTYPE_PER ->
			round(HpMax * ?_per(Buff#p_buff.value))
	end,
	NewHp  = min(HpMax, round(Hp + HpAdd)),
	Actor2 = Actor#actor{attr=?_setattr(Attr, ?ATTR_HP, NewHp)},
	scene_actor:set_actor(Actor2),
	?_if(NewHp > Hp, scene_actor:notify_hp(Actor2, HpAdd, ?HEAL_TYPE_SKILL));
%% 定时释放技能
effect(?BUFF_EFFECT_SKILL, Actor, Buff) when not ?is_death(Actor#actor.state) ->
	SceneSt = scene_util:get_state(),
	creep_ai:attack(Actor, Buff#p_buff.value, ?nil, SceneSt);
%% 世界Boss归属
effect(?BUFF_EFFECT_BELONG, Actor, _Buff) ->
	Actor2 = boss_ai:change_belong(Actor),
	scene_actor:set_actor(Actor2);
%% 定时加Buff
effect(?BUFF_EFFECT_ADDBUFF, Actor, Buff) when not ?is_death(Actor#actor.state) ->
	buff_util:add_buffs(Actor, [Buff#p_buff.value]);
%% 为队友加光环buff
effect(?BUFF_EFFECT_TEAMMATE, Actor, Buff) when not ?is_death(Actor#actor.state) ->
	MembIDs = scene_team:get_membs(Actor#actor.team),
	lists:foreach(fun
		(MembID) when MembID == Actor#actor.uid ->
			ignore;
		(MembID) ->
			case scene_actor:get_actor(MembID) of
				?nil ->
					ignore;
				Memb ->
					case scene_util:is_nearby(Actor, Memb, 650) of
						true  -> buff_util:add_buffs(Memb, [Buff#p_buff.value]);
						false -> buff_util:del_buffs(Memb, [Buff#p_buff.value])
					end
			end
	end, MembIDs);
%% 随机净化
effect(?BUFF_EFFECT_PURIFY2, Actor, Buff) ->
	BuffIDs = maps:values(Actor#actor.buffs),
	Actor2  = purify(Actor, BuffIDs, Buff#p_buff.value),
	scene_actor:set_actor(Actor2);
%% 流血状态
effect(?BUFF_EFFECT_BLEED, Actor, Buff) when not ?is_death(Actor#actor.state) ->
	Actor1 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_BLEED)},
	Attr  = #{?ATTR_HP:=OldHp} = Actor#actor.attr,
	HpDel = round(Buff#p_buff.value),
	case HpDel =< 0 of
		true  ->
			ignore;
		false ->
			NewHp  = max(0, OldHp-HpDel),
			Actor2 = Actor1#actor{attr=?_setattr(Attr, ?ATTR_HP, NewHp)},
			scene_actor:set_actor(Actor2),
			?_if(NewHp /= OldHp, scene_actor:notify_hp(Actor2, HpDel, ?HEAL_TYPE_BLEED))
	end;
%% 免疫
effect(?BUFF_EFFECT_IMMUNE, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_IMMUNE)},
	scene_actor:set_actor(Actor2);
%% 怒气技能-怒气增加
effect(?BUFF_EFFECT_ADD_ANGER, Actor, Buff) ->
	#actor{uid=ActorID, buffs=Buffs} = Actor,
	#p_buff{id=BuffID, value=Old, group=Group} = Buff,
	MaxAnger = cfg_game:max_anger(),
	case Old >= MaxAnger of
		true  ->
			ignore;
		false ->
			#cfg_buff{args=Args} = cfg_buff:find(BuffID),
			Add = proplists:get_value(anger_add, Args),
			Buff2  = Buff#p_buff{value=min(MaxAnger, Old+Add)},
			Actor2 = Actor#actor{buffs=maps:put(Group, Buff2, Buffs)},
			scene_actor:set_actor(Actor2),
			?ucast(ActorID, #m_buff_update_toc{uid=ActorID, chg=[Buff2]})
	end;
%% 怒气技能-怒气减少+释放
effect(?BUFF_EFFECT_DEL_ANGER, Actor, Buff1) ->
	#actor{uid=ActorID, buffs=Buffs, skills=Skills} = Actor,
	BuffList = maps:values(Buffs),
	case lists:keyfind(?BUFF_EFFECT_ADD_ANGER, #p_buff.eff, BuffList) of
		false ->
			ignore;
		Buff2 ->
			#p_buff{value=Old, group=Group} = Buff2,
			case Old < Buff1#p_buff.value of
				true  ->
					ignore;
				false ->
					Buff22 = Buff2#p_buff{value=max(0, Old-Buff1#p_buff.value)},
					Actor2 = Actor#actor{buffs=maps:put(Group, Buff22, Buffs)},
					scene_actor:set_actor(Actor2),
					?ucast(ActorID, #m_buff_update_toc{uid=ActorID, chg=[Buff22]}),
					#cfg_buff{args=Args} = cfg_buff:find(Buff1#p_buff.id),
					SkillID = proplists:get_value(skill, Args),
					SkillLv = maps:get(SkillID, Skills, 1),
					Attack  = #attack{
				        atker = Actor#actor.uid,
				        major = ?nil,
				        unit  = ?ATTACK_UNIT_ROLE,
				        skill = fight_util:make_skill(SkillID, SkillLv),
				        time  = ut_time:milliseconds(),
				        dir   = Actor#actor.dir,
				        coord = Actor#actor.coord,
				        endcd = 0,
				        seq   = 0,
				        opts  = []
				    },
				    fight_attack:start(Attack, scene_util:get_state())
			end
	end;
%% 机甲变身
effect(?BUFF_EFFECT_MECHA_MORPH, Actor, _Buff) ->
	Actor2 = Actor#actor{state=?_bis(Actor#actor.state, ?ACTOR_STATE_MECHA_MORPH)},
	scene_actor:set_actor(Actor2);
effect(_Effect, _Actor, _Buff) ->
	ignore.


%% 取消 buff 效果
%% 无敌
cancel(?BUFF_EFFECT_UNBEAT, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_UNBEAT)},
	scene_actor:set_actor(Actor2);
%% 眩晕
cancel(?BUFF_EFFECT_DIZZY, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_DIZZY)},
	scene_actor:set_actor(Actor2);
%% 沉默
cancel(?BUFF_EFFECT_SILENT, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_SILENT)},
	scene_actor:set_actor(Actor2);
%% 混乱
cancel(?BUFF_EFFECT_CHAOS, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_CHAOS)},
	scene_actor:set_actor(Actor2);
%% 定身
cancel(?BUFF_EFFECT_IMMOB, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_IMMOB)},
	scene_actor:set_actor(Actor2);
%% 麻痹
cancel(?BUFF_EFFECT_PALSY, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_PALSY)},
	scene_actor:set_actor(Actor2);
%% 护盾
cancel(?BUFF_EFFECT_SHIELD, Actor, Buff, _IsExpired) ->
	Actor1 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_SHIELD)},
	scene_actor:set_actor(Actor1),
	% 护盾消失时触发 冰甲护体/时之闪避
	#cfg_buff{args=Args} = cfg_buff:find(Buff#p_buff.id),
	case Args of
		{FromSkill, TrigSkill} ->
			Actor2 = case maps:find(FromSkill, Actor#actor.skills) of
				{ok, SkillLv1} ->
					#cfg_skill_level{abuffs=Buffs1} = cfg_skill_level:find(FromSkill, SkillLv1),
					buff_util:del_buffs(Actor1, [BuffID || {BuffID, _} <-Buffs1]);
				error ->
					Actor1
			end,
			Actor3 = case maps:find(TrigSkill, Actor#actor.skills) of
				{ok, SkillLv2} ->
					#cfg_skill_level{abuffs=Buffs2} = cfg_skill_level:find(TrigSkill, SkillLv2),
					buff_util:add_buffs(Actor2, [BuffID || {BuffID, _} <-Buffs2]);
				error ->
					Actor2
			end,
			scene_actor:set_actor(Actor3);
		_ ->
			ignore
	end;
%% 宠物变身
cancel(?BUFF_EFFECT_PET_MORPH, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_PET_MORPH)},
	scene_actor:set_actor(Actor2);
%% 机甲变身
cancel(?BUFF_EFFECT_MECHA_MORPH, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_MECHA_MORPH)},
	scene_actor:set_actor(Actor2);
%% 吸血
cancel(?BUFF_EFFECT_LEECH, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_LEECH)},
	scene_actor:set_actor(Actor2);
%% 占用
cancel(?BUFF_EFFECT_OCCUPY, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_OCCUPY)},
	scene_actor:set_actor(Actor2);
%% 不屈
cancel(?BUFF_EFFECT_UNYIELD, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state=?_bic(Actor#actor.state, ?ACTOR_STATE_UNYIELD)},
	scene_actor:set_actor(Actor2);
%% 减速
cancel(?BUFF_EFFECT_SLOW, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state=?_bic(Actor#actor.state, ?ACTOR_STATE_SLOW)},
	scene_actor:set_actor(Actor2);
%% 流血
cancel(?BUFF_EFFECT_BLEED, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_BLEED)},
	scene_actor:set_actor(Actor2);
%% 雷*攻潮
cancel(?BUFF_EFFECT_LEI_GC, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state=?_bic(Actor#actor.state, ?ACTOR_STATE_LEI_GC)},
	scene_actor:set_actor(Actor2);
%% 冰*铠甲
cancel(?BUFF_EFFECT_BING_KJ, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state=?_bic(Actor#actor.state, ?ACTOR_STATE_BING_KJ)},
	scene_actor:set_actor(Actor2);
%% 幽*攻潮
cancel(?BUFF_EFFECT_YOU_GC, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state=?_bic(Actor#actor.state, ?ACTOR_STATE_YOU_GC)},
	scene_actor:set_actor(Actor2);
%% 幻*灵闪
cancel(?BUFF_EFFECT_HUAN_LS, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state=?_bic(Actor#actor.state, ?ACTOR_STATE_HUAN_LS)},
	scene_actor:set_actor(Actor2);
%% 免疫
cancel(?BUFF_EFFECT_IMMUNE, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state=?_bic(Actor#actor.state, ?ACTOR_STATE_IMMUNE)},
	scene_actor:set_actor(Actor2);
%% 大招预警结束，释放技能
cancel(?BUFF_EFFECT_ALARM, Actor, Buff, true) when not ?is_death(Actor#actor.state) ->
	SceneSt = scene_util:get_state(),
	creep_ai:attack(Actor, Buff#p_buff.value, ?nil, SceneSt);
%% 在线时间到达后，触发掉落衰减
cancel(?BUFF_EFFECT_DECAYTRIG, Actor, Buff, true) when not ?is_death(Actor#actor.state) ->
	Midnight = ut_time:datetime_to_seconds({ut_time:date(), {23,59,59}}),
	buff_util:add_buffs(Actor, [{Buff#p_buff.value, #{etime => Midnight}}]);
%% 掉落衰减
cancel(?BUFF_EFFECT_DECAY, Actor, _Buff, _IsExpired) ->
	Actor2 = Actor#actor{state = ?_bic(Actor#actor.state, ?ACTOR_STATE_DECAY)},
	scene_actor:set_actor(Actor2);
%% 定时召唤小怪
cancel(?BUFF_EFFECT_SUMMON, Actor, Buff, true) when not ?is_death(Actor#actor.state) ->
	#cfg_buff{args=Creeps} = cfg_buff:find(Buff#p_buff.id),
	SceneSt = dunge_util:get_state(),
	dunge_creep:summon(Creeps, SceneSt);
cancel(_Effect, Actor, _Buff, _IsExpired) ->
	scene_actor:set_actor(Actor).

purify(Actor, Buffs, Num) when Buffs == []; Num == 0 ->
	Actor;
purify(Actor, [Buff | T], Num) ->
	case Buff#p_buff.type == ?BUFF_TYPE_NEGATIVE of
		true  ->
			Actor2 = buff_util:del_buffs(Actor, [Buff#p_buff.id]),
			purify(Actor2, T, Num-1);
		false ->
			purify(Actor, T, Num)
	end.