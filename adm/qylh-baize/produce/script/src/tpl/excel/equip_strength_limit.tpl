-include("equip.hrl").

{{ row . `find('id') -> #cfg_equip_strength_limit{
	id        = 'id',
	order     = 'order',
	color     = 'color',
	slot      = 'slot',
	max_phase = 'max_phase'
};` }}
find(_) -> undefined.

{{ col . `find_id({'slot', 'order', 'color'}) -> 'id';` }}
find_id(_) -> undefined.
