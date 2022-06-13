-include("yunying.hrl").

{{ row . `find('id') -> #cfg_yunying_lottery_rewards{
	id              = 'id',
	yunying_id      = 'yunying_id',
	rewards         = 'rewards',
	prob            = 'prob',
	is_rare         = 'is_rare',
	is_self         = 'is_self',
	is_all          = 'is_all',
	is_broadcast    = 'is_broadcast',
	absolute        = 'absolute'
};` }}
find(_) -> undefined.

{{ col . `ids('yunying_id', 'group', Level) when Level >= 'min_level', Level =< 'max_level' -> ['id'];` }}
ids(_, _, _) -> [].

{{gmax . `max('yunying_id')-> 'absolute';`}}
max(_) -> 0.
