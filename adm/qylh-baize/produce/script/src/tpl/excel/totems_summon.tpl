-include("totem.hrl").

{{ row . `find('slot') -> #cfg_totem_summon{
    restrict = 'restrict',
    cost     = 'cost'
};` }}
find(_) -> undefined.
