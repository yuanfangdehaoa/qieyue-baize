-include("wake.hrl").

{{ row . `find('id') -> #cfg_wake_grid{
	id       = 'id',
	pre_id   = 'pre_id',
	next_id  = 'next_id',
	cost     = 'cost',
	cost_exp = 'cost_exp',
	attr     = 'attr'
};` }}
find(_) -> undefined.
