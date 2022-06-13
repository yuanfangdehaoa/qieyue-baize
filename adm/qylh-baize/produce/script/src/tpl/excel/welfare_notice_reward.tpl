-include("welfare.hrl").

{{ row . `find('id') -> #cfg_welfare_notice_reward{
	id         = 'id',
	reward     = 'reward',
	start_time = 'start_time',
	end_time   = 'end_time',
	state      = 'state'
};` }}
find(_) -> undefined.
