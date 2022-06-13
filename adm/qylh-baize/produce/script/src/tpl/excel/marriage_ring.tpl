-include("marriage.hrl").

{{ row . `find('grade', 'level') -> #cfg_marriage_ring{
    grade = 'grade', 
    level = 'level',
    exp   = 'exp',
    ring  = 'ring'
};` }}
find(_, _) -> undefined.
