-include("daily.hrl").

{{ row . `find('id') -> #cfg_daily_reward{activation = 'activation', reward = 'reward'};` }}
find(_) -> undefined.
