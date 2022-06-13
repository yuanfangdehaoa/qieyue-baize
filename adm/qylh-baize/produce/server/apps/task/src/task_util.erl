%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(task_util).

-include("game.hrl").
-include("role.hrl").
-include("task.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([p_task/1]).
-export([is_expired/2]).
-export([check_reqs/2]).
-export([update_notify/5]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
p_task(Task) ->
	Goals = if
		Task#task.type == ?TASK_TYPE_DAILY;
		Task#task.type == ?TASK_TYPE_GUILD ->
            lists:map(fun
                (Goal) ->
                    case Goal#goal.event == ?EVENT_TALK of
                        true  ->
                            {Target, _} = Goal#goal.target;
                        false ->
                            Target = Goal#goal.target
                    end,
                    #p_task_goal{
                        event   = Goal#goal.event,
                        target  = Target,
                        amount  = Goal#goal.amount,
                        scene   = Goal#goal.scene,
                        findway = true
                    }
            end, [Task#task.doing | Task#task.rest]);
		true ->
			[]
	end,
    #p_task{
        id    = Task#task.id,
        prog  = Task#task.prog,
        count = Task#task.count,
        state = Task#task.state,
        etime = Task#task.etime,
        goal  = Goals
    }.

is_expired(Task, NowSecs) ->
	Task#task.etime > 0 andalso Task#task.etime < NowSecs.

check_reqs([{prev, TaskID} | T], RoleTask) ->
    case TaskID > 0 of
        true  ->
            case lists:member(TaskID, RoleTask#role_task.submit) of
                true  -> check_reqs(T, RoleTask);
                false -> false
            end;
        false ->
            check_reqs(T, RoleTask)
    end;
check_reqs([{level, MinLv, MaxLv} | T], RoleTask) ->
    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    case RoleLv >= MinLv andalso (MaxLv == 0 orelse RoleLv =< MaxLv) of
        true  -> check_reqs(T, RoleTask);
        false -> false
    end;
check_reqs([{viplv, VipLim} | T], RoleTask) ->
    case role_vip:get_level() >= VipLim of
        true  -> check_reqs(T, RoleTask);
        false -> false
    end;
check_reqs([guild | T], RoleTask) ->
    #role_guild{guild=GuildID} = role_data:get(?DB_ROLE_GUILD),
    case GuildID > 0 of
        true  -> check_reqs(T, RoleTask);
        false -> false
    end;
check_reqs([{opdays,Min} | T], RoleTask) ->
    Opdays = game_env:get_opened_days(),
    case Opdays >= Min of
        true  -> check_reqs(T, RoleTask);
        false -> false
    end;
check_reqs([{opdays,Min,Max} | T], RoleTask) ->
    Opdays = game_env:get_opened_days(),
    case Opdays >= Min andalso Opdays =< Max of
        true  -> check_reqs(T, RoleTask);
        false -> false
    end;
check_reqs([], _) ->
    true.

update_notify(RoleTask, Add, Chg, Del, RoleSt) ->
    Add2 = lists:filter(fun
        (Task) ->
            #cfg_task{show=Reqs} = cfg_task:find(Task#p_task.id),
            task_util:check_reqs(Reqs, RoleTask)
    end, Add),
    Chg2 = lists:filter(fun
        (Task) ->
            #cfg_task{show=Reqs} = cfg_task:find(Task#p_task.id),
            task_util:check_reqs(Reqs, RoleTask)
    end, Chg),
    case Add2 /= [] orelse Chg2 /= [] orelse Del /= [] of
        true  ->
            ?ucast(#m_task_update_toc{
                add  = Add2,
                chg  = Chg2,
                del  = Del,
                next = RoleTask#role_task.next
            });
        false ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
