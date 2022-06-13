-include("bag.hrl").

{{ row . `find('id') -> #cfg_bag{
	id   = 'id',
	name = 'name',
	type = 'type',
	cap  = 'cap',
	open = 'open',
	cost = [{'cost'}]
};` }}
find(_) -> undefined.

{{ col . `bags() -> ['id'].` }}
