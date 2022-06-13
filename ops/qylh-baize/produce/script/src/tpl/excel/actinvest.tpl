-include("actinvest.hrl").

{{ row . `find('id') -> #cfg_actinvest{name='name', cycle='cycle', days='days', time='time', pay='pay', panel='panel'};` }}
find(_) -> undefined.

{{ col . `all() -> ['id'].` }}
