%% @author rong
%% @doc
-module(web_mail_api).

-include("game.hrl").
-include("table.hrl").

-export([send/1]).

% 多条件发送
send(Req) ->
    {ok, Params, Req1} = cowboy_req:read_body(Req),
    Data = jiffy:decode(Params, [return_maps]),
    Title = maps:get(<<"title">>, Data),
    Content = maps:get(<<"content">>, Data),
    Ts = maps:get(<<"_ts">>, Data),
    Sign = maps:get(<<"_sign">>, Data),

    RoleIDs = web_util:to_int_list(maps:get(<<"role_ids">>, Data, [])),
    Items = to_items(maps:get(<<"items">>, Data, [])),

    web_util:validate_sign([Title, Content], Ts, Sign),
    AllRoleIDs = case RoleIDs =/= [] of
        true -> RoleIDs;
        false -> db:dirty_all_keys(?DB_ROLE_INFO)
    end,

    [begin
        IsOk = lists:all(fun(Func) ->
            Func(RoleID, Data)
        end, [
            fun check_role_type/2,
            fun check_role_game_chan_and_lv/2
        ]),
        ?debug("~w", [{IsOk, RoleID}]),
        case IsOk of
            true ->
                mail:send(RoleID, Title, Content, Items);
            _ ->
                ignore
        end
    end || RoleID <- AllRoleIDs],
    web_reply:ok(Req1).

check_role_type(RoleID, Data) ->
    RoleType = maps:get(<<"role_type">>, Data, <<"all">>),
    case RoleType of
        <<"all">> -> true;
        <<"online">> -> role:is_alive(RoleID);
        _ -> true
    end.

check_role_game_chan_and_lv(RoleID, Data) ->
    GCIDs = web_util:to_str_list(maps:get(<<"gcids">>, Data, [])),
    Level = ut_conv:to_integer(maps:get(<<"level">>, Data, 0)),
    case db:dirty_read(?DB_ROLE_INFO, RoleID) of
        [#role_info{userid={GameChan, _}, level=Lv}] when Lv >= Level ->
            GCIDs == [] orelse lists:member(GameChan, GCIDs);
        _ ->
            false
    end.

to_items(Items) ->
    to_items(Items, []).
to_items([], Acc) ->
    Acc;
to_items([Item | T], Acc) ->
    to_items(T, [{
        ut_conv:to_integer(maps:get(<<"item">>, Item)),
        ut_conv:to_integer(maps:get(<<"num">>, Item)),
        ut_conv:to_integer(maps:get(<<"bind">>, Item))
    } | Acc]).
