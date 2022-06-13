-include("enum.hrl").

{{ row . `find('id', 'level') -> #{
	?ATTR_HP       => 'hpmax',
	?ATTR_HPMAX    => 'hpmax',
	?ATTR_ATT      => 'att',
	?ATTR_DEF      => 'def',
	?ATTR_WRECK    => 'wreck',
	?ATTR_MISS     => 'miss',
	?ATTR_HIT      => 'hit',
	?ATTR_HOLY_ATT => 'holy_att',
	?ATTR_HOLY_DEF => 'holy_def',
	?ATTR_CRIT     => 'crit',
	?ATTR_TOUGH    => 'tough',
	?ATTR_HIT_PRO  => 'hit_pro'
};` }}
find(_, _) -> undefined.

{{ row . `exp('id', 'level') -> 'exp';` }}
exp(_, _) -> 0.
