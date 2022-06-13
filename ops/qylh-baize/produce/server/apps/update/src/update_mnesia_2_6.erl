-module(update_mnesia_2_6).

-behaviour(update_behavior).
-compile([export_all]).
-compile(nowarn_export_all).

-include("table.hrl").

vsn() ->
    "2.6".

run() ->
    ok = update_richman(),
    ok.

once() ->
    ok.

update_richman()->
    StartSecs = ut_time:datetime_to_seconds({{2020,5,28},{0,0,0}}),
    StopSecs  = ut_time:datetime_to_seconds({{2020,6,6},{23,59,59}}),
    Func = fun
        ({role_richman, ID, CURR_ROUND, CURR_GRID, LUCKY_ROUND, LUCKY_FETCH, ROUND_FETCH, DICE_GAIN}) ->
            {role_richman, ID, CURR_ROUND, CURR_GRID, LUCKY_ROUND, LUCKY_FETCH, ROUND_FETCH, DICE_GAIN, StartSecs, StopSecs};
        ({role_richman, ID, CURR_ROUND, CURR_GRID, LUCKY_ROUND, LUCKY_FETCH, ROUND_FETCH, DICE_GAIN, _, _}) ->
            {role_richman, ID, CURR_ROUND, CURR_GRID, LUCKY_ROUND, LUCKY_FETCH, ROUND_FETCH, DICE_GAIN, StartSecs, StopSecs};
        (R) ->
            R
    end,
    update_behavior:transform(role_richman, Func, record_info(fields, role_richman)),
    ok.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
