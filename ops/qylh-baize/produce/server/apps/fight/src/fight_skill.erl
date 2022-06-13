%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fight_skill).

-include("attr.hrl").
-include("buff.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([attack/4]).
-export([assist/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
attack([Defer | T], Fight, Attack, SceneSt) ->
    Fight1 = Fight#fight{defer=Defer, def_attr=#{}},
    Fight2 = do_attack(Fight1, Attack),
    #fight{atker=Atker2, defer=Defer2, damage=Damage} = Fight2,
    % ?debug(Atker2#actor.type == ?ACTOR_TYPE_ROLE, "damage:------->~w", [Damage]),
    scene_actor:set_actor(Defer2),
    Atker3 = scene_actor:get_actor(Atker2#actor.uid),
    Fight3 = Fight2#fight{
        atker   = Atker3,
        damages = [Damage | Fight2#fight.damages],
        results = [{Atker3, Defer2, Damage} | Fight2#fight.results]
    },
    case ?is_death(Atker3#actor.state) of
        true  -> Fight3;
        false -> attack(T, Fight3, Attack, SceneSt)
    end;
attack([], Fight, _Attack, _SceneSt) ->
    Fight.

assist([Defer | T], Fight, Attack, SceneSt) ->
    Fight1 = Fight#fight{defer=Defer, def_attr=#{}},
    Fight2 = do_assist(Fight1, Attack),
    assist(T, Fight2, Attack, SceneSt);
assist([], Fight, _Attack, _SceneSt) ->
    Fight.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_attack(Fight, Attack) ->
    #skill{
        id=SkillID, effect=Effects, abuffs=ABuffs, dbuffs=DBuffs
    } = Attack#attack.skill,
    % 触发攻击方的被动技能
    Fight1  = trigger_skills(Fight, Attack, #fight.atker, pre_attack),
    % 触发受击方的被动技能
    Fight2  = trigger_skills(Fight1, Attack, #fight.defer, pre_damage),
    % 计算伤害
    Fight3  = Fight2#fight{damage=fight_damage:calc(Fight2, Attack)},
    % 计算受击结果
    Fight4  = under_attack(Fight3, Attack),
    % 触发攻击方的被动技能
    Fight5  = trigger_skills(Fight4, Attack, #fight.atker, post_attack),
    % 触发受击方的被动技能
    Fight6  = trigger_skills(Fight5, Attack, #fight.defer, post_damage),
    % 触发攻击方buff
    Fight7  = trigger_buffs(Fight6, Attack, #fight.atker, ABuffs),
    % 触发受击方buff
    Fight8  = trigger_buffs(Fight7, Attack, #fight.defer, DBuffs),
    % 触发技能效果
    Fight9  = trigger_effects(Fight8, Attack, #fight.atker, SkillID, Effects),
    % 计算伤害结果
    Fight10 = deal_result(Fight9),
    Fight10.

do_assist(Fight, Attack) ->
    #skill{id=SkillID, effect=Effects, abuffs=ABuffs} = Attack#attack.skill,
    % 触发攻击方buff
    Fight1 = trigger_buffs(Fight, Attack, #fight.atker, ABuffs),
    % 触发技能效果
    Fight2 = trigger_effects(Fight1, Attack, #fight.atker, SkillID, Effects),
    Fight2.

%% 触发被动技能
trigger_skills(Fight, Attack, WhoIdx, When) ->
    Actor = element(WhoIdx, Fight),
    SkillIDs  = cfg_skill:trigger(When),
    SkillIDs2 = case Attack#attack.unit == ?ATTACK_UNIT_PET of
        true  ->
            lists:filter(fun
                (SkillID) ->
                    #cfg_skill{group=Group} = cfg_skill:find(SkillID),
                    Group == ?SKILL_GROUP_PET
            end, SkillIDs);
        false ->
            SkillIDs
    end,
    Passives = maps:with(SkillIDs2, Actor#actor.skills),
    % ?debug("trigger_skills------------:~w~n~w~n~w~n~w~n~w~n~n~n", [When, WhoIdx, SkillIDs, Actor#actor.skills, Passives]),
    maps:fold(fun
        (SkillID, SkillLv, AccFight) ->
            trigger_skill(AccFight, Attack, WhoIdx, SkillID, SkillLv)
    end, Fight, Passives).

trigger_skill(Fight, Attack, WhoIdx, SkillID, SkillLv) ->
    CfgLevel = cfg_skill_level:find(SkillID, SkillLv),
    #cfg_skill_level{
        trigger=Conds, abuffs=ABuffs, dbuffs=DBuffs, effect=Effects, cd=CD
    } = CfgLevel,
    Actor = #actor{endcds=EndCDs} = element(WhoIdx, Fight),
    EndCD = maps:get(SkillID, EndCDs, 0),
    case CD == 0 orelse Attack#attack.time >= EndCD of
        true  ->
            case check_trigger_skill(Conds, Fight, Attack) of
                true  ->
                    % ?debug("trigger_skill---------------------------:~w", [SkillID]),
                    Actor2 = Actor#actor{
                        endcds = maps:put(SkillID, Attack#attack.time+CD, EndCDs)
                    },
                    Fight1 = setelement(WhoIdx, Fight, Actor2),
                    Fight2 = trigger_buffs(Fight1, Attack, #fight.atker, ABuffs),
                    Fight3 = trigger_buffs(Fight2, Attack, #fight.defer, DBuffs),
                    Fight4 = trigger_effects(Fight3, Attack, WhoIdx, SkillID, Effects),
                    Fight4;
                false ->
                    Fight
            end;
        false ->
            Fight
    end.


% 概率触发
check_trigger_skill([{random, Prob} | T], Fight, Attack) ->
    case ut_rand:random(1, ?PER_10000) =< Prob of
        true  -> check_trigger_skill(T, Fight, Attack);
        false -> false
    end;
% 根据伤害类型触发
check_trigger_skill([{dmg_type, Type} | T], Fight, Attack) ->
    #fight{damage=Damage} = Fight,
    case Damage /= ?nil andalso Damage#damage.type == Type of
        true  -> check_trigger_skill(T, Fight, Attack);
        false -> false
    end;
% 受击方血量低于xx时触发
check_trigger_skill([{defer_hp, HpPer} | T], Fight, Attack) ->
    Hp    = ?_attr((Fight#fight.defer)#actor.attr, ?ATTR_HP),
    HpMax = ?_attr((Fight#fight.defer)#actor.attr, ?ATTR_HPMAX),
    % ?debug("check_trigger_skill--------------------:~w", [{HpPer, ?PER_10000*(Hp/HpMax)}]),
    case ?PER_10000*(Hp/HpMax) =< HpPer of
        true  -> check_trigger_skill(T, Fight, Attack);
        false -> false
    end;
% 攻击方血量低于xx时触发
check_trigger_skill([{atker_hp, HpPer} | T], Fight, Attack) ->
    Hp    = ?_attr((Fight#fight.atker)#actor.attr, ?ATTR_HP),
    HpMax = ?_attr((Fight#fight.atker)#actor.attr, ?ATTR_HPMAX),
    case ?PER_10000*(Hp/HpMax) =< HpPer of
        true  -> check_trigger_skill(T, Fight, Attack);
        false -> false
    end;
%% 根据受击方的状态触发
check_trigger_skill([{defer_state, State} | T], Fight, Attack) ->
    #fight{defer=Defer} = Fight,
    case (Defer#actor.state band State) > 0 of
        true  -> check_trigger_skill(T, Fight, Attack);
        false -> false
    end;
%% 根据攻击方的状态触发
check_trigger_skill([{atker_state, State} | T], Fight, Attack) ->
    #fight{atker=Atker} = Fight,
    % ?debug(Attack#attack.unit == ?ATTACK_UNIT_ROLE, "check_trigger_skill---------:~w", [{State, (Atker#actor.state band State) > 0}]),
    case (Atker#actor.state band State) > 0 of
        true  -> check_trigger_skill(T, Fight, Attack);
        false -> false
    end;
%% 由指定技能触发
check_trigger_skill([{skill, SkillList} | T], Fight, Attack) ->
    #skill{id=SkillID} = Attack#attack.skill,
    case lists:member(SkillID, SkillList) of
        true  -> check_trigger_skill(T, Fight, Attack);
        false -> false
    end;
%% 根据攻击方身上的buff效果
check_trigger_skill([{atker_effect, Effect} | T], Fight, Attack) ->
    case buff_util:had_effect(Fight#fight.atker, Effect) of
        true  -> check_trigger_skill(T, Fight, Attack);
        false -> false
    end;
%% 根据受击方身上的buff效果
check_trigger_skill([{defer_effect, Effect} | T], Fight, Attack) ->
    case buff_util:had_effect(Fight#fight.defer, Effect) of
        true  -> check_trigger_skill(T, Fight, Attack);
        false -> false
    end;
%% 不允许触发的actor.rarity
check_trigger_skill([{exclude_rarity, RarityList} | T], Fight, Attack) ->
    #fight{defer=Defer} = Fight,
    case lists:member(Defer#actor.rarity, RarityList) of
        true  -> false;
        false -> check_trigger_skill(T, Fight, Attack)
    end;
check_trigger_skill([], _Fight, _Attack) ->
    true.

trigger_buffs(Fight, Attack, WhoIdx, Buffs) ->
    Actor = element(WhoIdx, Fight),
    {IsImmune, Triggered} = check_trigger_buffs(Fight, Attack, Actor, Buffs),
    BuffNum2 = lists:foldl(fun
        (BuffID, Acc) ->
            ut_misc:maps_increase(BuffID, 1, Acc)
    end, Fight#fight.buff_num, Triggered),
    Fight1 = Fight#fight{buff_num=BuffNum2},
    Fight2 = case IsImmune of
        true  ->
            NewDmg = fight_util:damage(Actor, Attack#attack.unit, ?DAMAGE_IMMUNE, 0),
            Fight1#fight{damages=[NewDmg | Fight#fight.damages]};
        false ->
            Fight1
    end,
    Actor2 = buff_util:add_buffs(Actor, Triggered, Attack#attack.time div 1000),
    % ?debug("Triggered:~w", [{Buffs, Triggered}]),
    setelement(WhoIdx, Fight2, Actor2).

check_trigger_buffs(Fight, Attack, Actor, Buffs) ->
    lists:foldl(fun
        ({BuffID, Conds}, Acc={IsImmune, Triggered}) ->
            #cfg_buff{effect=Effect} = cfg_buff:find(BuffID),
            case lists:member(Effect, Fight#fight.immune) of
                true  ->
                    {true, Triggered};
                false ->
                    case check_trigger_buff(Conds, BuffID, Fight, Attack, Actor) of
                        true  -> {IsImmune, [BuffID | Triggered]};
                        false -> Acc
                    end
            end
    end, {false, []}, Buffs).

%% 触发数量限制
check_trigger_buff([{num, MaxNum} | T], BuffID, Fight, Attack, Actor) ->
    case maps:get(BuffID, Fight#fight.buff_num, 0) < MaxNum of
        true  -> check_trigger_buff(T, BuffID, Fight, Attack, Actor);
        false -> false
    end;
%% 触发概率
check_trigger_buff([{random, Prob} | T], BuffID, Fight, Attack, Actor) ->
    case ut_rand:random(1, ?PER_10000) =< Prob of
        true  -> check_trigger_buff(T, BuffID, Fight, Attack, Actor);
        false -> false
    end;
%% 允许触发的场景
check_trigger_buff([{scene_allow, Scenes} | T], BuffID, Fight, Attack, Actor) ->
    case lists:member(Actor#actor.scene, Scenes) of
        true  -> check_trigger_buff(T, BuffID, Fight, Attack, Actor);
        false -> false
    end;
%% 不允许触发的场景
check_trigger_buff([{scene_deny, Scenes} | T], BuffID, Fight, Attack, Actor) ->
    case lists:member(Actor#actor.scene, Scenes) of
        true  -> false;
        false -> check_trigger_buff(T, BuffID, Fight, Attack, Actor)
    end;
%% 允许触发的actor类型
check_trigger_buff([{actor_type, Types} | T], BuffID, Fight, Attack, Actor) ->
    case lists:member(Actor#actor.type, Types) of
        true  -> check_trigger_buff(T, BuffID, Fight, Attack, Actor);
        false -> false
    end;
check_trigger_buff([], _BuffID, _Fight, _Attack, _Actor) ->
    true.

trigger_effects(Fight, Attack, WhoIdx, SkillID, Effects) ->
    lists:foldl(fun
        (Effect, Acc) ->
            trigger_effect(Effect, Acc, Attack, WhoIdx, SkillID)
    end, Fight, Effects).


%% 给自己临时加属性
trigger_effect({attr, self, Attrs}, Fight, _Attack, WhoIdx, _SkillID) ->
    case WhoIdx of
        #fight.atker -> add_attr_to_atker(Fight, Attrs);
        #fight.defer -> add_attr_to_defer(Fight, Attrs)
    end;
%% 给对方临时加属性
trigger_effect({attr, peer, Attrs}, Fight, _Attack, WhoIdx, _SkillID) ->
    case WhoIdx of
        #fight.atker -> add_attr_to_defer(Fight, Attrs);
        #fight.defer -> add_attr_to_atker(Fight, Attrs)
    end;
%% 给自己临时加属性
trigger_effect({attr_with_type, self, Attrs}, Fight, _Attack, WhoIdx, _SkillID) ->
    #fight{atker=Atker, defer=Defer} = Fight,
    case WhoIdx of
        #fight.atker ->
            Attrs2 = proplists:get_value(Atker#actor.type, Attrs),
            add_attr_to_atker(Fight, Attrs2);
        #fight.defer ->
            Attrs2 = proplists:get_value(Defer#actor.type, Attrs),
            add_attr_to_defer(Fight, Attrs2)
    end;
%% 给对方临时加属性
trigger_effect({attr_with_type, peer, Attrs}, Fight, _Attack, WhoIdx, _SkillID) ->
    #fight{atker=Atker, defer=Defer} = Fight,
    case WhoIdx of
        #fight.atker ->
            Attrs2 = proplists:get_value(Defer#actor.type, Attrs),
            add_attr_to_defer(Fight, Attrs2);
        #fight.defer ->
            Attrs2 = proplists:get_value(Atker#actor.type, Attrs),
            add_attr_to_atker(Fight, Attrs2)
    end;
%% 给攻击方加buff
trigger_effect({buff, self, BuffID}, Fight, _Attack, WhoIdx, _SkillID) ->
    case WhoIdx of
        #fight.atker -> add_buff_to_atker(Fight, BuffID);
        #fight.defer -> add_buff_to_defer(Fight, BuffID)
    end;
%% 给受击方加buff
trigger_effect({buff, peer, BuffID}, Fight, _Attack, WhoIdx, _SkillID) ->
    case WhoIdx of
        #fight.atker -> add_buff_to_defer(Fight, BuffID);
        #fight.defer -> add_buff_to_atker(Fight, BuffID)
    end;
%% 伤害反弹
trigger_effect({reflect, Per}, Fight, Attack, WhoIdx, SkillID) ->
    #fight{damage=Damage} = Fight,
    % ?debug("reflect--------------------------~w", [{Damage#damage.value, Per}]),
    case Damage#damage.type == ?DAMAGE_MISS of
        true  -> Fight;
        false -> reflect(Fight, Attack, WhoIdx, SkillID, Per)
    end;
%% 斩杀
trigger_effect(kill, Fight, Attack, WhoIdx, SkillID) ->
    kill(Fight, Attack, WhoIdx, SkillID);
%% 裁决
trigger_effect({kill, Conds}, Fight, Attack, WhoIdx, SkillID) ->
    case check_trigger_skill(Conds, Fight, Attack) of
        true  -> kill(Fight, Attack, WhoIdx, SkillID);
        false -> Fight
    end;
%% 连击
trigger_effect({combo, DmgType}, Fight, Attack, WhoIdx, SkillID) ->
    #fight{defer=Defer, damage=Damage} = Fight,
    CanCombo = is_record(Damage, damage)
        andalso Damage#damage.type /= ?DAMAGE_MISS
        andalso (not ?is_death(Defer#actor.state)),
    case CanCombo of
        true  -> combo(Fight, Attack, WhoIdx, SkillID, DmgType);
        false -> Fight
    end;
%% 回血
trigger_effect({heal, Type, Val}, Fight, Attack, WhoIdx, SkillID) ->
    % ?debug("heal--------------------------~w", [{Type, Val}]),
    #actor{attr=Attr} = element(WhoIdx, Fight),
    AddHp = case Type of
        abs -> Val;
        per -> ?_attr(Attr, ?ATTR_HPMAX) * ?_per(Val)
    end,
    heal(Fight, Attack, WhoIdx, SkillID, AddHp, ?DAMAGE_HEAL);
%% 免疫控制
trigger_effect({immune, BuffEffects}, Fight, _Attack, _WhoIdx, _SkillID) ->
    Fight#fight{immune=BuffEffects};
%% 流血
trigger_effect({bleed, BuffID, Per}, Fight, _Attack, _WhoIdx, _SkillID) ->
    % ?debug("bleed--------------------------~w", [{BuffID, Per}]),
    #fight{atker=Atker, defer=Defer} = Fight,
    Bleed  = round(?_attr(Atker#actor.attr, ?ATTR_ATT) * ?_per(Per)),
    Defer2 = buff_util:add_buffs(Defer, [{BuffID, #{value => Bleed}}]),
    Fight#fight{defer=Defer2};
%% 幽*吸血
trigger_effect({leech, Per}, Fight, Attack, _WhoIdx, SkillID) ->
    #fight{defer=Defer, major_id=MajorID, damage=Damage} = Fight,
    case Defer#actor.uid == MajorID of
        true  ->
            AddHp = round(Damage#damage.value * ?_per(Per)),
            % ?debug("leech--------------------------~w", [{Damage#damage.value, Per, AddHp}]),
            heal(Fight, Attack, #fight.atker, SkillID, AddHp, ?DAMAGE_LEECH);
        false ->
            Fight
    end;
%% 幻*回血
trigger_effect({absorb, Per}, Fight, Attack, _WhoIdx, SkillID) ->
    #fight{damage=Damage} = Fight,
    AddHp = round(Damage#damage.value * ?_per(Per)),
    % ?debug("absorb--------------------------~w", [{Damage#damage.value, Per, AddHp}]),
    heal(Fight, Attack, #fight.atker, SkillID, AddHp, ?DAMAGE_HEAL);
%% 不屈
trigger_effect(unyield, Fight, Attack, _WhoIdx, _SkillID) ->
    % ?debug("unyield1111111111111-------------------------------"),
    unyield(Fight, Attack);
trigger_effect(_Effect, Fight, _Attack, _WhoIdx, _SkillID) ->
    Fight.

%% 反弹
reflect(Fight, Attack, _WhoIdx, _SkillID, Per) ->
    #fight{atker=Atker, damage=Damage, damages=Damages} = Fight,
    OldHp  = ?_attr(Atker#actor.attr, ?ATTR_HP),
    DelHp  = min(OldHp, round(Damage#damage.value * ?_per(Per))),
    NewHp  = max(1, OldHp - DelHp),
    Atker2 = Atker#actor{attr=?_setattr(Atker#actor.attr, ?ATTR_HP, NewHp)},
    NewDmg = fight_util:damage(Atker2, Attack#attack.unit, ?DAMAGE_REFLECT, DelHp),
    Fight#fight{atker=Atker2, damages=[NewDmg | Damages]}.

%% 斩杀
kill(Fight, Attack, _WhoIdx, _SkillID) ->
    #fight{defer=Defer, atker=Atker} = Fight,
    #actor{attr=DefAttr} = Defer,
    Defer1 = Defer#actor{attr=?_setattr(DefAttr, ?ATTR_HP, 0)},
    Defer2 = die(Atker, Defer1),
    NewDmg = fight_util:damage(
        Defer2, Attack#attack.unit, ?DAMAGE_KILL, ?_attr(DefAttr,?ATTR_HP)
    ),
    Fight#fight{defer=Defer2, damage=NewDmg}.

%% 连击
combo(Fight, Attack, _WhoIdx, SkillID, DmgType) ->
    #fight{atker=Atker, defer=Defer, damage=Damage} = Fight,
    SkillLv = maps:get(SkillID, Atker#actor.skills),
    Attack2 = Attack#attack{skill=fight_util:make_skill(SkillID, SkillLv)},
    DmgVal  = case fight_damage:calc_fix_damage(Defer) of
        0 -> fight_damage:calc_base_damage(Atker, Defer, Attack2);
        N -> N
    end,
    Damage1 = Damage#damage{type=DmgType, value=round(DmgVal)},
    Fight1  = Fight#fight{damage=Damage1},
    Fight2  = #fight{damage=Damage2} = under_attack(Fight1, Attack2),
    Damage3 = Damage2#damage{value=Damage#damage.value+round(DmgVal)},
    Fight2#fight{damage=Damage3}.

%% 回血
heal(Fight, Attack, WhoIdx, _SkillID, AddHp, DmgType) ->
    Actor = #actor{attr=Attr} = element(WhoIdx, Fight),
    OldHp = ?_attr(Attr, ?ATTR_HP),
    case OldHp =< 0 of
        true  ->
            Fight;
        false ->
            HpMax  = ?_attr(Attr, ?ATTR_HPMAX),
            NewHp  = min(HpMax, round(OldHp+AddHp)),
            Actor2 = Actor#actor{attr=?_setattr(Attr,?ATTR_HP,NewHp)},
            Fight1 = setelement(WhoIdx, Fight, Actor2),
            NewDmg = fight_util:damage(Actor2, Attack#attack.unit, DmgType, AddHp),
            Fight1#fight{damages=[NewDmg | Fight#fight.damages]}
    end.

add_attr_to_atker(Fight, Attrs) ->
    #fight{atk_attr=AtkAttr} = Fight,
    AtkAttr2 = mod_attr:add(AtkAttr, Attrs),
    Fight#fight{atk_attr=AtkAttr2}.

add_attr_to_defer(Fight, Attrs) ->
    #fight{def_attr=DefAttr} = Fight,
    DefAttr2 = mod_attr:add(DefAttr, Attrs),
    Fight#fight{def_attr=DefAttr2}.

add_buff_to_atker(Fight, BuffID) ->
    #fight{atker=Atker, immune=ImmuneEffects} = Fight,
    #cfg_buff{effect=Effect} = cfg_buff:find(BuffID),
    case lists:member(Effect, ImmuneEffects) of
        true  ->
            Fight;
        false ->
            Atker2 = buff_util:add_buffs(Atker, [BuffID]),
            Fight#fight{atker=Atker2}
    end.

add_buff_to_defer(Fight, BuffID) ->
    #fight{defer=Defer, immune=ImmuneEffects} = Fight,
    #cfg_buff{effect=Effect} = cfg_buff:find(BuffID),
    case lists:member(Effect, ImmuneEffects) of
        true  ->
            Fight;
        false ->
            Defer2 = buff_util:add_buffs(Defer, [BuffID]),
            Fight#fight{defer=Defer2}
    end.


under_attack(Fight, Attack) ->
    #fight{defer=Defer, damage=Damage} = Fight,
    case Damage#damage.type == ?DAMAGE_MISS of
        true  ->
            Fight;
        false when ?is_mechamorph(Defer#actor.state) ->
            Fight2 = #fight{defer=Defer2} = absorb_mecha(Fight, Attack),
            DefHp  = ?_attr(Defer2#actor.attr, ?ATTR_HP),
            case DefHp =< 0 andalso ?is_unyield(Defer#actor.state) of
                true  -> may_unyield(Fight2, Attack);
                false -> Fight2
            end;
        false when ?is_shield(Defer#actor.state), ?is_timeboss(Defer) ->
            absorb_timeboss(Fight, Attack);
        false when ?is_shield(Defer#actor.state), ?is_siegeboss(Defer) ->
            absorb_siegeboss(Fight, Attack);
        false when ?is_shield(Defer#actor.state) ->
            absorb(Fight, Attack);
        false when ?is_leech(Defer#actor.state) ->
            leech(Fight, Attack);
        false ->
            Fight2 = #fight{defer=Defer2} = injure(Fight, Attack),
            DefHp  = ?_attr(Defer2#actor.attr, ?ATTR_HP),
            % ?debug("under_attack------------------:~w", [{DefHp, Defer#actor.state, ?is_unyield(Defer#actor.state)}]),
            case DefHp =< 0 andalso ?is_unyield(Defer#actor.state) of
                true  -> may_unyield(Fight2, Attack);
                false -> Fight2
            end
    end.

%% 吸收
absorb(Fight, Attack=#attack{unit=Unit}) ->
    #fight{defer=Defer, damage=Damage} = Fight,
    #actor{buffs=Buffs} = Defer,
    Buff = lists:keyfind(?BUFF_EFFECT_SHIELD, #p_buff.eff, maps:values(Buffs)),
    #p_buff{id=BuffID, value=BufVal, group=Group} = Buff,
    Absorb  = min(BufVal, Damage#damage.value),
    BufVal2 = BufVal - Absorb,
    NewDmg  = fight_util:damage(Defer, Unit, ?DAMAGE_ABSORB, Absorb),
    case BufVal2 > 0 of
        true  ->
            Buff2  = Buff#p_buff{value=BufVal2},
            Defer2 = Defer#actor{buffs=maps:put(Group, Buff2, Buffs)},
            Fight#fight{defer=Defer2, damage=NewDmg};
        false ->
            Defer2  = buff_util:del_buffs(Defer, [BuffID]),
            Damage2 = Damage#damage{
                value = round(Damage#damage.value - Absorb)
            },
            Fight2  = Fight#fight{
                defer   = Defer2,
                damage  = Damage2,
                damages = [NewDmg | Fight#fight.damages]
            },
            injure(Fight2, Attack)
    end.

%% 机甲变身护盾
absorb_mecha(Fight, Attack=#attack{unit=Unit}) ->
    #fight{defer=Defer, damage=Damage} = Fight,
    #actor{buffs=Buffs} = Defer,
    case lists:keyfind(?BUFF_EFFECT_MECHA_SHIELD, #p_buff.eff, maps:values(Buffs)) of
        false ->
            injure(Fight, Attack);
        Buff  ->
            #p_buff{id=BuffID, value=BufVal, group=Group} = Buff,
            Absorb  = min(BufVal, Damage#damage.value),
            BufVal2 = BufVal - Absorb,
            NewDmg  = fight_util:damage(Defer, Unit, ?DAMAGE_ABSORB, Absorb),
            case BufVal2 > 0 of
                true  ->
                    Buff2  = Buff#p_buff{value=BufVal2},
                    ?ucast(
                        Defer#actor.uid,
                        #m_buff_update_toc{
                            uid = Defer#actor.uid,
                            chg = [Buff2]
                        }
                    ),
                    Defer2 = Defer#actor{buffs=maps:put(Group, Buff2, Buffs)},
                    Fight#fight{defer=Defer2, damage=NewDmg};
                false ->
                    Defer2  = buff_util:del_buffs(Defer, [BuffID]),
                    Damage2 = Damage#damage{
                        value = round(Damage#damage.value - Absorb)
                    },
                    Fight2  = Fight#fight{
                        defer   = Defer2,
                        damage  = Damage2,
                        damages = [NewDmg | Fight#fight.damages]
                    },
                    injure(Fight2, Attack)
            end
    end.

%% 限时boss护盾
absorb_timeboss(Fight, Attack) ->
    #fight{atker=Atker, defer=Defer, damage=Damage} = Fight,
    #actor{buffs=Buffs, attr=Attr} = Defer,
    Buff = lists:keyfind(?BUFF_EFFECT_SHIELD, #p_buff.eff, maps:values(Buffs)),
    #p_buff{id=BuffID, value=BufVal, group=Group} = Buff,
    Absorb  = cfg_game:timeboss_shield_reduce(),
    BufVal2 = BufVal - Absorb,

    Defer2  = case BufVal2 > 0 of
        true  ->
            Buff2 = Buff#p_buff{value=BufVal2},
            ?bcast(
                scene_util:get_bc_roles(Defer),
                #m_buff_update_toc{
                    uid = Defer#actor.uid,
                    chg = [Buff2]
                }
            ),
            Defer#actor{buffs=maps:put(Group, Buff2, Buffs)};
        false ->
            buff_util:del_buffs(Defer, [BuffID])
    end,

    {Per1, Per2} = cfg_game:timeboss_shield_injure(),
    DmgVal = min(
        Damage#damage.value * ?_per(Per1),
        ?_attr(Attr,?ATTR_HPMAX) * ?_per(Per2)
    ),
    Damage2 = Damage#damage{value=round(DmgVal)},
    Fight2  = Fight#fight{defer=Defer2, damage=Damage2},

    ?_if(
        BufVal2 =< 0,
        scene_hook:hook_shield_break(Atker, Defer2, scene_util:get_state())
    ),

    injure(Fight2, Attack).

%% 夺城战boss护盾
absorb_siegeboss(Fight, Attack) ->
    #fight{defer=Defer, damage=Damage} = Fight,
    #actor{buffs=Buffs, attr=Attr} = Defer,
    Buff = lists:keyfind(?BUFF_EFFECT_SHIELD, #p_buff.eff, maps:values(Buffs)),
    #p_buff{id=BuffID, value=BufVal, group=Group} = Buff,
    Absorb  = cfg_game:siegeboss_shield_reduce(),
    BufVal2 = BufVal - Absorb,

    % ?debug("absorb_siegeboss: ~w", [BufVal2]),

    Defer2  = case BufVal2 > 0 of
        true  ->
            Buff2 = Buff#p_buff{value=BufVal2},
            ?bcast(
                scene_util:get_bc_roles(Defer),
                #m_buff_update_toc{
                    uid = Defer#actor.uid,
                    chg = [Buff2]
                }
            ),
            Defer#actor{buffs=maps:put(Group, Buff2, Buffs)};
        false ->
            buff_util:del_buffs(Defer, [BuffID])
    end,

    {Per1, Per2} = cfg_game:siegeboss_shield_injure(),
    DmgVal = min(
        Damage#damage.value * ?_per(Per1),
        ?_attr(Attr,?ATTR_HPMAX) * ?_per(Per2)
    ),
    Damage2 = Damage#damage{value=round(DmgVal)},
    Fight2  = Fight#fight{defer=Defer2, damage=Damage2},

    injure(Fight2, Attack).


%% 吸血
leech(Fight, _Attack) ->
    #fight{defer=Defer, damage=Damage} = Fight,
    BuffList = maps:values(Defer#actor.buffs),
    case lists:keyfind(?BUFF_EFFECT_LEECH, #p_buff.eff, BuffList) of
        false ->
            Fight;
        Buff  ->
            OldDefHp = ?_attr(Defer#actor.attr, ?ATTR_HP),
            DefHpMax = ?_attr(Defer#actor.attr, ?ATTR_HPMAX),
            HealHp   = round(Damage#damage.value * ?_per(Buff#p_buff.value)),
            NewDefHp = round( min(OldDefHp+HealHp, DefHpMax) ),
            Defer2   = Defer#actor{attr=?_setattr(Defer#actor.attr,?ATTR_HP,NewDefHp)},
            Damage2  = Damage#damage{hp=NewDefHp, type=?DAMAGE_HEAL, value=HealHp},
            Fight#fight{defer=Defer2, damage=Damage2}
    end.


%% 减血
injure(Fight, _Attack) ->
    #fight{atker=Atker, defer=Defer, damage=Damage} = Fight,
    OldDefHp = ?_attr(Defer#actor.attr,?ATTR_HP),
    ReduceHp = round(min(OldDefHp, Damage#damage.value)),
    NewDefHp = round(OldDefHp - ReduceHp),
    Damage2  = Damage#damage{hp=NewDefHp, value=ReduceHp},
    Defer1 = Defer#actor{attr=?_setattr(Defer#actor.attr,?ATTR_HP,NewDefHp)},
    Defer2 = fight_threat:update(Atker, Defer1, Damage2),
    Fight#fight{defer=Defer2, damage=Damage2}.

may_unyield(Fight, Attack) ->
    % ?debug("unyield---------------------------"),
    #fight{defer=Defer} = Fight,
    Buffs = maps:values(Defer#actor.buffs),
    Buff  = lists:keyfind(?BUFF_EFFECT_UNYIELD, #p_buff.eff, Buffs),
    Value = case Defer#actor.uid == 180000700000002084 of
        true  -> 1000;
        false -> Buff#p_buff.value
    end,
    case ut_rand:random(1, ?PER_10000) =< Value of
        true  -> unyield(Fight, Attack);
        false -> Fight
    end.

%% 不屈
unyield(Fight, _Attack) ->
    #fight{defer=Defer, damage=Damage} = Fight,
    Defer2  = Defer#actor{attr=?_setattr(Defer#actor.attr,?ATTR_HP,1)},
    Damage2 = Damage#damage{type=?DAMAGE_UNYIELD, hp=1, value=1},
    Fight#fight{defer=Defer2, damage=Damage2}.

deal_result(Fight) ->
    #fight{atker=Atker, defer=Defer} = Fight,
    DefHp  = ?_attr(Defer#actor.attr, ?ATTR_HP),
    Defer2 = case DefHp =< 0 of
        true  -> die(Atker, Defer);
        false -> Defer
    end,
    Fight#fight{defer=Defer2}.

die(Atker, Defer) ->
    #actor{uid=AtkID, type=AtkType} = Atker,
    Defer1 = Defer#actor{state=?ACTOR_STATE_DEATH, killer=AtkID},
    Defer2 = buff_util:del_buffs(Defer1, cfg_buff:remove(dead)),
    scene_actor:set_actor(Defer2),
    ?_if(?is_role(Defer), role:cast(Defer#actor.uid, {dead, AtkID, AtkType})),
    Defer2.
