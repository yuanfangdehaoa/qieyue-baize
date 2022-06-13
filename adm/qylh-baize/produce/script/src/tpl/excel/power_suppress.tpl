{{ row . `role_2_creep('rarity', DiffPower) when DiffPower >= 'min_power', DiffPower =< 'max_power' -> 'role2creep';` }}
role_2_creep(_, _) -> 10000.

{{ row . `creep_2_role('rarity', DiffPower) when DiffPower >= 'min_power', DiffPower =< 'max_power' -> 'creep2role';` }}
creep_2_role(_, _) -> 10000.
