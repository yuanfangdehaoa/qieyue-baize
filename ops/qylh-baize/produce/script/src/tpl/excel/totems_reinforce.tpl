-include("totem.hrl").

{{ row . `find('slot', 'level') -> #cfg_totem_reinforce{
    exp   = 'exp',
    total = 'total',
    base  = 'base'
};` }}
find(_, _) -> undefined.
