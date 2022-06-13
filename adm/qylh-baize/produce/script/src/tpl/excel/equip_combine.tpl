-include("equip.hrl").

{{ row . `find('id') -> #cfg_equip_combine{
	id          = 'id',
	title       = 'title',
	open_level  = 'open_level',
	gain        = 'gain',
	cost        = 'cost',
	other_cost  = 'other_cost',
	min_num     = 'min_num',
	max_num     = 'max_num',
	probs       = 'probs',
	compose_key = 'compose_key'
};` }}
find(_) -> undefined.
