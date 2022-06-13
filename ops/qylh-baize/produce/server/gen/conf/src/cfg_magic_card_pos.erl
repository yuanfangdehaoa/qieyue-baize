% Automatically generated, do not edit
-module(cfg_magic_card_pos).

-compile([export_all]).
-compile(nowarn_export_all).

-include("magic_card.hrl").

find(1) -> #cfg_magic_card_pos{
	pos  = 1,
	gate = 0
};
find(2) -> #cfg_magic_card_pos{
	pos  = 2,
	gate = 0
};
find(3) -> #cfg_magic_card_pos{
	pos  = 3,
	gate = 0
};
find(4) -> #cfg_magic_card_pos{
	pos  = 4,
	gate = 4
};
find(5) -> #cfg_magic_card_pos{
	pos  = 5,
	gate = 8
};
find(6) -> #cfg_magic_card_pos{
	pos  = 6,
	gate = 16
};
find(7) -> #cfg_magic_card_pos{
	pos  = 7,
	gate = 32
};
find(8) -> #cfg_magic_card_pos{
	pos  = 8,
	gate = 42
};
find(_) -> undefined.
