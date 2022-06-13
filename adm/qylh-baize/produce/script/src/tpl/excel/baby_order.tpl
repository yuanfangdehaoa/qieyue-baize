-include("baby.hrl").

{{ row . `find('id', 'order') -> #cfg_baby_order{
	id         = 'id',
	type_id    = 'type_id',
	gender     = 'gender',
	order      = 'order',
	name       = 'name',
	res_id     = 'res_id',
	exp        = 'exp',
	cost       = 'cost',
	attr       = 'attr',
	skill      = 'skill',
	active     = 'active',
	next_id    = 'next_id',
	msgno      = 'msgno'
};` }}
find(_, _) -> undefined.

