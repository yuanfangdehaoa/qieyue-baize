-include("pet.hrl").

{{ row . `find('slot', 'level') -> #cfg_pet_equip_strength{
	slot  = 'slot',
	level = 'level',
	cost  = 'cost',
	attr  = 'attr'
};` }}
find(_, _) -> undefined.
