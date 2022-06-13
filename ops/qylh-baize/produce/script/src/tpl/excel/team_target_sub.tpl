-include("team.hrl").

{{ row . `find('id') -> #cfg_team_target_sub{
	id   = 'id',
	name = 'name'
};` }}
find(_) -> undefined.
