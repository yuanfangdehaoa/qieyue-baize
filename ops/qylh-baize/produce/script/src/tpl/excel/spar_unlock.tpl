-include("equip.hrl").

{{ row . `find('id') -> #cfg_spar_unlock{
	id             = 'id',
	open_condition = 'open_condition'
};` }}
find(_) -> undefined.
