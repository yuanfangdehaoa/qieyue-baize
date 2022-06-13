% Automatically generated, do not edit
-module(cfg_magic_card_suite).

-compile([export_all]).
-compile(nowarn_export_all).

-include("magic_card.hrl").

find(1) -> #cfg_magic_card_suite{
	id          = 1,
	com_sum     = 3,
	com_color   = 1,
	is_compose  = 0,
	skill_id    = "{400901,1}",
	desc        = "装备3张魔法卡"
};
find(2) -> #cfg_magic_card_suite{
	id          = 2,
	com_sum     = 7,
	com_color   = 1,
	is_compose  = 0,
	skill_id    = "{400902,1}",
	desc        = "装备7张魔法卡"
};
find(3) -> #cfg_magic_card_suite{
	id          = 3,
	com_sum     = 1,
	com_color   = 5,
	is_compose  = 1,
	skill_id    = "{400903,1}",
	desc        = "装备1张橙色融合魔法卡"
};
find(4) -> #cfg_magic_card_suite{
	id          = 4,
	com_sum     = 1,
	com_color   = 6,
	is_compose  = 1,
	skill_id    = "{400904,1}",
	desc        = "装备1张红色融合魔法卡"
};
find(_) -> undefined.

find_id() -> [3,4,1,2].
