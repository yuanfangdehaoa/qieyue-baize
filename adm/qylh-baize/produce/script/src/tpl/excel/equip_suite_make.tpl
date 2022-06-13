-include("equip.hrl").

{{ row . `find('id') -> #cfg_equip_suite_make{
	id      = 'id',
	slot    = 'slot',
	type_id = 'type_id',
	order   = 'order',
	level   = 'level',
	cost    = 'cost'
};` }}
find(_) -> undefined.

{{ col . `find_id({'slot', 'order', 'level'}) -> 'id';` }}
find_id(_) -> undefined.
