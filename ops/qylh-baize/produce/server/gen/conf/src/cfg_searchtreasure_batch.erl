% Automatically generated, do not edit
-module(cfg_searchtreasure_batch).

-compile([export_all]).
-compile(nowarn_export_all).

-include("search_treasure.hrl").

find(1) -> #cfg_searchtreasure_batch{
	id                = 1,
	type_id           = 1,
	first_bless_value = [{1,50},{2,35},{3,15}],
	bless_value       = [{1,70},{2,20},{3,10}],
	max_bless_value   = 560,
	open_server_days  = {1,9999},
	player_level      = {1,219},
	cost              = [{1,11006,1},{10,11006,10},{50,11006,45}],
	gain              = [{90010021,1}]
};
find(2) -> #cfg_searchtreasure_batch{
	id                = 2,
	type_id           = 1,
	first_bless_value = [{1,50},{2,35},{3,15}],
	bless_value       = [{1,70},{2,20},{3,10}],
	max_bless_value   = 560,
	open_server_days  = {1,9999},
	player_level      = {220,289},
	cost              = [{1,11006,1},{10,11006,10},{50,11006,45}],
	gain              = [{90010021,1}]
};
find(3) -> #cfg_searchtreasure_batch{
	id                = 3,
	type_id           = 1,
	first_bless_value = [{1,50},{2,35},{3,15}],
	bless_value       = [{1,70},{2,20},{3,10}],
	max_bless_value   = 560,
	open_server_days  = {1,9999},
	player_level      = {290,319},
	cost              = [{1,11006,1},{10,11006,10},{50,11006,45}],
	gain              = [{90010021,1}]
};
find(4) -> #cfg_searchtreasure_batch{
	id                = 4,
	type_id           = 1,
	first_bless_value = [{1,50},{2,35},{3,15}],
	bless_value       = [{1,70},{2,20},{3,10}],
	max_bless_value   = 560,
	open_server_days  = {1,9999},
	player_level      = {320,379},
	cost              = [{1,11006,1},{10,11006,10},{50,11006,45}],
	gain              = [{90010021,1}]
};
find(5) -> #cfg_searchtreasure_batch{
	id                = 5,
	type_id           = 1,
	first_bless_value = [{1,50},{2,35},{3,15}],
	bless_value       = [{1,70},{2,20},{3,10}],
	max_bless_value   = 560,
	open_server_days  = {1,9999},
	player_level      = {380,999999},
	cost              = [{1,11006,1},{10,11006,10},{50,11006,45}],
	gain              = [{90010021,1}]
};
find(21) -> #cfg_searchtreasure_batch{
	id                = 21,
	type_id           = 2,
	first_bless_value = [{1,50},{2,35},{3,15}],
	bless_value       = [{1,70},{2,20},{3,10}],
	max_bless_value   = 560,
	open_server_days  = {1,9999},
	player_level      = {1,410},
	cost              = [{1,11046,1},{10,11046,10},{50,11046,45}],
	gain              = [{90010021,2}]
};
find(22) -> #cfg_searchtreasure_batch{
	id                = 22,
	type_id           = 2,
	first_bless_value = [{1,50},{2,35},{3,15}],
	bless_value       = [{1,70},{2,20},{3,10}],
	max_bless_value   = 560,
	open_server_days  = {1,9999},
	player_level      = {411,999999},
	cost              = [{1,11046,1},{10,11046,10},{50,11046,45}],
	gain              = [{90010021,2}]
};
find(31) -> #cfg_searchtreasure_batch{
	id                = 31,
	type_id           = 3,
	first_bless_value = [{1,50},{2,35},{3,15}],
	bless_value       = [{1,70},{2,20},{3,10}],
	max_bless_value   = 560,
	open_server_days  = {1,9999},
	player_level      = {1,999999},
	cost              = [{1,11012,1},{10,11012,10},{50,11012,45}],
	gain              = [{90010021,2}]
};
find(41) -> #cfg_searchtreasure_batch{
	id                = 41,
	type_id           = 4,
	first_bless_value = [{1,50},{2,35},{3,15}],
	bless_value       = [{1,70},{2,20},{3,10}],
	max_bless_value   = 560,
	open_server_days  = {1,9999},
	player_level      = {1,999999},
	cost              = [{1,11013,1},{10,11013,10},{50,11013,45}],
	gain              = [{90010021,2}]
};
find(_) -> undefined.

find_type(1) -> [2,3,4,5,1];
find_type(2) -> [21,22];
find_type(3) -> [31];
find_type(4) -> [41];
find_type(_) -> [].
