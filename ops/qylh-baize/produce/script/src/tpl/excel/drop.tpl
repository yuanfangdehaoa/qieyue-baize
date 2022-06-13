-include("creep.hrl").

{{ row . `find('id', Level) when Level >= 'minlv', Level =< 'maxlv' -> #cfg_drop{
	id   = 'id',
	rule = 'rule',
	drop = 'drop'
};` }}
find(_, _) -> undefined.


{{ row . `find('id') -> {'rule', 'drop'};` }}
find(_) -> undefined.

{{ col . `drops() -> ['id'].` }}

{{ row . `seq2id('seq') -> 'id';` }}
seq2id(_) -> undefined.
