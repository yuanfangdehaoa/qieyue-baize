% Automatically generated, do not edit
-module(cfg_power_suppress).

-compile([export_all]).
-compile(nowarn_export_all).

role_2_creep(6, DiffPower) when DiffPower >= 999, DiffPower =< 0 -> 10000;
role_2_creep(6, DiffPower) when DiffPower >= 0, DiffPower =< 0 -> 7000;
role_2_creep(6, DiffPower) when DiffPower >= 0, DiffPower =< 0 -> 5000;
role_2_creep(6, DiffPower) when DiffPower >= 0, DiffPower =< 0 -> 4000;
role_2_creep(6, DiffPower) when DiffPower >= 0, DiffPower =< 0 -> 3000;
role_2_creep(6, DiffPower) when DiffPower >= 0, DiffPower =< -999 -> 2000;
role_2_creep(_, _) -> 10000.

creep_2_role(6, DiffPower) when DiffPower >= 999, DiffPower =< 0 -> 10000;
creep_2_role(6, DiffPower) when DiffPower >= 0, DiffPower =< 0 -> 10000;
creep_2_role(6, DiffPower) when DiffPower >= 0, DiffPower =< 0 -> 10000;
creep_2_role(6, DiffPower) when DiffPower >= 0, DiffPower =< 0 -> 10000;
creep_2_role(6, DiffPower) when DiffPower >= 0, DiffPower =< 0 -> 10000;
creep_2_role(6, DiffPower) when DiffPower >= 0, DiffPower =< -999 -> 10000;
creep_2_role(_, _) -> 10000.
