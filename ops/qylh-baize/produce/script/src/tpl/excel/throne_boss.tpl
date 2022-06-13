-include("throne.hrl").

{{ row . `find('id') -> #cfg_throne_boss{
	id     = 'id',
	name   = 'name',
	scene  = 'scene',
	coord  = 'coord',
	score  = 'score',
	attr   = 'attr',
	reborn = 'reborn'
};` }}
find(_) -> undefined.

{{ col . `scenes() -> ['scene'].` }}

{{ col . `bosses() -> ['id'].` }}
