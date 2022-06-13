-include("activity.hrl").

{{ row . `find('id') -> #cfg_activity{
    id    = 'id',
    name  = 'name',
    group = 'group',
    type  = 'type',
    level = 'level',
    reqs  = 'reqs',
    cycle = 'cycle',
    days  = 'days',
    pre   = 'pre',
    time  = 'time',
    post  = 'post',
    scene = 'scene',
    msgno = 'msgno'
};` }}
find(_) -> undefined.

{{ col . `all('level') -> ['id'];` }}
all(_) -> [].

{{ col . `all() -> ['id'].` }}

{{ scol . `group('group') -> ['id'];` "id" false }}
group(_) -> [].

{{ scol . `group('group', 'type') -> ['id'];` "id" false }}
group(_, _) -> [].
