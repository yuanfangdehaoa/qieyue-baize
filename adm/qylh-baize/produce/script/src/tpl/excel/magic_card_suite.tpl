-include("magic_card.hrl").

{{ row . `find('id') -> #cfg_magic_card_suite{
	id          = 'id',
	com_sum     = 'com_sum',
	com_color   = 'com_color',
	is_compose  = 'is_compose',
	skill_id    = 'skill_id',
	desc        = 'desc'
};` }}
find(_) -> undefined.

{{ col . `find_id() -> ['id'].` }}
