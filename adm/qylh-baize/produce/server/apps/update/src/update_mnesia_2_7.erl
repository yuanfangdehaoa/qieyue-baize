-module(update_mnesia_2_7).

-behaviour(update_behavior).
-compile([export_all]).
-compile(nowarn_export_all).

-include("game.hrl").

vsn() ->
    "2.7".

run() ->
    ok.

once() ->
    ok = update_bag(),
    ok = update_role_welfare(),
    ok = update_role_mchunt(),
    ok = update_role_searchtreasure(),
    ok.

update_bag()->
    update_common:update_bag([401]),
    ok.

update_role_welfare() ->
    update_common:update_role_welfare(),
    ok.

update_role_mchunt() ->
    update_common:update_role_mchunt(),
    ok.

update_role_searchtreasure() ->
    update_common:update_role_searchtreasure(),
    ok.



%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
