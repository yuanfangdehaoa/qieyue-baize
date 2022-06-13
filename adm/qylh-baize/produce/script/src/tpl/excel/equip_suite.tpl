-include("equip.hrl").

{{ row . `find('id') -> #cfg_equip_suite{
	id      = 'id',
	title   = 'title',
	type_id = 'type_id',
	level   = 'level',
	order   = 'order',
	slots   = 'slots',
	attribs = 'attribs'
};` }}
find(_) -> undefined.

{{ col . `find_id({'type_id', 'order', 'level'}) -> 'id';` }}
find_id(_) -> undefined.
