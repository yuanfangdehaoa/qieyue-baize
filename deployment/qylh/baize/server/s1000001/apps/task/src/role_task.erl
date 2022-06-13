%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_task).

-include("creep.hrl").
-include("game.hrl").
-include("role.hrl").
-include("task.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").

%% API
-export([init/1]).
-export([hook_login/1]).
-export([hook_reset/5]).
-export([hook_upgrade/2]).
-export([notify/3]).
-export([trigger/2]).
-export([accept/1]).
-export([submit/2]).
-export([remove/1]).
-export([quick/2]).
-export([reload/2]).
-export([get_task/1]).
-export([is_accept/1]).
-export([is_finish/1]).
-export([update_guild_task/1]).
-export([gm_trigger/2]).
-export([gm_finish/1, gm_finish/2]).

-define(is_trigger(Task), Task#task.state == ?TASK_STATE_TRIGGER).
-define(is_accept(Task) , Task#task.state == ?TASK_STATE_ACCEPT).
-define(is_finish(Task) , Task#task.state == ?TASK_STATE_FINISH).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(RoleID) ->
    TaskIDs = cfg_task:trigger_by_level(?TASK_TYPE_MAIN, 1),
    {RoleTask, _} = try_trigger(TaskIDs, #role_task{id=RoleID}, []),
    role_data:set(RoleTask).

%% 首次登录
hook_login(_RoleSt) ->
    RoleTask = role_data:get(?DB_ROLE_TASK),
    {Accepted2, Listened2} = lists:foldl(fun
        (Task, Acc={AccAccpet, AccListen}) ->
            #task{id=TaskID, doing = #goal{event=Event}} = Task,
            case cfg_task:find(TaskID) == ?nil of
                true  ->
                    ?error("task had been deleted: ~w", [TaskID]),
                    Acc;
                false ->
                    role_event:listen(Event, ?MODULE, notify),
                    AccAccpet2 = maps:put(TaskID, Task, AccAccpet),
                    AccListen2 = ut_misc:maps_append(Event, TaskID, AccListen),
                    {AccAccpet2, AccListen2}
            end
    end, {#{}, #{}}, maps:values(RoleTask#role_task.accept)),
    RoleTask2 = RoleTask#role_task{accept=Accepted2, listen=Listened2},
    role_data:set(RoleTask2).

%% 重置任务
hook_reset(_DoW, _Hour, _Group, ID, RoleSt) ->
    RoleTask = role_data:get(?DB_ROLE_TASK),
    {RoleTask2, Del, Add} = reset_task(ID, RoleTask),
    role_data:set(RoleTask2),
    task_util:update_notify(RoleTask2, Add, [], Del, RoleSt).

%% 升级触发任务
hook_upgrade(NewLv, RoleSt) ->
    RoleTask = role_data:get(?DB_ROLE_TASK),
    TaskIDs  = lists:foldl(fun
        (Type, Acc) ->
            cfg_task:trigger_by_level(Type, NewLv) ++ Acc
    end, [], [
        ?TASK_TYPE_MAIN,
        ?TASK_TYPE_SIDE,
        ?TASK_TYPE_REIN,
        ?TASK_TYPE_TIME,
        ?TASK_TYPE_PREV1,
        ?TASK_TYPE_PREV2,
        ?TASK_TYPE_PREV3,
        ?TASK_TYPE_PREV4,
        ?TASK_TYPE_BABY,
        ?TASK_TYPE_ACTIVE
    ]),
    {RoleTask2, Add} = try_trigger(TaskIDs, RoleTask, []),
    role_data:set(RoleTask2),
    task_util:update_notify(RoleTask2, Add, [], [], RoleSt).

%% 任务更新
notify(Event, Args, RoleSt) ->
    RoleTask = #role_task{listen=Listened} = role_data:get(?DB_ROLE_TASK),
    TaskIDs  = maps:get(Event, Listened, []),
    NowSecs  = ut_time:seconds(),
    {RoleTask1, Add1, Chg} =
        try_finish(TaskIDs, Event, Args, NowSecs, RoleTask, RoleSt, [], []),
    task_util:update_notify(RoleTask1, [], Chg, [], RoleSt),
    role_data:set(RoleTask1),
    {RoleTask2, Add2, Del, Cost, Gain} =
        auto_submit(Chg, RoleTask1, RoleSt, [], [], [], []),
    role_bag:deal(Cost, Gain, ?LOG_TASK_SUBMIT, RoleSt),
    role_data:set(RoleTask2),
    Add = Add1 ++ Add2,
    task_util:update_notify(RoleTask2, Add, [], Del, RoleSt).

%% 触发指定任务
trigger(TaskIDs, RoleSt) ->
    RoleTask = role_data:get(?DB_ROLE_TASK),
    {RoleTask2, Add} = try_trigger(TaskIDs, RoleTask, []),
    role_data:set(RoleTask2),
    task_util:update_notify(RoleTask2, Add, [], [], RoleSt).

%% 接受任务
accept(TaskID) ->
	RoleTask = #role_task{accept=Accepted} = role_data:get(?DB_ROLE_TASK),
	case maps:find(TaskID, Accepted) of
		{ok, Task} when ?is_trigger(Task) ->
            Task2 = Task#task{state=?TASK_STATE_ACCEPT},
            RoleTask2 = accept_task(Task2, RoleTask),
			{ok, Task2, RoleTask2};
        {ok, Task} when ?is_finish(Task) ->
            {ok, Task, RoleTask};
		_ ->
			throw(?err(?ERR_TASK_NOT_TRIGGER))
	end.

%% 提交任务
submit(TaskID, RoleSt) ->
    RoleTask = #role_task{accept=Accepted} = role_data:get(?DB_ROLE_TASK),
    case maps:find(TaskID, Accepted) of
        {ok, Task = #task{etime=ETime}} when ?is_finish(Task) ->
            case ETime > 0 andalso ut_time:seconds() > ETime of
                true  ->
                    throw(?err(?ERR_TASK_HAD_EXPIRED));
                false ->
                    {RoleTask2, Add} = submit_task(TaskID, RoleTask, RoleSt),
                    {ok, Task, RoleTask2, Add}
            end;
        _ ->
            throw(?err(?ERR_TASK_NOT_FINISH))
    end.

%% 移除任务
remove(TaskID) ->
    RoleTask  = role_data:get(?DB_ROLE_TASK),
    RoleTask2 = remove_task(RoleTask, TaskID),
    role_data:set(RoleTask2).

%% 快速完成
quick(TaskID, RoleSt) ->
    RoleTask = #role_task{accept=Accepted} = role_data:get(?DB_ROLE_TASK),
    case maps:find(TaskID, Accepted) of
        {ok, Task} when ?is_accept(Task) ->
            RoleTask1 = delisten(Task, RoleTask),
            {RoleTask2, Add} = submit_task(TaskID, RoleTask1, RoleSt),
            {ok, Task, RoleTask2, Add};
        _ ->
            throw(?err(?ERR_TASK_NOT_ACCEPT))
    end.

reload(Accepted, TaskIDs) ->
    lists:foldl(fun
        (TaskID, Acc) ->
            case maps:is_key(TaskID, Acc) of
                true  -> maps:put(TaskID, new_task(TaskID), Acc);
                false -> Acc
            end
    end, Accepted, TaskIDs).




%%-----------------------------------------------
%% @doc 获取任务
-spec get_task(integer()) ->
    {ok, #task{}} | error.
%%-----------------------------------------------
get_task(TaskID) ->
    RoleTask = role_data:get(?DB_ROLE_TASK),
    maps:find(TaskID, RoleTask#role_task.accept).

%%-----------------------------------------------
%% @doc 任务是否已接受
-spec is_accept(integer()) ->
    boolean().
%%-----------------------------------------------
is_accept(TaskID) ->
    RoleTask = role_data:get(?DB_ROLE_TASK),
    case maps:find(TaskID, RoleTask#role_task.accept) of
        {ok, Task} when ?is_accept(Task) ->
            true;
        _ ->
            false
    end.


%%-----------------------------------------------
%% @doc 任务是否已完成
-spec is_finish(integer()) ->
    boolean().
%%-----------------------------------------------
is_finish(TaskID) ->
    RoleTask = role_data:get(?DB_ROLE_TASK),
    is_finish(TaskID, RoleTask).

is_finish(TaskID, RoleTask) ->
    lists:member(TaskID, RoleTask#role_task.submit).


update_guild_task(RoleSt) ->
    case RoleSt#role_st.guild > 0 of
        true  ->
            case role_count:get_times(?ROLE_COUNT_GUILD_JOIN) == 1 of
                true  ->
                    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
                    TaskIDs  = cfg_task:trigger_by_level(?TASK_TYPE_PREV2, RoleLv),
                    RoleTask = role_data:get(?DB_ROLE_TASK),
                    {RoleTask2, Add} = try_trigger(TaskIDs, RoleTask, []),
                    role_data:set(RoleTask2),
                    task_util:update_notify(RoleTask2, Add, [], [], RoleSt);
                false ->
                    ignore
            end;
        false ->
            #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
            TaskIDs = cfg_task:trigger_by_level(?TASK_TYPE_PREV2, RoleLv)
                   ++ cfg_task:trigger_by_level(?TASK_TYPE_LOOP2, RoleLv)
                   ++ cfg_task:trigger_by_level(?TASK_TYPE_GUILD, RoleLv),
            RoleTask = role_data:get(?DB_ROLE_TASK),
            task_util:update_notify(RoleTask, [], [], TaskIDs, RoleSt)
    end.
gm_trigger(TaskID, RoleSt) ->
    RoleTask = role_data:get(?DB_ROLE_TASK),
    {RoleTask2, Add2} = trigger_task(TaskID, RoleTask),
    role_data:set(RoleTask2),
    task_util:update_notify(RoleTask2, Add2, [], [], RoleSt).
gm_finish(RoleSt) ->
    TaskIDs = cfg_task:trigger_by_type(?TASK_TYPE_MAIN),
    lists:foreach(fun
        (TaskID) ->
            role_task:gm_finish(TaskID, RoleSt)
    end, lists:sort(TaskIDs)).
gm_finish(TaskID, RoleSt) ->
    RoleTask = #role_task{accept=Accepted} = role_data:get(?DB_ROLE_TASK),
    case maps:find(TaskID, Accepted) of
        {ok, Task} when ?is_accept(Task) ->
            RoleTask1 = delisten(Task, RoleTask),
            {RoleTask2, Add} = submit_task(TaskID, RoleTask1, RoleSt),
            role_data:set(RoleTask2),
            task_util:update_notify(RoleTask2, Add, [], [TaskID], RoleSt);
        _ ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
try_trigger([TaskID | T], RoleTask, Add) ->
    case can_trigger(TaskID, RoleTask) of
        true  ->
            {RoleTask2, Add2} = trigger_task(TaskID, RoleTask),
            try_trigger(T, RoleTask2, Add2 ++ Add);
        false ->
            try_trigger(T, RoleTask, Add)
    end;
try_trigger([], RoleTask, Add) ->
    {RoleTask, Add}.

trigger_task(TaskID, RoleTask) ->
    Task1 = #task{id=TaskID, type=Type, state=State} = new_task(TaskID),
    RoleTask1 = case State of
        ?TASK_STATE_TRIGGER -> update_task(Task1, RoleTask);
        ?TASK_STATE_ACCEPT  -> accept_task(Task1, RoleTask);
        ?TASK_STATE_FINISH  -> update_task(Task1, RoleTask)
    end,
    Add1 = [task_util:p_task(Task1)],
    case Type of
        ?TASK_TYPE_MAIN  ->
            NextID = cfg_task:next(TaskID),
            {RoleTask1#role_task{next=NextID}, Add1};
        _ ->
            {RoleTask1, Add1}
    end.

new_task(TaskID) ->
    CfgTask = cfg_task:find(TaskID),
    #cfg_task{
        id=TaskID, type=Type, goals=Goals, time=TimeLim, accept=AutoAccept
    } = CfgTask,
    [{Event, Target, Amount, SceneID, _, Conds} | T] = Goals,
    Goal = make_goal(TaskID, Type, Event, Target, Amount, SceneID, Conds),
    Task = make_task(TaskID, Type, TimeLim, Goal, T),
    case ?is_finish(Task) of
        true  ->
            Task;
        false ->
            case AutoAccept of
                true  -> Task#task{state=?TASK_STATE_ACCEPT};
                false -> Task#task{state=?TASK_STATE_TRIGGER}
            end
    end.

make_task(TaskID, Type, TimeLim, Goal, Rest) ->
    #task{
        id    = TaskID,
        type  = Type,
        prog  = 0,
        count = 0,
        doing = Goal,
        rest  = Rest,
        etime = ?_if(TimeLim > 0, ut_time:seconds() + TimeLim, 0),
        state = task_state:init(Goal, Rest, ?TASK_STATE_TRIGGER)
    }.

make_goal(TaskID, Type, Event, Target, Amount, SceneID, Conds) ->
    case lists:member(Type, [?TASK_TYPE_DAILY, ?TASK_TYPE_GUILD]) of
        true  ->
            case Event of
                ?EVENT_TALK ->
                    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
                    Target1  = ut_rand:choose(cfg_task_loop:npcs(Type, RoleLv)),
                    Amount2  = Amount,
                    SceneID2 = cfg_npc:find(Target1),
                    Event2   = Event,
                    Conds2   = [];
                ?EVENT_CREEP ->
                    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
                    Target1  = ut_rand:choose(cfg_task_loop:creeps(Type, RoleLv)),
                    Amount2  = cfg_task_loop:creep_num(Type, RoleLv),
                    #cfg_creep{scene=SceneID2} = cfg_creep:find(Target1),
                    Event2   = Event,
                    Conds2   = [];
                ?EVENT_DUNGE_FLOOR ->
                    Target1  = Target,
                    Amount2  = Amount,
                    SceneID2 = SceneID,
                    Event2   = Event,
                    Conds2   = [];
                ?EVENT_COLLECT ->
                    Target1  = Target,
                    Amount2  = Amount,
                    SceneID2 = SceneID,
                    Event2   = Event,
                    Conds2   = [];
                ?EVENT_TALK_WITHIN_SCENE ->
                    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
                    SceneID2 = lists:nth(SceneID, cfg_task_loop:scenes(Type, RoleLv)),
                    {Target1, _} = ut_rand:choose(scene_config:npcs(SceneID2)),
                    Amount2  = Amount,
                    Event2   = ?EVENT_TALK,
                    Conds2   = [];
                ?EVENT_CREEP_WITHIN_SCENE ->
                    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
                    SceneID2 = lists:nth(SceneID, cfg_task_loop:scenes(Type, RoleLv)),
                    CreepIDs = lists:filtermap(fun
                        ({ID, _}) ->
                            #cfg_creep{kind=Kind, rarity=Rarity} = cfg_creep:find(ID),
                            case Kind == ?CREEP_KIND_MONSTER of
                                true  ->
                                    case Rarity == ?CREEP_RARITY_BOSS2 of
                                        true  -> false;
                                        false -> {true, ID}
                                    end;
                                false ->
                                    false
                            end
                    end, scene_config:creeps(SceneID2)),
                    Target1  = ut_rand:choose(CreepIDs),
                    Amount2  = cfg_task_loop:creep_num(Type, RoleLv),
                    Event2   = ?EVENT_CREEP,
                    Conds2   = []
            end;
        false ->
            Target1  = Target,
            Amount2  = Amount,
            SceneID2 = SceneID,
            Event2   = Event,
            Conds2   = Conds
    end,
    Target2 = ?_if(Event2 == ?EVENT_TALK, {Target1, TaskID}, Target1),
    #goal{event=Event2, target=Target2, amount=Amount2, scene=SceneID2, conds=Conds2}.

accept_task(Task, RoleTask) ->
    #role_task{listen=Listened, accept=Accepted} = RoleTask,
    #task{id=TaskID, doing=#goal{event=Event}} = Task,
    role_event:listen(Event, ?MODULE, notify),
    log_api:log_task(TaskID, ?TASK_STATE_ACCEPT),
    RoleTask#role_task{
        listen = ut_misc:maps_append(Event, TaskID, Listened),
        accept = maps:put(TaskID, Task, Accepted)
    }.

try_finish([TaskID | T], Event, Args, NowSecs, RoleTask, RoleSt, Add, Chg) ->
    Task = maps:get(TaskID, RoleTask#role_task.accept, ?nil),
    case
        is_record(Task, task) andalso ?is_accept(Task) andalso
        (not task_util:is_expired(Task, NowSecs)) andalso
        update_counter(Task, Event, Args, RoleSt)
    of
        false ->
            try_finish(T, Event, Args, NowSecs, RoleTask, RoleSt, Add, Chg);
        Task1 ->
            #task{type=Type, doing=#goal{amount=Amt}, prog=Prog, rest=Rest} = Task1,
            case Task1#task.count >= Amt of
                true when Rest == [] ->
                    Task2 = Task#task{count=Amt, prog=Prog+1, state=?TASK_STATE_FINISH},
                    RoleTask2 = update_task(Task2, delisten(Task1, RoleTask)),
                    Chg2  = [task_util:p_task(Task2) | Chg],
                    log_api:log_task(Task2#task.id, ?TASK_STATE_FINISH),
                    try_finish(T, Event, Args, NowSecs, RoleTask2, RoleSt, Add, Chg2);
                true ->
                    case Rest of
                        [{Event2, Target, Amount, SceneID, _, Conds} | Rest2] when is_integer(Event2) ->
                            Goal = make_goal(TaskID, Type, Event2, Target, Amount, SceneID, Conds);
                        [Goal | Rest2] ->
                            ok
                    end,
                    Task2 = Task#task{
                        prog  = Prog + 1,
                        doing = Goal,
                        count = 0,
                        rest  = Rest2,
                        state = task_state:init(Goal, Rest2, ?TASK_STATE_ACCEPT)
                    },
                    RoleTask2 = case ?is_finish(Task2) of
                        true  -> update_task(Task2, RoleTask);
                        false -> accept_task(Task2, delisten(Task1, RoleTask))
                    end,
                    Chg2 = [task_util:p_task(Task2) | Chg],
                    try_finish(T, Event, Args, NowSecs, RoleTask2, RoleSt, Add, Chg2);
                false ->
                    RoleTask1 = update_task(Task1, RoleTask),
                    Chg2 = [task_util:p_task(Task1) | Chg],
                    try_finish(T, Event, Args, NowSecs, RoleTask1, RoleSt, Add, Chg2)
            end
    end;
try_finish([], _, _, _, RoleTask, _RoleSt, Add, Chg) ->
    {RoleTask, Add, Chg}.

update_counter(Task, Event, Args, RoleSt) ->
    #task{type=Type, doing=Goal, count=Count} = Task,
    case Type == ?TASK_TYPE_GUILD andalso RoleSt#role_st.guild == 0 of
        true  ->
            false;
        false ->
            #goal{target=Target, conds=Conds} = Goal,
            Conds2 = lists:keydelete(link, 1, Conds),
            case task_counter:update(Event, Args, Target, Conds2) of
                false -> false;
                {'=',N} when Event == ?EVENT_ITEM ->
                    Task#task{count = N};
                {'=',N} -> Task#task{count = max(Count, N)};
                {'+',N} -> Task#task{count = Count + N}
            end
    end.

update_task(Task, RoleTask = #role_task{accept=Accepted}) ->
    RoleTask#role_task{
        accept = maps:put(Task#task.id, Task, Accepted)
    }.

delisten(Task, RoleTask = #role_task{listen=Listened}) ->
    #task{id=TaskID, doing=#goal{event=Event}} = Task,
    Listened2 = ut_misc:maps_delete(Event, TaskID, Listened),
    ?_if(Listened2 == [], role_event:remove(Event, ?MODULE, notify)),
    RoleTask#role_task{listen=Listened2}.

submit_task(TaskID, RoleTask, RoleSt) ->
    role_hook:hook_finish(TaskID, RoleSt),
    #cfg_task{type=Type} = cfg_task:find(TaskID),
    role_event:event(?EVENT_TASK, {Type, TaskID}),

    % 异兽岛单服和跨服的任务互斥
    RoleTask1 = case Type of
        ?TASK_TYPE_PREV3 ->
            {RoleTask_1, _} = remove_by_type(RoleTask, ?TASK_TYPE_PREV4),
            {RoleTask_2, _} = remove_by_type(RoleTask_1, ?TASK_TYPE_LOOP4),
            RoleTask_2;
        ?TASK_TYPE_PREV4 ->
            {RoleTask_1, _} = remove_by_type(RoleTask, ?TASK_TYPE_PREV3),
            {RoleTask_2, _} = remove_by_type(RoleTask_1, ?TASK_TYPE_LOOP3),
            RoleTask_2;
        _ ->
            RoleTask
    end,

    RoleTask2 = RoleTask1#role_task{
        accept = maps:remove(TaskID, RoleTask1#role_task.accept),
        submit = [TaskID | RoleTask1#role_task.submit]
    },
    TaskIDs = cfg_task:trigger_by_task(TaskID),
    try_trigger(TaskIDs, RoleTask2, []).

auto_submit([Task | T], RoleTask, RoleSt, Add, Del, Cost, Gain) ->
    #p_task{id=TaskID, state=State} = Task,
    CfgTask = cfg_task:find(TaskID),
    #cfg_task{type=Type, submit=Auto, cost=Cost1, gain=Gain1} = CfgTask,
    case State == ?TASK_STATE_FINISH andalso Auto of
        true  ->
            {RoleTask2, Add1} = submit_task(TaskID, RoleTask, RoleSt),
            Add2  = Add1 ++ Add,
            Del2  = [TaskID | Del],
            Cost2 = Cost1 ++ Cost,
            Gain2 = if
                Type == ?TASK_TYPE_DAILY;
                Type == ?TASK_TYPE_GUILD ->
                    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
                    cfg_task_loop:loop_reward(Type, RoleLv);
                Type == ?TASK_TYPE_LOOP1;
                Type == ?TASK_TYPE_LOOP2;
                Type == ?TASK_TYPE_LOOP3;
                Type == ?TASK_TYPE_LOOP4 ->
                    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
                    cfg_task_loop:extra_reward(Type, RoleLv);
                true ->
                    Gain1
            end,
            Gain3 = Gain2 ++ Gain,
            auto_submit(T, RoleTask2, RoleSt, Add2, Del2, Cost2, Gain3);
        false ->
            auto_submit(T, RoleTask, RoleSt, Add, Del, Cost, Gain)
    end;
auto_submit([], RoleTask, _RoleSt, Add, Del, Cost, Gain) ->
    {RoleTask, Add, Del, Cost, Gain}.

%% 重置日常任务
reset_task(1, RoleTask) ->
    {RoleTask1, Del1, Add1} = reset_daily_task(RoleTask),
    {RoleTask2, Del2} = remove_expired_task(RoleTask1),
    {RoleTask2, Del1++Del2, Add1};
%% 重置公会任务
reset_task(2, RoleTask) ->
    reset_guild_task(RoleTask);
%% 重置子女任务
reset_task(3, RoleTask)->
    reset_baby_task(RoleTask).

remove_expired_task(RoleTask) ->
    NowSecs = ut_time:seconds(),
    maps:fold(fun
        (TaskID, Task, Acc = {AccRoleTask, AccDel}) ->
            case task_util:is_expired(Task, NowSecs) of
                true  ->
                    AccRoleTask2 = remove_task(AccRoleTask, Task),
                    {AccRoleTask2, [TaskID | AccDel]};
                false ->
                    Acc
            end
    end, {RoleTask, []}, RoleTask#role_task.accept).

reset_daily_task(RoleTask0) ->
    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    {RoleTask1, Del1} = remove_by_type(RoleTask0, ?TASK_TYPE_DAILY),
    {RoleTask2, Del2} = remove_by_type(RoleTask1, ?TASK_TYPE_BEAST),
    {RoleTask3, Del3} = remove_by_type(RoleTask2, ?TASK_TYPE_LOOP1),
    {RoleTask4, Del4} = remove_by_type(RoleTask3, ?TASK_TYPE_LOOP3),
    {RoleTask5, Del5} = remove_by_type(RoleTask4, ?TASK_TYPE_LOOP4),
    {RoleTask6, Del6} = remove_by_type(RoleTask5, ?TASK_TYPE_PREV1),
    {RoleTask7, Del7} = remove_by_type(RoleTask6, ?TASK_TYPE_PREV3),
    {RoleTask8, Del8} = remove_by_type(RoleTask7, ?TASK_TYPE_PREV4),
    {RoleTask9, Del9} = remove_by_type(RoleTask8, ?TASK_TYPE_ACTIVE),
    TaskIDs1 = cfg_task:trigger_by_level(?TASK_TYPE_PREV1, RoleLv),
    TaskIDs2 = cfg_task:trigger_by_level(?TASK_TYPE_PREV3, RoleLv),
    TaskIDs3 = cfg_task:trigger_by_level(?TASK_TYPE_PREV4, RoleLv),
    TaskIDs4 = cfg_task:trigger_by_type(?TASK_TYPE_ACTIVE),
    {RoleTask, Add} = try_trigger(TaskIDs1++TaskIDs2++TaskIDs3++TaskIDs4, RoleTask9, []),
    {RoleTask, Del1++Del2++Del3++Del4++Del5++Del6++Del7++Del8++Del9, Add}.

reset_guild_task(RoleTask) ->
    #role_guild{id=GuildID} = role_data:get(?DB_ROLE_GUILD),
    case GuildID > 0 of
        true  ->
            {RoleTask1, Del1} = remove_by_type(RoleTask, ?TASK_TYPE_PREV2),
            {RoleTask2, Del2} = remove_by_type(RoleTask1, ?TASK_TYPE_LOOP2),
            {RoleTask3, Del3} = remove_by_type(RoleTask2, ?TASK_TYPE_GUILD),
            #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
            TaskIDs = cfg_task:trigger_by_level(?TASK_TYPE_PREV2, RoleLv),
            {RoleTask4, Add}  = try_trigger(TaskIDs , RoleTask3, []),
            {RoleTask4, Del1++Del2++Del3, Add};
        false ->
            {RoleTask, [], []}
    end.

reset_baby_task(RoleTask)->
    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    {RoleTask1, Del} = remove_by_type(RoleTask, ?TASK_TYPE_BABY),
    TaskIDs = cfg_task:trigger_by_level(?TASK_TYPE_BABY, RoleLv),
    {RoleTask2, Add}  = try_trigger(TaskIDs , RoleTask1, []),
    {RoleTask2, Del, Add}.

remove_by_type(RoleTask, DelType) ->
    lists:foldl(fun
        (TaskID, {AccRoleTask, AccDel}) ->
            #role_task{accept=Accepted, submit=Submitted} = AccRoleTask,
            case maps:find(TaskID, Accepted) of
                {ok, Task} ->
                    AccRoleTask2 = remove_task(AccRoleTask, Task),
                    {AccRoleTask2, [TaskID | AccDel]};
                error ->
                    AccRoleTask2 = AccRoleTask#role_task{
                        submit = lists:delete(TaskID, Submitted)
                    },
                    {AccRoleTask2, AccDel}
            end
    end, {RoleTask, []}, cfg_task:trigger_by_type(DelType)).

remove_task(RoleTask, TaskID) when is_integer(TaskID) ->
    #role_task{accept=Accepted, submit=Submitted} = RoleTask,
    case maps:find(TaskID, Accepted) of
        {ok, Task} ->
            remove_task(RoleTask, Task);
        error ->
            RoleTask#role_task{submit=lists:delete(TaskID, Submitted)}
    end;
remove_task(RoleTask, Task) ->
    #role_task{accept=Accepted, submit=Submitted} = RoleTask,
    RoleTask2 = delisten(Task, RoleTask),
    RoleTask2#role_task{
        accept = maps:remove(Task#task.id, Accepted),
        submit = lists:delete(Task#task.id, Submitted)
    }.

can_trigger(TaskID, RoleTask) ->
    #cfg_task{type=Type, reqs=Reqs} = cfg_task:find(TaskID),
    case accept_before(RoleTask, TaskID) of
        true  ->
            false;
        false ->
            case task_util:check_reqs(Reqs, RoleTask) of
                true  ->
                    if
                        Type == ?TASK_TYPE_PREV3 ->
                            MutexIDs = cfg_task:trigger_by_type(?TASK_TYPE_PREV4),
                            lists:all(fun
                                (MutexID) ->
                                    not is_finish(MutexID, RoleTask)
                            end, MutexIDs);
                        Type == ?TASK_TYPE_PREV4 ->
                            MutexIDs = cfg_task:trigger_by_type(?TASK_TYPE_PREV3),
                            lists:all(fun
                                (MutexID) ->
                                    not is_finish(MutexID, RoleTask)
                            end, MutexIDs);
                        true ->
                            true
                    end;
                false ->
                    false
            end
    end.

accept_before(RoleTask, TaskID) ->
    #role_task{accept=Accepted, submit=Submitted} = RoleTask,
    maps:is_key(TaskID, Accepted) orelse lists:member(TaskID, Submitted).
