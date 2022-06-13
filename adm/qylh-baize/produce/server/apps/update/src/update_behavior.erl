%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(update_behavior).

-include("game.hrl").

-callback vsn() -> string().
-callback run() -> ok | any().

%% API
-export([transform/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
transform(Tab, Fun, NewA) ->
	case cluster:is_center() of
		true  ->
			case lists:keymember(Tab, #r_tab.name, table:cross_tabs() ++ table:game_tabs()) of
				true  ->
					do_transform(Tab, Fun, NewA);
				false ->
					ignore
			end;
		false ->
			do_transform(Tab, Fun, NewA)
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_transform(Tab, Fun, NewA) ->
	mnesia:transform_table(Tab, Fun, NewA).