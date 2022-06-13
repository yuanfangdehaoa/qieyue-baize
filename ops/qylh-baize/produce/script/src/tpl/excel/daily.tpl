-include("daily.hrl").

{{ row . `find('id') -> #cfg_daily{
	act_type   = 'act_type',
	reset      = 'reset',
	activation = 'activation',
	count      = 'count',
	target     = 'target',
	reqs       = 'reqs'
};` }}
find(_) -> undefined.

{{ col . `list() -> ['id'].` }}
