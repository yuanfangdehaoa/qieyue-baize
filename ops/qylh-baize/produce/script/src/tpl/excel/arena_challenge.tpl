-include("arena.hrl").

{{ row . `find('level') -> #cfg_arena_challenge{win='win', lose='lose'};` }}
find(_) -> undefined.
