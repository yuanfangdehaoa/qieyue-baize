-ifndef(WARRIOR_HRL).
-define(WARRIOR_HRL, ok).

-define(WARRIOR_ACTID, 10231).
-define(kill_num, {'@kill_num', RoleID}).
-define(floor_gain, {'@floor_gain', RoleID, SceneID}).
-define(ckill_num, {'@ckill_num', RoleID}).
-define(last_scene, {'@last_scen', RoleID}).

%层数表
-record(cfg_warrior_floor, {
	  scene_id        %场景id
	, floor           %层数
	, kill_target     %击杀目标
	, gain            %该层奖励
	, cross_gain      %跨服奖励
	, is_down         %是否降层
	, prob            %降层概率(万分比)
	, score           %击杀获得积分
	, kill_num        %击杀获得数量
}).

%排名奖励
-record(cfg_warrior_reward, {
	  rank_min            %最小排名
	, rank_max            %最大排名
	, gain                %奖励
}).



-endif.