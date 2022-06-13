%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(yunying_hook).

%% API
-export([hook_start/1]).
-export([hook_stop/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_start(YYActID) ->
    case cluster:is_cross() of
        true ->
            yunying_shop_manager:hook_start(YYActID);
        false ->
            ignore
    end,
	ok.

hook_stop(YYActID) ->
    case cluster:is_cross() of
        true ->
            yunying_shop_manager:hook_stop(YYActID);
        false ->
            ignore
    end,
	ok.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
