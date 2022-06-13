-include("soul.hrl").

{{ row . `find('id', 'level') -> #cfg_soul_level{
	id         = 'id',
	level      = 'level',
	cost       = 'cost',
	total_cost = 'total_cost',
	attrib     = 'attrib',
	fight      = 'fight'
};` }}
find(_, _) -> undefined.
