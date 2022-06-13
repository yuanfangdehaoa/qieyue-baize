% Automatically generated, do not edit
-module(cfg_mall_type_name).

-compile([export_all]).
-compile(nowarn_export_all).

find({ 1,1 }) -> "限时抢购";
find({ 1,2 }) -> "每周限购";
find({ 2,1 }) -> "日常道具";
find({ 2,2 }) -> "绑钻商店";
find({ 2,3 }) -> "时装商城";
find({ 2,4 }) -> "材料商城";
find({ 3,1 }) -> "荣耀商城";
find({ 3,10 }) -> "魂卡兑换";
find({ 20,1 }) -> "抢购活动";
find({ 50,1 }) -> "vip终身礼包";
find({ 60,1 }) -> "结婚商城";
find({ 70,1 }) -> "寻宝商城";
find({ 80,1 }) -> "异兽限购";
find(_) -> undefined.
