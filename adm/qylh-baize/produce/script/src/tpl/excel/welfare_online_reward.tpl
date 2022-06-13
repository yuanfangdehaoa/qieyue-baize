-include("welfare.hrl").

{{ row . `find('id') -> #cfg_welfare_online_reward{
	id     = 'id',
	reward = 'reward',
	time   = 'time'
};` }}
find(_) -> undefined.
