-include("equip.hrl").

{{ row . `find('level') -> #cfg_equip_suite_level{
	level = 'level',
	name  = 'name',
	color = 'color',
	star  = 'star'
};` }}
find(_) -> undefined.
