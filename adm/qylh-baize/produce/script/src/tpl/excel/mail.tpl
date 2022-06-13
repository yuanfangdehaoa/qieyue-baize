{{ row . `find('id') -> {'title', 'content'};` }}
find(_) -> undefined.

{{ row . `is_log('id') -> 'is_log';` }}
is_log(_) -> false.