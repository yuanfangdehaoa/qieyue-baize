%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(yunying).

-include("yunying.hrl").

%% API
-export([is_start/1]).
-export([is_show/1]).
-export([get_act_time/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 活动是否已开启
is_start(YYActID) ->
	case ets:lookup(?ETS_YY_ACT, YYActID) of
		[R] -> R#yy_act.act_state == ?YY_ST_STARTED;
		[]  -> false
	end.

%% 活动是否展示中
is_show(YYActID) ->
	case ets:lookup(?ETS_YY_ACT, YYActID) of
		[R] -> R#yy_act.show_state == ?YY_ST_STARTED;
		[]  -> false
	end.

get_act_time(YYActID) ->
	case ets:lookup(?ETS_YY_ACT, YYActID) of
		[R] when R#yy_act.act_state == ?YY_ST_STARTED ->
			{ok, R#yy_act.act_stime, R#yy_act.act_etime};
		_ ->
			error
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
