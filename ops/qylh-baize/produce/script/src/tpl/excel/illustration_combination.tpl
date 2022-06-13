-include("illustration.hrl").

{{ row . `find('combination') -> #cfg_illustration_combination{
    illustrations = 'illustrations', 
    attr          = 'attr'
};` }}
find(_) -> undefined.

{{ col . `list() -> ['combination'].` }}
