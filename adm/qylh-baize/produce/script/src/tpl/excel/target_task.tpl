-include("target.hrl").

{{ row . `find('id') -> #cfg_target_task{
	id    = 'id',
	goals = 'goals',
	gain  = 'gain'
};` }}
find(_) -> undefined.

{{ col . `task_ids() -> ['id'].` }}
