% Automatically generated, do not edit
-module(cfg_scene_change).

-compile([export_all]).
-compile(nowarn_export_all).

find(1) -> {
	[1,2],
	[0,1,2],
	[]
};
find(2) -> {
	[1,2],
	[0,1,2],
	[]
};
find(3) -> {
	[1,2,3],
	[5],
	[2]
};
find(4) -> {
	[1,2,4],
	[3],
	[2]
};
find(5) -> {
	[1,2],
	[4],
	[2]
};
find(_) -> undefined.
