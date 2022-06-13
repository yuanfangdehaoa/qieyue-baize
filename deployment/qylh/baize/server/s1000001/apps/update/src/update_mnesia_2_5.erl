-module(update_mnesia_2_5).

-behaviour(update_behavior).
-compile([export_all]).
-compile(nowarn_export_all).

-include("game.hrl").

vsn() ->
    "2.5".

run() ->
    ok = update_item(),
    ok.

once() ->
    ok.

update_item()->
    Func = fun
        (R = {p_item, UID, ID, NUM, BAG, BIND, ETIME, GENDER, SCORE, EQUIP, PET, EXTRA}) ->
            case EQUIP == ?nil of
                true  ->
                    R;
                false ->
                    EQUIP2 = case EQUIP of
                        {p_equip, BASE, RARE1, RARE2, RARE3, MARRIAGE, STREN_PHASE, STREN_LV, STONES, POWER, CAST, REFINE, SUITE} ->
                            {p_equip, BASE, RARE1, RARE2, RARE3, MARRIAGE, STREN_PHASE, STREN_LV, STONES, POWER, CAST, REFINE, SUITE, ?nil};
                        EQUIP1 ->
                            EQUIP1
                    end,
                    {p_item, UID, ID, NUM, BAG, BIND, ETIME, GENDER, SCORE, EQUIP2, PET, EXTRA}
            end;
        (R) ->
            R
    end,
    update_common:update_item(Func),
    ok.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
