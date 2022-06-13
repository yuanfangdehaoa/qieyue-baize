%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(sdk_common).

-include("game.hrl").
-include("errno.hrl").


%% API
-export([verify/6]).
-export([is_android/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
verify(Path, GameChan, Account, Token, SDKArgs, IP) ->
	Headers = [{<<"Content-Type">>, <<"application/json">>}],
	Body = jiffy:encode(#{
		<<"gamechan">>     => ut_conv:to_binary(GameChan),
		<<"account">>      => ut_conv:to_binary(Account),
		<<"token">>        => ut_conv:to_binary(Token),
		<<"gamezone">>     => ut_conv:to_binary(maps:get("zone_id", SDKArgs, game_uid:suid2ssid())),
		<<"ip">>           => ut_conv:to_binary(inet_parse:ntoa(IP)),
		<<"os_type">>      => ut_conv:to_binary(maps:get("os_type", SDKArgs, "")),
		<<"ios_idfa">>     => ut_conv:to_binary(maps:get("ios_idfa", SDKArgs, "")),
		<<"android_imei">> => ut_conv:to_binary(maps:get("android_imei", SDKArgs, "")),
		<<"suid">>         => ut_conv:to_binary(game_env:get_suid()),
		<<"sessid">>       => ut_conv:to_binary(maps:get("sessid", SDKArgs, ""))
	}),
	?debug("login verify, path: ~p, body: ~p", [Path, Body]),
	case web_request:get(Path, #{}, Headers, Body) of
		{ok, Resp} ->
			Ret = jiffy:decode(Resp, [return_maps]),
			?debug("response: ~p", [Ret]),
			?_check(maps:get(<<"succ">>, Ret), ?ERR_LOGIN_VERIFY_FAIL),
			ErrCode = maps:get(<<"err_code">>, Ret, 0),
			?_check(ErrCode == 0, ErrCode),
		    % ?_check(maps:get(<<"opened">>, Ret), ?ERR_GAME_NOT_OPENED),
			ok;
		Error ->
			?debug("verify error: ~p", [Error]),
			throw(?err(?ERR_GAME_NOT_OPENED))
	end.

is_android(SDKArgs) ->
	ut_conv:to_binary(maps:get("os_type", SDKArgs)) == <<"android">>.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
