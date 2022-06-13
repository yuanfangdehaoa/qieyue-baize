-ifndef(DAILY_HRL).
-define(DAILY_HRL, ok).

-record(cfg_daily_reward, {activation, reward}).
-record(cfg_daily, {act_type, reset, activation, count, target, reqs}).
-record(cfg_daily_show, {group, activation, attr}).

-endif.