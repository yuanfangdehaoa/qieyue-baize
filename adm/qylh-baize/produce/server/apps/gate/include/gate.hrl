-ifndef(GATE_HRL).
-define(GATE_HRL, ok).

-define(ST_VERIFY, st_verify). % 登录验证
-define(ST_SELECT, st_select). % 选取角色
-define(ST_NORMAL, st_normal). % 游戏中

-record(gate_st, {
	  gpid  :: pid()     % GatePid
	, trans :: module()  % ranch_tcp | ranch_ssl
	, sock  :: inet:socket()
	, ip    :: inet:ip_address()
	, state :: atom()    % st_verify | st_select | st_normal
	, user  :: tuple()   % #user_info
    , role  :: integer() % RoleID
    , name  :: string()  % RoleName
	, rpid  :: pid()     % RolePid
	, heart :: reference() % 心跳包检测定时器
	, recv1 :: integer() % 心跳包检测
	, recv2 :: integer() % 发包速度检测
	, error :: integer() % 非法数据包错误次数
	, fast  :: integer() % 发包速度过快次数
	, token :: string()  % 登录token
	, sdk   :: map()     % sdk参数
}).

-define(LOGIN_NORMAL  , 10). %正常登录
-define(LOGIN_RELOGIN , 11). %顶号登录
-define(LOGOUT_NORMAL , 20). %正常登出
-define(LOGOUT_RELOGIN, 21). %顶号登出
-define(LOGOUT_KICKOUT, 22). %GM踢下线
-define(LOGOUT_TOOFAST, 23). %发包过快，被踢下线
-define(LOGOUT_NOHREAT, 24). %检测心跳失败，断开连接
-define(LOGOUT_UNKNOWN, 25). %其他原因
-define(LOGOUT_FCM,     26). %防沉迷踢下线

-endif.