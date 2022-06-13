{{ row . `find(local, 'rank') -> 'reward';` }}
{{ row . `find(cross, 'rank') -> 'cross_reward';` }}
find(_, _) -> [].
