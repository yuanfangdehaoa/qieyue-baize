-include("search_treasure.hrl").

{{ row . `find('id') -> #cfg_searchtreasure_rewards{
	id           = 'id',
	type_id      = 'type_id',
	batch_id     = 'batch_id',
	prob         = 'prob',
	rewards      = 'rewards',
	is_rare      = 'is_rare',
	is_broadcast = 'is_broadcast',
	channel      = 'channel',
	is_notice    = 'is_notice'
};` }}
find(_) -> undefined.

{{ col . `find_ids_by_batchid('batch_id') -> ['id'];` }}
find_ids_by_batchid(_) -> [].
