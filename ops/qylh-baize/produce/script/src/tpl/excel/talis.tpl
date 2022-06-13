-include("train.hrl").

{{ row . `find('level') -> #cfg_train{
	level = 'level',
	exp   = 'exp',
	attrs = 'attrs',
	skill = 'skill'
};` }}
find(_) -> undefined.

max() -> {{ max . "level" }}.
