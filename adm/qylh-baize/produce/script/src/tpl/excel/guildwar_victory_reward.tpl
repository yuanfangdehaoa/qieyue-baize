{{ row . `victory_reward('times') -> 'victory';` }}
victory_reward(_) -> [].

{{ row . `breakup_reward('times') -> 'breakup';` }}
breakup_reward(_) -> [].

{{ row . `against_buffs('times') -> 'buff';` }}
against_buffs(_) -> [].