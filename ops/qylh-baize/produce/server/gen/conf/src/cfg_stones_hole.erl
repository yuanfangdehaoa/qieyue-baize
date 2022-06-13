% Automatically generated, do not edit
-module(cfg_stones_hole).

-compile([export_all]).
-compile(nowarn_export_all).

-include("equip.hrl").

find(1) -> #cfg_stones_hole{
	id             = 1,
	open_condition = {vip,15}
};
find(2) -> #cfg_stones_hole{
	id             = 2,
	open_condition = {order,2}
};
find(3) -> #cfg_stones_hole{
	id             = 3,
	open_condition = {order,4}
};
find(4) -> #cfg_stones_hole{
	id             = 4,
	open_condition = {order,6}
};
find(5) -> #cfg_stones_hole{
	id             = 5,
	open_condition = {order,8}
};
find(6) -> #cfg_stones_hole{
	id             = 6,
	open_condition = {order,10}
};
find(_) -> undefined.
