-include("buff.hrl").

{{ row . `find('id') -> #cfg_buff{
	id     = 'id',
	name   = 'name',
	type   = 'type',
	group  = 'group',
	lap    = 'lap',
	level  = 'level',
	last   = 'last',
	tick   = 'tick',
	effect = 'effect',
	args   = 'args',
	vtype  = 'vtype',
	value  = 'value',
	attrs  = 'attrs',
	show   = 'show',
	notify = 'notify',
	mirror = 'mirror'
};` }}
find(_) -> undefined.

{{ with (filter . `ne remove undefined`) }}
{{ col . `remove('remove') -> ['id'];` }}
remove(_) -> [].
{{ end }}
