-include("rank.hrl").

{{ row . `%%%% 'desc'
find('id') -> #cfg_rank{
	id        = 'id',
    mode      = 'mode',
	type      = 'ranktype',
	size      = 'size',
	page_size = 'page_size',
	limen     = 'limen',
	event     = 'event',
	actid     = 'actid',
	copy      = 'copy',
	rank_limen = 'rank_limen'
};` }}
find(_) -> undefined.

{{ col . `all() -> ['id'].` }}

{{ with (filter . "eq mode server") }}
{{ col . `local() -> ['id'].` }}
{{ end }}

{{ with (filter . "eq mode cross") }}
{{ col . `cross() -> ['id'].` }}
{{ end }}

{{ col . `events() -> [{'event', 'args', 'id'}].` }}
