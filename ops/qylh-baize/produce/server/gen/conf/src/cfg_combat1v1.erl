% Automatically generated, do not edit
-module(cfg_combat1v1).

-compile([export_all]).
-compile(nowarn_export_all).

-include("enum.hrl").

weaken_robot() -> [{2,7000},{4,7000},{5,7000}]. % "机器人属性削弱 {属性，万分比}" 
last() -> 300. % "副本时长" 
prep() -> 3. % "准备倒计时" 
wait() -> 20. % "副本等待玩家进入最大时长" 
stat_cd() -> 15. % "结算倒计时" 
buff() -> 310000010. % "定身buff" 
