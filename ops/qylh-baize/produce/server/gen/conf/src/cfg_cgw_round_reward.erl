% Automatically generated, do not edit
-module(cfg_cgw_round_reward).

-compile([export_all]).
-compile(nowarn_export_all).

find(Level) when Level >= 1, Level =< 99999 -> {[{90010018,50000,1},{90010011,5000,1},{13170,10,1}], [{90010018,30000,1},{90010011,3000,1},{13170,5,1}]};
find(_) -> undefined.
