{{ row . `find(Level) when 'minlv' =< Level, Level =< 'maxlv' ->
	{ 'power', 'viplv', 'rolelv'};` }}
find(_) ->
	undefined.
