-ifndef(FIGHT_HRL).
-define(FIGHT_HRL, ok).

%% 攻击参数
-record(attack, {
	  atker % 攻击方   ActorID
    , unit  % 攻击单位 ATTACK_UNIT_XXX
    , skill % #skill
    , dir   % 朝向
	, major % 锁定目标 ActorID
    , coord % 目标坐标
    , time  % 攻击时间(毫秒)
	, endcd % cd结束时间(毫秒)
    , seq   % 序列号(前端用)
    , opts  % 选项参数
}).

%% 技能数据
-record(skill, {
      id     % 技能id
    , level  % 技能等级
    , is_hew % 是否普攻
    , aim    % 施法目标 SKILL_AIM_XXX
    , is_hit % 是否必中
    , cd     % cd时间
    , amp    % 技能伤害倍率
    , area   % 攻击范围 SKILL_AREA_XXX
    , center % 攻击点
    , dist   % 攻击距离
    , radius % 半径|角度|宽度
    , cover  % {攻击人数, 攻击怪物数}
    , abuffs % 触发的buff [{BuffID, Cond, Prob, EffNum}]
    , dbuffs % 触发的buff [{BuffID, Cond, Prob, EffNum}]
    , effect % 技能效果
    , group  % 技能分组
}).

-record(fight, {
      atker
    , atk_attr       % 攻击方临时加的属性
    , defer
    , def_attr       % 受击方临时加的属性
    , damage
    , buff_num = #{} % key=BuffID, val=作用人数
    , damages  = []  %
    , results  = []  % [{Atker, Defer, DmgVal}]
    , immune   = []  % 免疫控制 [BuffEffect]
    , major_id       % 主目标id
}).

-record(damage, {
      uid
    , unit
    , coord
    , hp
    , type
    , value
    , state
    , bctype
}).

%% 掉落
-record(drop, {
	  id     :: integer()  % 道具id
	, num    :: integer()  % 道具数量
	, opts   :: map()      % 道具定制参数
    , coord  :: tuple()    % #p_coord
    , owner  :: integer()  % 所属怪物 ActorID
    , creep  :: integer()  % 所属怪物 CreepID
    , belong :: list()     % 归属列表([]表示无归属)
    , killer :: integer()  % 怪物击杀者
    , tired  :: list()     % 归属者当时的疲劳值
}).

-endif.