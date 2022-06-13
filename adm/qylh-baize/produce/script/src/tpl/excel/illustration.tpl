-include("illustration.hrl").

{{ row . `find('id') -> #cfg_illustration{
    name     = 'name',
    max_star = 'max_star',
    color    = 'color'
};` }}
find(_) -> undefined.
