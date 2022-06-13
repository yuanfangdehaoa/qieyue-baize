-include("dunge.hrl").

{{ row . `find('floor') -> #cfg_dunge_magic{
	floor = 'floor',
	dunge = 'dunge',
	loto  = 'loto',
	gift  = 'gift',
	power = 'power'
};` }}
find(_) -> undefined.

max_floor() ->{{ max . "floor" }}.
