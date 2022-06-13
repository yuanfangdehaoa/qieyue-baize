-include("equip.hrl").

{{ row . `find('id') -> #cfg_stones_hole{
	id             = 'id',
	open_condition = 'open_condition'
};` }}
find(_) -> undefined.
