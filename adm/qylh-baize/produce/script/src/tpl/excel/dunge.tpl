-include("dunge.hrl").

{{ row . `find('id') -> #cfg_dunge{
	id     = 'id',
	scene  = 'scene',
	name   = 'name',
	level  = 'level',
	type   = 'type',
	stype  = 'stype',
	floor  = 'floor',
	power  = 'power',
	last   = 'last',
	ai_id  = 'ai',
	aiargs = 'complete'
};` }}
find(_) -> undefined.

{{ row . `reward('id') -> #cfg_dunge_reward{
	id     = 'id',
	first  = 'reward_first',
	fixed  = 'reward_fixed',
	random = 'reward_random'
};` }}
reward(_) -> undefined.

{{ with (distinct . "stype") }}
{{ row . `enter('stype') -> #cfg_dunge_enter{
	id    = 'id',
	times = 'enter_times',
	cd    = 'cd',
	clrcd = 'clearcd',
	buy   = 'enter_buy'
};` }}
enter(_) -> undefined.

{{ row . `sweep('stype') -> #cfg_dunge_sweep{
	id    = 'id',
	reqs  = 'sweep_reqs',
	times = 'sweep_times',
	cost  = 'sweep_cost'
};` }}
sweep(_) -> undefined.

{{ row . `cd('stype') -> #cfg_dunge_cd{
	id   = 'id',
	prep = 'prep',
	stat = 'stat_cd',
	exit = 'exit_cd'
};` }}
cd(_) -> undefined.
{{ end }}

{{ scol . `dunge('stype') -> ['id'];` "id" false }}
dunge(_) -> [].
