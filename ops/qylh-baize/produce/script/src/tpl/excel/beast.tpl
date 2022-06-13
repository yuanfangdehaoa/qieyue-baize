-include("beast.hrl").

{{ row . `find('id') -> #cfg_beast{
    name  = 'name',
    attr  = 'attr',
    skill = 'skill',
    slot  = 'slot',
    color = 'color'
};` }}
find(_) -> undefined.