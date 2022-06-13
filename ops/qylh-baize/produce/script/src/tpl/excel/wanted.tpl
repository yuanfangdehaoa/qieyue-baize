-include("wanted.hrl").

{{ row . `find('id') -> #cfg_wanted{target = 'target', skill = 'skill'};` }}
find(_) -> undefined.

{{ scol . `all() -> ['id'].` "id" false }}
