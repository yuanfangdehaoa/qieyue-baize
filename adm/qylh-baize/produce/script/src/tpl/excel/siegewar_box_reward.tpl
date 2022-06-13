-include("siegewar.hrl").

{{ row . `find('id', 'type', 'times', Level) when Level >= 'worldlv_min', Level =< 'worldlv_max' -> #cfg_siegewar_box{
	id     = 'id',
	type   = 'type',
	reqs   = 'reqs',
	cost   = 'cost',
	reward = 'reward'
};` }}
find(_, _, _, _) -> undefined.

{{ gmax . `max_times('id') -> 'times';` }}
max_times(_) -> 0.