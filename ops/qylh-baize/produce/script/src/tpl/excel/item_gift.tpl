-include("item.hrl").

{{ row . `find('id') -> #cfg_item_gift{
    id       = 'id',
    type     = 'type',
    mul      = 'mul',
    reward   = 'reward',
    currency = 'currency',
    cost     = 'cost',
    notice   = 'notice'
};` }}
find(_) -> undefined.
