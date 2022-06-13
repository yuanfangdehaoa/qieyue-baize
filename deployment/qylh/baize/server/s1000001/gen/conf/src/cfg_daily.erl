% Automatically generated, do not edit
-module(cfg_daily).

-compile([export_all]).
-compile(nowarn_export_all).

-include("daily.hrl").

find(1) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 1,
	count      = 20,
	target     = [{7,3}],
	reqs       = [{level,65}]
};
find(2) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 3,
	count      = 5,
	target     = [{13,0}],
	reqs       = [{level,60}]
};
find(3) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 2,
	count      = 5,
	target     = [{8,0}],
	reqs       = [{level,70}]
};
find(4) -> #cfg_daily{
	act_type   = 1,
	reset      = weekly,
	activation = 0,
	count      = 40,
	target     = [{7,4}],
	reqs       = [{level,150}]
};
find(5) -> #cfg_daily{
	act_type   = 1,
	reset      = never,
	activation = 0,
	count      = 0,
	target     = [{9,303}],
	reqs       = [{level,70}]
};
find(6) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 8,
	count      = 2,
	target     = [{10,301}],
	reqs       = [{level,105}]
};
find(7) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 10,
	count      = 3,
	target     = [{3,1}],
	reqs       = [{level,90}]
};
find(8) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 10,
	count      = 2,
	target     = [{4,307}],
	reqs       = [{level,165}]
};
find(9) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 0,
	count      = 0,
	target     = [],
	reqs       = [{level,65}]
};
find(10) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 5,
	count      = 3,
	target     = [{14,0}],
	reqs       = [{level,130}]
};
find(11) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 5,
	count      = 2,
	target     = [{10,302}],
	reqs       = [{level,220}]
};
find(12) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 10,
	count      = 3,
	target     = [{10,304}],
	reqs       = [{level,100}]
};
find(13) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 20,
	count      = 1,
	target     = [{10,308}],
	reqs       = [{level,200}]
};
find(14) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 10,
	count      = 2,
	target     = [{10,310}],
	reqs       = [{level,240}]
};
find(15) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 10,
	count      = 1,
	target     = [{10,313}],
	reqs       = [{level,213}]
};
find(16) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 2,
	count      = 10,
	target     = [{10,309}],
	reqs       = [{level,110}]
};
find(17) -> #cfg_daily{
	act_type   = 1,
	reset      = daily,
	activation = 5,
	count      = 1,
	target     = [{3,[5,6]}],
	reqs       = [{level,371}]
};
find(1000) -> #cfg_daily{
	act_type   = 2,
	reset      = daily,
	activation = 0,
	count      = 3,
	target     = [{14,0}],
	reqs       = [{level,130}]
};
find(1002) -> #cfg_daily{
	act_type   = 2,
	reset      = weekly,
	activation = 5,
	count      = 1,
	target     = [{10,502}],
	reqs       = [{level,115}]
};
find(1004) -> #cfg_daily{
	act_type   = 2,
	reset      = daily,
	activation = 5,
	count      = 1,
	target     = [{10,503}],
	reqs       = [{level,130}]
};
find(1006) -> #cfg_daily{
	act_type   = 2,
	reset      = weekly,
	activation = 5,
	count      = 2,
	target     = [{10,501}],
	reqs       = [{level,140}]
};
find(1007) -> #cfg_daily{
	act_type   = 2,
	reset      = weekly,
	activation = 5,
	count      = 1,
	target     = [{10,504}],
	reqs       = [{level,130}]
};
find(1008) -> #cfg_daily{
	act_type   = 2,
	reset      = weekly,
	activation = 5,
	count      = 20,
	target     = [{10,506}],
	reqs       = [{level,140}]
};
find(1009) -> #cfg_daily{
	act_type   = 2,
	reset      = weekly,
	activation = 5,
	count      = 1,
	target     = [{10,507}],
	reqs       = [{level,130}]
};
find(1010) -> #cfg_daily{
	act_type   = 2,
	reset      = weekly,
	activation = 10,
	count      = 1,
	target     = [{10,311}],
	reqs       = [{level,130}]
};
find(1011) -> #cfg_daily{
	act_type   = 2,
	reset      = daily,
	activation = 10,
	count      = 5,
	target     = [{10,319}],
	reqs       = [{level,75}]
};
find(1012) -> #cfg_daily{
	act_type   = 2,
	reset      = weekly,
	activation = 10,
	count      = 1,
	target     = [{10,508}],
	reqs       = [{level,115}]
};
find(_) -> undefined.

list() -> [7,1,3,16,17,1012,13,1004,2,5,8,9,15,4,1006,1009,6,10,14,1000,1002,1007,11,12,1008,1010,1011].
