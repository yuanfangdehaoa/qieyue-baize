% Automatically generated, do not edit
-module(cfg_melee).

-compile([export_all]).
-compile(nowarn_export_all).

creep_score() -> 10. % "击杀小怪获得积分"
min_score() -> 50. % "玩家保底积分"
max_score() -> 500. % "玩家积分上限"
buff_unbeat() -> 120110002. % "无敌buff"
kill() -> [3,5,8,10,15,20]. % "连续击杀广播"
