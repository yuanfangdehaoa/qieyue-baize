-include("god_equips.hrl").

{{ row . `find('slot') -> #cfg_god_equip_open{
	slot     = 'slot',
	open     = 'open'
};` }}
find(_) -> undefined.

{{ col . `slots() -> ['slot'].` }}

