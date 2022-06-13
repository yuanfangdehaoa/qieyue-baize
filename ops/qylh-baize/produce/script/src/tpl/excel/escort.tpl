-include("escort.hrl").

{{ row . `find('id') -> #cfg_escort{
	id             = 'id',
	attend         = 'attend',
	robcount       = 'robcount',
	support        = 'support',
	support_reward = 'support_reward',
	robbed         = 'robbed',
	fail_robbed    = 'fail_robbed',
	protect        = 'protect',
	refresh        = 'refresh',
	price          = 'price',
	lost           = 'lost',
	show           = 'show',
	fresh          = 'fresh',
	max_quality    = 'max_quality',
	duration       = 'duration',
	random         = 'random',
	buff           = 'buff'
};` }}
find(_) -> undefined.
