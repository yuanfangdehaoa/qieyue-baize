-include("morph.hrl").

{{ row . `find('id') -> #cfg_morph{
	id   = 'id',
	name = 'name',
	reqs = 'reqs',
	cost = 'cost'
};` }}
find(_) -> undefined.

{{ col . `list() -> ['id'].` }}

{{ row . `res('id') -> 'res';` }}
res(_) -> 0.
