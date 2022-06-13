-include("task.hrl").

{{ row . `find('id') -> #cfg_task{
	id     = 'id',
	name   = 'name',
	type   = 'type',
	group  = 'group',
	reqs   = [{prev,'prev'}, {level,'minlv','maxlv'} | 'reqs'],
	accept = 'accept',
	submit = 'submit',
	quest  = 'quest',
	goals  = 'goals',
	cost   = 'cost',
	gain   = 'gain',
	quick  = 'quick',
	time   = 'time',
	show   = 'show_reqs'
};` }}
find(_) -> undefined.

{{ with (sort . "minlv" true) }}
{{ col . `trigger_by_level('type', Level) when Level >= 'minlv', Level =< 'maxlv' -> ['id'];` }}
trigger_by_level(_, _) -> [].
{{ end }}

{{ with (filter . `gt prev 0`) }}
{{ col . `trigger_by_task('prev') -> ['id'];` }}
trigger_by_task(_) -> [].
{{ end }}

{{ col . `trigger_by_type('type') -> ['id'];` }}
trigger_by_type(_) -> [].

{{ with (filter . `eq type 1`) }}
{{ with (filter . `gt prev 0`) }}
{{ row . `next('prev') -> 'id';` }}
next(_) -> 0.
{{ end }}
{{ end }}

{{ with (filter . `gt chapter 0`) }}
{{ col . `chapter('chapter') -> ['id'];` }}
chapter(_) -> [].
{{ end }}

{{ with (filter . `gt group 0`) }}
{{ col . `group('group') -> ['id'];` }}
group(_) -> [].
{{ end }}