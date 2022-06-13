-include("search_treasure.hrl").

{{ row . `find('id') -> #cfg_searchtreasure_batch{
	id                = 'id',
	type_id           = 'type_id',
	first_bless_value = 'first_bless_value',
	bless_value       = 'bless_value',
	max_bless_value   = 'max_bless_value',
	open_server_days  = 'open_server_days',
	player_level      = 'player_level',
	cost              = 'cost',
	gain              = 'gain'
};` }}
find(_) -> undefined.

{{ col . `find_type('type_id') -> ['id'];` }}
find_type(_) -> [].
