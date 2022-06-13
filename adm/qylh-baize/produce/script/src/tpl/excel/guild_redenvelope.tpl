-include("guild_redenvelope.hrl").

{{ row . `find('id') -> #cfg_guild_redenvelope{
	id       = 'id',
	type_id  = 'type_id',
	belong   = 'belong',
	target   = 'target',
	is_count = 'is_count',
	limit    = 'limit',
	cost     = 'cost',
	item_id  = 'item_id',
	money    = 'money',
	num      = 'num',
	range    = 'range',
	msgno    = 'msgno'
};` }}
find(_) -> undefined.

{{ col . `ids() -> ['id'].` }}
