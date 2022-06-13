% Automatically generated, do not edit
-module(cfg_dunge_couple).

-compile([export_all]).
-compile(nowarn_export_all).


buy_times() -> 1. % "结婚副本购买次数"
reward() -> [{1,[{90010018,200,1},{11141,20,1},{15220,2,1},{15218,2,1}]}, {2,[{90010018,200,1},{11141,10,1},{15221,2,1},{15218,2,1}]}]. % "结婚副本奖励（1：一致；2：不一致）"
base() -> 5. % "基础分"
extra() -> 10. % "答案相同额外加分"
answer_protect() -> 5. % "答题新手保护次数"
answer_timeout() -> 25. % "答题超时"
