-include("fashion.hrl").

{{ row . `find('id', 'star') -> #cfg_fashion_star{
	id     = 'id',
	star   = 'star',
	cost   = 'cost',
	attrib = 'attrib',
	msgno  = 'msgno'
};` }}
find(_, _) -> undefined.
