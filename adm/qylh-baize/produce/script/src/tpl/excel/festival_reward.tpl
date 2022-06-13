-include("yunying.hrl").
-include("proto.hrl").

{{ row . `find('act_id', 'id') -> #cfg_yunying_reward{
    id      = 'id',
    act_id  = 'act_id',
    level   = 'level',
    event   = 'event',
    goal    = 'task',
    trigger = 'trigger',
    reqs    = 'reqs',
    limit   = 'limit',
    cost    = 'cost',
    reward  = 'reward',
    misc    = 'sundries'
};` }}
find(_, _) -> undefined.

{{ with (filter . `ne task ""`)}}
{{ col . `tasks('act_id') -> ['id'];` }}
tasks(_) -> [].
{{ end }}

{{ col . `all() -> [{'act_id','id'}].` }}
