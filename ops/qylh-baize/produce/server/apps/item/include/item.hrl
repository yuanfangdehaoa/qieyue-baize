-ifndef(ITEM_HRL).
-define(ITEM_HRL, ok).

-record(cfg_item, {
      id
    , name
    , bag           % 所属背包(当道具进背包时，进哪个背包)
    , depot         % 所属仓库(将道具放仓库时，放哪个仓库)
    , type          % 类型
    , stype         % 子类型
    , color         % 颜色
    , level         % 道具等级
    , lap           % 叠加数量
    , bind          % 是否绑定
    , career        % 职业限制
    , level_limit   % 等级限制
    , vip_limit     % vip限制
    , money         % 出售价格类型
    , price         % 出售价格
    , chuck         % 是否可丢弃
    , trade         % 是否可交易
    , effect        % 使用效果
    , expire        % 过期时间(秒)
    , notify        % 公告
}).

-record(cfg_item_gift, {
      id
    , type
    , mul       % 多选
    , reward    % 奖励内容
    , currency  % 货币内容
    , cost      % 消耗
    , notice    % 公告
}).

-record(cfg_item_monitor, {
      item_id    %
    , start_time % 监控开始
    , end_time   % 监控结束
    , alert      % 警告数量
    , exception  % 异常数量
}).

-record(cfg_exp_acti_base, {role_exp, world_exp}).

-endif.