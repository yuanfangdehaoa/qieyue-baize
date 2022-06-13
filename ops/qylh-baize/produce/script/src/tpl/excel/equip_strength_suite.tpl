-include("equip.hrl").

{{ row . `find('id') -> #cfg_equip_strength_suite{
	id     = 'id',
	phase  = 'phase',
	level  = 'level',
	slots  = 'slots',
	num    = 'num',
	attrib = 'attrib'
};` }}
find(_) -> undefined.

{{ col . `suite_ids() -> ['id'].` }}
