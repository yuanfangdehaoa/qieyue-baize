-include("baby.hrl").

{{ row . `find('gender') -> #cfg_baby{
	gender     = 'gender',
	name       = 'name',
	reqs       = 'reqs',
	play_gain  = 'play_gain',
	play_count = 'play_count',
	growitem   = 'growitem',
	id         = 'id'
};` }}
find(_) -> undefined.

