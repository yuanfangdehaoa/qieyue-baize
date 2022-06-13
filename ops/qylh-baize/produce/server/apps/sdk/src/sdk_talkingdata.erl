%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(sdk_talkingdata).

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
	Json = jiffy:encode([
		Data#{<<"status">> => <<"request">>},
		Data#{<<"status">> => <<"success">>}
	]),
	ReqHeader = [{<<"Content-Type">>, <<"application/json">>}],
	ReqBody  = zlib:gzip(Json),
	ReqURL   = "http://api.talkinggame.com/api/charge/798E8EF3C6BF4880A159F3ADD2E60F70",
	Response = hackney:request(post, ReqURL, ReqHeader, ReqBody),
	?debug("Json----------:~p", [Json]),
	case Response of
		{ok, 200, _, Ref} ->
			{ok, Body} = hackney:body(Ref),
			Ret  = jiffy:decode(zlib:gunzip(Body), [return_maps]),
			?debug("Ret-------------:~p", [Ret]),
			Code = maps:get(<<"code">>, Ret, 0),
			?_if(Code /= 100, ?error("upload fail: ~p", [Ret])),
			lists:foreach(fun
				(Status) ->
					StCode = maps:get(<<"code">>, Status),
					?_if(StCode /= 1, ?error("data error: ~p", [Status]))
			end, maps:get(<<"dataStatus">>, Ret, [])),
			ok;
		_ ->
			?debug("response:~p", [Response])
	end.

-endif.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
