%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(sdk_youjing).

-include("game.hrl").
-include("errno.hrl").

%% API
-export([verify/5]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
verify(GameChan, Account, Token, SDKArgs, IP) ->
	Path = "/api/youjing/verify",
	sdk_common:verify(Path, GameChan, Account, Token, SDKArgs, IP).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
