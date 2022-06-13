{{ row . `price('id') -> 'price';` }}
price(_) -> undefined.

{{ row . `gain('id') -> 'diamand_num';` }}
gain(_) -> undefined.

{{ row . `rebate('id') -> 'extra_num';` }}
rebate(_) -> undefined.

{{ row . `rebate2('id') -> 'extra_num2';` }}
rebate2(_) -> undefined.

{{ with (filter . `ne ispay false`) }}
{{ row . `rebate_by_price('price') -> {'id', 'extra_num'};` }}
{{ end }}
rebate_by_price(_) -> {0, []}.

{{ row . `ispay('id') -> 'ispay';` }}
ispay(_) -> false.

{{ col . `all() -> ['id'].` }}
