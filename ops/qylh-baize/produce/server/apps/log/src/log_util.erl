%% @author rong
%% @doc 
-module(log_util).

-export([week_tag/1, month_tag/1, month_tag/2]).

week_tag(Tab) ->
    {Year, Week} = ut_time:week_num(),
    ut_conv:to_binary(lists:concat([ut_conv:to_list(Tab), "_", Year, "_", Week])).

month_tag(Tab) ->
    month_tag(ut_time:date(), Tab).

month_tag(Date, Tab) ->
    {Year, Month, _} = Date,
    ut_conv:to_binary(lists:concat([ut_conv:to_list(Tab), "_", Year, "_", Month])).