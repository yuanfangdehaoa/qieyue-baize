-include("pet.hrl").

{{ row . `find('id') -> #cfg_pet{
	id        = 'id',
	name      = 'name',
	order     = 'order',
	wake      = 'wake',
	level     = 'level',
	evolution = 'evolution',
	base      = 'base',
	count     = 'count',
	rare1     = 'rare1',
	rare2     = 'rare2',
	rare3     = 'rare3',
	gain      = 'gain',
	atk       = 'atk',
	quality   = 'quality'
};` }}
find(_) -> undefined.