-ifndef(ILLUSTRATION_HRL).
-define(ILLUSTRATION_HRL, ok).

-record(cfg_illustration, {name, max_star, color}).
-record(cfg_illustration_combination, {illustrations, attr}).
-record(cfg_illustration_star, {item, essence, attr, notify}).

-endif.