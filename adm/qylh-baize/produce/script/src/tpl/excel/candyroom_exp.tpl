{{ row . `loop_exp(local, 'level') -> 'loop_exp';` }}
{{ row . `loop_exp(cross, 'level') -> 'cross_loop_exp';` }}
loop_exp(_, _) -> 0.

{{ row . `gift_exp(local, 'level') -> 'gift_exp';` }}
{{ row . `gift_exp(cross, 'level') -> 'cross_gift_exp';` }}
gift_exp(_, _) -> 0.