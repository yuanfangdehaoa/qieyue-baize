-include("title.hrl").

{{ row . `find('id') -> #cfg_title{
	id       = 'id',
	type_id  = 'type_id',
	res      = 'res',
	attrib   = 'attrib',
	expire   = 'expire'
};` }}
find(_) -> undefined.
