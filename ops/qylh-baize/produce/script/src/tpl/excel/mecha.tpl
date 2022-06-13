-include("mecha.hrl").

{{ row . `find('id') -> #cfg_mecha{
    id    = 'id',
    name  = 'name',
    color = 'color'
};` }}
find(_) -> undefined.

