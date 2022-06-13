-include("mecha.hrl").

{{ row . `find('id', 'slot') -> #cfg_mecha_equip_open{
	id       = 'id',
	slot     = 'slot',
	open     = 'open'
};` }}
find(_, _) -> undefined.

{{ col . `slots('id') -> ['slot'];` }}
slots(_) -> [].

