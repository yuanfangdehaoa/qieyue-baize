-include("dunge.hrl").

{{ row . `find('id', 'wave', Level) when 'minlv' =< Level, Level =< 'maxlv' -> #cfg_dunge_wave{
	id     = 'id',
	wave   = 'wave',
	reqs   = 'reqs',
	creeps = 'creeps',
	last   = 'last',
	reward = 'drop',
	first  = 'first'
};` }}
find(_, _, _) -> undefined.

{{ gmax . `max('id') -> 'wave';` }}
max(_) -> 0.
