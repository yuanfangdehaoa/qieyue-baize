-include("god_equips.hrl").

{{ row . `find('id') -> #cfg_god_equip{
	id       = 'id',
	slot     = 'slot',
	base     = 'base',
	gain     = 'gain'
};` }}
find(_) -> undefined.

