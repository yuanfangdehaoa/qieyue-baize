-include("weekly.hrl").

{{ row . `find('id') -> #cfg_weekly_reward{activation = 'activation', reward = 'reward'};` }}
find(_) -> undefined.
