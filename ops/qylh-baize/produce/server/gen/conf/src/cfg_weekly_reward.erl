% Automatically generated, do not edit
-module(cfg_weekly_reward).

-compile([export_all]).
-compile(nowarn_export_all).

-include("weekly.hrl").

find(1) -> #cfg_weekly_reward{activation = 60, reward = [{11140,1}]};
find(2) -> #cfg_weekly_reward{activation = 90, reward = [{11005,1}]};
find(3) -> #cfg_weekly_reward{activation = 120, reward = [{10005,5}]};
find(4) -> #cfg_weekly_reward{activation = 150, reward = [{11005,1}]};
find(5) -> #cfg_weekly_reward{activation = 300, reward = [{13100,1}]};
find(_) -> undefined.
