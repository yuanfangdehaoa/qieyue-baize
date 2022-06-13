-include("faker.hrl").
-include("proto.hrl").

{{ row . `find('id') -> #cfg_faker{
    id     = 'id',
    name   = 'name',
    career = 'career',
    gender = 'gender',
    level  = 'level',
    viplv  = 'viplv',
    figure = 'figure',
    coef   = 'coef'
};` }}
find(_) -> undefined.

{{ col . `list() -> ['id'].` }}

{{ col . `gender('gender') -> ['id'];` }}
gender(_) -> [].
