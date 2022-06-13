-include("pet.hrl").

{{ row . `find('id', 'order') -> #cfg_pet_equip{
	id    = 'id',
	order = 'order',
	star  = 'star',
	cost  = 'cost',
	base  = 'base',
	rare1 = 'rare1',
	rare2 = 'rare2',
	rare3 = 'rare3',
	exp   = 'exp',
	limit = 'limit'
};` }}
find(_, _) -> undefined.
