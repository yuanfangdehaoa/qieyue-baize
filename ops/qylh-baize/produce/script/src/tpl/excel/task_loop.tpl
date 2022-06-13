{{ row . `loop_reward('type', RoleLv) when 'minlv' =< RoleLv, RoleLv =< 'maxlv' -> 'loop_reward';` }}
loop_reward(_, _) -> [].

{{ row . `extra_reward('type', RoleLv) when 'minlv' =< RoleLv, RoleLv =< 'maxlv' -> 'extra_reward';` }}
extra_reward(_, _) -> [].

{{ row . `npcs('type', RoleLv) when 'minlv' =< RoleLv, RoleLv =< 'maxlv' -> 'npcs';` }}
npcs(_, _) -> [].

{{ row . `creeps('type', RoleLv) when 'minlv' =< RoleLv, RoleLv =< 'maxlv' -> 'creeps';` }}
creeps(_, _) -> [].

{{ row . `creep_num('type', RoleLv) when 'minlv' =< RoleLv, RoleLv =< 'maxlv' -> 'creep_num';` }}
creep_num(_, _) -> 99.

{{ row . `scenes('type', RoleLv) when 'minlv' =< RoleLv, RoleLv =< 'maxlv' -> 'scenes';` }}
scenes(_, _) -> [].
