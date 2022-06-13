-include("chat.hrl").

{{ row . `find(OpenDays) when OpenDays >= 'day_min' andalso OpenDays =< 'day_max' -> 'contents';` }}
find(_) -> [].
