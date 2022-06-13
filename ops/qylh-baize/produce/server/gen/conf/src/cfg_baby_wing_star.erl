% Automatically generated, do not edit
-module(cfg_baby_wing_star).

-compile([export_all]).
-compile(nowarn_export_all).

-include("baby.hrl").

find(61001, 0) -> #cfg_baby_wing_star{
	id    = 61001,
	star  = 0,
	cost  = [{51401,1}],
	attrs = [{2,7700},{4,385},{6,241},{5,241},{1102,50}]
};
find(61001, 1) -> #cfg_baby_wing_star{
	id    = 61001,
	star  = 1,
	cost  = [{51401,2}],
	attrs = [{2,15400},{4,770},{6,482},{5,482},{1102,100}]
};
find(61001, 2) -> #cfg_baby_wing_star{
	id    = 61001,
	star  = 2,
	cost  = [{51401,3}],
	attrs = [{2,23100},{4,1155},{6,723},{5,723},{1102,150}]
};
find(61001, 3) -> #cfg_baby_wing_star{
	id    = 61001,
	star  = 3,
	cost  = [{51401,4}],
	attrs = [{2,30800},{4,1540},{6,964},{5,964},{1102,200}]
};
find(61001, 4) -> #cfg_baby_wing_star{
	id    = 61001,
	star  = 4,
	cost  = [{51401,5}],
	attrs = [{2,38500},{4,1925},{6,1205},{5,1205},{1102,250}]
};
find(61001, 5) -> #cfg_baby_wing_star{
	id    = 61001,
	star  = 5,
	cost  = [],
	attrs = [{2,46200},{4,2310},{6,1446},{5,1446},{1102,300}]
};
find(61002, 0) -> #cfg_baby_wing_star{
	id    = 61002,
	star  = 0,
	cost  = [{51402,1}],
	attrs = [{2,38580},{4,1929},{6,1206},{5,1206}]
};
find(61002, 1) -> #cfg_baby_wing_star{
	id    = 61002,
	star  = 1,
	cost  = [{51402,2}],
	attrs = [{2,77160},{4,3858},{6,2412},{5,2412}]
};
find(61002, 2) -> #cfg_baby_wing_star{
	id    = 61002,
	star  = 2,
	cost  = [{51402,3}],
	attrs = [{2,115740},{4,5787},{6,3618},{5,3618}]
};
find(61002, 3) -> #cfg_baby_wing_star{
	id    = 61002,
	star  = 3,
	cost  = [{51402,4}],
	attrs = [{2,154320},{4,7716},{6,4824},{5,4824}]
};
find(61002, 4) -> #cfg_baby_wing_star{
	id    = 61002,
	star  = 4,
	cost  = [{51402,5}],
	attrs = [{2,192900},{4,9645},{6,6030},{5,6030}]
};
find(61002, 5) -> #cfg_baby_wing_star{
	id    = 61002,
	star  = 5,
	cost  = [],
	attrs = [{2,231480},{4,11574},{6,7236},{5,7236}]
};
find(61003, 0) -> #cfg_baby_wing_star{
	id    = 61003,
	star  = 0,
	cost  = [{51403,1}],
	attrs = [{2,7700},{4,385},{6,241},{5,241},{1102,50}]
};
find(61003, 1) -> #cfg_baby_wing_star{
	id    = 61003,
	star  = 1,
	cost  = [{51403,2}],
	attrs = [{2,15400},{4,770},{6,482},{5,482},{1102,100}]
};
find(61003, 2) -> #cfg_baby_wing_star{
	id    = 61003,
	star  = 2,
	cost  = [{51403,3}],
	attrs = [{2,23100},{4,1155},{6,723},{5,723},{1102,150}]
};
find(61003, 3) -> #cfg_baby_wing_star{
	id    = 61003,
	star  = 3,
	cost  = [{51403,4}],
	attrs = [{2,30800},{4,1540},{6,964},{5,964},{1102,200}]
};
find(61003, 4) -> #cfg_baby_wing_star{
	id    = 61003,
	star  = 4,
	cost  = [{51403,5}],
	attrs = [{2,38500},{4,1925},{6,1205},{5,1205},{1102,250}]
};
find(61003, 5) -> #cfg_baby_wing_star{
	id    = 61003,
	star  = 5,
	cost  = [],
	attrs = [{2,46200},{4,2310},{6,1446},{5,1446},{1102,300}]
};
find(_, _) -> undefined.

max(61001) -> 5;
max(61002) -> 5;
max(61003) -> 5;
max(_) -> 0.
