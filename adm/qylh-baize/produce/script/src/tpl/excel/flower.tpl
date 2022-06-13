-include("friend.hrl").

{{ row . `find('id') -> #cfg_flower{
    id           = 'id',
    intimacy     = 'intimacy',
    charm        = 'charm',
    cost         = 'cost',
    first_reward = 'first_reward',
    reward       = 'reward',
    broadcast    = 'broadcast'
};` }}
find(_) -> undefined.
