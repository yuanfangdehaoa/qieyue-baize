-include("yunying.hrl").

{{ row . `find('id') -> #cfg_yunying_gift{
    id          = 'id',
    refund_time = 'refund_time',
    cycle       = 'cycle',
    days        = 'days',
    time        = 'time',
    desc        = 'desc'
};` }}
find(_) -> undefined.

{{ col . `all() -> ['id'].` }}
