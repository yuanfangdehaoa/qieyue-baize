-include("vip.hrl").

{{ row . `find('day') -> #cfg_vip_mcard{
    type    = 'type',
    reward = 'reward'
};` }}
find(_) -> undefined.

{{ col . `all() -> ['day'].` }}