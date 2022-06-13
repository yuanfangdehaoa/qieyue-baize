% Automatically generated, do not edit
-module(cfg_daily_reward).

-compile([export_all]).
-compile(nowarn_export_all).

-include("daily.hrl").

find(1) -> #cfg_daily_reward{activation = 30, reward = [{11140,1,1}]};
find(2) -> #cfg_daily_reward{activation = 60, reward = [{11005,1,1}]};
find(3) -> #cfg_daily_reward{activation = 90, reward = [{50000,5,1}]};
find(4) -> #cfg_daily_reward{activation = 120, reward = [{11005,1,1}]};
find(5) -> #cfg_daily_reward{activation = 150, reward = [{13100,1,1}]};
find(_) -> undefined.
