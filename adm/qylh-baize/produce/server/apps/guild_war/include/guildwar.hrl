-ifndef(GUILDWAR_HRL).
-define(GUILDWAR_HRL, ok).

-define(ETS_GW_FIELD, ets_gw_field).

-define(ETS_GW_GUILD, ets_gw_guild).

-define(ETS_GW_CRYST, ets_gw_cryst).
-record(gw_cryst, {
	  id     % {FieldID, CrystID}
	, owner
	, time
	, coord
}).

-define(ETS_GW_ROLE, ets_gw_role).
-record(gw_role, {
	  id         % 玩家id
	, name       % 玩家名称
	, guild      % 所属帮派
	, gname      % 帮派名称
	, field      % 所在战区
	, kill   = 0 % 击杀数量
	, dead   = 0 % 死亡次数
	, occupy = 0 % 占领数量
	, score  = 0 % 积分
	, rank   = 0 % 排名
}).

-record(gw_result, {
	  winner  = 0 % 主宰帮派id
	, victory = 0 % 连胜次数
	, v_allot = 0 % 连胜次数奖励分配 RoleID
	, breakup = 0 % 连胜击败
	, b_allot = 0 % 连胜击败奖励分配 RoleID
}).


%% 分组
-record(gw_divide, {
	  group = #{} % key=FieldID, val=[Player]
	, field = #{} % key=PlayerID, val=FieldID
}).

-endif.