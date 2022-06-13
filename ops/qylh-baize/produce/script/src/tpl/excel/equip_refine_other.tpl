-include("equip.hrl").

{{ row . `find('id') -> #cfg_equip_refine_other{
	id         =  'id',
	unlock     =  'unlock',
	lock       =  'lock',
	freecount  =  'freecount',
	cost       =  'cost'
};` }}
find(_) -> undefined.


