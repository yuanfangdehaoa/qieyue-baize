-include("arti.hrl").

{{ row . `find('aid', 'nth') -> #cfg_artifact_enchant{
	id   = 'aid',
	code = 'attr_code',
	base = 'attr_base',
	max  = 'attr_max',
	add  = 'attr_add'
};` }}
find(_, _) -> undefined.

{{ col . `cost('aid') -> 'cost';` }}
cost(_) -> [].
