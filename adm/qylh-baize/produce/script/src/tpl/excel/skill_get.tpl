-include("skill.hrl").

{{ row . `find('career', 'level') -> 'skill_ids';` }}
find(_, _) -> [].

{{ col . `skills('career') -> ['level'];` }}
skills(_) -> [].