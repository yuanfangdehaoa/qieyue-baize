-include("welfare.hrl").

{{ row . `find('id') -> #cfg_welfare_sign_reward{
	id     = 'id',
	month  = 'month',
	day    = 'day',
	reward = 'reward',
	vip    = 'vip'
};` }}
find(_) -> undefined.

{{ col . `ids() -> ['id'].` }}
