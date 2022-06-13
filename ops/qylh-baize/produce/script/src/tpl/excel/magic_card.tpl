-include("magic_card.hrl").

{{ row . `find('id') -> #cfg_magic_card{
	id        = 'id',
	star      = 'star',
	max_star  = 'max_star',
	cost      = 'cost',
	slot      = 'slot',
	attr_type = 'attr_type',
	base      = 'base',
	rare      = 'rare',
	gate      = 'gate',
	score     = 'score',
	gain      = 'gain'
};` }}
find(_) -> undefined.
