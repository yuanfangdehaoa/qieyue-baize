-include("welfare.hrl").

{{ row . `find('level') -> #cfg_welfare_level_reward{
	level   = 'level',
	reward  = 'reward',
	reward2 = 'reward2',
	count   = 'count'
};` }}
find(_) -> undefined.
