-include("mecha.hrl").

{{ row . `find('id') -> #cfg_mecha_equip{
	id       = 'id',
	slot     = 'slot',
	base     = 'base',
	gain     = 'gain',
	mecha_id = 'mecha_id'
};` }}
find(_) -> undefined.

