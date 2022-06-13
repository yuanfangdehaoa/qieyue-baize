-include("target.hrl").

{{ row . `find('id') -> #cfg_target{
	id     = 'id',
	name   = 'name',
	pre_id = 'pre_id',
	limit  = 'limit',
	skill  = 'skill',
	tasks  = 'tasks'
};` }}
find(_) -> undefined.

{{ col . `get_ids() -> ['id'].` }}
