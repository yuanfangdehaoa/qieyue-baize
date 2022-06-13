-include("item.hrl").

{{ row . `find('lv') -> #cfg_exp_acti_base{role_exp = 'player_exp', world_exp = 'worldlv_exp'};` }}
find(_) -> undefined.
