-include("welfare.hrl").

{{ row . `find('count') -> #cfg_welfare_grail_cost{
	count = 'count',
	cost  = 'cost'
};` }}
find(_) -> undefined.
