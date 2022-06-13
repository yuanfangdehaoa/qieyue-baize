%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(cron_worker).

-behaviour(gen_server).

-include("game.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/3]).

-record(state, {
      ref
    , type  % 周期类型 once | daily | weekly | daily | during | opdays
    , cycle % 周期
    , cron  % 时间
    , until % 多少秒后执行下个任务
    , task  % 任务内容
}).

-define(TEST, true).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link(Ref, Type, Cron) ->
    gen_server:start_link(?MODULE, {Ref, Type, Cron}, []).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({Ref, Type, Cron}) ->
    erlang:send(self(), check),
    {ok, #state{ref=Ref, type=Type, cron=Cron}}.


handle_call(get_state, _From, State) ->
    {reply, {ok, State}, State};

handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.


handle_cast(_Msg, State) ->
    {noreply, State}.


handle_info(check, State) ->
    {Date, Time} = ut_time:datetime(),
    case until_next_seconds(Date, Time, State) of
        {ok, State2} when State2#state.until == 0 ->
            erlang:send(self(), run),
            {noreply, State2};
        {ok, State2} ->
            Secs = timer:seconds(State2#state.until),
            erlang:send_after(Secs, self(), run),
            {noreply, State2};
        timeout ->
            {stop, normal, State}
    end;

handle_info(run, State) ->
    do_run_task(State#state.task),
    erlang:send(self(), check),
    {noreply, State#state{task = undefined}};

handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
until_next_seconds(Date, Time, State) ->
    #state{type=Type, cycle=Cycle} = State,
    case is_today(Type, Cycle, Date) of
        true  ->
            until_next_seconds2(Date, Time, State);
        false ->
            until_next_seconds3(Date, Time, State)
    end.

until_next_seconds2(Date, Time, State) ->
    case until_next_time(State#state.cron, Date, Time) of
        timeout ->
            until_next_seconds3(Date, Time, State);
        {Secs, Task} ->
            {ok, State#state{until=Secs, task=Task}}
    end.

until_next_seconds3(Date, Time, State) ->
    #state{type=Type, cycle=Cycle, cron=CronList} = State,
    case until_next_days(Type, Cycle, Date) of
        timeout ->
            case until_next_cycle(Type, Cycle, Date) of
                timeout ->
                    timeout;
                Days ->
                    {Secs, Task} = until_next_daytime(CronList, Days, Date, Time),
                    {ok, State#state{until=Secs, task=Task}}
            end;
        Days ->
            {Secs, Task} = until_next_daytime(CronList, Days, Date, Time),
            {ok, State#state{until=Secs, task=Task}}
    end.

is_today(daily, _Cycle, _Date) ->
    true;
is_today(weekly, DoWList, Date) ->
    is_today2(DoWList, ut_time:day_of_week(Date));
is_today(monthly, DoMList, {_,_,DoM}) ->
    is_today2(DoMList, DoM);
is_today(during, DateList, Date) ->
    is_today2(DateList, Date);
is_today(opdays, DayList, _Date) ->
    is_today2(DayList, game_env:get_opened_days()).

is_today2([{Day1, Day2} | T], Day) ->
    case Day1 =< Day andalso Day =< Day2 of
        true  -> true;
        false -> is_today2(T, Day)
    end;
is_today2([Day1 | T], Day) ->
    case Day == Day1 of
        true  -> true;
        false -> is_today2(T, Day)
    end;
is_today2([], _Day) ->
    false.


until_next_time([{offset, DateTime1={_,_}, DateTime2, Task} | T], Date, Time) ->
    if
        {Date,Time} =< DateTime1 ->
            {diff_seconds({Date,Time}, DateTime1), Task};
        {Date,Time} =< DateTime2 ->
            {0, Task};
        true ->
            until_next_time(T, Date, Time)
    end;
until_next_time([{offset, Time1, Time2, Task} | T], Date, Time) ->
    if
        Time =< Time1 ->
            {diff_seconds(Time, Time1), Task};
        Time =< Time2 ->
            {0, Task};
        true ->
            until_next_time(T, Date, Time)
    end;
until_next_time([{DateTime1={_,_}, Task} | T], Date, Time) ->
    if
        {Date,Time} =< DateTime1 ->
            {diff_seconds({Date,Time}, DateTime1), Task};
        true ->
            until_next_time(T, Date, Time)
    end;
until_next_time([{Time1, Task} | T], Date, Time) ->
    if
        Time =< Time1 ->
            {diff_seconds(Time, Time1), Task};
        true ->
            until_next_time(T, Date, Time)
    end;
until_next_time([], _Date, _Time) ->
    timeout.

until_next_days(daily, _Cycle, _Date) ->
    1;
until_next_days(weekly, DoWList, Date) ->
    until_next_days2(DoWList, ut_time:day_of_week(Date));
until_next_days(monthly, DoMList, {_, _, Day}) ->
    until_next_days2(DoMList, Day);
until_next_days(during, DateList, Date) ->
    until_next_days2(DateList, Date);
until_next_days(opdays, DayList, _Date) ->
    until_next_days2(DayList, game_env:get_opened_days()).

until_next_days2([{Day1, _} | T], Day) ->
    if
        Day < Day1 ->
            diff_days(Day, Day1);
        true ->
            until_next_days2(T, Day)
    end;
until_next_days2([Day1 | T], Day) ->
    if
        Day < Day1 ->
            diff_days(Day, Day1);
        true ->
            until_next_days2(T, Day)
    end;
until_next_days2([], _Day) ->
    timeout.


until_next_cycle(weekly, [DoW | _], Date) ->
    DoW + 7 - calendar:day_of_the_week(Date);
until_next_cycle(monthly, [DoM | _], Date = {Y,M,_}) ->
    case M == 12 of
        true  -> diff_days(Date, {Y+1, 1, DoM});
        false -> diff_days(Date, {Y, M+1, DoM})
    end;
until_next_cycle(_Type, _DayList, _Date) ->
    timeout.


until_next_daytime([{offset, DateTime1={_,_}, _, Task} | _], _Days, Date, Time) ->
    {diff_seconds({Date,Time}, DateTime1), Task};
until_next_daytime([{offset, Time1, _, Task} | _], Days, _Date, Time) ->
    {until_next_daytime2(Time, Time1, Days), Task};
until_next_daytime([{DateTime1={_,_}, Task} | _], _Days, Date, Time) ->
    {diff_seconds({Date,Time}, DateTime1), Task};
until_next_daytime([{Time1, Task} | _], Days, _Date, Time) ->
    {until_next_daytime2(Time, Time1, Days), Task}.

until_next_daytime2(Time1, Time2, Days) ->
    86400 * (Days - 1) + 86400 - to_seconds(Time1) + to_seconds(Time2).


diff_days(Day1, Day2) when is_integer(Day1) ->
    Day2 - Day1;
diff_days(Date1, Date2) ->
    ut_time:diff_days(Date1, Date2).

diff_seconds(Time1, Time2) ->
    to_seconds(Time2) - to_seconds(Time1).

to_seconds({_,_} = DateTime) ->
    calendar:datetime_to_gregorian_seconds(DateTime);
to_seconds({_,_,_} = Time) ->
    calendar:time_to_seconds(Time).


do_run_task(F) when is_function(F) ->
    F();
do_run_task({M, F, A}) ->
    M:F(A);
do_run_task(_) ->
    ignore.

%%%-----------------------------------------------------------------------------
%%% Test Functions
%%%-----------------------------------------------------------------------------
% -ifdef(TEST).
% -include_lib("eunit/include/eunit.hrl").

% until_next_time_test_() ->
%     [
%         ?_assertEqual(60,
%             until_next_time({16,59,00}, {between, {17,00,00}, {17,05,00}})),
%         ?_assertEqual(0,
%             until_next_time({17,00,00}, {between, {17,00,00}, {17,05,00}})),
%         ?_assertEqual(0,
%             until_next_time({17,00,01}, {between, {17,00,00}, {17,05,00}})),
%         ?_assertEqual(0,
%             until_next_time({17,05,00}, {between, {17,00,00}, {17,05,00}})),
%         ?_assertEqual(-1,
%             until_next_time({17,05,01}, {between, {17,00,00}, {17,05,00}})),

%         ?_assertEqual(60,
%             until_next_time({16,59,00}, {17,00,00})),
%         ?_assertEqual(0,
%             until_next_time({17,00,00}, {17,00,00})),
%         ?_assertEqual(-1,
%             until_next_time({17,00,01}, {17,00,00}))
%     ].

% until_next_days_test_() ->
%     [
%         ?_assertEqual(1,
%             until_next_days(weekly, {2017,11,02}, 5)),
%         ?_assertEqual(0,
%             until_next_days(weekly, {2017,11,03}, 5)),
%         ?_assertEqual(-1,
%             until_next_days(weekly, {2017,11,04}, 5)),

%         ?_assertEqual(1,
%             until_next_days(monthly, {2017,11,04}, 5)),
%         ?_assertEqual(0,
%             until_next_days(monthly, {2017,11,05}, 5)),
%         ?_assertEqual(-1,
%             until_next_days(monthly, {2017,11,06}, 5)),

%         ?_assertEqual(1,
%             until_next_days(during, {2017,11,04}, {2017,11,05})),
%         ?_assertEqual(0,
%             until_next_days(during, {2017,11,05}, {2017,11,05})),
%         ?_assertEqual(-1,
%             until_next_days(during, {2017,11,06}, {2017,11,05})),
%         ?_assertEqual(-31,
%             until_next_days(during, {2017,12,06}, {2017,11,05}))
%     ].

% until_next_cycle_test_() ->
%     [
%         ?_assertEqual(6,
%             until_next_cycle(weekly, {2017,11,04}, 5)),
%         ?_assertEqual(7,
%             until_next_cycle(weekly, {2017,11,04}, 6)),
%         ?_assertEqual(8,
%             until_next_cycle(weekly, {2017,11,04}, 7)),

%         ?_assertEqual(29,
%             until_next_cycle(monthly, {2017,11,04}, 3)),
%         ?_assertEqual(30,
%             until_next_cycle(monthly, {2017,11,04}, 4)),
%         ?_assertEqual(31,
%             until_next_cycle(monthly, {2017,11,04}, 5))
%     ].

% until_next_seconds_test_() ->
%     [
%         ?_assertMatch({ok, #state{next = 1, rest = []}},
%             until_next_seconds({2017,11,04}, {17,59,59}, #state{
%                 type = once,
%                 all  = [{{18,00,00}, task}],
%                 rest = [{{18,00,00}, task}]
%             })),
%         ?_assertMatch({ok, #state{next = 0, rest = []}},
%             until_next_seconds({{2017,11,04},{18,00,00}}, #state{
%                 type = once,
%                 all  = [{{18,00,00}, task}],
%                 rest = [{{18,00,00}, task}]
%             })),
%         ?_assertEqual(-1,
%             until_next_seconds({{2017,11,04},{18,00,01}}, #state{
%                 type = once,
%                 all  = [{{18,00,00}, task}],
%                 rest = [{{18,00,00}, task}]
%             })),

%         ?_assertMatch({ok, #state{next = 1, rest = []}},
%             until_next_seconds({{2017,11,04},{17,59,59}}, #state{
%                 type = daily,
%                 all  = [{{18,00,00}, task}],
%                 rest = [{{18,00,00}, task}]
%             })),
%         ?_assertMatch({ok, #state{next = 0, rest = []}},
%             until_next_seconds({{2017,11,04},{18,00,00}}, #state{
%                 type = daily,
%                 all  = [{{18,00,00}, task}],
%                 rest = [{{18,00,00}, task}]
%             })),
%         ?_assertMatch({ok, #state{next = 86400 - 1, rest = []}},
%             until_next_seconds({{2017,11,04},{18,00,01}}, #state{
%                 type = daily,
%                 all  = [{{18,00,00}, task}],
%                 rest = [{{18,00,00}, task}]
%             })),

%         ?_assertMatch({ok, #state{next = 1, rest = [{6, {18,00,00}, task}]}},
%             until_next_seconds({{2017,11,01},{17,59,59}}, #state{
%                 type = weekly,
%                 all  = [{3, {18,00,00}, task}, {6, {18,00,00}, task}],
%                 rest = [{3, {18,00,00}, task}, {6, {18,00,00}, task}]
%             })),
%         ?_assertMatch({ok, #state{next = 86400 * 3 - 1, rest = []}},
%             until_next_seconds({{2017,11,01},{18,00,01}}, #state{
%                 type = weekly,
%                 all  = [{3, {18,00,00}, task}, {6, {18,00,00}, task}],
%                 rest = [{3, {18,00,00}, task}, {6, {18,00,00}, task}]
%             })),
%         ?_assertMatch({ok, #state{next = 1, rest = []}},
%             until_next_seconds({{2017,11,04},{17,59,59}}, #state{
%                 type = weekly,
%                 all  = [{3, {18,00,00}, task}, {6, {18,00,00}, task}],
%                 rest = [{3, {18,00,00}, task}, {6, {18,00,00}, task}]
%             })),
%         ?_assertMatch({ok, #state{next = 86400 * 4 - 1, rest = [{6, {18,00,00}, task}]}},
%             until_next_seconds({{2017,11,04},{18,00,01}}, #state{
%                 type = weekly,
%                 all  = [{3, {18,00,00}, task}, {6, {18,00,00}, task}],
%                 rest = [{3, {18,00,00}, task}, {6, {18,00,00}, task}]
%             })),

%         ?_assertMatch({ok, #state{next = 1, rest = [{20, {18,00,00}, task}]}},
%             until_next_seconds({{2017,11,10},{17,59,59}}, #state{
%                 type = monthly,
%                 all  = [{10, {18,00,00}, task}, {20, {18,00,00}, task}],
%                 rest = [{10, {18,00,00}, task}, {20, {18,00,00}, task}]
%             })),
%         ?_assertMatch({ok, #state{next = 86400 * 10 - 1, rest = []}},
%             until_next_seconds({{2017,11,10},{18,00,01}}, #state{
%                 type = monthly,
%                 all  = [{10, {18,00,00}, task}, {20, {18,00,00}, task}],
%                 rest = [{10, {18,00,00}, task}, {20, {18,00,00}, task}]
%             })),
%         ?_assertMatch({ok, #state{next = 1, rest = []}},
%             until_next_seconds({{2017,11,20},{17,59,59}}, #state{
%                 type = monthly,
%                 all  = [{10, {18,00,00}, task}, {20, {18,00,00}, task}],
%                 rest = [{10, {18,00,00}, task}, {20, {18,00,00}, task}]
%             })),
%         ?_assertMatch({ok, #state{next = 86400 * 20 - 1, rest = [{20, {18,00,00}, task}]}},
%             until_next_seconds({{2017,11,20},{18,00,01}}, #state{
%                 type = monthly,
%                 all  = [{10, {18,00,00}, task}, {20, {18,00,00}, task}],
%                 rest = [{10, {18,00,00}, task}, {20, {18,00,00}, task}]
%             }))
%     ].

% -endif.