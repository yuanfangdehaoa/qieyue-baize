-include("fashion.hrl").

{{ row . `find('id') -> #cfg_fashion{
	id         = 'id',
	type_id    = 'type_id',
	man_model  = 'man_model',
	girl_model = 'girl_model',
	max_star   = 'max_star',
	cost       = 'cost',
	time       = 'time',
	msgno      = 'msgno'
};` }}
find(_) -> undefined.

{{ with (filter . `eq cost []` )}}
{{ col . `get_ids() -> ['id'].` }}
{{end}}

{{ with (filter . `eq cost []` )}}
{{ row . `default('type_id') -> 'id';` }}
{{end}}
default(_) -> 0.
