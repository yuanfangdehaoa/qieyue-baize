% Automatically generated, do not edit
-module(cfg_baby_wing_morph).

-compile([export_all]).
-compile(nowarn_export_all).

-include("baby.hrl").

find(61001) -> #cfg_baby_wing_morph{
	id    = 61001,
	name  = "莺莺环羽",
	reqs  = [{gender,1}],
	cost  = [{51401,1}]
};
find(61002) -> #cfg_baby_wing_morph{
	id    = 61002,
	name  = "云裳朵朵",
	reqs  = [{gender,1}],
	cost  = [{51402,1}]
};
find(61003) -> #cfg_baby_wing_morph{
	id    = 61003,
	name  = "风翎蝶展",
	reqs  = [{gender,1}],
	cost  = [{51403,1}]
};
find(_) -> undefined.

list() -> [61002,61003,61001].

res(61001) -> 60001;
res(61002) -> 60002;
res(61003) -> 60003;
res(_) -> 0.
