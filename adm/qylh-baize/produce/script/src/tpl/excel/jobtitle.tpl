-include("jobtitle.hrl").

{{ row . `find('id') -> #cfg_jobtitle{
	id         = 'id',
	name       = 'name',
	need_power = 'need_power',
	cost       = 'cost',
	attr       = 'attr',
	next_id    = 'next_id'
};` }}
find(_) -> undefined.
