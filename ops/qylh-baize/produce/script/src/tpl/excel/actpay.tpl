-include("actpay.hrl").

{{ row . `find('id') -> #cfg_actpay{opdays='opdays', pay='pay'};` }}
find(_) -> undefined.

{{ col . `all() -> ['id'].` }}
