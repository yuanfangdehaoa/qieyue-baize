-include("magic_card.hrl").

{{ row . `find('pos') -> #cfg_magic_card_pos{
	pos  = 'pos',
	gate = 'gate'
};` }}
find(_) -> undefined.
