%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(yunying_reward).

-include("game.hrl").
-include("yunying.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("table.hrl").
-include("role.hrl").

%% API
-export([give/1, give/3]).
-export([calc/4]).
-export([listen_check/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 发放奖励
give(YYActID) ->
	AllRoles = yunying_agent:get_yy_roles(YYActID),
	lists:foreach(fun
		(#yy_role{key={_, RoleID}, tasks=Tasks}) ->
			do_give(YYActID, RoleID, Tasks)
	end, AllRoles).

give(YYActID, RoleID, Tasks) ->
	do_give(YYActID, RoleID, Tasks).

calc(RoleID, YYActID, TaskID, Tasks) ->
	#cfg_yunying_reward{reqs=Reqs, reward=Rewards} = find(YYActID, TaskID),
	case check(RoleID, Reqs, Tasks) of
		true  -> Rewards;
		false -> throw(?err(?ERR_YUNYING_NOT_REACH))
	end.

listen_check(RoleID, Reqs0, Tasks) ->
	Reqs = lists:filter(fun(Req) ->
		element(1, Req) == opdays
	end, Reqs0),
	check(RoleID, Reqs, Tasks).

reward_check(RoleID, Reqs0, Tasks) ->
	Reqs = lists:filter(fun(Req) ->
		element(1, Req) =/= opdays
	end, Reqs0),
	check(RoleID, Reqs, Tasks).

check(RoleID, [{opdays, Min, Max} | T], Tasks) ->
	Days = game_env:get_opened_days(),
	case Min =< Days andalso Days =< Max of
		true  -> check(RoleID, T, Tasks);
		false -> false
	end;
check(RoleID, [{vip, Min, Max} | T], Tasks) ->
	{ok, #role_cache{viplv=Vip}} = role:get_cache(RoleID),
	if
		Vip >= Min, Vip =< Max ->
			check(RoleID, T, Tasks);
		true ->
			false
	end;
check(RoleID, [{vip, NeedVip} | T], Tasks) ->
	{ok, #role_cache{viplv=Vip}} = role:get_cache(RoleID),
	if
		Vip >= NeedVip ->
			check(RoleID, T, Tasks);
		true ->
			false
	end;
check(RoleID, [{mutex, TaskID} | T], Tasks) ->
	Task = maps:get(TaskID, Tasks, ?nil),
	case Task /= ?nil andalso Task#yy_task.state /= ?YY_TASK_STATE_REWARD of
		true ->
			check(RoleID, T, Tasks);
		false ->
			false
	end;
check(RoleID, [_ | T], Tasks) ->
  check(RoleID, T, Tasks);
check(_, [], _) ->
	true.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_give(YYActID, RoleID, Tasks) ->
	try
		do_give2(YYActID, RoleID, Tasks)
	catch Class2:Reason2:Stacktrace2 ->
		?stacktrace(Class2, Reason2, Stacktrace2)
	end.

do_give2(YYActID, RoleID, Tasks) ->
	Mod  = yunying_util:cfg_act_mod(YYActID),
	#cfg_yunying{name=Name, mail=MailID, rank=RankID} = Mod:find(YYActID),
	Rank = ?_if(RankID > 0, rank:get_rank(RankID, RoleID), 0),
	Gain = maps:fold(fun
		(TaskID, Task, Acc) ->
			#cfg_yunying_reward{reward=Rewards, goal=Goal, reqs=Reqs} = find(YYActID, TaskID),
			case reward_check(RoleID, Reqs, Tasks) of
				true ->
					if
						RankID > 0 ->
							{_, Min, Max} = Goal,
							case Min =< Rank andalso Rank =< Max of
								true  -> Rewards ++ Acc;
								false -> Acc
							end;
						Task#yy_task.state == ?YY_TASK_STATE_FINISH ->
							Rewards ++ Acc;
						true ->
							Acc
					end;
				false ->
					Acc
			end
	end, [], Tasks),
	case Gain /= [] of
		true when RankID > 0 ->
			{FmtTitle, FmtText} = cfg_mail:find(MailID),
			Title = io_lib:format(FmtTitle, [Name]),
			Text  = io_lib:format(FmtText, [Name, Rank]),
			mail:send(RoleID, Title, Text, Gain);
		true  ->
			mail:send(RoleID, MailID, Gain, [Name]);
		false ->
			ignore
	end.

find(YYActID, TaskID) ->
	Mod = yunying_util:cfg_reward_mod(YYActID),
	Mod:find(YYActID, TaskID).
