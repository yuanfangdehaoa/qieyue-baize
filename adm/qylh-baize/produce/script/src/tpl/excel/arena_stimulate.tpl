-include("arena.hrl").

{{ row . `find('times') -> #cfg_arena_stimulate{cost='cost', stimulate='stimulate'};` }}
find(_) -> undefined.
