-include("weekly.hrl").

{{ row . `find('id') -> #cfg_weekly{count = 'count', target = 'target', reward = 'reward'};` }}
find(_) -> undefined.

{{ col . `list() -> ['id'].` }}
