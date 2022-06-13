-include("item.hrl").

{{ row . `find('id') -> #cfg_item{
	id          = 'id',
	name        = 'name',
	bag         = 'bag',
	depot       = 'depot',
	type        = 'type',
	stype       = 'stype',
	color       = 'color',
	level       = 'level',
	level_limit = 'level_limit',
	vip_limit   = 'vip_limit',
	lap         = 'lap',
	bind        = 'isbind',
	career      = 'career',
	money       = 'money',
	price       = 'price',
	chuck       = 'chuck',
	trade       = 'trade',
	expire      = 'expire',
	notify      = 'notify',
	effect      = 'effect'
};` }}
find(_) -> undefined.

{{ col . `items_with_color('color') -> ['id'];` }}
items_with_color(_) -> [].

{{ col . `items_with_stype('stype') -> ['id'];` }}
items_with_stype(_) -> [].

