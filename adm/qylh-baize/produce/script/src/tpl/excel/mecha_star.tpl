-include("mecha.hrl").

{{ row . `find('id', 'star') -> #cfg_mecha_star{
    id    = 'id',
    star  = 'star',
    cost  = 'cost',
    attrs = 'attrs',
    power = 'power',
    skill = 'skill'
};` }}
find(_, _) -> undefined.

{{ gmax . `max('id') -> 'star';` }}
max(_) -> 0.
