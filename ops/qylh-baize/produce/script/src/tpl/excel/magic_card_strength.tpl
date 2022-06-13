-include("magic_card.hrl").

{{ row . `find('id', 'level') -> #cfg_magic_card_strength{
	id         = 'id',
	level      = 'level',
	cost       = 'cost',
	total_cost = 'total_cost',
	attrib     = 'attrib',
	fight      = 'fight'
};` }}
find(_, _) -> undefined.
