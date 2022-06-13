-include("baby.hrl").

{{ row . `find('gender', 'level') -> #cfg_baby_level{
	gender     = 'gender',
	level      = 'level',
	cost       = 'cost',
	attr       = 'attr'
};` }}
find(_, _) -> undefined.

