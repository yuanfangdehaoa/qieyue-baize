{{ row . `role_2_creep('rarity', DiffLv) when DiffLv >= 'min_lv', DiffLv =< 'max_lv' -> 'role2creep';` }}
role_2_creep(_, _) -> 10000.

{{ row . `creep_2_role('rarity', DiffLv) when DiffLv >= 'min_lv', DiffLv =< 'max_lv' -> 'creep2role';` }}
creep_2_role(_, _) -> 10000.
