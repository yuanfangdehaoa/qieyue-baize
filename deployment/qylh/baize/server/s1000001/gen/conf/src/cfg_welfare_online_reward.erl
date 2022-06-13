% Automatically generated, do not edit
-module(cfg_welfare_online_reward).

-compile([export_all]).
-compile(nowarn_export_all).

-include("welfare.hrl").

find(1) -> #cfg_welfare_online_reward{
	id     = 1,
	reward = [{90010004,1000,1},{10000,1,1},{90010005,20000,1},{90010005,20000,1}],
	time   = 600
};
find(2) -> #cfg_welfare_online_reward{
	id     = 2,
	reward = [{11128,1,1},{10000,1,1},{90010005,30000,1},{90010005,30000,1}],
	time   = 1800
};
find(3) -> #cfg_welfare_online_reward{
	id     = 3,
	reward = [{15020,1,1},{10000,2,1},{90010005,50000,1},{90010005,50000,1}],
	time   = 3600
};
find(_) -> undefined.
