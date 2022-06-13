-include("welfare.hrl").

{{ row . `find('count') -> #cfg_welfare_sign_count{
	count  = 'count',
	active = 'active'
};` }}
find(_) -> undefined.
