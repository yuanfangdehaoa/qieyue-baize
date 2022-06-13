{{ row . `find('lv') -> 'reward';` }}
find(_) -> undefined.

{{ scol . `all() -> ['lv'].` "lv" false }}

max() -> {{ max . "lv" }}.