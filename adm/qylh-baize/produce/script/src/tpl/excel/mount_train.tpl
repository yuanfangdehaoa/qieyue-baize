{{ row . `attrs('item_id') -> 'attrs';` }}
attrs(_) -> [].

{{ row . `limit('item_id') -> 'limit';` }}
limit(_) -> undefined.

{{ col . `all() -> ['item_id'].` }}
