%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(ut_activity).

%% API
-export([schedule/3]).

-include("game.hrl").

-type cycle() :: daily | weekly | monthly | during | opdays | mgdays.

-type day_of_week()  :: 1..7.  % day of week
-type day_of_month() :: 1..31. % day of month
-type opened_days()  :: pos_integer().

-type cron_day()  :: day_of_week()
                   | day_of_month()
                   | opened_days().

-type cron_time() :: calendar:datetime()
                   | calendar:time()
                   | {opened_days(), calendar:time()}.

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
-spec schedule(
    cycle(),
    [cron_day()],
    [
        {Start :: cron_time(), Offset :: cron_time(), Stop :: cron_time()} |
        {Start :: cron_time(), Stop :: cron_time()} |
        {opdays, Start :: cron_time(), Offset :: cron_time(), Stop :: cron_time()} |
        {opdays, Start :: cron_time(), Stop :: cron_time()}
    ]
) ->
    timeout | {ok, StartTime :: integer(), StopTime :: integer()}.
schedule(Cycle, DayList, TimeList) ->
    {Date, Time} = ut_time:datetime(),
    when_to_start(Cycle, DayList, TimeList, Date, Time).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
when_to_start(during, [], TimeList, Date, Time) ->
    find_among_datetime(TimeList, Date, Time);
when_to_start(opdays, [], TimeList, Date, Time) ->
    {OpenDate, _} = game_env:get_env(opened),
    OpenDays = ut_time:diff_days(OpenDate, Date) + 1,
    find_among_opendays(TimeList, Time, OpenDate, OpenDays);
when_to_start(mgdays, [], TimeList, Date, Time) ->
    MergeDate = ut_time:seconds_to_date(game_env:get_merged_time()),
    OpenDays  = ut_time:diff_days(MergeDate, Date) + 1,
    find_among_mergedays(TimeList, Time, MergeDate, OpenDays);
when_to_start(weekly, [], TimeList, Date, Time)->
    DoW = ut_time:day_of_week(Date),
    case find_among_weekday(TimeList, Time, Date, DoW) of
        {ok, Start, Stop} ->
            {ok, Start, Stop};
        timeout ->
            case hd(TimeList) of
                {{StartDoW,StartTime}, _, {StopDoW,StopTime}} ->
                    StartDate = ut_time:add_days(Date, StartDoW+7-DoW),
                    StopDate  = ut_time:add_days(Date, StopDoW+7-DoW),
                    {ok, {StartDate,StartTime}, {StopDate,StopTime}};
                {{StartDoW,StartTime}, {StopDoW,StopTime}} ->
                    StartDate = ut_time:add_days(Date, StartDoW+7-DoW),
                    StopDate  = ut_time:add_days(Date, StopDoW+7-DoW),
                    {ok, {StartDate,StartTime}, {StopDate,StopTime}};
                _ ->
                    timeout
            end
    end;
when_to_start(Cycle, DayList, TimeList, Date, Time) ->
    case find_opening_date(Cycle, DayList, Date) of
        {ok, StartDate, StopDate} when TimeList == [] ->
            {ok, {StartDate,{0,0,0}}, {StopDate,{23,59,59}}};
        {ok, StartDate, StopDate} ->
            case find_time_in_today(TimeList, Time) of
                {ok, StartTime, StopTime} ->
                    {ok, {StartDate,StartTime}, {StopDate,StopTime}};
                {ok, TheTime} ->
                    {ok, {StartDate,TheTime}};
                timeout ->
                    find_next_date(Cycle, DayList, TimeList, Date, Time)
            end;
        false ->
            find_next_date(Cycle, DayList, TimeList, Date, Time)
    end.

find_next_date(Cycle, DayList, TimeList, Date, Time) ->
    case until_next_date(Cycle, DayList, Date) of
        timeout  ->
            case until_next_cycle(Cycle, DayList, Date) of
                timeout  ->
                    timeout;
                DiffDays ->
                    calc_next_datetime(TimeList, DiffDays, Date, Time)
            end;
        DiffDays ->
            calc_next_datetime(TimeList, DiffDays, Date, Time)
    end.


find_among_datetime([{Start, Offset, Stop} | T], Date, Time) ->
    case {Date,Time} =< Offset of
        true  -> {ok, Start, Stop};
        false -> find_among_datetime(T, Date, Time)
    end;
find_among_datetime([{Start, Stop} | T], Date, Time) ->
    case {Date,Time} =< Start of
        true  -> {ok, Start, Stop};
        false -> find_among_datetime(T, Date, Time)
    end;
find_among_datetime([DateTime | T], Date, Time) ->
    case {Date,Time} =< DateTime of
        true  -> {ok, DateTime};
        false -> find_among_datetime(T, Date, Time)
    end;
find_among_datetime([], _Date, _Time) ->
    timeout.


find_among_opendays([{Start, Offset, Stop} | T], Time, OpenDate, OpenDays) ->
    case {OpenDays,Time} =< Offset of
        true  ->
            {ok,
                conv_days_time(OpenDate, Start),
                conv_days_time(OpenDate, Stop)
            };
        false ->
            find_among_opendays(T, Time, OpenDate, OpenDays)
    end;
find_among_opendays([{Start, Stop} | T], Time, OpenDate, OpenDays) ->
    case {OpenDays,Time} =< Start of
        true  ->
            {ok,
                conv_days_time(OpenDate, Start),
                conv_days_time(OpenDate, Stop)
            };
        false ->
            find_among_opendays(T, Time, OpenDate, OpenDays)
    end;
find_among_opendays([], _Time, _OpenDate, _OpenDays) ->
    timeout.

find_among_mergedays([{Start, Offset, Stop} | T], Time, OpenDate, OpenDays) ->
    case {OpenDays,Time} =< Offset of
        true  ->
            {ok,
                conv_days_time(OpenDate, Start),
                conv_days_time(OpenDate, Stop)
            };
        false ->
            find_among_mergedays(T, Time, OpenDate, OpenDays)
    end;
find_among_mergedays([{Start, Stop} | T], Time, OpenDate, OpenDays) ->
    case {OpenDays,Time} =< Start of
        true  ->
            {ok,
                conv_days_time(OpenDate, Start),
                conv_days_time(OpenDate, Stop)
            };
        false ->
            find_among_mergedays(T, Time, OpenDate, OpenDays)
    end;
find_among_mergedays([], _Time, _OpenDate, _OpenDays) ->
    timeout.


find_among_weekday([{Start, Offset, Stop} | T], Time, Date, DoW) ->
    case {DoW,Time} =< Offset of
        true  ->
            {ok,
                conv_weekday_time(Date, DoW, Start),
                conv_weekday_time(Date, DoW, Stop)
            };
        false ->
            find_among_weekday(T, Time, Date, DoW)
    end;
find_among_weekday([{Start, Stop} | T], Time, Date, DoW) ->
    case {DoW,Time} =< Start of
        true  ->
            {ok,
                conv_weekday_time(Date, DoW, Start),
                conv_weekday_time(Date, DoW, Stop)
            };
        false ->
            find_among_weekday(T, Time, Date, DoW)
    end;
find_among_weekday([], _Time, _Date, _DoW) ->
    timeout.

conv_weekday_time(Date, DoW1, {DoW2, Time}) ->
    {ut_time:add_days(Date, DoW2-DoW1), Time}.


find_opening_date(daily, _DayList, Date) ->
    {ok, Date, Date};
find_opening_date(weekly, DoWList, Date) ->
    DoW = ut_time:day_of_week(Date),
    find_opening_date2(DoWList, DoW, Date, weekly);
find_opening_date(monthly, DoMList, Date) ->
    DoM = ut_time:day_of_month(Date),
    find_opening_date2(DoMList, DoM, Date, monthly);
find_opening_date(during, DateList, Date) ->
    find_opening_date2(DateList, Date, Date, during);
find_opening_date(opdays, DayList, Date) ->
    Days = game_env:get_opened_days(),
    find_opening_date2(DayList, Days, Date, opdays);
find_opening_date(mgdays, DayList, Date) ->
    Days = game_env:get_merged_days(),
    find_opening_date2(DayList, Days, Date, mgdays).

find_opening_date2([{Day1, Day2} | T], Day, Date, Cycle) when Day1 < Day2 ->
    if
        Day =< Day2, is_integer(Day) ->
            Start = ut_time:add_days(Date, Day1-Day),
            Stop  = ut_time:add_days(Date, Day2-Day),
            {ok, Start, Stop};
        Day =< Day2 ->
            {ok, Day1, Day2};
        true ->
            find_opening_date2(T, Day, Date, Cycle)
    end;
% 只有 weekly, monthly 才会有这种情况
find_opening_date2([{Day1, Day2} | T], Day, Date, Cycle) when Day1 > Day2 ->
    case Day >= Day1 orelse Day =< Day2 of
        true when Cycle == weekly  ->
            Start = ut_time:add_days(Date, Day1-Day),
            Stop  = ut_time:add_days(Date, Day2+7-Day),
            {ok, Start, Stop};
        true when Cycle == monthly ->
            {Y, M, _} = Date,
            Start = ut_time:add_days(Date, Day1-Day),
            Stop  = case M == 12 of
                true  -> {Y+1, 1, Day2};
                false -> {Y, M+1, Day2}
            end,
            {ok, Start, Stop};
        false ->
            find_opening_date2(T, Day, Date, Cycle)
    end;
find_opening_date2([Day1 | T], Day, Date, Cycle) ->
    case Day == Day1 of
        true  ->
            {ok, Date, Date};
        false ->
            find_opening_date2(T, Day, Date, Cycle)
    end;
find_opening_date2([], _Day, _Date, _Cycle) ->
    false.


find_time_in_today([{Start, Offset, Stop} | T], Time) when is_tuple(Start) ->
    case Time =< Offset of
        true  -> {ok, Start, Stop};
        false -> find_time_in_today(T, Time)
    end;
find_time_in_today([{Start, Stop} | T], Time) ->
    case Time =< Start of
        true  -> {ok, Start, Stop};
        false -> find_time_in_today(T, Time)
    end;
find_time_in_today([Time1 | T], Time2) ->
    case Time2 =< Time1 of
        true  -> {ok, Time1};
        false -> find_time_in_today(T, Time2)
    end;
find_time_in_today([], _Time) ->
    timeout.


until_next_date(daily, _DayList, _Date) ->
    1;
until_next_date(weekly, DoWList, Date) ->
    until_next_date2(DoWList, ut_time:day_of_week(Date));
until_next_date(monthly, DoMList, Date) ->
    until_next_date2(DoMList, ut_time:day_of_month(Date));
until_next_date(during, DateList, Date) ->
    until_next_date2(DateList, Date);
until_next_date(opdays, DayList, _Date) ->
    until_next_date2(DayList, game_env:get_opened_days());
until_next_date(mgdays, DayList, _Date) ->
    until_next_date2(DayList, game_env:get_merged_days()).


until_next_date2([{Day1, _} | T], Day) ->
    case Day < Day1 of
        true  -> diff_days(Day, Day1);
        false -> until_next_date2(T, Day)
    end;
until_next_date2([Day1 | T], Day) ->
    case Day < Day1 of
        true  -> diff_days(Day, Day1);
        false -> until_next_date2(T, Day)
    end;
until_next_date2([], _Day) ->
    timeout.


until_next_cycle(weekly, [{DoW, _} | T], Date) ->
    until_next_cycle(weekly, [DoW | T], Date);
until_next_cycle(weekly, [DoW | _], Date) ->
    DoW + 7 - ut_time:day_of_week(Date);
until_next_cycle(monthly, [{DoM,_} | T], Date) ->
    until_next_cycle(monthly, [DoM | T], Date);
until_next_cycle(monthly, [DoM | _], Date={Y,M,_}) ->
    case M == 12 of
        true  -> diff_days(Date, {Y+1, 1, DoM});
        false -> diff_days(Date, {Y, M+1, DoM})
    end;
until_next_cycle(_Type, _DayList, _Date) ->
    timeout.

calc_next_datetime([{Start, _, Stop} | _], Days, Date, _Time) when is_tuple(Start) ->
    Date2 = ut_time:add_days(Date, Days),
    {ok, {Date2,Start}, {Date2,Stop}};
calc_next_datetime([{Start, Stop} | _], Days, Date, _Time) ->
    Date2 = ut_time:add_days(Date, Days),
    {ok, {Date2,Start}, {Date2,Stop}};
calc_next_datetime([Time | _], Days, Date, _Time) ->
    Date2 = ut_time:add_days(Date, Days),
    {ok, {Date2,Time}};
calc_next_datetime(_, _Days, _Date, _Time) ->
    timeout.

diff_days(Day1, Day2) when is_integer(Day1) ->
    Day2 - Day1;
diff_days(Date1, Date2) ->
    ut_time:diff_days(Date1, Date2).

conv_days_time(OpenDate, {Days, Time}) ->
    {ut_time:add_days(OpenDate, Days-1), Time}.
