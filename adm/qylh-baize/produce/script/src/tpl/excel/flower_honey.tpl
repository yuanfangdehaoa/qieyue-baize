-include("friend.hrl").

{{ row . `buff_ids(Intimacy) when Intimacy >= 'honey' andalso Intimacy < 'honey_max' ->
	'buff';` }}
buff_ids(_) -> undefined.

{{ col . `all_buff_ids() -> ['buff'].` }}
