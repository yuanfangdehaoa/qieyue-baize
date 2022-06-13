-include("skill.hrl").

{{ row . `find('id', 'level') -> #cfg_skill_level{
	id      = 'id',
	level   = 'level',
	exp     = 'exp',
	reqs    = 'reqs',
	learn   = 'learn',
	attrs   = 'attrs',
	buffs   = 'buffs',
	cd      = 'cd',
	play	= 'play',
	amp     = 'amp',
	area    = 'area',
	center  = 'centre',
	dist    = 'dist',
	radius  = 'radius',
	cover   = {'cover1', 'cover2'},
	trigger = 'trigger',
	abuffs  = 'abuffs',
	dbuffs  = 'dbuffs',
	effect  = 'effect'
};` }}
find(_, _) -> undefined.

{{ gmax . `max('id') -> 'level';`}}
max(_) -> 0.

{{ col . `levels('id') -> ['level'];` }}
levels(_) -> undefined.
