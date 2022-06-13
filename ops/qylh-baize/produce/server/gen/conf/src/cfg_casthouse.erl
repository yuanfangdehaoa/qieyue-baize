% Automatically generated, do not edit
-module(cfg_casthouse).

-compile([export_all]).
-compile(nowarn_export_all).

-include("casthouse.hrl").

find(1) -> #cfg_casthouse{
	id              = 1,
	free_count      = 3,
	cost            = [{11007,2}],
	reset_cost      = [{90010003,2500}],
	pp              = [{1,[{1,100},{2,200},{3,200},{4,1500},{5,4000},{6,4000}]},{2,[{1,100},{2,200},{3,2000},{4,3700},{5,2500},{6,1500}]}]
};
find(_) -> undefined.


