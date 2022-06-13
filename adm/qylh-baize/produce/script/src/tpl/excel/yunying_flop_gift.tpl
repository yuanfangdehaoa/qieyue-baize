-include("yunying.hrl").

{{ row . `find('round') -> #cfg_yunying_flop_gift{
    round       = 'round',
	reset       = 'reset',
	cost        = 'cost',
	reward      = 'reward'
};` }}
find(_) -> undefined.

{{ col . `all() -> ['round'].` }}