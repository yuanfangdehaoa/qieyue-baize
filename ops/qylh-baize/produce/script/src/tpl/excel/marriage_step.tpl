-include("marriage.hrl").

{{ row . `find('id') -> #cfg_marriage_step{target = 'target', reward = 'reward'};` }}
find(_) -> undefined.

{{ scol . `list() -> ['id'].` "id" false }}
