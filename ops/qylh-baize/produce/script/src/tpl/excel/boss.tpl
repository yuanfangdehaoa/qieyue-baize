-include("boss.hrl").

{{ row . `find('id') -> #cfg_boss{
	id     = 'id',
	name   = 'name',
	kind   = 'kind',
	type   = 'type',
	group  = 'group',
	floor  = 'floor',
	qual   = 'qual',
	weak   = 'weak',
	scene  = 'scene',
	coord  = 'coord',
	reborn = 'reborn',
	reward = 'reward',
	droplv = 'drop_lv',
	num    = 'num'
};` }}
find(_) -> undefined.

{{ col . `all('kind') -> ['id'];` }}
all(_) -> [].

{{ with (filter . "gt next 0") }}

{{ row . `next('id') -> 'next';` }}
next(_) -> 0.

{{ row . `prev('next') -> 'id';` }}
prev(_) -> 0.

{{ end }}

{{ with (distinct . "type,floor") }}
{{ row . `scene('type', 'floor') -> 'scene';` }}
scene(_, _) -> undefined.
{{ end }}

{{ with (distinct . "type") }}
{{ row . `kind('type') -> 'kind';` }}
kind(_) -> undefined.
{{ end }}


{{ with (filter . "gt group 0") }}
{{ col . `group('type', 'floor', 'group') -> ['id'];` }}
{{ end }}
group(_, _, _) -> [].

{{ with (filter . "gt auto_care 0") }}
{{ col . `auto_care('auto_care') -> ['id'];` }}
{{ end }}
auto_care(_) -> [].

{{ with (filter . "gt auto_cancel 0") }}
{{ col . `auto_cancel() -> [{'id', 'auto_cancel'}].` }}
{{ end }}
