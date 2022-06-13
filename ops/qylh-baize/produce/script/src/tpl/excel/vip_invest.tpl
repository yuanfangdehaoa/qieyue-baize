
{{ row . `find('type', 'grade') -> 'price';`}}
find(_, _) -> undefined.

max_type() -> {{ max . "type" }}.

max_grade() -> {{ max . "grade" }}.