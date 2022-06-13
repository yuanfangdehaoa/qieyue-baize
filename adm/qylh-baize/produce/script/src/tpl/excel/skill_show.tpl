-include("skill.hrl").

{{ row . `find('id') -> #cfg_skill_show{
	id     = 'id',
	career = 'career',
	type   = 'type',
	sort   = 'sort'
};` }}
find(_) -> undefined.

{{ col . `all() -> ['id'].` }}
