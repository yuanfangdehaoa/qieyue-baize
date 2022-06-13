-include("equip.hrl").

{{ row . `find('id') -> #cfg_equip_smelt{
	id   = 'id',
	exp  = 'exp',
	attr = 'attr'
};` }}
find(_) -> undefined.
