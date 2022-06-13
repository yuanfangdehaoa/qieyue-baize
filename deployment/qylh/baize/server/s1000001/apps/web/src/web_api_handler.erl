%% @author rong
%% @doc 
-module(web_api_handler).
-include("game.hrl").

-export([init/2]).

init(Req0, {Mod, Fun} = State) ->
    Req1 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<$*>>, Req0),
    Req2 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET, POST">>, Req1),
    Req3 = cowboy_req:set_resp_header(<<"access-control-allow-headers">>, <<"content-type">>, Req2),
    Req =
        case check_admin_host(Req3, Mod, Fun) of
            ok ->
                deal_web_api(Req3, Mod, Fun);
            _ ->
                web_reply:error(Req3)
        end,
    {ok, Req, State}.

deal_web_api(Req3, Mod, Fun) ->
    try
        Mod:Fun(Req3)
    catch
        throw:{error, ErrCode, Reason}:_ ->
            web_reply:error(ErrCode, Reason, Req3);
        Class:Reason:Stacktrace ->
            ?stacktrace(Class, Reason, Stacktrace),
            web_reply:error(Req3)
    end.

check_admin_host(Req, Mod, Fun) ->
    case maps:get(peer, Req, null) of
        {{N1, N2, N3, N4}, _Port} ->
            AdminHost = log_env:host(),
            case lists:concat([N1,".",N2,".",N3,".",N4]) of
                AdminHost ->
                    ok;
                HackHost ->
                    ?info("receive hacker web_api_handler ==== ~p", [{HackHost, Mod, Fun, Req}]),
                    error
            end;
        _ ->
            ok
    end.
