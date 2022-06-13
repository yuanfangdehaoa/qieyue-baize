-include("magic_card.hrl").

{{ row . `find('r_item_id') -> #cfg_magic_card_combine{
	r_item_id  = 'r_item_id',
	c_item_id1 = 'c_item_id1',
	c_item_id2 = 'c_item_id2',
	cost       = 'cost'
};` }}
find(_) -> undefined.
