-include("beast.hrl").

{{ row . `find('slot', 'level') -> #cfg_beast_reinforce{
    exp   = 'exp',
    total = 'total',
    base  = 'base'
};` }}
find(_, _) -> undefined.
