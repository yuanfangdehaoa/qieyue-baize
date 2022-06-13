-include("welfare.hrl").

{{ row . `find('power') -> #cfg_welfare_power_reward{
	power   = 'power',
	reward  = 'reward',
	reward2 = 'reward2',
	count   = 'count'
};` }}
find(_) -> undefined.
