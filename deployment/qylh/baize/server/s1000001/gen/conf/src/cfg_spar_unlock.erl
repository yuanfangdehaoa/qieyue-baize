% Automatically generated, do not edit
-module(cfg_spar_unlock).

-compile([export_all]).
-compile(nowarn_export_all).

-include("equip.hrl").

find(101) -> #cfg_spar_unlock{
	id             = 101,
	open_condition = {order,1}
};
find(102) -> #cfg_spar_unlock{
	id             = 102,
	open_condition = {order,4}
};
find(103) -> #cfg_spar_unlock{
	id             = 103,
	open_condition = {order,7}
};
find(104) -> #cfg_spar_unlock{
	id             = 104,
	open_condition = {order,9}
};
find(105) -> #cfg_spar_unlock{
	id             = 105,
	open_condition = {order,10}
};
find(106) -> #cfg_spar_unlock{
	id             = 106,
	open_condition = {order,11}
};
find(_) -> undefined.
