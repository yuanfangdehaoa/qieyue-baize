-include("warrior.hrl").

{{ row . `find('floor') -> #cfg_warrior_floor{
	floor          = 'floor',
	kill_target    = 'kill_target',
	gain           = 'gain',
	cross_gain     = 'cross_gain',
	is_down        = 'is_down',
	prob           = 'prob',
	score          = 'score',
	kill_num       = 'kill_num',
	scene_id       = 'scene_id'
};` }}
find(_) -> undefined.

{{ col . `floors() -> ['floor']. `}}
