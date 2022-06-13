-include("morph.hrl").

{{ row . `find('id', 'star') -> #cfg_morph_star{
	id    = 'id',
	star  = 'star',
	cost  = 'cost',
	attrs = 'attrs',
    power = 'power',
    skill = 'skill'
};` }}
find(_, _) -> undefined.

{{ gmax . `max('id') -> 'star';` }}
max(_) -> 0.

{{ with (filter . `ne skill []`) }}
{{ row . `skills('id') -> 'skill';` }}
skills(_) -> [].
{{ end }}
