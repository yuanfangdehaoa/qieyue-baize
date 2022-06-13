-include("vip.hrl").

{{ row . `find('level') -> #cfg_vip_level{
	level  = 'level',
	exp    = 'exp',
	reward = 'reward',
	gift   = 'gift',
	gold   = 'max_gold',
	bgold  = 'max_bgold',
	vipexp = 'vip_exp',
	buffs  = 'buffs',
	attrs  = 'attrs'
};` }}
find(_) -> undefined.
