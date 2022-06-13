-ifndef(SKILL_HRL).
-define(SKILL_HRL, ok).

-record(cfg_skill, {
      id      % 技能id
    , name    % 技能名称
    , type    % 技能类型 SKILL_TYPE_XXX
    , group   % 技能分组 SKILL_GROUP_XXX
    , gender  % 所需性别
    , career  % 所需职业
    , wake    % 所需觉醒次数
    , aim     % 施法目标 SKILL_AIM_XXX
    , is_hit  % 是否必中
    , center  % 攻击点
    , is_hew  % 是否普攻
    , pos     % 制定位置
    , auto    % 设置自动释放
    , ctrl    % 是否受控制状态限制
}).

-record(cfg_skill_level, {
      id
    , level   % 技能等级
    , exp     % 熟练度(升到下级)
    , reqs    % 学习条件
    , learn   % 升级消耗
    , attrs   % 技能属性
    , buffs   % 技能buff
    , power   % 技能战力
    , cd      % cd时间
    , play    % 播放时间
    , amp     % 技能伤害倍率
    , area    % 攻击范围 SKILL_AREA_XXX
    , center  % 作用点
    , dist    % 攻击距离
    , radius  % 半径|角度|宽度
    , cover   % {攻击人数, 攻击怪物数}
    , trigger % 技能触发条件
    , abuffs  % 触发的buff [{BuffID, Cond, Prob, EffNum}]
    , dbuffs  % 触发的buff [{BuffID, Cond, Prob, EffNum}]
    , effect  % 技能效果
}).


%技能面板配置
-record(cfg_skill_show, {
      id          %技能id
    , career      %职业
    , type        %技能显示分类(1-主动，2-被动)
    , sort        %排序
}).

-endif.