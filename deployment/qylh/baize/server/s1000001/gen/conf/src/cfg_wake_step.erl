% Automatically generated, do not edit
-module(cfg_wake_step).

-compile([export_all]).
-compile(nowarn_export_all).

-include("wake.hrl").

find(1, 1) -> #cfg_wake_step{
wake_times = 1,
step       = 1,
tasks      = [60101,60102,60103,60104],
grid  	   = {0,0}
};
find(1, 2) -> #cfg_wake_step{
wake_times = 1,
step       = 2,
tasks      = [60105,60106,60107,60108],
grid  	   = {0,0}
};
find(2, 1) -> #cfg_wake_step{
wake_times = 2,
step       = 1,
tasks      = [60201,60202,60203,60204],
grid  	   = {0,0}
};
find(2, 2) -> #cfg_wake_step{
wake_times = 2,
step       = 2,
tasks      = [60205,60206,60207,60208],
grid  	   = {0,0}
};
find(3, 1) -> #cfg_wake_step{
wake_times = 3,
step       = 1,
tasks      = [60301,60302,60303,60304],
grid  	   = {0,0}
};
find(3, 2) -> #cfg_wake_step{
wake_times = 3,
step       = 2,
tasks      = [60305,60306,60307,60308],
grid  	   = {0,0}
};
find(4, 1) -> #cfg_wake_step{
wake_times = 4,
step       = 1,
tasks      = [],
grid  	   = {0,12}
};
find(5, 1) -> #cfg_wake_step{
wake_times = 5,
step       = 1,
tasks      = [],
grid  	   = {12,27}
};
find(5, 2) -> #cfg_wake_step{
wake_times = 5,
step       = 2,
tasks      = [],
grid  	   = {27,47}
};
find(6, 1) -> #cfg_wake_step{
wake_times = 6,
step       = 1,
tasks      = [],
grid  	   = {47,72}
};
find(6, 2) -> #cfg_wake_step{
wake_times = 6,
step       = 2,
tasks      = [],
grid  	   = {72,102}
};
find(6, 3) -> #cfg_wake_step{
wake_times = 6,
step       = 3,
tasks      = [],
grid  	   = {102,137}
};
find(_, _) -> undefined.

get_step(1, Grid) when Grid > 0, Grid < 0->
1;
get_step(1, Grid) when Grid > 0, Grid < 0->
2;
get_step(2, Grid) when Grid > 0, Grid < 0->
1;
get_step(2, Grid) when Grid > 0, Grid < 0->
2;
get_step(3, Grid) when Grid > 0, Grid < 0->
1;
get_step(3, Grid) when Grid > 0, Grid < 0->
2;
get_step(4, Grid) when Grid > 0, Grid < 12->
1;
get_step(5, Grid) when Grid > 12, Grid < 27->
1;
get_step(5, Grid) when Grid > 27, Grid < 47->
2;
get_step(6, Grid) when Grid > 47, Grid < 72->
1;
get_step(6, Grid) when Grid > 72, Grid < 102->
2;
get_step(6, Grid) when Grid > 102, Grid < 137->
3;
get_step(_, _) -> undefined.


find_step(0) -> 2;
find_step(12) -> 1;
find_step(27) -> 1;
find_step(47) -> 2;
find_step(72) -> 1;
find_step(102) -> 2;
find_step(137) -> 3;
find_step(_) -> undefined.
