-include("siegewar.hrl").

{{ row . `find('id') -> #cfg_siegewar_boss{
	id    = 'id',
	name  = 'name',
	type  = 'type',
	scene = 'scene',
	coord = 'coord',
	score = 'score',
	attr  = 'attr',
	level = 'level'
};` }}
find(_) -> undefined.

{{ row . `box_coord('id') -> 'box_coord';` }}
box_coord(_) -> undefined.

{{ scol . `scenes('level') -> ['scene'];` "scene" false }}
scenes(_) -> [].

{{ col . `scenes() -> ['scene'].` }}

{{ col . `bosses('scene') -> ['id'];` }}
bosses(_) -> [].

{{ col . `bosses() -> ['id'].` }}

{{ col . `level('scene') -> 'level';` }}
level(_) -> 0.
