%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_ai).

-include("btree.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([run/2]).
%% Internal API
-export([callback/2]).
-export([sleep/2]).
-export([clear_sleep/0]).
-export([summon/1]).
-export([over/2]).
-export([stat/1]).
-export([clear/1]).
-export([kickout/1]).
-export([stop/1]).
-export([is_clear/1]).
-export([is_over/1]).
-export([is_boss_dead/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
run(dunge_ai, [Mod, Fun | Args]) ->
	% ?debug("run2---------------:~w", [{Mod, Fun, Args}]),
	SceneSt = scene_util:get_state(),
	apply(Mod, Fun, Args ++ [SceneSt]).

%% 设置回调模块
callback(Mod, _SceneSt) ->
	% ?debug("~ts:~w", ["设置回调模块", Mod]),
	DungeSt = dunge_util:get_state(),
	dunge_util:set_state(DungeSt#dunge_st{mod=Mod}),
	?SUCCESS.

%% 准备倒计时
sleep(prep, #scene_st{stype=SType}) ->
	#cfg_dunge_cd{prep=PrepCD} = cfg_dunge:cd(SType),
	% ?debug("~ts:~w", ["准备倒计时", PrepCD]),
	do_sleep(PrepCD);
%% 结算倒计时
sleep(stat, #scene_st{stype=SType}) ->
	#cfg_dunge_cd{stat=StatCD} = cfg_dunge:cd(SType),
	% ?debug("~ts:~w", ["结算倒计时", StatCD]),
	do_sleep(StatCD);
%% 退出倒计时
sleep(exit, #scene_st{stype=SType}) ->
	#cfg_dunge_cd{exit=ExitCD} = cfg_dunge:cd(SType),
	% ?debug("~ts: ~w", ["退出倒计时", ExitCD]),
	do_sleep(ExitCD + 30).

clear_sleep() ->
    DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
    case maps:find(sleep, Opts) of
        {ok, _} ->
            Opts2 = maps:remove(sleep, Opts),
            dunge_util:set_state(DungeSt#dunge_st{opts=Opts2});
        _ ->
            ignore
    end,
    ?SUCCESS.

%% 生成怪物
summon(SceneSt) ->
	dunge_aiwave:summon(SceneSt),
	?SUCCESS.

%% 副本结束
over(IsClear, SceneSt) ->
	% ?debug("~ts", ["副本结束"]),
	DungeSt = dunge_util:get_state(),
	case DungeSt#dunge_st.over of
		true  ->
			?FAILURE;
		false ->
			dunge_util:set_state(DungeSt#dunge_st{
				over  = true,
				clear = IsClear,
				used  = ut_time:seconds() - SceneSt#scene_st.stime
			}),
			?SUCCESS
	end.

%% 清怪
clear(SceneSt) ->
	% ?debug("~ts", ["清怪"]),
	#dunge_st{mod=Mod} = dunge_util:get_state(),
	case Mod == ?nil of
		true  ->
			creep_agent:clear(SceneSt);
		false ->
			code:ensure_loaded(Mod),
			case erlang:function_exported(Mod, clear, 1) of
				true  ->
					Mod:clear(SceneSt);
				false ->
					creep_agent:clear(SceneSt)
			end
	end,
	?SUCCESS.

%% 副本结算
stat(SceneSt) ->
	% ?debug("~ts", ["副本结算"]),
	DungeSt = dunge_util:get_state(),
	#dunge_st{id=DungeID, mod=Mod, stat=IsStat, roles=Roles} = DungeSt,
	case IsStat of
		true  ->
			ignore;
		false ->
			case Mod == ?nil of
				true  ->
					do_stat(DungeSt, SceneSt);
				false ->
					code:ensure_loaded(Mod),
					case erlang:function_exported(Mod, stat, 1) of
						true  ->
							Mod:stat(SceneSt);
						false ->
							do_stat(DungeSt, SceneSt)
					end
			end
	end,
	DungeSt1 = dunge_util:get_state(),
	dunge_util:set_state(DungeSt1#dunge_st{stat=true}),
	#cfg_dunge{type=Type} = cfg_dunge:find(DungeID),
	AnyRole = lists:any(fun(RoleID) -> role:is_online(RoleID) end, Roles),
	CanStop = (not AnyRole) andalso
		(Type == ?DUNGE_TYPE_ROLE orelse Type == ?DUNGE_TYPE_TEAM),
	?_if(CanStop, erlang:send(self(), {stop, normal})),
	?SUCCESS.

%% 踢出副本
kickout(SceneSt) ->
	?debug("~ts ~w ~w", ["踢出副本", SceneSt#scene_st.scene, scene_actor:get_actids(?ACTOR_TYPE_ROLE)]),
	scene_util:kickout(SceneSt),
	?SUCCESS.

%% 副本关闭
stop(_SceneSt) ->
	?debug("~ts ~w ~w", ["副本关闭", _SceneSt#scene_st.scene, scene_actor:get_actids(?ACTOR_TYPE_ROLE)]),
	scene:cast(self(), {stop, normal}),
	?SUCCESS.

%% 是否已通关
is_clear(_SceneSt) ->
	DungeSt = dunge_util:get_state(),
	DungeSt#dunge_st.clear.

%% 是否已经结算了
is_over(_SceneSt) ->
	DungeSt = dunge_util:get_state(),
	DungeSt#dunge_st.over.

is_boss_dead(_SceneSt) ->
    {hook_creep_dead, [_Atker, Defer]} = dunge_util:get_event(),
    Defer#actor.rarity == ?CREEP_RARITY_BOSS2.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_sleep(Secs) ->
	DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
	case maps:find(sleep, Opts) of
	    {ok, N} when N =< 1 ->
	        Opts2 = maps:remove(sleep, Opts),
	        dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
	        ?SUCCESS;
	    {ok, N} ->
	        Opts2 = maps:put(sleep, N-1, Opts),
	        dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
	        ?RUNNING;
	    error when Secs =< 0 ->
	    	?SUCCESS;
	    error ->
			Opts2 = maps:put(sleep, Secs, Opts),
	        dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
	        ?RUNNING
	end.

do_stat(DungeSt, SceneSt) ->
	#dunge_st{clear=IsClear, roles=Roles} = DungeSt,
	case Roles of
		[RoleID] ->
			?ucast(RoleID, #m_dunge_over_toc{
				stype = SceneSt#scene_st.stype,
				id    = SceneSt#scene_st.dunge,
				clear = IsClear
			});
		_ ->
			ignore
	end.
