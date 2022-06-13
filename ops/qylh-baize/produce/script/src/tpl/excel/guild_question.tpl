-include("guild_house.hrl").

{{ row . `answer('id') -> 'answer';` }}
answer(_) -> undefined.

{{ col . `ids() -> ['id']. `}}
