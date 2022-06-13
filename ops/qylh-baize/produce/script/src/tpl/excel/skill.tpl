-include("skill.hrl").

{{ row . `find('id') -> #cfg_skill{
	id     = 'id',
	name   = 'name',
	type   = 'type',
	group  = 'group',
	gender = 'gender',
	career = 'career',
	wake   = 'wake',
	aim    = 'aim',
	center = 'center',
	is_hit = 'hit',
	is_hew = 'is_hew',
	pos    = 'pos',
	auto   = 'auto',
	ctrl   = 'controllable'
};` }}
find(_) -> undefined.

{{ with (filter . `ne trigger undefined`)}}
{{ col . `trigger('trigger') -> ['id'];` }}
trigger(_) -> [].
{{ end }}

{{ col . `skills('group') -> ['id'];` }}
skills(_) -> [].

{{ col . `all() -> ['id'].` }}
