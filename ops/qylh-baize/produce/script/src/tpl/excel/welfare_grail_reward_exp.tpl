-include("welfare.hrl").

{{ row . `find('id', 'count') -> #cfg_welfare_grail_reward_exp{
	id    = 'id',
	count = 'count',
	exp   = 'exp'
};` }}
find(_,_) -> undefined.
