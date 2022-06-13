-include("pet.hrl").

{{ row . `find('order', 'cross') -> #cfg_pet_strong{
	order         = 'order',
	cross         = 'cross',
	percent       = 'percent',
	base          = 'base',
	max           = 'max',
	add_value     = 'add_value',
	strength_cost = 'strength_cost',
	cross_cost    = 'cross_cost',
	plus_percent  = 'plus_percent'
};` }}
find(_, _) -> undefined.
