{{ row . `find('key', 'islocal') -> 'val'; %% 'desc'` }}
find(_, _) -> undefined.
