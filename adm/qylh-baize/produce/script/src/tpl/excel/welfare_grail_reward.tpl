-include("welfare.hrl").

{{ row . `find('id') -> #cfg_welfare_grail_reward{
	id        = 'id',
	down_line = 'down_line',
	up_line   = 'up_line'
};` }}
find(_) -> undefined.

{{ col . `find_ids() -> ['id'].` }}
