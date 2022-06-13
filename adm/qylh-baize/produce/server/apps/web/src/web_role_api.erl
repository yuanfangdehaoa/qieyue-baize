%% @author rong
%% @doc
-module(web_role_api).

-include("game.hrl").
-include("errno.hrl").
-include("table.hrl").
-include("role.hrl").

-export([ban/1, silent/1, kick/1, online/1]).
-export([detail/1]).
-export([role_info/1]).

% 封号/解封
ban(Req) ->
    {ok, Params, Req1} = cowboy_req:read_urlencoded_body(Req),
    RoleIDStr = proplists:get_value(<<"role_ids">>, Params),
    {ok, RoleIDs} = web_util:int_list(?nil, RoleIDStr),
    {ok, Ban} = web_util:boolean(?nil, proplists:get_value(<<"ban">>, Params)),
    web_util:validate_sign([ut_conv:to_list(RoleIDStr)], Params),
    [case Ban of
        true ->
            login_server:ban_role_id(RoleID),
            [rank_server:gm_del(RankID, RoleID) || RankID <- [1001, 1002, 1003, 1004, 1005]],
            kickout(RoleID);
        false ->
            login_server:unban_role_id(RoleID)
    end || RoleID <- RoleIDs],
    web_reply:ok(Req1).

% 禁言/解禁
silent(Req) ->
    {ok, Params, Req1} = cowboy_req:read_urlencoded_body(Req),
    RoleIDStr = proplists:get_value(<<"role_ids">>, Params),
    {ok, RoleIDs} = web_util:int_list(?nil, RoleIDStr),
    {ok, Silent} = web_util:boolean(?nil, proplists:get_value(<<"silent">>, Params)),
    web_util:validate_sign([ut_conv:to_list(RoleIDStr)], Params),
    [case Silent of
        true ->
            chat_silent:ban(RoleID);
        false ->
            chat_silent:unban(RoleID)
    end || RoleID <- RoleIDs],
    web_reply:ok(Req1).

% 踢玩家下线
kick(Req) ->
    {ok, Params, Req1} = cowboy_req:read_urlencoded_body(Req),
    RoleIDStr = proplists:get_value(<<"role_ids">>, Params),
    {ok, RoleIDs} = web_util:int_list(?nil, RoleIDStr),
    web_util:validate_sign([ut_conv:to_list(RoleIDStr)], Params),
    [kickout(RoleID) || RoleID <- RoleIDs],
    web_reply:ok(Req1).

online(Req) ->
    #{role_id := RoleID} = cowboy_req:match_qs([{role_id, int}], Req),
    Data = #{<<"online">> => role:is_alive(RoleID)},
    web_reply:ok(Data, Req).

detail(Req) ->
    #{role_id := RoleID} = cowboy_req:match_qs([{role_id, int}], Req),
    web_util:validate_sign([RoleID], Req),
    case db:dirty_read(?DB_ROLE_INFO, RoleID) of
        [_] ->
            {ok, [RoleAttr]} = user_default:data(RoleID, [role_attr]),
            #role_attr{attr=Attr} = RoleAttr,
            Attr2 = maps:fold(fun(K, V, Acc) ->
                maps:put(ut_conv:to_binary(K), ut_conv:to_binary(V), Acc)
            end, #{}, Attr),
            {ok, #role_cache{marry=MarryWith, mname=MName}} = role:get_cache(RoleID),
            Data = #{
                <<"online">> => role:is_alive(RoleID), 
                <<"couple">> => #{<<"marry">> => MarryWith, <<"mname">> => ut_conv:to_binary(MName)},
                <<"attr">> => Attr2
            },
            web_reply:ok(Data, Req);
        _ ->
            web_reply:error(Req)
    end.

kickout(RoleID) ->
    role:is_alive(RoleID) andalso role:kickout(RoleID, ?ERR_GAME_KICKOUT).


%% 获取玩家数据
role_info(Req) ->
    #{role_id := RoleID} = cowboy_req:match_qs([{role_id, int}], Req),
    Data =
        case role:is_alive(RoleID) of
            true ->
                get_cache_data(RoleID);
            false ->
                role_info_db(RoleID)
        end,
    web_reply:ok(Data, Req).

role_info_db(RoleID) ->
    [#role_info{level = Level}] = db:dirty_read(?DB_ROLE_INFO, RoleID),
    [#role_attr{power = Power}] = db:dirty_read(?DB_ROLE_ATTR, RoleID),
    Data = #{
        <<"level">> => Level,
        <<"power">> => Power
    },
    Data.

get_cache_data(RoleID) ->
    {ok, #role_cache{level = Level, power = Power}} = role_cache:get_cache(RoleID),
    Data = #{
        <<"level">> => Level,
        <<"power">> => Power
    },
    Data.