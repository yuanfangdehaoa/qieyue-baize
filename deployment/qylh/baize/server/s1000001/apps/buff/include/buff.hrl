-ifndef(BUFF_HRL).
-define(BUFF_HRL, ok).

%% 特殊buff
-define(BUFF_ID_AUTOHEAL, 110110002).
-define(BUFF_ID_OCCUPY, 120510001).

-record(cfg_buff, {
      id
    , name
    , type   % 类型 BUFF_TYPE_XXX
    , group  % 分组(最多同时存在一个分组相同的buff)
    , lap    % 同一分组的叠加方式 BUFF_LAP_XXX
    , level  % 等级
    , last   % 持续时长(秒)
    , tick   % 触发间隔
    , effect % 效果 BUFF_EFFECT_XXX
    , args   % 其他参数
    , vtype  % 值类型
    , value  % 值
    , attrs  % 属性
    , show   % 前端是否显示
    , notify % 是否通知前端战力变化
    , mirror % 是否保存到镜像
}).

-endif.