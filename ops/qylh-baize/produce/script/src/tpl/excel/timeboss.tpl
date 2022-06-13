-include("timeboss.hrl").

{{ row . `find('id') -> #cfg_timeboss{
	id     = 'id',
	name   = 'name',
	kind   = 'kind',
	type   = 'type',
	floor  = 'floor',
	scene  = 'scene',
	coord  = 'coord',
	room   = 'room_num',
	shield = 'shield_reward'
};` }}
find(_) -> undefined.

{{ row . `box('id') -> #cfg_timeboss_box{
	id    = 'id',
	coord = 'box_coord',
	reqs  = 'high_box_cond',
	times = 'box_time'
};` }}
box(_) -> undefined.

{{ col . `bosses() -> ['id'].` }}

{{ col . `scenes() -> ['scene'].` }}

{{ col . `room('scene') -> 'room_num';` }}
room(_) -> 0.

{{ with (filter . "gt auto_care 0") }}
{{ col . `auto_care('auto_care') -> ['id'];` }}
{{ end }}
auto_care(_) -> [].

{{ with (filter . "gt auto_cancel 0") }}
{{ col . `auto_cancel() -> [{'id', 'auto_cancel'}].` }}
{{ end }}
