-include("casthouse.hrl").

{{ row . `find('id') -> #cfg_casthouse_grid{
	id              = 'id',
	drop            = 'drop',
	prob            = 'prob'
};` }}
find(_) -> undefined.


