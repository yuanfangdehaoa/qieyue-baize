-include("god_equips.hrl").

{{ row . `find('slot', 'level') -> #cfg_god_equip_level{
	slot     = 'slot',
	level    = 'level',
	attr     = 'attr',
	cost     = 'cost'
};` }}
find(_, _) -> undefined.

