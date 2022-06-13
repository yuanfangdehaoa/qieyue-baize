-include("achieve.hrl").

{{ row . `find('id') -> #cfg_achieve{
	id     = 'id',
	point  = 'point',
	reward = 'reward',
	target = 'target'
};` }}
find(_) -> undefined.

{{ col . `list() -> ['id'].`}}
