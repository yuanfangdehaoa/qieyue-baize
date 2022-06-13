-ifndef(AFK_HRL).
-define(AFK_HRL, ok).

-record(cfg_afk, {creep, fight, exp, atk, show_robot}).

-record(robot, {role_id, etime, robot_id, scene, creep, coord}).
% robot_id : 取值
%   pendding    正在添加
%   timeout     超时删除 
%   undefined   没在地图创建
%   RobotID     创建的机器人ID

-define(ETS_ROBOT, ets_robot).

-endif.