-include("escort.hrl").

{{ row . `find('quality', 'level') -> #cfg_escort_product{
	quality  = 'quality',
	level    = 'level',
	complete = 'complete',
	failure  = 'failure',
	rob      = 'rob'
};` }}
find(_, _) -> undefined.
