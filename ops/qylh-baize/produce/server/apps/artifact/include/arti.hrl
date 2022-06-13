-ifndef(ARTI_HRL).
-define(ARTI_HRL, ok).

-record(cfg_artifact_element, {
	  id
	, name
	, type
	, level
	, cost
	, attrs
}).

-record(cfg_artifact_reinf, {
	  id
	, level
	, exp
	, attrs
	, enchant
}).

-record(cfg_artifact_enchant, {
	  id
	, code
	, base
	, max
	, add
	, cost
}).

-endif.
