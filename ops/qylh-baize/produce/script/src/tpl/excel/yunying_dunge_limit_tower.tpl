-include("yunying.hrl").

{{ row . `find('act_id', 'floor') -> #cfg_yunying_dunge_limit_tower{dunge = 'dunge', assist = 'assist'};` }}
find(_, _) -> undefined.

{{ gmax . `max_floor('act_id') -> 'floor';` }}
max_floor(_) -> 0.

{{ row . `floor('dunge') -> 'floor';` }}
floor(_) -> undefined.

{{ col . `act_ids() -> ['act_id'].` }}

{{ row . `is_open('act_id', 'dunge') -> true;` }}
is_open(_, _) -> false.
