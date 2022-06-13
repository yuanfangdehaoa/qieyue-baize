-include("totem.hrl").

{{ row . `find('id') -> #cfg_totem_equip{
    slot  = 'slot',
    star  = 'star',
    base  = 'base',
    rare1 = 'rare1',
    rare2 = 'rare2',
    exp   = 'exp'
};` }}
find(_) -> undefined.