{{ col . `suits('pet_id') -> ['id'];` }}
suits(_) -> [].

{{ row . `limit('pet_id', 'id') -> {'com_color', 'com_star'};`}}
limit(_, _) -> undefined.

{{ row . `attr('pet_id', 'id') -> 'attr';` }}
attr(_, _) -> [].
