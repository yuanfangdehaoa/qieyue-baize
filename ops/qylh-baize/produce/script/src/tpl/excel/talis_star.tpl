-include("morph.hrl").

{{ row . `find('id', 'star') -> #cfg_morph_star{
	id    = 'id',
	star  = 'star',
	cost  = 'cost',
	attrs = 'attrs'
};` }}
find(_, _) -> undefined.

{{ gmax . `max('id') -> 'star';` }}
max(_) -> 0.
