-include("escort.hrl").

{{ row . `find('id') -> #cfg_escort_road{
	id      = 'id',
	start   = 'start',
	second  = 'second',
	end_npc = 'end_npc'
};` }}
find(_) -> undefined.
