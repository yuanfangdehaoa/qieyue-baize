-ifndef(CREEP_HRL).
-define(CREEP_HRL, ok).

-record(cfg_creep, {
      id
    , name
    , kind    % 怪物种类
    , type    % 怪物类型
    , rarity  % 稀有度 0=普通怪,1=精英怪,2=boss怪
    , level   % 怪物等级
    , guardarea % 警戒范围 grid | scene
    , guard   % 警戒半径
    , patrol  % 巡逻半径
    , pursue  % 追击半径
    , volume  % 体积半径
    , reborn  % 重生时间
    , atktype % 攻击类型 1=近战,2=远程
    , atklag  % 攻击间隔
    , collect % 采集时长
    , speed   % 移动速度
    , immune  % 是否免疫控制
    , injure  % 伤害类型
    , heal    % 回血速度
    , ai_id   % 怪物ai
    , exp     % 掉落经验
    , drops   % 掉落列表 [{DropID, Num}]
    , rare1   % 珍稀掉落1
    , rare2   % 珍稀掉落2
    , mode    % 掉落模式
    , belong  % 掉落归属
    , skills1 % 普攻技能列表 [{SkillID, Weight}]
    , skills2 % Boss技能列表 [SkillID]
    , bctype  % 广播类型
    , share   % 击杀分享模式 0=最后一击才算击杀; 1=有过伤害就算击杀
    , scene
    , auto    % 是否自动生成
    , opts    % 其他参数
}).

-record(cfg_drop, {
      id
    , desc
    , rule
    , drop
}).

-endif.