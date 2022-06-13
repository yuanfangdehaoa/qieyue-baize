-include("marriage.hrl").

{{ row . `find('type') -> #cfg_marriage_type{
    name    = 'name', 
    reward  = 'reward',
    title   = 'title',
    cost    = 'cost',
    wcount  = 'wcount'
};` }}
find(_) -> undefined.
