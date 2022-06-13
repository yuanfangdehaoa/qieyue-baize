-include("mount.hrl").

{{ row . `id('order', 'level') -> 'id';` }}
id(_, _) -> 0.

{{ row . `find('order', 'level') -> #cfg_mount{
	name  = 'name',
	order = 'order',
	level = 'level',
	exp   = 'exp',
	speed = 'speed',
	skill = 'skill'
};` }}
find(_, _) -> undefined.

{{ row . `attrs('order', 'level') -> 'attrs';` }}
attrs(_, _) -> [].

max_order() -> {{ max . "order" }}.

{{ gmax . `max_level('order') -> 'level';` }}
max_level(_) -> 0.

{{ gmax . `res('order') -> 'model';` }}
res(_) -> [].
