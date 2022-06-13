%% @author rong
%% @doc 
-module(web_marquee_api).

-include("game.hrl").
-include("marquee.hrl").

-export([add/1, del/1]).

add(Req) ->
    {ok, Params, Req1} = cowboy_req:read_urlencoded_body(Req),
    ID        = ut_conv:to_integer(proplists:get_value(<<"id">>, Params)),
    {ok, GCIDs} = web_util:str_list(?nil, proplists:get_value(<<"gcids">>, Params)),
    StartTime = ut_conv:to_integer(proplists:get_value(<<"start_time">>, Params)),
    EndTime   = ut_conv:to_integer(proplists:get_value(<<"end_time">>, Params)),
    Content   = ut_conv:to_list(proplists:get_value(<<"content">>, Params)),
    Interval  = ut_conv:to_integer(proplists:get_value(<<"interval">>, Params)),
    web_util:validate_sign([ID], Params),
    marquee_manager:add(#r_marquee{
        id         = ID,
        type       = 0,
        gcids      = GCIDs,
        start_time = StartTime,
        end_time   = EndTime,
        content    = Content,
        interval   = Interval,
        ext        = #{}
    }),
    web_reply:ok(Req1).

del(Req) ->
    {ok, Params, Req1} = cowboy_req:read_urlencoded_body(Req),
    ID = ut_conv:to_integer(proplists:get_value(<<"id">>, Params)),
    web_util:validate_sign([ID], Params),
    marquee_manager:del(ID),
    web_reply:ok(Req1).
