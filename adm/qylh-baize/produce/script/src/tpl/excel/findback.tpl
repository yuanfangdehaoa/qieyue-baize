-include("findback.hrl").

{{ row . `find("'id'@'sub_id'") -> #cfg_findback{
	key             = "'id'@'sub_id'",
	module          = 'module',
	cost            = 'cost',
	exp_type        = 'exp_type',
	params          = 'params',
	drops           = 'drops',
	dropsgold       = 'dropsgold',
	event           = 'event',
	role_count      = 'role_count',
	max_count       = 'max_count',
	vip_role_count  = 'vip_role_count',
	vip_rights      = 'vip_rights',
	vip_cost        = 'vip_cost'
};` }}
find(_) -> undefined.

{{ col . `keys() -> ["'id'@'sub_id'"].` }}
