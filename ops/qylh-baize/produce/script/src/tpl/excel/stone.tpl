-include("equip.hrl").

{{ row . `find('id') -> #cfg_stone{
	id            = 'id',
	level         = 'level',
	slots         = 'slots',
	attrib        = 'attrib',
	need_num      = 'need_num',
	next_level_id = 'next_level_id',
	pre_level_id  = 'pre_level_id'
};` }}
find(_) -> undefined.
