% Automatically generated, do not edit
-module(cfg_level_suppress).

-compile([export_all]).
-compile(nowarn_export_all).

role_2_creep(3, DiffLv) when DiffLv >= 0, DiffLv =< 20 -> 10000;
role_2_creep(3, DiffLv) when DiffLv >= 21, DiffLv =< 50 -> 8000;
role_2_creep(3, DiffLv) when DiffLv >= 51, DiffLv =< 70 -> 7000;
role_2_creep(3, DiffLv) when DiffLv >= 71, DiffLv =< 100 -> 6000;
role_2_creep(3, DiffLv) when DiffLv >= 101, DiffLv =< 150 -> 4000;
role_2_creep(3, DiffLv) when DiffLv >= 151, DiffLv =< 200 -> 3000;
role_2_creep(3, DiffLv) when DiffLv >= 201, DiffLv =< 9999 -> 2000;
role_2_creep(_, _) -> 10000.

creep_2_role(3, DiffLv) when DiffLv >= 0, DiffLv =< 20 -> 10000;
creep_2_role(3, DiffLv) when DiffLv >= 21, DiffLv =< 50 -> 10500;
creep_2_role(3, DiffLv) when DiffLv >= 51, DiffLv =< 70 -> 11000;
creep_2_role(3, DiffLv) when DiffLv >= 71, DiffLv =< 100 -> 12000;
creep_2_role(3, DiffLv) when DiffLv >= 101, DiffLv =< 150 -> 15000;
creep_2_role(3, DiffLv) when DiffLv >= 151, DiffLv =< 200 -> 20000;
creep_2_role(3, DiffLv) when DiffLv >= 201, DiffLv =< 9999 -> 30000;
creep_2_role(_, _) -> 10000.
