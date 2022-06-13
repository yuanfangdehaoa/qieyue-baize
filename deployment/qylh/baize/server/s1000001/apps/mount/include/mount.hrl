-ifndef(MOUNT_HRL).
-define(MOUNT_HRL, ok).

-record(mount, {
	  type
	, order = 0   % 阶位
	, level = 0   % 星级
	, exp   = 0   % 祝福值
	, train = #{} % key=ItemID, val=Level
}).

-record(cfg_mount, {
	  id
	, name
	, order
	, level
	, exp
	, speed
	, skill
}).

-endif.