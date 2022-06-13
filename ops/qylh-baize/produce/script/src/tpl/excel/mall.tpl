-include("mall.hrl").

{{ row . `find('id') -> #cfg_mall{
	id              = 'id',
	mall_type       = 'mall_type',
	order           = 'order',
	item            = 'item',
	discount        = 'discount',
	price           = 'price',
	original_price  = 'original_price',
	name            = 'name',
	limit_type      = 'limit_type',
	limit_num       = 'limit_num',
	limit_vip       = 'limit_vip',
	limit_pre_id    = 'limit_pre_id',
	limit_level     = 'limit_level',
	limit_open_days = 'limit_open_days',
	limit_duration  = 'limit_duration',
	limit_other     = 'limit_other',
	refresh         = 'refresh',
	activity        = 'activity',
	notify          = 'notify',
	panel           = 'panel'
};` }}
find(_) -> undefined.

{{ col . `find_ids_by_limittype('limit_type') -> ['id'];` }}
find_ids_by_limittype(_) -> [].

{{ col . `act_items('activity') -> ['id'];` }}
act_items(_) -> [].
