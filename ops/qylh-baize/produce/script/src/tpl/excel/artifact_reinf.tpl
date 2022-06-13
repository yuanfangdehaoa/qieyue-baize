-include("arti.hrl").

{{ row . `find('aid', 'level') -> #cfg_artifact_reinf{
	id      = 'aid',
	level   = 'level',
	exp     = 'exp',
	attrs   = 'attrs',
	enchant = 'enchant'
};` }}
find(_, _) -> undefined.
