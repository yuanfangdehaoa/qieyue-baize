% Automatically generated, do not edit
-module(cfg_god_equip_open).

-compile([export_all]).
-compile(nowarn_export_all).

-include("god_equips.hrl").

find(5001) -> #cfg_god_equip_open{
	slot     = 5001,
	open     = {own,5,1}
};
find(5002) -> #cfg_god_equip_open{
	slot     = 5002,
	open     = undefined
};
find(5003) -> #cfg_god_equip_open{
	slot     = 5003,
	open     = {own,5,2}
};
find(5004) -> #cfg_god_equip_open{
	slot     = 5004,
	open     = undefined
};
find(5005) -> #cfg_god_equip_open{
	slot     = 5005,
	open     = {dunge,11}
};
find(5006) -> #cfg_god_equip_open{
	slot     = 5006,
	open     = {own,6,1}
};
find(5007) -> #cfg_god_equip_open{
	slot     = 5007,
	open     = {dunge,16}
};
find(5008) -> #cfg_god_equip_open{
	slot     = 5008,
	open     = {dunge,26}
};
find(5009) -> #cfg_god_equip_open{
	slot     = 5009,
	open     = {own,6,2}
};
find(5010) -> #cfg_god_equip_open{
	slot     = 5010,
	open     = {dunge,36}
};
find(_) -> undefined.

slots() -> [5001,5002,5003,5006,5007,5009,5004,5005,5008,5010].

