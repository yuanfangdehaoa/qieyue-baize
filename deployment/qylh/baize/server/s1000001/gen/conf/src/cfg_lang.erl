% Automatically generated, do not edit
-module(cfg_lang).

-compile([export_all]).
-compile(nowarn_export_all).

find(assist) -> "小助手";
find(level) -> "级";
find(peak) -> "巅峰";
find({color,1}) -> "白色";
find({color,2}) -> "绿色";
find({color,3}) -> "蓝色";
find({color,4}) -> "紫色";
find({color,5}) -> "橙色";
find({color,6}) -> "红色";
find({color,7}) -> "粉色";
find(_) -> "".