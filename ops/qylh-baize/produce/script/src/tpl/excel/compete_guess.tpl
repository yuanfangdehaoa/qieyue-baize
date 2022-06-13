-include("compete.hrl").

{{ row . `find('type', 'islocal') -> #cfg_compete_guess{
	type  = 'type',
	cost  = 'cost',
	right = 'right',
	wrong = 'wrong'
};` }}
find(_, _) -> undefined.
