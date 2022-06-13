{{ col . `unlock_artifact('type') -> 'unlock';` }}
unlock_artifact(_) -> [].

{{ col . `artifacts('type') -> ['aid'];` }}
artifacts(_) -> [].


{{ row . `unlock_enchant('aid') -> {'unlock1', 'unlock2', 'unlock3', 'unlock4'};` }}
unlock_enchant(_) -> undefined.

{{ row . `artifact_name('aid') -> 'name';` }}
artifact_name(_) -> "".

{{ col . `artifact_typename('type') -> 'will_name';` }}
artifact_typename(_) -> "".
