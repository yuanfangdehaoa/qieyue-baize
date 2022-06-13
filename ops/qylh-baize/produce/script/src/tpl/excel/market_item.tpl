-include("market.hrl").

{{ row . `get_key('item_id') -> {'type', 'stype'};` }}
get_key(_) -> undefined.

{{ row . `price('item_id') -> #cfg_market_price{
	id  = 'item_id',
	min = 'min_price',
	max = 'max_price'
};` }}
price(_) -> undefined.

{{ with (filter . `gt min_num 0`) }}
{{ row . `fill('item_id') -> #cfg_market_fill{
	id    = 'item_id',
	floor = 'min_num',
	lap   = 'lap',
	fill  = 'fill_num',
	price = 'fill_price'
};` }}
fill(_) -> undefined.
{{ end }}

{{ col . `all() -> ['item_id'].` }}
