%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(task_state).

-include("dunge.hrl").
-include("game.hrl").
-include("task.hrl").
-include("enum.hrl").
-include("table.hrl").

%% API
-export([init/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(Goal, Rest, Default) ->
	case Rest == [] of
		true  ->
			#goal{event=Event, target=Target, amount=Amount, conds=Conds} = Goal,
			do_init(Event, Target, Amount, Conds, Default);
		false ->
			Default
	end.

do_init(?EVENT_DUNGE_FLOOR, ?SCENE_STYPE_DUNGE_MAGICTOWER, CfgFloor, _Conds, Default) ->
	#dunge_magic{clear_floor=ClrFloor} = role_data:get(?DB_DUNGE_MAGIC),
	case ClrFloor >= CfgFloor of
		true  -> ?TASK_STATE_FINISH;
		false -> Default
	end;
do_init(?EVENT_LEVEL, _Target, TargetLevel, _Conds, Default)->
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	case Level >= TargetLevel of
		true  -> ?TASK_STATE_FINISH;
		false -> Default
	end;
do_init(_Event, _Target, _Amount, _Conds, Default) ->
	Default.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
