-ifndef(CGW_HRL).
-define(CGW_HRL, ok).

-define(ETS_CGW_GUILDS, ets_cgw_guilds).
-record(cgw_guild, {
      id
    , name
    , power
    , chief
    , score
    , rival1 % 自己预约的对手
    , rival2 % 被谁预约
    , book1  % 已预约次数
    , book2  % 已被预约次数
    , book_time % 被预约时间
    , cost   % 预约需要扣除的分数
    , group  % 1=进攻方; 2=防守方
    , rank   % 排名
    , time   % 上榜时间
    , battle % #{Round=>#cgw_battle.id}
}).

-define(ETS_CGW_BATTLE, ets_cgw_battle).
-record(cgw_battle, {
      id
    , round   % 第几轮
    , atk_id  % 攻击方
    , atk_name
    , def_id  % 防守方
    , def_name
    , scene   % 场景pid
    , winner = 0 % 胜方
    , joined = [] % 参与活动的玩家 {RoleID,GuildID}
}).

-define(CGW_GROUP_ATKER, 2).
-define(CGW_GROUP_DEFER, 1).

-endif.
