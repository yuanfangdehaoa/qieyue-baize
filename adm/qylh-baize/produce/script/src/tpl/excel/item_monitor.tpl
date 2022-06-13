-include("item.hrl").

{{ row . `find('id') -> #cfg_item_monitor{
    item_id    = 'item_id',
    start_time = 'start_time',
    end_time   = 'end_time',
    alert      = 'alert',
    exception  = 'exception'
};` }}
find(_) -> undefined.

{{ col . `monitor('item_id') -> ['id'];` }}
monitor(_) -> [].
