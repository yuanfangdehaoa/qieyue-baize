%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(sdk_yige).

%% API
-export([verify/5]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
verify("eco1001", _Account, _Token, _SDKArgs, _IP) ->
	ok;
verify(GameChan, Account, Token, SDKArgs, IP) ->
	Path = case GameChan of
		"eco0001" -> "/api/yige/verify";
 		"eco0002" -> "/api/yigequick/verify";
		_ -> "/api/yigequick/verify"
	end,
	sdk_common:verify(Path, GameChan, Account, Token, SDKArgs, IP).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
