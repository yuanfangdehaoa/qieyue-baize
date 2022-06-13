-include("arti.hrl").

{{ row . `find('type', 'eid', 'level') -> #cfg_artifact_element{
	id    = 'eid',
	name  = 'name',
	type  = 'type',
	level = 'level',
	cost  = 'cost',
	attrs = 'attrs'
};` }}
find(_, _, _) -> undefined.
