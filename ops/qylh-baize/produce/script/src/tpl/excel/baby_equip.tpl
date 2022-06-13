-include("baby.hrl").

{{ row . `find('id') -> #cfg_baby_equip{
	id       = 'id',
	slot     = 'slot',
	base     = 'base',
	gain     = 'gain'
};` }}
find(_) -> undefined.

