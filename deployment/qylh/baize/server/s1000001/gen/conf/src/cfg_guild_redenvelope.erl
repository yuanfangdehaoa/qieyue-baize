% Automatically generated, do not edit
-module(cfg_guild_redenvelope).

-compile([export_all]).
-compile(nowarn_export_all).

-include("guild_redenvelope.hrl").

find(1) -> #cfg_guild_redenvelope{
	id       = 1,
	type_id  = 1,
	belong   = 1,
	target   = {16,first_pay},
	is_count = 1,
	limit    = {},
	cost     = 0,
	item_id  = 90010004,
	money    = 2500,
	num      = {500,750},
	range    = {-100,150},
	msgno    = 0
};
find(2) -> #cfg_guild_redenvelope{
	id       = 2,
	type_id  = 1,
	belong   = 1,
	target   = {16,680},
	is_count = 1,
	limit    = {},
	cost     = 0,
	item_id  = 90010004,
	money    = 5000,
	num      = {500,1000},
	range    = {-150,200},
	msgno    = 140401
};
find(3) -> #cfg_guild_redenvelope{
	id       = 3,
	type_id  = 1,
	belong   = 1,
	target   = {41,[1,2,3]},
	is_count = 0,
	limit    = {},
	cost     = 0,
	item_id  = 90010004,
	money    = 5000,
	num      = {500,1000},
	range    = {-150,200},
	msgno    = 140401
};
find(5) -> #cfg_guild_redenvelope{
	id       = 5,
	type_id  = 1,
	belong   = 1,
	target   = {34,4},
	is_count = 0,
	limit    = {},
	cost     = 0,
	item_id  = 90010004,
	money    = 5000,
	num      = {500,1000},
	range    = {-150,200},
	msgno    = 140401
};
find(6) -> #cfg_guild_redenvelope{
	id       = 6,
	type_id  = 1,
	belong   = 1,
	target   = {34,5},
	is_count = 0,
	limit    = {},
	cost     = 0,
	item_id  = 90010004,
	money    = 10000,
	num      = {500,1250},
	range    = {-300,400},
	msgno    = 140401
};
find(7) -> #cfg_guild_redenvelope{
	id       = 7,
	type_id  = 2,
	belong   = 1,
	target   = {},
	is_count = 0,
	limit    = {vip,5},
	cost     = 90010003,
	item_id  = 90010003,
	money    = 0,
	num      = {50,49950},
	range    = 0,
	msgno    = 0
};
find(_) -> undefined.

ids() -> [1,2,3,5,6,7].
