-ifndef(TIMEBOSS_HRL).
-define(TIMEBOSS_HRL, ok).

-define(ETS_TIMEBOSS, ets_timeboss).
-record(timeboss, {
	  key          % {SceneID, RoomID}
	, boss         % BossID
	, type         % BossType
	, born   = 0   % 出生时间
	, tomb   = 0   % 墓碑id
	, box    = 0   % 宝箱id
	, care   = []  % [RoleID]
	, role   = 0   % 场景人数
	, owners = []  % 击杀信息 [{SUID, RoleID, Name}]
	, opened = #{} % 开启信息 #{RoleID=>Times}
}).

-record(timeboss_dice, {
	  dice_etime
	, dice_result % #{RoleID=>Score}
	, max_score
	, owner_id
	, owner_name
}).

-define(ETS_TIMEBOSS_ENTRY, ets_timeboss_entry).
-record(timeboss_entry, {
	  key   % {SceneID, SUID}
	, room
}).

-record(cfg_timeboss, {
	  id
	, name
	, kind
	, type
	, floor
	, scene
	, coord
	, room
	, shield   % 破盾奖励
}).

-record(cfg_timeboss_box, {
	  id
	, coord % 宝箱位置
	, reqs  % 宝箱开启条件
	, times % 宝箱奖励次数
}).

-endif.