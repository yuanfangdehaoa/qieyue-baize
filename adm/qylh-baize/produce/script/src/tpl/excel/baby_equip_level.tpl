-include("baby.hrl").

{{ row . `find('slot', 'level') -> #cfg_baby_equip_level{
	slot     = 'slot',
	level    = 'level',
	attr     = 'attr',
	cost     = 'cost'
};` }}
find(_, _) -> undefined.

