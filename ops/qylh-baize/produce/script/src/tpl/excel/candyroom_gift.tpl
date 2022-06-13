-include("candyroom.hrl").

{{ row . `find('id') -> #cfg_candyroom_gift{name='name', pop='pop', msg_no='msg_no'};` }}
find(_) -> undefined.