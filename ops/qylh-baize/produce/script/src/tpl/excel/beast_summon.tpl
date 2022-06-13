-include("beast.hrl").

{{ row . `find('slot') -> #cfg_beast_summon{
    restrict = 'restrict',
    cost     = 'cost'
};` }}
find(_) -> undefined.
