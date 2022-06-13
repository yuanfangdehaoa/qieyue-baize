-include("scene.hrl").

{{ row . `find('id') -> #cfg_scene{
	id      = 'id',
	name    = 'name',
	kind    = 'kind',
	type    = 'type',
	stype   = 'stype',
	reqs    = 'reqs',
	buffs   = 'buffs',
	safe    = 'safe',
	tele    = 'tele',
	jump    = 'jump',
	pkmode  = 'pkmode',
	pkallow = 'pkallow',
	mount   = 'mount'
};` }}
find(_) -> undefined.

{{ row . `line('id') -> #cfg_line{
	id   = 'id',
	soft = 'line_soft',
	hard = 'line_hard',
	max  = 'line_max',
	keep = 'line_keep'
};` }}
line(_) -> undefined.

{{ row . `cost('id') -> #cfg_scene_cost{
	id    = 'id',
	type  = 'cost_type',
	cost  = 'cost',
	free  = 'free',
	force = 'force'
};` }}
cost(_) -> undefined.

{{ row . `revive('id') -> #cfg_revive{
	notify = 'dead_notify',
	manu   = 'can_revive',
	type   = 'revive_type',
	time   = 'revive_time',
	cost   = 'revive_cost'
};` }}
revive(_) -> undefined.

{{ col . `scenes('kind', 'type') -> ['id'];` }}
scenes(_, _) -> [].

{{ col . `scenes() -> ['id'].` }}

{{ row . `whole('id') -> 'whole';` }}
whole(_) -> false.

{{ with (filter . `eq kind 2`) }}
{{ row . `cluster('id') -> 'cluster';` }}
cluster(_) -> undefined.
{{ end }}