-include("totem.hrl").

{{ row . `find('id') -> #cfg_totem{
    name  = 'name',
    attr  = 'attr',
    skill = 'skill',
    slot  = 'slot',
    color = 'color'
};` }}
find(_) -> undefined.