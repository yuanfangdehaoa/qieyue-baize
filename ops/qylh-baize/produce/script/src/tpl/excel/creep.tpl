-include("creep.hrl").
-include("proto.hrl").

{{ row . `find('id') -> #cfg_creep{
	id      = 'id',
	name    = 'name',
	kind    = 'kind',
	type    = 'type',
	rarity  = 'rarity',
	level   = 'level',
	guardarea = 'guardarea',
	guard   = 'guard',
	patrol  = 'patrol',
	pursue  = 'pursue',
	volume  = 'volume',
	reborn  = 'reborn',
	atktype = 'attack',
	atklag  = 'atklag',
	collect = 'collect',
	speed   = 'speed',
	immune  = 'immune',
	injure  = 'injure',
	heal    = 'heal',
	ai_id   = 'ai_id',
	exp     = 'exp',
	drops   = 'drops',
	rare1   = 'rare1_drops',
	rare2   = 'rare2_drops',
	mode    = 'mode',
	belong  = 'belong',
	skills1 = 'skills1',
	skills2 = 'skills2',
	bctype  = 'bctype',
	share   = 'share',
	scene   = 'scene_id',
	auto    = 'auto',
	opts    = 'opts'
};` }}
find(_) -> undefined.

{{ with (filter . `ne aiargs undefined` )}}
{{ row . `aiargs('id') -> ['aiargs'];` }}
aiargs(_) -> undefined.
{{ end }}

{{ col . `creeps('kind', 'rarity') -> ['id'];` }}
creeps(_, _) -> [].

{{ col . `creeps() -> ['id'].` }}
