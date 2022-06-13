-include("equip.hrl").

{{ row . `find('id') -> #cfg_equip{
	id       = 'id',
	slot     = 'slot',
	order    = 'order',
	star     = 'star',
	career   = 'career',
	wake     = 'wake',
	base     = 'base',
	rare1    = 'rare1',
	rare2    = 'rare2',
	rare3    = 'rare3',
	rare4 	 = 'rare4'
};` }}
find(_) -> undefined.

{{ with (filter . `gt donate_score 0`)}}
{{ row . `donate('id') -> 'donate_score';` }}
donate(_) -> 0.
{{ end }}

{{ with (filter . `gt exp 0`)}}
{{ row . `smelt_exp('id') -> 'exp';` }}
smelt_exp(_) -> 0.
{{ end }}

{{ col . `equips('order') -> ['id'];` }}
equips(_) -> [].
