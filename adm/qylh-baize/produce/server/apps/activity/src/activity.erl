%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(activity).

-include("activity.hrl").
-include("game.hrl").
-include("role.hrl").
-include("enum.hrl").

%% API
-export([is_start/1]).
-export([is_stop/1]).
-export([reload/1]).
-export([activity/1]).
-export([stime/1]).
-export([etime/1]).
-export([get_acts/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 活动是否已开启
is_start(ActID) ->
	case ets:lookup(?ETS_ACTIVITY, ActID) of
		[R] -> R#activity.state == ?ACT_ST_STARTED;
		[]  -> false
	end.

%% 活动是否已关闭
is_stop(ActID) ->
    case ets:lookup(?ETS_ACTIVITY, ActID) of
        [R] -> R#activity.state == ?ACT_ST_STOPPED;
        []  -> false
    end.

%% 重新加载配置
reload(ActID) ->
	activity_manager:reload(ActID).

activity(ActID) ->
	case ets:lookup(?ETS_ACTIVITY, ActID) of
        [R] -> R;
        []  -> ?nil
    end.

stime(ActID) ->
	case ets:lookup(?ETS_ACTIVITY, ActID) of
        [R] -> R#activity.stime;
        []  -> 0
    end.

etime(ActID) ->
    case ets:lookup(?ETS_ACTIVITY, ActID) of
        [R] -> R#activity.etime;
        []  -> 0
    end.

%% 获取当前日期应该开单服还是跨服活动
get_acts(Group) ->
    case get_acts(Group, ?ACTIVITY_TYPE_LOCAL) of
        [] -> cfg_activity:group(Group, ?ACTIVITY_TYPE_CROSS);
        L  -> L
    end.

get_acts(Group, Type) ->
    Opdays = game_env:get_opened_days(),
    ActIDs = cfg_activity:group(Group, Type),
    lists:filter(fun
        (ActID) ->
            #cfg_activity{reqs=Reqs} = cfg_activity:find(ActID),
            case lists:keyfind(opdays, 1, Reqs) of
                {opdays, Min} ->
                    Opdays >= Min;
                {opdays, Min, Max} ->
                    Opdays >= Min andalso Opdays =< Max;
                _ ->
                    true
            end
    end, ActIDs).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
