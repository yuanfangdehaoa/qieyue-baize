-ifndef(CHAT_HRL).
-define(CHAT_HRL, ok).


-define(chat_off_msg, {'@off_msg', RoleId}).
-define(chat_items, 'chat_items').
-define(CHAT_OFF_MSG_NUM, 3).

%% 禁言
-record(chat_silent, {
      role_ids = [] %封禁的玩家ID
}).

-record(state, {id=0}).

%机器人聊天
-record(cfg_faker_world_chat, {
	  id
	, day_min
	, day_max
	, contents
}).

-record(cfg_faker_world_content, {
	  id
	, level
	, vip
	, content
}).

-endif.