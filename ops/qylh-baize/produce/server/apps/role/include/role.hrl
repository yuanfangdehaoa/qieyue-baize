-ifndef(ROLE_HRL).
-define(ROLE_HRL, ok).

%% 判断 role 状态
-define(is_mchunt(State), ((State band 2#00000000000000000000000000000001) > 0)). % 魂卡寻宝中
-define(is_escort(State), ((State band 2#00000000000000000000000000000010) > 0)). % 极地穿越中

-record(role_st, {
      role  % RoleID
    , ip
    , name  % RoleName
    , gate  % GatePid
    , user  % #game_user
    , token % 断线重连token
    , guild % GuildID
    , gpid  % GuildPid
    , team  % TeamID
    , tpid  % TeamPid
    , scene % SceneID
    , spid  % ScenePid
    , room  % RoomID
    , dunge % DungeID
    , floor % FloorID
    , line  % LineID
    , type  % SceneType
    , stype % SceneSType
    , coord % #p_coord
    , state % 玩家状态
    , jump  % 跳转点
    , sdk   % sdk参数
}).

%% 玩家缓存数据
-record(role_cache, {
	  id     % 角色id
	, name   % 角色名
    , career % 职业
    , gender % 性别
	, level  % 玩家等级
	, power  % 战力
    , viptype % vip类型
	, viplv   % vip等级
    , vipend  % vip结束时间
    , guild  % 帮派id
    , gname  % 帮派名称
    , gpost  % 帮派职位
    , figure % 形象
    , suid   % 服务器id
    , login  % 登陆时间
    , logout % 离线时间
    , charm  % 魅力
    , online % 是否在线
    , wake   % 觉醒等级
    , icon   % 玩家头像
    , marry  % 结婚对象id
    , mname  % 结婚对象名称
    , mtype  % 结婚档次
    , zoneid % 区服id
    , team   % 队伍id
}).

%% 位置信息
-record(site, {
      scene
    , room
    , coord
}).

-endif.