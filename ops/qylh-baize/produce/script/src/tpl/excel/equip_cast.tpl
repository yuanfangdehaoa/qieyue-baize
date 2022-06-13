-include("equip.hrl").

{{ row . `find('slot', 'level') -> #cfg_equip_cast{
	slot            = 'slot',
	level           = 'level',
	name            = 'name',
	order           = 'order',
	color           = 'color',
	star            = 'star',
	percent         = 'percent',
	attr            = 'attr',
	cost            = 'cost',
	msgno           = 'msgno'
};` }}
find(_, _) -> undefined.


