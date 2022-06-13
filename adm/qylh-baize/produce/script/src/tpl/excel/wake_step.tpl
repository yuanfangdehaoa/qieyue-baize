-include("wake.hrl").

{{ row . `find('wake_times', 'step') -> #cfg_wake_step{
wake_times = 'wake_times',
step       = 'step',
tasks      = 'tasks',
grid  	   = {'mingrid','maxgrid'}
};` }}
find(_, _) -> undefined.

{{ row . `get_step('wake_times', Grid) when Grid > 'mingrid', Grid < 'maxgrid'->
'step';` }}
get_step(_, _) -> undefined.


{{ gmax . `find_step('maxgrid') ->'step';` }}
find_step(_) -> undefined.
