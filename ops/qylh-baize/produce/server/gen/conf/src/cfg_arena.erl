% Automatically generated, do not edit
-module(cfg_arena).

-compile([export_all]).
-compile(nowarn_export_all).

-include("enum.hrl").

top_challenge() -> 3. % "大神挑战次数上限" 
dunge_id() -> 30371. % "副本id" 
robot_id() -> 30371001. % "机器人的creep_id" 
max_rank() -> 3000. % "最大排名" 
rush() -> {1410,680}. % "攻方冲刺目标点" 
def_rush() -> {1610,735}. % "守方冲刺目标点" 
skip_lv() -> 150. % "跳过等级" 
com_lv() -> 200. % "合并等级" 
