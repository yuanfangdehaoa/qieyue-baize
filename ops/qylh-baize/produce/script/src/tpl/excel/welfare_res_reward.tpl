-include("welfare.hrl").

{{ row . `find('id') -> #cfg_welfare_res_reward{
	id     = 'id',
	reward = 'reward'
};` }}
find(_) -> undefined.
