-ifndef(THRONE_HRL).
-define(THRONE_HRL, ok).

-define(ETS_THRONE_BOSS, ets_throne_boss).
-record(throneboss, {
	  id
	, born = 0
	, tomb = 0
}).

-define(ETS_THRONE_SCORE, ets_throne_score).
% {SUID, Score}

-record(cfg_throne_boss, {
	  id
	, name
	, scene
	, coord
	, score
	, attr
	, reborn
}).

-endif.