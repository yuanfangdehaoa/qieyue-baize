-ifndef(SCENE_HRL).
-define(SCENE_HRL, ok).
-include("enum.hrl").
-define(LOOP_MILLIS, 200).

-define(DELAY_STOP, 30).

% 像素坐标 -> tile坐标
-define(TILE_WIDTH , 20).
-define(TILE_HEIGHT, 20).

-define(MAIN_LINE, 1).

% 怪物ai调度优先级
-define(MAX_PRIOR, 1000000).

-define(tile(Coord), ?tile(Coord#p_coord.x, Coord#p_coord.y)).
-define(tile(X, Y), {
    ut_math:floor(X / ?TILE_WIDTH),
    ut_math:floor(Y / ?TILE_HEIGHT)
}).

-define(GRID_WIDTH , 700).
-define(GRID_HEIGHT, 400).

-define(grid(Coord), ?grid(Coord#p_coord.x, Coord#p_coord.y)).
-define(grid(X, Y), {
    ut_math:floor(X / ?GRID_WIDTH),
    ut_math:floor(Y / ?GRID_HEIGHT)
}).


%% #actor.type
-define(is_role(Actor) , (Actor#actor.type == ?ACTOR_TYPE_ROLE)).
-define(is_creep(Actor), (Actor#actor.type == ?ACTOR_TYPE_CREEP)).
-define(is_robot(Actor), (Actor#actor.type == ?ACTOR_TYPE_ROBOT)).

%% #actor.kind
-define(is_monst(Actor), (Actor#actor.kind == ?CREEP_KIND_MONSTER)).
-define(is_coll(Actor), (Actor#actor.kind == ?CREEP_KIND_COLLECT)).
-define(is_tomb(Actor), (Actor#actor.kind == ?CREEP_KIND_TOMB)).

%% #actor.rarity
-define(is_elite(Actor), (Actor#actor.rarity == ?CREEP_RARITY_ELITE)).
-define(is_boss(Actor), (Actor#actor.rarity == ?CREEP_RARITY_BOSS)).
-define(is_hunt(Actor), (Actor#actor.rarity == ?CREEP_RARITY_HUNT)).
-define(is_guild_boss(Actor), (Actor#actor.rarity == ?CREEP_GUILD_BOSS)).
-define(is_afk(Actor), (Actor#actor.rarity == ?CREEP_RARITY_AFK)).
-define(is_faker(Actor), (Actor#actor.rarity == ?CREEP_RARITY_FAKER)).
-define(is_boss2(Actor), (Actor#actor.rarity == ?CREEP_RARITY_BOSS2)).
-define(is_timeboss(Actor), (Actor#actor.rarity == ?CREEP_RARITY_TIMEBOSS)).
-define(is_siegeboss(Actor), (Actor#actor.rarity == ?CREEP_RARITY_SIEGEBOSS)).
-define(is_throneboss(Actor), (Actor#actor.rarity == ?CREEP_RARITY_THRONE)).
-define(is_cgw_crystal(Actor), Actor#actor.rarity == ?CREEP_RARITY_CGW_CRYSTAL).
-define(is_cgw_statue(Actor), Actor#actor.rarity == ?CREEP_RARITY_CGW_STATUE).

-define(is_city_scene(SceneSt), (SceneSt#scene_st.type == ?SCENE_TYPE_CITY)).
-define(is_field_scene(SceneSt), (SceneSt#scene_st.type == ?SCENE_TYPE_FIELD)).
-define(is_boss_scene(SceneSt), (SceneSt#scene_st.type == ?SCENE_TYPE_BOSS)).
-define(is_dunge_scene(SceneSt), (SceneSt#scene_st.type == ?SCENE_TYPE_DUNGE)).
-define(is_act_scene(SceneSt), (SceneSt#scene_st.type == ?SCENE_TYPE_ACT)).

%% 判断 actor 状态
-define(is_death(State)     , ((State band 2#00000000000000000000000000000001) > 0)). % 死亡
-define(is_zazen(State)     , ((State band 2#00000000000000000000000000000010) > 0)). % 打坐
-define(is_collect(State)   , ((State band 2#00000000000000000000000000000100) > 0)). % 采集
-define(is_occupy(State)    , ((State band 2#00000000000000000000000000001000) > 0)). % 占用
-define(is_convey(State)    , ((State band 2#00000000000000000000000000010000) > 0)). % 运送
-define(is_unbeat(State)    , ((State band 2#00000000000000000000000000100000) > 0)). % 无敌
-define(is_dizzy(State)     , ((State band 2#00000000000000000000000001000000) > 0)). % 眩晕
-define(is_silent(State)    , ((State band 2#00000000000000000000000010000000) > 0)). % 沉默
-define(is_chaos(State)     , ((State band 2#00000000000000000000000100000000) > 0)). % 混乱
-define(is_immob(State)     , ((State band 2#00000000000000000000001000000000) > 0)). % 定身
-define(is_palsy(State)     , ((State band 2#00000000000000000000010000000000) > 0)). % 麻痹
-define(is_shield(State)    , ((State band 2#00000000000000000000100000000000) > 0)). % 护盾
-define(is_petmorph(State)  , ((State band 2#00000000000000000001000000000000) > 0)). % 宠物变身
-define(is_leech(State)     , ((State band 2#00000000000000000010000000000000) > 0)). % 吸血
-define(is_decay(State)     , ((State band 2#00000000000000000100000000000000) > 0)). % 掉落衰减
-define(is_dance(State)     , ((State band 2#00000000000000001000000000000000) > 0)). % 跳舞
-define(is_bleed(State)     , ((State band 2#00000000000000010000000000000000) > 0)). % 流血
-define(is_unyield(State)   , ((State band 2#00000000000000100000000000000000) > 0)). % 不屈
-define(is_slow(State)      , ((State band 2#00000000000001000000000000000000) > 0)). % 减速
-define(is_lei_gc(State)    , ((State band 2#00000000000010000000000000000000) > 0)). % 雷*攻潮
-define(is_bing_kj(State)   , ((State band 2#00000000000100000000000000000000) > 0)). % 冰*铠甲
-define(is_you_gc(State)    , ((State band 2#00000000001000000000000000000000) > 0)). % 幽*攻潮
-define(is_huan_ls(State)   , ((State band 2#00000000010000000000000000000000) > 0)). % 幻*灵闪
-define(is_immune(State)    , ((State band 2#00000000100000000000000000000000) > 0)). % 免疫
-define(is_mechamorph(State), ((State band 2#00000001000000000000000000000000) > 0)). % 机甲变身

%% 场景信息
-record(scene, {
      scene % SceneID
    , room  % RoomID
    , type  % SceneType
    , opts  % 场景定制参数
    , lines % 分线列表 key=LineID, val=#line
    , trash % 回收的分线id
    , track % 记录玩家所在分线(仅活动场景) key=RoleID, val=LineID
}).


%% 场景入口信息
-record(entry, {
      scene
    , stype
    , dunge
    , floor
    , room
    , coord
    , opts
}).
%% 分线信息
-record(line, {
      id    % LineID
    , spid  % ScenePid
    , num   % RoleNum
    , mref  % MonitorRef
    , dunge
    , floor
}).

%% 格子信息
-record(grid, {
      around = []  % [GridID] 九宫格
    , actids = #{} % key=ActorType, val=ActorID
}).

-record(scene_st, {
      scene :: integer() % SceneID
    , room  :: integer() % RoomID
    , line  :: integer() % LineID
    , dunge :: integer() % DungeID
    , floor :: integer() % FloorID
    , type  :: integer() % 场景类型
    , stype :: integer() % 场景子类型
    , stime :: integer() % 开始时间
    , etime :: integer() % 结束时间
    , opts  :: map()     % 场景定制参数
    , state :: integer() % 场景状态
}).

%% 场景中的对象
-record(actor, {
      uid     :: integer()  % 唯一id
    , id      :: integer()  % CreepID | ItemID
    , pid     :: integer()
    , type    :: integer()  % ACTOR_TYPE_XXX
    , kind    :: integer()  % 怪物种类
    , rarity  :: integer()  % 怪物稀有度
    , name    :: string()   % 名称
    , state   :: integer()  % 状态 ACTOR_STATE_XXX
    , num     :: integer()  % 数量(掉落物)
    , bctype  :: integer()  % 广播类型 BCTYPE_XXX
    , suid=0  :: integer()  % 服务器id
    , zoneid  :: integer()  % 区服id
    , hostile :: list()    % 敌对服务器 [SUID]
    , prior=?MAX_PRIOR     % ai调度优先级

    , spid   :: pid()      % ScenePid
    , scene  :: integer()  % SceneID
    , room   :: integer()  % RoomID
    , dunge  :: integer()  % DungeID
    , floor  :: integer()  % FloorID
    , line   :: integer()  % LineID
    , born   :: tuple()    % 出生坐标 #p_coord{}
    , dir    :: integer()  % 朝向
    , coord  :: tuple()    % 当前坐标 #p_coord
    , dest   :: tuple()    % 目的坐标 #p_coord
    , etime  :: integer()  % 死亡时间

    , buffs  :: map()      % key=Group, val=#p_buff
    , attrid :: tuple()    % 属性id
    , atcoef :: integer()  % 攻击侧系数
    , dfcoef :: integer()  % 防御侧系数
    , initattr :: map()    % 初始属性(没有加上buff)
    , buffattr :: map()    % buff属性(加上需要变更战力的buff)
    , attr   :: map()      % 最终属性
    , power  :: integer()  % 战力
    , skills :: map()      % key=SkillID, val=SkillLv
    , endcds :: map()      % key=SkillID, val=EndCD
    , skill  :: integer()  % 将要使用的技能

    , level  :: integer()  % 等级
    , career :: integer()  % 职业
    , gender :: integer()  % 性别
    , viplv  :: integer()  % vip等级
    , figure :: tuple()    % 形象 #p_figure
    , marry  :: integer()  % 结婚对象ID
    , mname  :: string()   % 结婚对象名
    , mtype  :: integer()  % 结婚类型
    , icon   :: tuple()    % p_icon

    , captain = 0 :: integer() % 队长id
    , team   :: integer()  % 队伍id
    , guild  :: integer()  % 帮派id
    , gname  :: string()   % 帮派名
    , gpost  :: integer()  % 帮派职位
    , group  :: integer()  % 分组
    , owner  :: integer()  % 主人
    , belong :: list()     % 归属

    , pkmode :: integer()  % PKMODE_XXX
    , atkrad :: integer()  % 攻击半径
    , offset :: integer()  % 攻击半径偏差
    , atkcd  :: integer()  % 攻击cd
    , crime  :: integer()  % 罪恶值
    , threat :: map()      % 仇恨 key=RoleID, val=DmgVal
    , enemy  :: integer()  % 敌人 ActorID
    , killer :: integer()  % 被谁杀死 ActorID
    , dist   :: integer()  % 与攻击点之间的距离

    , center = born :: atom()     % born | self 警戒/追击时以什么为中心
    , aiid   :: integer()  % AI id
    , aiargs :: map()      % AI 初始参数
    , aidata :: map()      % AI 动态数据

    , enter  = #{} :: map() % 进入参数
    , exargs :: any()       % 扩展参数
}).

-record(cfg_scene, {
      id
    , name
    , kind    % 场景种类 SCENE_KIND_XXX
    , type    % 场景类型 SCENE_TYPE_XXX
    , stype   % 场景子类型 SCENE_STYPE_XXX
    , bctype  % 广播类型 SCENE_BC_XXX
    , reqs    % 进入限制
    , pkmode  % 进入该场景后的PK模式
    , pkallow % 该场景允许切换的PK模式
    , buffs   % 场景buff
    , safe    % 是否安全场景
    , tele    % 是否可瞬移
    , jump    % 是否记录跳转点
    , mount   % 是否可上下坐骑
}).

-record(cfg_line, {
      id
    , max   % 最大分线数
    , soft  % 分线人数上限
    , hard  % 分线人数上限
    , keep  % 是否记录进入分线
}).

%% 场景进入消耗
-record(cfg_scene_cost, {
      id
    , type  % 消耗类型
    , cost  % 进入消耗
    , free  % 免费进入条件
    , force % 强行进入消耗
}).

%% 复活
-record(cfg_revive, {
      notify % 是否弹窗
    , manu   % 是否手动复活
    , type   % 自动复活类型 REVIVE_TYPE_XXX
    , time   % 自动复活时间
    , cost   % 原地复活消耗
}).

-endif.
