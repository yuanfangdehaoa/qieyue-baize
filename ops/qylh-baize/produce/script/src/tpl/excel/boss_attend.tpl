{{ row . `find('id', 'rank') -> 'reward';` }}
find(_, _) -> [].

{{ col . `has_reward('id') -> true;` }}
has_reward(_) -> false.
