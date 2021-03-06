%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(ut_time).

%% API
-export([datetime/0, date/0, time/0, seconds/0, milliseconds/0, microseconds/0]).
-export([timezone/0]).
-export([today/0, yesterday/0, tomorrow/0, monday/1, sunday/1, last_weekday_of_month/2]).
-export([day_of_week/0, day_of_week/1]).
-export([day_of_month/0, day_of_month/1]).
-export([week_num/0, week_num/1]).
-export([midnight/0, midnight/1]).
-export([add_seconds/2, add_days/2]).
-export([diff_days/2]).
-export([is_same_month/2, is_same_week/2, is_same_date/2, is_today/1]).

-export([seconds_to_datetime/1]).
-export([seconds_to_date/1]).
-export([seconds_to_time/1]).
-export([datetime_to_seconds/1]).
-export([time_to_seconds/1]).

-export([date_to_string/1, date_to_string/2]).
-export([time_to_string/1, time_to_string/2]).
-export([datetime_to_string/1, datetime_to_string/4]).
-export([seconds_to_string/1]).

-export([string_to_date/1, string_to_date/2]).
-export([string_to_time/1, string_to_time/2]).
-export([string_to_datetime/1, string_to_datetime/4]).

-export([is_debug/0]).
-define(DATETIME_1970_GMT, {{1970,1,1},{0,0,0}}).
-define(SECONDS_FROM_0_TO_1970,
    calendar:datetime_to_gregorian_seconds(calendar:universal_time_to_local_time(?DATETIME_1970_GMT))
).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

-ifdef(DEBUG).

datetime() ->
    ?MODULE:seconds_to_datetime(?MODULE:seconds()).

date() ->
    {Date, _} = ?MODULE:seconds_to_datetime(?MODULE:seconds()),
    Date.

time() ->
    {_, Time} = ?MODULE:seconds_to_datetime(?MODULE:seconds()),
    Time.

seconds() ->
    try
        {Setting, When} = mochiglobal:get(gm_time),
        Now = ?MODULE:datetime_to_seconds(erlang:localtime()),
        Setting + (Now - When)
    catch _:_:_ ->
        ?MODULE:datetime_to_seconds(erlang:localtime())
    end.

milliseconds() ->
    ?MODULE:seconds() * 1000 + erlang:system_time(millisecond) rem 1000.

microseconds() ->
    ?MODULE:seconds() * 1000000 + erlang:system_time(microsecond) rem 1000000.
is_debug() ->
    true.

-else.

%%-----------------------------------------------
%% @doc ????????????????????????
-spec datetime() ->
    calendar:datetime().
%%-----------------------------------------------
datetime() ->
    erlang:localtime().


%%-----------------------------------------------
%% @doc ????????????????????????
-spec date() ->
    calendar:date().
%%-----------------------------------------------
date() ->
    erlang:date().


%%-----------------------------------------------
%% @doc ????????????????????????
-spec time() ->
    calendar:time().
%%-----------------------------------------------
time() ->
    erlang:time().


%%-----------------------------------------------
%% @doc ???????????????????????????(???)
-spec seconds() ->
    integer().
%%-----------------------------------------------
seconds() ->
	erlang:system_time(second).

%%-----------------------------------------------
%% @doc ????????????????????????????????????
-spec milliseconds() ->
    integer().
%%-----------------------------------------------
milliseconds() ->
    erlang:system_time(millisecond).

%%-----------------------------------------------
%% @doc ????????????????????????????????????
-spec microseconds() ->
    integer().
%%-----------------------------------------------
microseconds() ->
    erlang:system_time(microsecond).

is_debug() ->
    false.
-endif.


%%-----------------------------------------------
%% @doc ????????????
-spec timezone() ->
    integer().
%%-----------------------------------------------
timezone() ->
    DateTime1 = ?DATETIME_1970_GMT,
    DateTime2 = calendar:universal_time_to_local_time(?DATETIME_1970_GMT),
    Seconds1  = calendar:datetime_to_gregorian_seconds(DateTime1),
    Seconds2  = calendar:datetime_to_gregorian_seconds(DateTime2),
    (Seconds2 - Seconds1) div (60*60).


%%-----------------------------------------------
%% @doc ????????????
-spec today() ->
    calendar:date().
%%-----------------------------------------------
today() ->
    ?MODULE:date().

%%-----------------------------------------------
%% @doc ???????????????
-spec yesterday() ->
    calendar:date().
%%-----------------------------------------------
yesterday() ->
    add_days(?MODULE:date(), -1).


%%-----------------------------------------------
%% @doc ???????????????
-spec tomorrow() ->
    calendar:date().
%%-----------------------------------------------
tomorrow() ->
    add_days(?MODULE:date(), 1).

%%-----------------------------------------------
%% @doc ??????
-spec monday(calendar:date()) ->
    calendar:date().
%%-----------------------------------------------
monday(Date) ->
    Day = day_of_week(Date),
    add_days(Date, 1 - Day).

%%-----------------------------------------------
%% @doc ??????
-spec sunday(calendar:date()) ->
    calendar:date().
%%-----------------------------------------------
sunday(Date) ->
    Day = day_of_week(Date),
    add_days(Date, 7 - Day).

%%-----------------------------------------------
%% @doc ??????????????????????????????
-spec last_weekday_of_month(calendar:date(), integer()) ->
    calendar:date().
%%-----------------------------------------------
last_weekday_of_month(Date, WeekDay) ->
    {Year, Month, _} = Date,
    LastDay = calendar:last_day_of_the_month(Year, Month),
    LastDate = {Year, Month, LastDay},
    LastDayOfWeek = day_of_week(LastDate),
    Diff = if
        LastDayOfWeek >= WeekDay -> LastDayOfWeek-WeekDay;
        true -> 7 + (LastDayOfWeek-WeekDay)
    end,
    add_days(LastDate, -Diff).

%%-----------------------------------------------
%% @doc ??????????????????????????????
%% ????????? 7
-spec day_of_week() ->
    integer().
-spec day_of_week(calendar:date()) ->
    integer().
%%-----------------------------------------------
day_of_week() ->
    {Date, _} = ?MODULE:datetime(),
    calendar:day_of_the_week(Date).
day_of_week(Date) ->
    calendar:day_of_the_week(Date).


%%-----------------------------------------------
%% @doc ??????
-spec day_of_month() ->
    integer().
-spec day_of_month(calendar:date()) ->
    integer().
%%-----------------------------------------------
day_of_month() ->
    element(3, ?MODULE:date()).
day_of_month(Date) ->
    element(3, Date).


%%-----------------------------------------------
%% @doc ???????????????????????????????????????
-spec week_num() ->
    {Year :: integer(), Num :: integer()}.
-spec week_num(calendar:date()) ->
    {Year :: integer(), Num :: integer()}.
%%-----------------------------------------------
week_num() ->
    {Date, _} = calendar:local_time(),
    calendar:iso_week_number(Date).
week_num(Date) ->
    calendar:iso_week_number(Date).


%%-----------------------------------------------
%% @doc ??????12???
-spec midnight() ->
    integer().
-spec midnight(calendar:date()) ->
    integer().
%%-----------------------------------------------
midnight() ->
    midnight(ut_time:date()).

midnight(Date) ->
    ut_time:datetime_to_seconds({Date,{23,59,59}}).


%%-----------------------------------------------
%% @doc ?????????????????????
-spec add_seconds(calendar:datetime() | calendar:time(), integer()) ->
    calendar:datetime().
%%-----------------------------------------------
add_seconds({_, _} = DateTime, Secs) ->
    ?MODULE:seconds_to_datetime(?MODULE:datetime_to_seconds(DateTime) + Secs);
add_seconds(Time, Secs) ->
    NewSecs = ?MODULE:time_to_seconds(Time) + Secs,
    {_, NewTime} = ?MODULE:seconds_to_datetime(NewSecs),
    NewTime.


%%-----------------------------------------------
%% @doc ?????????????????????
-spec add_days(calendar:datetime() | calendar:date() , integer()) ->
    calendar:datetime().
%%-----------------------------------------------
add_days({Date, Time}, Days) ->
    GregDays = calendar:date_to_gregorian_days(Date) + Days,
    {calendar:gregorian_days_to_date(GregDays), Time};
add_days(Date, Days) ->
    GregDays = calendar:date_to_gregorian_days(Date) + Days,
    calendar:gregorian_days_to_date(GregDays).


%%-----------------------------------------------
%% @doc ????????????/????????????????????????
%% ??????????????? 0 ???
-spec diff_days(calendar:date() | integer(), calendar:date() | integer()) ->
    integer().
%%-----------------------------------------------
diff_days({_, _, _} = Date1, Date2) ->
     calendar:date_to_gregorian_days(Date2) - calendar:date_to_gregorian_days(Date1);
diff_days(Seconds1, Seconds2) ->
    {Date1, _} = seconds_to_datetime(Seconds1),
    {Date2, _} = seconds_to_datetime(Seconds2),
    calendar:date_to_gregorian_days(Date2) - calendar:date_to_gregorian_days(Date1).


%%-----------------------------------------------
%% @doc ????????????/??????????????????????????????
-spec is_same_month(calendar:date() | integer(), calendar:date() | integer()) ->
    boolean().
%%-----------------------------------------------
is_same_month({_, Month1, _} = _Date, {_, Month2, _}) ->
    Month1 == Month2;
is_same_month(Seconds1, Seconds2) ->
    {{_, Month1, _}, _} = seconds_to_datetime(Seconds1),
    {{_, Month2, _}, _} = seconds_to_datetime(Seconds2),
    Month1 == Month2.


%%-----------------------------------------------
%% @doc ????????????/?????????????????????????????????
-spec is_same_week(calendar:date() | integer(), calendar:date() | integer()) ->
    boolean().
%%-----------------------------------------------
is_same_week({_, _, _} = Date1, Date2) ->
    calendar:iso_week_number(Date1) == calendar:iso_week_number(Date2);
is_same_week(Seconds1, Seconds2) ->
    {Date1, _} = seconds_to_datetime(Seconds1),
    {Date2, _} = seconds_to_datetime(Seconds2),
    calendar:iso_week_number(Date1) == calendar:iso_week_number(Date2).


%%-----------------------------------------------
%% @doc ?????????????????????????????????
-spec is_same_date(integer(), integer()) ->
    boolean().
%%-----------------------------------------------
is_same_date(Seconds1, Seconds2) ->
    {Date1, _} = seconds_to_datetime(Seconds1),
    {Date2, _} = seconds_to_datetime(Seconds2),
    Date1 == Date2.


%%-----------------------------------------------
%% @doc ??????/?????????????????????
-spec is_today(calendar:date() | integer()) ->
    boolean().
%%-----------------------------------------------
is_today({_, _, _} = Date) ->
    Date =:= ?MODULE:date();
is_today(Seconds) ->
    {Date,_} = seconds_to_datetime(Seconds),
    Date =:= ?MODULE:date().


%%-----------------------------------------------
%% @doc ???????????????????????????
-spec seconds_to_datetime(integer()) ->
    calendar:datetime().
%%-----------------------------------------------
seconds_to_datetime(Seconds)->
    calendar:gregorian_seconds_to_datetime(?SECONDS_FROM_0_TO_1970 + Seconds).


%%-----------------------------------------------
%% @doc ???????????????????????????
-spec seconds_to_date(integer()) ->
    calendar:date().
%%-----------------------------------------------
seconds_to_date(Seconds) ->
    {Date,_} = seconds_to_datetime(Seconds),
    Date.


%%-----------------------------------------------
%% @doc ???????????????????????????
-spec seconds_to_time(integer()) ->
    calendar:time().
%%-----------------------------------------------
seconds_to_time(Seconds) ->
    {_,Time} = seconds_to_datetime(Seconds),
    Time.


%%-----------------------------------------------
%% @doc ????????????????????????
-spec datetime_to_seconds(calendar:datetime()) ->
    integer().
%%-----------------------------------------------
datetime_to_seconds(DateTime)->
    calendar:datetime_to_gregorian_seconds(DateTime) - ?SECONDS_FROM_0_TO_1970.


%%-----------------------------------------------
%% @doc ????????????????????????
-spec time_to_seconds(calendar:time()) ->
    integer().
%%-----------------------------------------------
time_to_seconds(Time)->
    calendar:datetime_to_gregorian_seconds({?MODULE:date(),Time}) - ?SECONDS_FROM_0_TO_1970.


%%-----------------------------------------------
%% @doc ???????????????????????????
%% Sep ??????????????????????????????
-spec date_to_string(calendar:date(), string()) ->
    string().
%%-----------------------------------------------
date_to_string(Date) ->
    date_to_string(Date, "-").

date_to_string({Y, M, D}, Sep) ->
    io_lib:format("~4..0B~s~2..0B~s~2..0B", [Y, Sep, M, Sep, D]).


%%-----------------------------------------------
%% @doc ???????????????????????????
%% Sep ??????????????????????????????
-spec time_to_string(calendar:time(), string()) ->
    string().
%%-----------------------------------------------
time_to_string(Time) ->
    time_to_string(Time, ":").

time_to_string({H, M, S}, Sep) ->
    io_lib:format("~2..0B~s~2..0B~s~2..0B", [H, Sep, M, Sep, S]).


%%-----------------------------------------------
%% @doc ???????????????????????????
%% Sep1 ???????????????????????????????????????
%% Sep2 ??????????????????????????????
%% Sep3 ??????????????????????????????
-spec datetime_to_string(calendar:datetime(), string(), string(), string()) ->
    string().
%%-----------------------------------------------
datetime_to_string(DateTime) ->
    datetime_to_string(DateTime, " ", "-", ":").

datetime_to_string({{Y, M, D}, {H, MM, S}}, Sep1, Sep2, Sep3) ->
    io_lib:format("~4..0B~s~2..0B~s~2..0B~s~2..0B~s~2..0B~s~2..0B",
        [Y, Sep2, M, Sep2, D, Sep1, H, Sep3, MM, Sep3, S]).

%%-----------------------------------------------
%% @doc ??????????????????????????????
-spec seconds_to_string(integer()) ->
    string().
%%-----------------------------------------------
seconds_to_string(Seconds) ->
    datetime_to_string(seconds_to_datetime(Seconds)).

%%-----------------------------------------------
%% @doc ???????????????????????????
%% Sep ??????????????????????????????
-spec string_to_date(string(), string()) ->
    calendar:date().
%%-----------------------------------------------
string_to_date(Str) ->
    string_to_date(Str, "-").

string_to_date(Str, Sep) ->
    list_to_tuple([list_to_integer(X) || X <- string:tokens(Str, Sep)]).


%%-----------------------------------------------
%% @doc ???????????????????????????
%% Sep ??????????????????????????????
-spec string_to_time(string(), string()) ->
    calendar:time().
%%-----------------------------------------------
string_to_time(Str) ->
    string_to_time(Str, ":").

string_to_time(Str, Sep) ->
    list_to_tuple([list_to_integer(X) || X <- string:tokens(Str, Sep)]).


%%-----------------------------------------------
%% @doc ???????????????????????????
%% Sep1 ???????????????????????????????????????
%% Sep2 ??????????????????????????????
%% Sep3 ??????????????????????????????
-spec string_to_datetime(string(), string(), string(), string()) ->
    calendar:datetime().
%%-----------------------------------------------
string_to_datetime(Str) ->
    [Date, Time] = string:tokens(Str, " "),
    {string_to_date(Date), string_to_time(Time)}.

string_to_datetime(Str, Sep1, Sep2, Sep3) ->
    [Date, Time] = string:tokens(Str, Sep1),
    {string_to_date(Date, Sep2), string_to_time(Time, Sep3)}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
