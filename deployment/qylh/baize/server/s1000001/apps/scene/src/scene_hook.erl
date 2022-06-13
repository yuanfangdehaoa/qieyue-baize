%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_hook).

-include("fight.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([hook_init/1]).
-export([hook_enter/2]).
-export([hook_relogin/2]).
-export([pre_leave/2]).
-export([hook_leave/2]).
-export([hook_move/3]).
-export([hook_born/2]).
-export([hook_fight/4]).
-export([hook_creep_dead/3]).
-export([hook_shield_break/3]).
-export([hook_drop/3]).
-export([hook_drop_exp/3]).
-export([hook_disappear/2]).
-export([hook_role_dead/3]).
-export([hook_dead_notify/3]).
-export([hook_revive/3]).
-export([hook_waveout/1]).
-export([hook_timeout/1]).
-export([hook_pickup/3]).
-export([hook_kickout/2]).
-export([hook_loopsec/2]).
-export([hook_destroy/1]).
-export([hook_start/1]).
-export([hook_over/2]).
-export([pre_enter/2]).
-export([pre_enter/3]).
-export([pre_pickup/3]).
-export([pre_collect/3]).
-export([finish_collect/3]).
-export([get_entry/2]).
-export([get_next/1]).
-export([get_drops/2]).
-export([get_expcoef/3]).
-export([create_opts/2]).
-export([enter_opts/2]).
-export([get_reborn/2]).

-define(is_exported(Mod, Fun, Arity),
    erlang:function_exported(Mod, Fun, Arity)).

-define(callback(SceneSt, Args),
    ?callback(SceneSt, Args, ok)).
-define(callback(SceneSt, Args, Return),
    case scene_router:event(SceneSt) of
        ?nil -> ignore;
        Mod1 -> Mod1:event(?FUNCTION_NAME, Args)
    end,
    case scene_router:route(SceneSt) of
        ?nil -> Return;
        Mod2 -> ?do_callback(Mod2, Args ++ [SceneSt], Return)
    end
).

-define(do_callback(Mod, Args, Return),
    case Mod == ?nil of
        true  ->
            Return;
        false ->
            % ?debug("do_callback----------:~w", [{Mod, erlang:module_loaded(Mod)}]),
            code:ensure_loaded(Mod),
            case ?is_exported(Mod, ?FUNCTION_NAME, length(Args)) of
                true  -> apply(Mod, ?FUNCTION_NAME, Args);
                false -> Return
            end
    end
).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 场景初始化
-spec hook_init(#scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_init(SceneSt) ->
    ?callback(SceneSt, []).


%%-----------------------------------------------
%% @doc 进入场景后
-spec hook_enter(#actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_enter(Actor, SceneSt) ->
    ?callback(SceneSt, [Actor]).


%%-----------------------------------------------
%% @doc 玩家重登
-spec hook_relogin(#actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_relogin(Actor, SceneSt) ->
    ?callback(SceneSt, [Actor]).


%%-----------------------------------------------
%% @doc 离开场景前
-spec pre_leave(#actor{}, #scene_st{}) ->
    #actor{}.
%%-----------------------------------------------
pre_leave(Actor, SceneSt) ->
    ?callback(SceneSt, [Actor], Actor).


%%-----------------------------------------------
%% @doc 离开场景后
-spec hook_leave(#actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_leave(Actor, SceneSt) ->
    ?callback(SceneSt, [Actor]).


%%-----------------------------------------------
%% @doc 移动
-spec hook_move(#actor{}, #p_coord{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_move(Actor, Coord, SceneSt) ->
    ?callback(SceneSt, [Actor, Coord]).


%%-----------------------------------------------
%% @doc 怪物出生
-spec hook_born(#actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_born(Actor, SceneSt) ->
    ?callback(SceneSt, [Actor]).


%%-----------------------------------------------
%% @doc 战斗
-spec hook_fight(#actor{}, #actor{}, integer(), #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_fight(Atker, Defer, DmgVal, SceneSt) ->
    ?callback(SceneSt, [Atker, Defer, DmgVal]).


%%-----------------------------------------------
%% @doc 怪物死亡
-spec hook_creep_dead(#actor{}, #actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_creep_dead(Atker, Defer, SceneSt) ->
    ?callback(SceneSt, [Atker, Defer]).


%%-----------------------------------------------
%% @doc 击破护盾
-spec hook_shield_break(#actor{}, #actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_shield_break(Atker, Defer, SceneSt) ->
    ?callback(SceneSt, [Atker, Defer]).


%%-----------------------------------------------
%% @doc 怪物掉落
-spec hook_drop(#actor{}, [#drop{}], #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_drop(Actor, Drops, SceneSt) ->
    ?callback(SceneSt, [Actor, Drops]).


%%-----------------------------------------------
%% @doc 怪物掉落
-spec hook_drop_exp(#actor{}, integer(), #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_drop_exp(Actor, Exp, SceneSt) ->
    ?callback(SceneSt, [Actor, Exp]).


%%-----------------------------------------------
%% @doc 怪物消失
-spec hook_disappear(#actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_disappear(Actor, SceneSt) ->
    ?callback(SceneSt, [Actor]).


%%-----------------------------------------------
%% @doc 玩家死亡
-spec hook_role_dead(#actor{}, #actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_role_dead(Atker, Defer, SceneSt) ->
    case ?is_role(Atker) of
        true  ->
            #actor{uid=RoleID, scene=SceneID, crime=Crime} = Atker,
            role_event:event(RoleID, ?EVENT_KILL_ROLE, {SceneID, Crime});
        false ->
            ignore
    end,
    ?callback(SceneSt, [Atker, Defer]).


%%-----------------------------------------------
%% @doc 死亡弹窗通知
-spec hook_dead_notify(#actor{}, #actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_dead_notify(Atker, Defer, SceneSt) ->
    case scene_router:route(SceneSt#scene_st.scene) of
        ?nil ->
            fight_dead:notify(Atker, Defer, SceneSt);
        Mod  ->
            code:ensure_loaded(Mod),
            case ?is_exported(Mod, hook_dead_notify, 3) of
                true  ->
                    Mod:hook_dead_notify(Atker, Defer, SceneSt);
                false ->
                    fight_dead:notify(Atker, Defer, SceneSt)
            end
    end.


%%-----------------------------------------------
%% @doc 复活
-spec hook_revive(#actor{}, integer(), #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_revive(Actor, Type, SceneSt) ->
    ?callback(SceneSt, [Actor, Type]).


%%-----------------------------------------------
%% @doc 波数超时
-spec hook_waveout(#scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_waveout(SceneSt) ->
    ?callback(SceneSt, []).


%%-----------------------------------------------
%% @doc 副本超时
-spec hook_timeout(#scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_timeout(SceneSt) ->
    ?callback(SceneSt, []).


%%-----------------------------------------------
%% @doc 拾取掉落
-spec hook_pickup(#drop{}, #p_item{}, #role_st{}) ->
    no_return().
%%-----------------------------------------------
hook_pickup(Drop, Item, RoleSt) ->
    Mod = scene_router:route(RoleSt#role_st.scene),
    ?do_callback(Mod, [Drop, Item, RoleSt], ok).


%%-----------------------------------------------
%% @doc 踢出场景
-spec hook_kickout(#actor{}, #role_st{}) ->
    #actor{}.
%%-----------------------------------------------
hook_kickout(Actor, RoleSt) ->
    Mod = scene_router:route(RoleSt#role_st.scene),
    ?do_callback(Mod, [Actor, RoleSt], Actor).


%%-----------------------------------------------
%% @doc 每秒循环
-spec hook_loopsec(integer(), #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_loopsec(Seconds, SceneSt) ->
    Mod = scene_router:route(SceneSt),
    ?do_callback(Mod, [Seconds, SceneSt], ok).


%%-----------------------------------------------
%% @doc 场景销毁
-spec hook_destroy(#scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_destroy(SceneSt) ->
    ?callback(SceneSt, []).


%%-----------------------------------------------
%% @doc 副本开始
-spec hook_start(#scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_start(SceneSt) ->
    ?callback(SceneSt, []).


%%-----------------------------------------------
%% @doc 副本结束
-spec hook_over(integer(), #scene_st{}) ->
    no_return().
%%-----------------------------------------------
hook_over(RoleID, SceneSt) ->
    ?callback(SceneSt, [RoleID]).


%%-----------------------------------------------
%% @doc 场景进入前
-spec pre_enter(integer(), map(), #role_st{}) ->
    no_return().
%%-----------------------------------------------
pre_enter(SceneID, Args, RoleSt) ->
    Mod = scene_router:route(SceneID),
    ?do_callback(Mod, [SceneID, Args, RoleSt], ok).


%%-----------------------------------------------
-spec pre_enter(#actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
pre_enter(Actor, SceneSt) ->
    ?callback(SceneSt, [Actor]).



%%-----------------------------------------------
%% @doc 拾取前检测
-spec pre_pickup(#actor{}, #actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
pre_pickup(Actor, Drop, SceneSt) ->
    ?callback(SceneSt, [Actor, Drop]).


%%-----------------------------------------------
%% @doc 采集前检测
-spec pre_collect(#actor{}, #actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
pre_collect(Actor, Collect, SceneSt) ->
    ?callback(SceneSt, [Actor, Collect]).

%%-----------------------------------------------
%% @doc 完成采集
-spec finish_collect(#actor{}, #actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
finish_collect(Actor, Collect, SceneSt) ->
    ?callback(SceneSt, [Actor, Collect]).

%%-----------------------------------------------
%% @doc 获取副本入口
-spec get_entry(integer(), #role_st{}) ->
    integer().
%%-----------------------------------------------
get_entry(SType, RoleSt) ->
    case scene_router:route(?SCENE_TYPE_DUNGE, SType) of
        ?nil ->
            #{};
        Mod  ->
            code:ensure_loaded(Mod),
            case ?is_exported(Mod, ?FUNCTION_NAME, 1) of
                true  -> Mod:get_entry(RoleSt);
                false -> #{}
            end
    end.

%%-----------------------------------------------
%% @doc 获取副本入口
-spec get_next(#role_st{}) ->
    integer().
%%-----------------------------------------------
get_next(RoleSt) ->
    case scene_router:route(?SCENE_TYPE_DUNGE, RoleSt#role_st.stype) of
        ?nil ->
            #{};
        Mod  ->
            code:ensure_loaded(Mod),
            case ?is_exported(Mod, ?FUNCTION_NAME, 1) of
                true  -> Mod:get_next(RoleSt);
                false -> #{}
            end
    end.

create_opts(Entry, RoleSt) ->
    #entry{stype=SType, dunge=DungeID, floor=FloorID} = Entry,
    Opts1 = #{dunge=>DungeID, floor=>FloorID},
    Opts2 = case scene_router:route(?SCENE_TYPE_DUNGE, SType) of
        ?nil ->
            #{};
        Mod  ->
            code:ensure_loaded(Mod),
            case ?is_exported(Mod, ?FUNCTION_NAME, 2) of
                true  -> Mod:create_opts(Entry, RoleSt);
                false -> #{}
            end
    end,
    maps:merge(Opts1, Opts2).

enter_opts(Entry, RoleSt) ->
    case scene_router:route(?SCENE_TYPE_DUNGE, Entry#entry.stype) of
        ?nil ->
            #{};
        Mod  ->
            code:ensure_loaded(Mod),
            case ?is_exported(Mod, ?FUNCTION_NAME, 2) of
                true  -> Mod:enter_opts(Entry, RoleSt);
                false -> #{}
            end
    end.


%%-----------------------------------------------
%% @doc 获取额外的掉落
-spec get_drops(#actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
get_drops(Actor, SceneSt) ->
    ?callback(SceneSt, [Actor], []).


%%-----------------------------------------------
%% @doc 获取额外的经验加成系数
-spec get_expcoef(#actor{}, #actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
get_expcoef(Atker, Defer, SceneSt) ->
    ?callback(SceneSt, [Atker, Defer], 0).


%%-----------------------------------------------
%% @doc 获取复活点
-spec get_reborn(#actor{}, #scene_st{}) ->
    no_return().
%%-----------------------------------------------
get_reborn(Actor, SceneSt = #scene_st{scene=SceneID}) ->
    ?callback(SceneSt, [Actor], scene_util:get_reborn(SceneID)).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
