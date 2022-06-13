%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(cron).

%% API
-export([at/3, at/2]).
-export([daily/3, daily/2]).
-export([weekly/4, weekly/3]).
-export([monthly/4, monthly/3]).
-export([during/4, during/3]).
-export([cron/4]).
-export([cancel/1]).
-export([get_state/1]).

-type dow() :: 1..7.  % day of week
-type dom() :: 1..31. % day of month

-type cron_ref()  :: any().
-type crontab()   :: [{cron_when(), cron_task()}].
-type cron_when() :: cron_time() | {between, cron_time(), cron_time()}.
-type cron_task() :: {module(), function(), any()}.
-type cron_time() :: calendar:datetime() | calendar:time().

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 执行一次定时任务
-spec at(cron_ref(), cron_when(), cron_task()) ->
    no_return().
%%-----------------------------------------------
at(Ref, When, Task) ->
    cron_manager:start_cron(Ref, once, [{When, Task}]).

%%-----------------------------------------------
-spec at(cron_ref(), crontab()) ->
    no_return().
%%-----------------------------------------------
at(Ref, Cron) ->
    cron_manager:start_cron(Ref, once, Cron).


%%-----------------------------------------------
%% @doc 每天定时运行周期性任务
-spec daily(cron_ref(), cron_when(), cron_task()) ->
    no_return().
%%-----------------------------------------------
daily(Ref, When, Task) ->
    cron_manager:start_cron(Ref, daily, [{When, Task}]).

%%-----------------------------------------------
-spec daily(cron_ref(), crontab()) ->
    no_return().
%%-----------------------------------------------
daily(Ref, Cron) ->
    cron_manager:start_cron(Ref, daily, Cron).


%%-----------------------------------------------
%% @doc 每周定时运行周期性任务
-spec weekly(cron_ref(), [dow()], cron_when(), cron_task()) ->
    no_return().
%%-----------------------------------------------
weekly(Ref, DaysOfWeek, When, Task) ->
    cron_manager:start_cron(Ref, weekly, DaysOfWeek, [{When, Task}]).

%%-----------------------------------------------
-spec weekly(cron_ref(), [dow()], crontab()) ->
    no_return().
%%-----------------------------------------------
weekly(Ref, DaysOfWeek, Cron) ->
    cron_manager:start_cron(Ref, weekly, DaysOfWeek, Cron).


%%-----------------------------------------------
%% @doc 每月定时运行周期性任务
-spec monthly(cron_ref(), [dom()], cron_when(), cron_task()) ->
    no_return().
%%-----------------------------------------------
monthly(Ref, DaysOfMonth, When, Task) ->
    cron_manager:start_cron(Ref, monthly, DaysOfMonth, [{When, Task}]).

%%-----------------------------------------------
-spec monthly(cron_ref(), [dom()], crontab()) ->
    no_return().
%%-----------------------------------------------
monthly(Ref, DaysOfMonth, Cron) ->
    cron_manager:start_cron(Ref, monthly, DaysOfMonth, Cron).


%%-----------------------------------------------
%% @doc 定期定时运行周期性任务
-spec during(
    cron_ref(),
    [calendar:date()] | {between, calendar:date(), calendar:date()},
    cron_when(),
    cron_task()
) ->
    no_return().
%%-----------------------------------------------
during(Ref, Dates, When, Task) ->
    cron_manager:start_cron(Ref, during, Dates, [{When, Task}]).

%%-----------------------------------------------
-spec during(
    cron_ref(),
    [calendar:date()] | {between, calendar:date(), calendar:date()},
    crontab()
) ->
    no_return().
%%-----------------------------------------------
during(Ref, Dates, Cron) ->
    cron_manager:start_cron(Ref, during, Dates, Cron).


cron(Ref, Cycle, Days, Cron) ->
    cron_manager:start_cron(Ref, Cycle, Days, Cron).


%%-----------------------------------------------
%% @doc 取消定时器
-spec cancel(cron_ref()) ->
    no_return().
%%-----------------------------------------------
cancel(Ref) ->
	cron_manager:stop_cron(Ref).


%%-----------------------------------------------
%% @doc 获取定时器信息
-spec get_state(cron_ref()) ->
    tuple().
%%-----------------------------------------------
get_state(Ref) ->
    cron_manager:get_state(Ref).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
