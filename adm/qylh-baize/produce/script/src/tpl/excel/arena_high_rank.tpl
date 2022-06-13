-include("arena.hrl").

{{ row . `find('id') -> #cfg_arena_high_rank{rank='max', reward='reward'};` }}
find(_) -> undefined.

{{ col . `all() -> ['id'].` }}
