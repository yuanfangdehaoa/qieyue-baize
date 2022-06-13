-include("yunying.hrl").

{{ row . `find('id') -> #cfg_yunying{
	id    = 'id',
	type  = 'type',
	name  = 'name',
	reqs  = 'reqs',
	level = 'level',
	wake  = 'wake',
	cycle = 'cycle',
	days  = 'days',
	time  = 'time',
	show  = 'show',
	rank  = 'rank',
	mail  = 'mail',
	clear = 'clear',
	form  = 'form'
};` }}
find(_) -> undefined.

{{ col . `all() -> ['id'].` }}

{{ col . `all('cycle') -> ['id'];` }}
all(_) -> [].

{{ col . `list('cross') -> ['id'];` }}
list(_) -> [].

{{ col . `level('level') -> ['id'];` }}
level(_) -> [].

{{ col . `wake('wake') -> ['id'];` }}
wake(_) -> [].

{{ row . `panel('id') -> 'panel';` }}
panel(_) -> "".

{{ col . `type('type') -> ['id'];` }}
type(_) -> [].
