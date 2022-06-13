-include("afk.hrl").

{{ row . `find(Level) when 'minlv' =< Level, Level =< 'maxlv'  -> #cfg_afk{
    creep      = 'creep',
    fight      = 'fight',
    exp        = 'exp',
    atk        = 'atk',
    show_robot = 'show_robot'
};` }}
find(_) -> undefined.
