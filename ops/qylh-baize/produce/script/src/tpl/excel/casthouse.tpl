-include("casthouse.hrl").

{{ row . `find('id') -> #cfg_casthouse{
	id              = 'id',
	free_count      = 'free_count',
	cost            = 'cost',
	reset_cost      = 'reset_cost',
	pp              = 'pp'
};` }}
find(_) -> undefined.


