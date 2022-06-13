-include("soul.hrl").

{{ row . `find('id') -> #cfg_soul{
	id        = 'id',
	slot      = 'slot',
	attr_type = 'attr_type',
	base      = 'base',
	score     = 'score',
	gain      = 'gain'
};` }}
find(_) -> undefined.
