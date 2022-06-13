-include("pet.hrl").

{{ row . `find('order', 'times') -> #cfg_pet_evolution{
	order      = 'order',
	times      = 'times',
	cost       = 'cost',
	skill      = 'skill',
	attr       = 'attr',
	normal_atk = 'normal_atk',
	change_atk = 'change_atk',
	profound   = 'profound',
	passive    = 'passive',
	fight_attr = 'fight_attr'
};` }}
find(_, _) -> undefined.
