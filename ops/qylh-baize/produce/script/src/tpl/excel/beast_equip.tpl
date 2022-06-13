-include("beast.hrl").

{{ row . `find('id') -> #cfg_beast_equip{
    slot  = 'slot',
    star  = 'star',
    base  = 'base',
    rare1 = 'rare1',
    rare2 = 'rare2',
    exp   = 'exp'
};` }}
find(_) -> undefined.