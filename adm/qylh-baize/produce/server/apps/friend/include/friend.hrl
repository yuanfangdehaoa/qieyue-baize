-ifndef(FRIEND_HRL).
-define(FRIEND_HRL, ok).

-record(friend_info, {
      id
    , relation       = 1 % 1：陌生人；2：好友；3：黑名单
    , is_enemy       = false % 是否敌人
    , intimacy       = 0 % 亲密度
}).

-record(cfg_flower, {
      id
    , intimacy      % 亲密度
    , charm         % 魅力值
    , cost          % 消耗
    , first_reward  % 首次奖励
    , reward        % 奖励
    , broadcast     % 广播消息
}).

-endif.