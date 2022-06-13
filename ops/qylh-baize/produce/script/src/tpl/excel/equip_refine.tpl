-include("equip.hrl").

{{ row . `find('slot') -> #cfg_equip_refine{
	slot            = 'slot',
	open            = 'open',
	attr_libs       = 'attr_libs'
};` }}
find(_) -> undefined.


