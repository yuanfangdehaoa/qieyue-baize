% Automatically generated, do not edit
-module(cfg_equip_refine_other).

-compile([export_all]).
-compile(nowarn_export_all).

-include("equip.hrl").

find(1) -> #cfg_equip_refine_other{
	id         =  1,
	unlock     =  [{1, [{90010004,0}]},{2, [{90010004,100}]},{3, [{90010004,100}]},{4, [{90010004,100}]},{5, {vip,15}}],
	lock       =  [{1,[{13118,1}]},{2,[{13118,2}]},{3,[{13118,4}]},{4,[{13118,8}]}],
	freecount  =  3,
	cost       =  [{13114,20}]
};
find(_) -> undefined.


