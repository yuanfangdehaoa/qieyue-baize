-include("talent.hrl").

{{ row . `find('id') -> #cfg_talent{
	id    = 'id',
	group = 'group',
	reqs  = 'reqs',
	point = 'point'
};` }}
find(_) -> [].

{{ col . `group('group') -> ['id'];` }}
group(_) -> [].