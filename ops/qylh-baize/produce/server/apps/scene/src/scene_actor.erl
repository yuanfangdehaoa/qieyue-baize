%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_actor).

-include("attr.hrl").
-include("buff.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([get_actor/1]).
-export([set_actor/1]).
-export([del_actor/1]).
-export([get_autoid/0]).
-export([set_state/2]).
-export([clr_state/2]).
-export([get_actids/0, get_actids/1, get_actids/2]).
-export([set_actids/1]).
-export([del_actid/3]).
-export([recalc_attr/1]).
-export([update_actor/2]).
-export([notify_hp/3]).
-export([notify_state/1]).
-export([rush/3]).
-export([coll_start/2]).
-export([coll_stop/2]).
-export([nobody/0]).
-export([update_afk_rank/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 获取 Actor 信息
get_actor(ActorID) ->
    get({k_actor, ActorID}).

set_actor(Actor) ->
    put({k_actor, Actor#actor.uid}, Actor).

del_actor(ActorID) ->
    erase({k_actor, ActorID}).

%% 获取 Actor 递增id
get_autoid() ->
	AutoID = case get(k_autoid) of
		?nil -> 2000000;
		ID   -> ID
	end,
	put(k_autoid, AutoID+1),
	AutoID.

set_state(Actor, State) ->
    Actor#actor{state=?_bis(Actor#actor.state, State)}.

clr_state(Actor, State) ->
    Actor#actor{state=?_bic(Actor#actor.state, State)}.

%% 获取场景中的 ActorID
-define(k_actids, k_actids).
get_actids() ->
    get(?k_actids).

get_actids(Type) ->
    maps:get(Type, get(?k_actids), []).

get_actids(Type, Coord) ->
    scene_grid:get_actids(Type, Coord).

set_actids(ActIDs) ->
    put(?k_actids, ActIDs).

del_actid(ActorID, Type, Coord) ->
    scene_grid:del_actid(ActorID, Type, Coord).

%% 重算 Actor 属性
recalc_attr(Actor) ->
    #actor{initattr=InitAttr, attr=OldAttr, buffs=Buffs} = Actor,
    Actor#actor{
        buffattr = recalc_with_buff(InitAttr, OldAttr, Buffs, true),
        attr     = recalc_with_buff(InitAttr, OldAttr, Buffs, false)
    }.

%% 更新 Actor
update_actor(KVList, Actor) ->
    do_update(KVList, Actor, #m_actor_update_toc{}).

%% 血量更新通知
notify_hp(Actor, Change, Type) ->
    #actor{uid=ActorID, attr=Attr} = Actor,
    Toc = #m_actor_heal_toc{
        uid  = ActorID,
        hp   = ?_attr(Attr, ?ATTR_HP),
        type = Type,
        heal = Change
    },
    ?bcast(scene_util:get_bc_roles(Actor), Toc).

%% 状态更新通知
notify_state(Actor) ->
    scene_util:bc_to_grid(Actor#actor.coord, #m_actor_update_toc{
        uid   = Actor#actor.uid,
        upint = #{"state"=>Actor#actor.state}
    }).

rush(Actor, Dest, SceneSt) ->
    scene_grid:move(Actor, Dest, SceneSt),
    scene_actor:set_actor(Actor#actor{coord=Dest, dest=Dest}),
    ?bcast(
        scene_util:get_bc_roles(Actor),
        #m_scene_rush_toc{uid=Actor#actor.uid, coord=Dest}
    ).

coll_start(Actor, CollID) ->
    #actor{state=State, exargs=ExArgs} = Actor,
    Actor2 = Actor#actor{
        state  = ?_bis(State, ?ACTOR_STATE_COLLECT),
        exargs = maps:put(coll, CollID, ExArgs)
    },
    scene_actor:set_actor(Actor2),
    notify_state(Actor2).

coll_stop(Actor, UpdateColl) ->
    #actor{state=State, exargs=ExArgs} = Actor,
    Actor2 = Actor#actor{
        state  = ?_bic(State, ?ACTOR_STATE_COLLECT),
        exargs = maps:remove(coll, ExArgs)
    },
    scene_actor:set_actor(Actor2),
    notify_state(Actor2),
    case UpdateColl of
        true  ->
            CollID = maps:get(coll, ExArgs, 0),
            case scene_actor:get_actor(CollID) of
                ?nil -> ignore;
                Coll -> buff_util:del_buffs(Coll, [?BUFF_ID_OCCUPY])
            end;
        false ->
            ok
    end.

nobody() ->
    get_actids(?ACTOR_TYPE_ROLE) == [].

update_afk_rank(Actor) ->
    case ?is_role(Actor) of
        true  ->
            #actor{uid=ActorID, level=Level, attr=Attr} = Actor,
            AfkEff = role_afk:effect(Level, Attr),
            rank:update_rank(?RANK_ID_AFK, ActorID, AfkEff);
        false ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 升级
do_update([{level, NewLv} | T], Actor, Toc) ->
    update_cache(Actor, [{#role_cache.level, NewLv}]),
    Actor2 = Actor#actor{level=NewLv},
    do_update(T, Actor2, Toc);
%% 帮派变化
do_update([{guild, GuildID, GuildName, GuildPost} | T], Actor, Toc) ->
    update_cache(Actor, [
        {#role_cache.guild, GuildID},
        {#role_cache.gpost, GuildPost},
        {#role_cache.gname, GuildName}
    ]),
    Actor2 = Actor#actor{guild=GuildID, gname=GuildName, gpost=GuildPost},
    Toc2 = Toc#m_actor_update_toc{
        upint = maps:put("guild", GuildID, Toc#m_actor_update_toc.upint),
        upstr = maps:put("gname", GuildName, Toc#m_actor_update_toc.upstr)
    },
    do_update(T, Actor2, Toc2);
%% 帮派职位变化
do_update([{guild_post, GuildPost} | T], Actor, Toc) ->
    update_cache(Actor, [{#role_cache.gpost, GuildPost}]),
    Actor2 = Actor#actor{gpost=GuildPost},
    do_update(T, Actor2, Toc);
%% 队伍变化
do_update([{team, TeamID, Captain} | T], Actor, Toc) ->
    case TeamID > 0 of
        true  -> scene_team:add_memb(TeamID, Actor#actor.uid);
        false -> scene_team:del_memb(Actor#actor.team, Actor#actor.uid)
    end,
    Actor2 = Actor#actor{team=TeamID, captain=Captain},
    Toc2 = Toc#m_actor_update_toc{
        upstr = maps:put("team", ut_conv:to_list(TeamID), Toc#m_actor_update_toc.upstr)
    },
    do_update(T, Actor2, Toc2);
%% 上下坐骑
do_update([{mount, Speed, AspKey, Aspect} | T], Actor, Toc) ->
    #actor{uid=ActorID, initattr=InitAttr, figure=Figure} = Actor,
    Figure2 = maps:put(AspKey, Aspect, Figure),
    Actor1  = Actor#actor{figure=Figure2},
    Actor2  = Actor1#actor{initattr=?_setattr(InitAttr, ?ATTR_SPEED, Speed)},
    Actor3  = ?MODULE:recalc_attr(Actor2),
    Speed2  = ?_attr(Actor3#actor.attr, ?ATTR_SPEED),
    ?ucast(ActorID, #m_role_update_toc{upint=#{"attr.speed"=>Speed2}}),
    AspKey2 = io_lib:format("figure.~s", [AspKey]),
    Toc2 = Toc#m_actor_update_toc{
        upint  = maps:put("attr.speed", Speed2, Toc#m_actor_update_toc.upint),
        aspect = maps:put(AspKey2, Aspect, Toc#m_actor_update_toc.aspect)
    },
    do_update(T, Actor3, Toc2);
%% 更新形象
do_update([{figure, AspKey, Aspect} | T], Actor, Toc)->
    Figure2 = maps:put(AspKey, Aspect, Actor#actor.figure),
    update_cache(Actor, [{#role_cache.figure, Figure2}]),
    Actor2  = Actor#actor{figure=Figure2},
    AspKey2 = io_lib:format("figure.~s", [AspKey]),
    Toc2 = Toc#m_actor_update_toc{
        aspect = maps:put(AspKey2, Aspect, Toc#m_actor_update_toc.aspect)
    },
    do_update(T, Actor2, Toc2);
do_update([{delskill, SkillID} | T], Actor, Toc) ->
    case maps:find(SkillID, Actor#actor.skills) of
        {ok, SkillLv} ->
            Actor1 = Actor#actor{skills=maps:remove(SkillID, Actor#actor.skills)},
            #cfg_skill_level{buffs=Buffs} = cfg_skill_level:find(SkillID, SkillLv),
            Actor2 = buff_util:add_buffs(Actor1, Buffs),
            do_update(T, Actor2, Toc);
        error ->
            do_update(T, Actor, Toc)
    end;
do_update([{addskill, SkillID, SkillLv} | T], Actor, Toc) ->
    Actor1 = Actor#actor{skills=maps:put(SkillID, SkillLv, Actor#actor.skills)},
    #cfg_skill_level{buffs=Buffs} = cfg_skill_level:find(SkillID, SkillLv),
    Actor2 = buff_util:add_buffs(Actor1, Buffs),
    do_update(T, Actor2, Toc);
%% 婚姻变化
do_update([{marriage, Marry, MName, MType} | T], Actor, Toc) ->
    Actor2 = Actor#actor{marry=Marry, mname=MName, mtype=MType},
    UpInt  = #{"marry"=>Marry, "mtype"=>MType},
    Toc2 = Toc#m_actor_update_toc{
        upint = maps:merge(Toc#m_actor_update_toc.upint, UpInt),
        upstr = maps:put("mname", MName, Toc#m_actor_update_toc.upstr)
    },
    do_update(T, Actor2, Toc2);
%% 头像变化
do_update([{icon, Icon} | T], Actor, Toc) ->
    update_cache(Actor, [{#role_cache.icon, Icon}]),
    Actor2 = Actor#actor{icon=Icon},
    Toc2   = Toc#m_actor_update_toc{icon=Icon},
    do_update(T, Actor2, Toc2);
%% 更新属性
do_update([{attr, Attr, Power} | T], Actor, Toc) ->
    Actor1 = Actor#actor{initattr=Attr, power=Power},
    Actor2 = #actor{attr=Attr2} = ?MODULE:recalc_attr(Actor1),
    UpInt  = #{
        "hp"    => ?_attr(Attr2, ?ATTR_HP),
        "hpmax" => ?_attr(Attr2, ?ATTR_HPMAX)
    },
    ?ucast(Actor#actor.uid, #m_role_upattr_toc{
        attr  = mod_attr:p_attr(Attr2),
        power = Power
    }),
    update_afk_rank(Actor2),
    Toc2 = Toc#m_actor_update_toc{
        upint = maps:merge(Toc#m_actor_update_toc.upint, UpInt)
    },
    do_update(T, Actor2, Toc2);
% 名字
do_update([{name, Name} | T], Actor, Toc) ->
    update_cache(Actor, [{#role_cache.name, Name}]),
    Actor2 = Actor#actor{name=Name},
    Toc2 = Toc#m_actor_update_toc{
        upstr = maps:put("name", Name, Toc#m_actor_update_toc.upstr)
    },
    do_update(T, Actor2, Toc2);
%% vip升级
do_update([{viplv, NewLv} | T], Actor, Toc) ->
    Actor2 = Actor#actor{viplv=NewLv},
    do_update(T, Actor2, Toc);
% 敌对服务器
do_update([{hostile, Hostile} | T], Actor, Toc) ->
    Actor2 = Actor#actor{hostile=Hostile},
    do_update(T, Actor2, Toc);
do_update([], Actor, Toc) ->
    {Actor, Toc}.

recalc_with_buff(InitAttr, OldAttr, Buffs, IsFilter) ->
    Attr = maps:fold(fun
        (_Group, Buff, Acc) ->
            case Buff#p_buff.attrs == [] of
                true  ->
                    Acc;
                false ->
                    #cfg_buff{notify=Notify} = cfg_buff:find(Buff#p_buff.id),
                    case (not IsFilter) orelse Notify of
                        true  -> mod_attr:add(Acc, Buff#p_buff.attrs);
                        false -> Acc
                    end
            end
    end, InitAttr, Buffs),
    Attr1 = mod_attr:calc_global_pro(Attr),
    NewHp = calc_hp(OldAttr, Attr1),
    ?_setattr(Attr1, ?ATTR_HP, NewHp).

calc_hp(OldAttr, NewAttr) ->
    OldHpMax = ?_attr(OldAttr, ?ATTR_HPMAX),
    NewHpMax = ?_attr(NewAttr, ?ATTR_HPMAX),
    OldHp = ?_attr(OldAttr, ?ATTR_HP, ?nil),
    NewHp = case OldHp == ?nil of
        true  ->
            NewHpMax;
        false ->
            case OldHp =< 0 of
                true  ->
                    0;
                false ->
                    case OldHpMax == NewHpMax of
                        true  -> OldHp;
                        false -> max(1, round((NewHpMax/OldHpMax)*OldHp))
                    end
            end
    end,
    round(NewHp).

update_cache(Actor, KVList) ->
    ?_if(cluster:is_cross(), role_cache:update(Actor#actor.uid, KVList)).
