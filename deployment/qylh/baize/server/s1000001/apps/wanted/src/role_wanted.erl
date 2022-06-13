%% @author rong
%% @doc
-module(role_wanted).

-include("table.hrl").
-include("game.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("wanted.hrl").
-include("role.hrl").

-export([hook_login/1, hook_sysopen/1, new_task/1, notify/4, add_listener/2,
    trigger_next/1]).

hook_login(RoleSt) ->
    init_listener(RoleSt).

hook_sysopen(RoleSt) ->
    #role_wanted{task=Task} = RoleWanted = role_data:get(?DB_ROLE_WANTED),
    if
        Task == ?nil ->
            Task2 = new_task(hd(cfg_wanted:all())),
            role_data:set(RoleWanted#role_wanted{task=Task2}),
            add_listener(Task2, RoleSt);
        true ->
            ignore
    end.

new_task(ID) ->
    #p_wanted_task{id=ID, progress=0, state=?WANTED_TASK_STATE_UNDONE}.

notify(Event, TaskID, Args, RoleSt) ->
    #role_wanted{task=Task} = RoleWanted = role_data:get(?DB_ROLE_WANTED),
    #p_wanted_task{progress=Progress} = Task,
    #cfg_wanted{target=Target} = cfg_wanted:find(TaskID),
    {Event, Goal, Conds, Amount} = Target,
    case task_counter:update(Event, Args, Goal, Conds) of
        {Op, Num} ->
            Progress2 = ut_math:calc(Progress, Op, Num),
            Task2 = Task#p_wanted_task{progress=Progress2},
            case Progress2 >= Amount of
                true ->
                    Task3 = Task2#p_wanted_task{state=?WANTED_TASK_STATE_FINISH},
                    role_data:set(RoleWanted#role_wanted{task=Task3}),
                    role_event:remove(Event, ?MODULE, notify, TaskID);
                false ->
                    Task3 = Task2,
                    role_data:set(RoleWanted#role_wanted{task=Task3})
            end,
            ?ucast(#m_wanted_update_toc{task=Task3});
        false ->
            ignore
    end.

init_listener(RoleSt) ->
    #role_wanted{task=Task} = role_data:get(?DB_ROLE_WANTED),
    case Task of
        _ when is_record(Task, p_wanted_task) ->
            add_listener(Task, RoleSt);
        _ ->
            ignore
    end.

add_listener(Task, _RoleSt) ->
    #p_wanted_task{id=TaskID, state=State} = Task,
    case State of
        ?WANTED_TASK_STATE_UNDONE ->
            #cfg_wanted{target=Target} = cfg_wanted:find(TaskID),
            {Event, _Goal, _Conds, _Num} = Target,
            role_event:listen(Event, ?MODULE, notify, TaskID);
        _ ->
            ignore
    end.

trigger_next(Task) ->
    case find_next(Task#p_wanted_task.id, cfg_wanted:all()) of
        NextID when is_integer(NextID) ->
            role_wanted:new_task(NextID);
        _ ->
            ?nil
    end.

find_next(TaskID, [TaskID|T]) ->
    case length(T) > 0 of
        true -> hd(T);
        false -> ?nil
    end;
find_next(TaskID, [_|T]) ->
    find_next(TaskID, T).
