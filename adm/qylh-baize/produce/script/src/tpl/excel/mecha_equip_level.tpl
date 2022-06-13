-include("mecha.hrl").

{{ row . `find('slot', 'level') -> #cfg_mecha_equip_level{
	slot     = 'slot',
	level    = 'level',
	attr     = 'attr',
	cost     = 'cost'
};` }}
find(_, _) -> undefined.

