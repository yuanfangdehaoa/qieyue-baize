-include("vip.hrl").

{{ row . `find('id') -> #cfg_vip_card{
	id    = 'id',
	item  = 'item',
	level = 'level',
	last  = 'last',
	exp   = 'exp',
	goods = 'goods'
};` }}
find(_) -> undefined.
