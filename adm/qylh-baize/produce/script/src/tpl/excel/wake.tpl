-include("wake.hrl").

{{ row . `find('career', 'wake_times') -> #cfg_wake{
	career     = 'career',
	wake_times = 'wake_times',
	open_level = 'open_level',
	level      = 'level',
	icon       = 'icon',
	title      = 'title',
	step       = 'step',
	name       = 'name',
	pic        = 'pic',
	res        = 'res',
	attribs    = 'attribs',
	skills     = 'skills',
	new_skills = 'new_skills',
	desc       = 'desc'
};` }}
find(_, _) -> undefined.
