-include("soul.hrl").

{{ row . `find('pos') -> #cfg_soul_pos{
	pos   = 'pos',
	level = 'level'
};` }}
find(_) -> undefined.
