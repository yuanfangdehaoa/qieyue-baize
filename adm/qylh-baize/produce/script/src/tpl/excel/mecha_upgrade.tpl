-include("mecha.hrl").

{{ row . `find('id', 'level') -> #cfg_mecha_upgrade{
    level = 'level',
    exp   = 'exp',
    attrs = 'attrs'
};` }}
find(_, _) -> undefined.

{{ gmax . `max('id') -> 'level';` }}
max(_) -> 0.
