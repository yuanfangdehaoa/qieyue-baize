-include("yunying.hrl").

{{ row . `find('yunying_id', 'id') -> #cfg_yunying_lottery_shop{
    category = 'category',
    rewards  = 'rewards',
    total    = 'total',
    limit    = 'limit',
    max      = 'max',
    min      = 'min'
};` }}
find(_, _) -> undefined.

{{ col . `ids('yunying_id', 'day', Level) when Level >= 'min_level', Level =< 'max_level' -> ['id'];` }}
ids(_, _, _) -> [].
