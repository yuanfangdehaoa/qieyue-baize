-include("equip.hrl").

{{ row . `find('id') -> #cfg_equip_refine_attr{
	id            = 'id',
	attr_type     = 'attr_type',
	attr          = 'attr'
};` }}
find(_) -> undefined.


