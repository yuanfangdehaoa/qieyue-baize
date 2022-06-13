-include("pet.hrl").

{{ row . `find('id') -> #cfg_pet_compose{
	id     = 'id',
	level  = 'level',
	target = 'target',
	cost   = 'cost',
	proba  = 'proba',
	compose_key = 'compose_key'
};` }}
find(_) -> undefined.
