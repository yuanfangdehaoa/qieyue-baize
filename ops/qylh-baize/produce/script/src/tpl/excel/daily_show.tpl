-include("daily.hrl").

{{ row . `find('level') -> #cfg_daily_show{group = 'group', activation = 'activation', attr = 'attr'};` }}
find(_) -> undefined.
