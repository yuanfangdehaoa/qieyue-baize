-module(update_mnesia_2_2).

-behaviour(update_behavior).
-compile([export_all]).
-compile(nowarn_export_all).

-include("table.hrl").
-include("game.hrl").

vsn() ->
    "2.2".

run() ->
    ok = update_role_pet(),
    ok = update_role_bag(),
    ok.

once() ->
    ok.

update_role_pet()->
    Func = fun
        ({role_pet, ID, PETS, STRONG, STRONG_ATTR, FIGHT, COSTS}) ->
            {role_pet, ID, PETS, STRONG, STRONG_ATTR, FIGHT, COSTS, #{}};
        (R) ->
            R
    end,
    update_behavior:transform(role_pet, Func, record_info(fields, role_pet)),
    ok.

update_role_bag() ->
    update_common:update_bag([110, 310]),
    ok.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
