% Automatically generated, do not edit
-module(cfg_welfare_res_reward).

-compile([export_all]).
-compile(nowarn_export_all).

-include("welfare.hrl").

find(1) -> #cfg_welfare_res_reward{
	id     = 1,
	reward = [{50000,5,1},{90010004,2500,1},{90010005,200000,1}]
};
find(_) -> undefined.
