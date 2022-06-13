% Automatically generated, do not edit
-module(cfg_dunge_soul).

-compile([export_all]).
-compile(nowarn_export_all).


wait() -> 60. % "每回合等待时间"
summon_cost() -> {90010004,1500}. % "召唤boss消耗"
escape() -> 100. % "逃跑怪物上限"
slot() -> [{1,3030,1280}, {2,2670,1280}, {3,2300,1280}, {4,1935,1280}, {5,1555,1280}, {6,1210,1280}]. % "神灵的坐标"
waypoint() -> [{3010,943},{2611,930},{861,930},{759,1249},{835,1497},{1318,1616},{2246,1573},{3356,1783}]. % "寻路的路点"
