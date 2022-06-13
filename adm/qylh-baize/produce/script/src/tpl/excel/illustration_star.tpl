-include("illustration.hrl").

{{ row . `find('id', 'star') -> #cfg_illustration_star{
    item    = 'item', 
    essence = 'essence', 
    attr    = 'attr',
    notify  = 'notify'
};` }}
find(_, _) -> undefined.
