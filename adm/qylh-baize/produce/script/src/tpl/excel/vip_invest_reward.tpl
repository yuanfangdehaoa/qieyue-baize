-include("vip.hrl").

{{ row . `find('type', 'id') -> #cfg_vip_invest_reward{
    grade  = 'grade',
    level  = 'level',
    reward = 'reward',
    bgold  = 'bgold'
};` }}
find(_, _) -> undefined.

{{ col . `all('type', 'grade') -> [{'id','level'}];`}}
all(_, _) -> [].

