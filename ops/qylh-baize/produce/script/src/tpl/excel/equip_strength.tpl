-include("equip.hrl").

{{ row . `find('id') -> #cfg_equip_strength{
	id              = 'id',
	slot            = 'slot',
	phase           = 'phase',
	level           = 'level',
	cost            = 'cost',
	bless_value     = 'bless_value',
	max_bless_value = 'max_bless_value',
	prob            = 'prob',
	attrib          = 'attrib',
	next_id         = 'next_id'
};` }}
find(_) -> undefined.

{{ row . `find_id({'slot', 'phase', 'level'}) -> 'id';` }}
find_id(_) -> undefined.
