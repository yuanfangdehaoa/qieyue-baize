% Automatically generated, do not edit
-module(cfg_escort_road).

-compile([export_all]).
-compile(nowarn_export_all).

-include("escort.hrl").

find(1) -> #cfg_escort_road{
	id      = 1,
	start   = 1311,
	second  = 1501,
	end_npc = 1503
};
find(_) -> undefined.
