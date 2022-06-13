-include("morph.hrl").

{{ row . `find('id') -> #cfg_morph{
	id    = 'id',
	name  = 'name',
	reqs  = 'reqs',
	cost  = 'cost',
	speed = 'speed',
	msgno = 'msgno'
};` }}
find(_) -> undefined.

{{ col . `list() -> ['id'].` }}

{{ row . `res('id') -> 'res';` }}
res(_) -> 0.

{{ row . `model('id') -> 'model';` }}
model(_) -> 0.
