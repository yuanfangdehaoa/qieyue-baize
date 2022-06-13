%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(log_talkingdata).

-include("game.hrl").
-include("table.hrl").

%% API
-export([log_pay/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

-ifdef(DEBUG).

log_pay(_,_,_,_) ->
	ignore.

-else.

log_pay(User, _IP, SDKArgs, {AppOrder,SDKOrder,GoodsID,TotalFee,GainGold}) ->
	Role = role_data:get(?DB_ROLE_INFO),
	Data = #{
		<<"msgID">>                 => ut_conv:to_binary(AppOrder),
		<<"OS">>                    => ut_conv:to_binary(maps:get("os_type", SDKArgs, "android")),
		<<"accountID">>             => ut_conv:to_binary(User#game_user.account),
		<<"orderID">>               => ut_conv:to_binary(SDKOrder),
		<<"currencyAmount">>        => TotalFee,
		<<"currencyType">>          => <<"CNY">>,
		<<"virtualCurrencyAmount">> => GainGold,
		<<"chargeTime">>            => ut_time:seconds(),
		<<"iapID">>                 => ut_conv:to_binary(GoodsID),
		<<"gameServer">>            => ut_conv:to_binary(game_env:get_suid()),
		<<"gameVersion">>           => ut_conv:to_binary(game_env:get_version()),
		<<"level">>                 => Role#role_info.level,
		<<"partner">>               => ut_conv:to_binary(User#game_user.gamechan)
	},
	Headers = [{<<"Content-Type">>, <<"application/json">>}],
	URL  = "http://api.talkinggame.com/api/charge/798E8EF3C6BF4880A159F3ADD2E60F70",
	Body = zlib:gzip(jiffy:encode([
		Data#{<<"status">> => <<"request">>},
		Data#{<<"status">> => <<"success">>}
	])),
	case web_request:post(URL, "", #{}, Headers, Body, []) of
		{ok, _} ->
			ok;
		Error ->
			?debug("upload error: ~p", [Error])
	end.

-endif.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
