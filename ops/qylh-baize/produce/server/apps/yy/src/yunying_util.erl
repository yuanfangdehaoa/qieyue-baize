%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(yunying_util).

-include("game.hrl").
-include("role.hrl").
-include("pay.hrl").
-include("yunying.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([reg_name/1]).
-export([hook_start/2]).
-export([hook_stop/2]).
-export([cfg_act_mod/1]).
-export([cfg_reward_mod/1]).
-export([calc_logid/1]).
-export([p_yy_task/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
reg_name(YYActID) ->
    ut_conv:to_atom( lists:concat(["yunying-", YYActID]) ).

hook_start(YYActID, RoleSt) ->
	yunying_task:add_listen(YYActID, RoleSt).

hook_stop(YYActID, _RoleSt) ->
	yunying_task:del_listen(YYActID).

cfg_act_mod(YYActID) ->
	case YYActID div 100000 of
		1 -> cfg_yunying;
		2 -> cfg_festival
	end.

cfg_reward_mod(YYActID) ->
	case YYActID div 100000 of
		1 -> cfg_yunying_reward;
		2 -> cfg_festival_reward
	end.

calc_logid(YYActID) ->
	Mod = cfg_act_mod(YYActID),
	#cfg_yunying{type=Type} = Mod:find(YYActID),
	1700*1000+Type.

p_yy_task(YYActID, Task) ->
	Mod = yunying_util:cfg_reward_mod(YYActID),
	CfgReward = Mod:find(YYActID, Task#yy_task.id),
	#cfg_yunying_reward{trigger=Trigger, goal=Goal} = CfgReward,
	Count = case Trigger of
		{done, _} ->
			#yy_task{count=Count1} = Task,
			case Goal of
				{NeedTimes, _Times} ->
					min(Count1 div NeedTimes, NeedTimes);
				_ ->
					Task#yy_task.count
			end;
		_ ->
			Task#yy_task.count
	end,
	#p_yy_task{
		id    = Task#yy_task.id,
		level = CfgReward#cfg_yunying_reward.level,
		count = Count,
		state = Task#yy_task.state
	}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
