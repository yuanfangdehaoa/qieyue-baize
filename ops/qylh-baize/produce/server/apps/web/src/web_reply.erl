%% @author rong
%% @doc 
-module(web_reply).

-include("errno.hrl").

-export([ok/1, ok/2, error/1, error/2, error/3]).

ok(Req) ->
    ok(<<>>, Req).

ok(Data, Req) ->
    cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json; charset=utf-8">>
    }, jiffy:encode(#{data => Data, msg => <<>>, code => 0}), Req).

error(Req) ->
    % 默认系统程序错误
    error(?ERR_WEB_SYS_ERROR, <<>>, Req).

error(Code, Req) ->
    error(Code, <<>>, Req).

error(Code, Reason, Req) ->
    cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json; charset=utf-8">>
    }, jiffy:encode(#{data => <<>>, msg => Reason, code => Code}), Req).
