{{ row . `reward('id') -> 'reward';` }}
reward(_) -> [].

{{ col . `weight('type') -> [{'id', 'tower', 'opened', 'wt', 'wt_add'}];` }}
weight(_) -> [].
