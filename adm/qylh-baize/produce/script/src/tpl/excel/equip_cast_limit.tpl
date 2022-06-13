-include("equip.hrl").

{{ row . `max_level('order', 'color', 'star') -> 'level';` }}
max_level(_, _, _) -> 0.



