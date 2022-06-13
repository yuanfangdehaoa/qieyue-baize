-include("chat.hrl").

{{ row . `find('id') -> #cfg_faker_world_content{
	id         = 'id',
	level      = 'level',
	vip        = 'vip',
	content    = 'content'
};` }}
find(_) -> undefined.

