% Automatically generated, do not edit
-module(cfg_compete_misc).

-compile([export_all]).
-compile(nowarn_export_all).

find(enroll_reqs, true) -> [{wake,1}, {rank,200}]; % "报名条件"
find(enroll_cost, true) -> [{10002,1}]; % "报名消耗"
find(join_num, true) -> 128; % "参与人数"
find(exp_add, true) -> [{90010018,10}]; % "预备场景每10秒获得经验"
find(rank_len1, true) -> 16; % "天榜长度"
find(rank_len2, true) -> 16; % "地榜长度"
find(battle_life, true) -> 3; % "战场初始命数"
find(battle_buffs, true) -> [{304100005,304100001,self,[{90010003,300}]},{304100006,304100002,peer,[{90010003,300}]},{304100007,304100003,self,[{90010003,300}]}]; % "战场buff {BuffID, CostList}"
find(select_round, true) -> 8; % "海选赛共几轮"
find(select_prepare_last, true) -> 10; % "海选赛准备时长"
find(select_battle_last, true) -> 120; % "海选赛战斗时长"
find(rank_reward1, true) -> [{90010004,10000},{90010029,200},{10301,3},{100033,1},{11129,1}]; % "晋级天榜奖励"
find(rank_reward2, true) -> [{90010004,5000},{90010029,100},{10301,3},{100033,1},{11129,1}]; % "晋级地榜奖励"
find(rank_round, true) -> 4; % "争霸赛共几轮"
find(rank_prepare_last, true) -> 100; % "争霸赛准备时长"
find(rank_battle_last, true) -> 120; % "争霸赛战斗时长"
find(enroll_reqs, false) -> [{wake,2}, {rank,200}]; % "报名条件"
find(enroll_cost, false) -> [{10002,1}]; % "报名消耗"
find(join_num, false) -> 128; % "参与人数"
find(exp_add, false) -> [{90010018,10}]; % "预备场景每10秒获得经验"
find(rank_len1, false) -> 16; % "天榜长度"
find(rank_len2, false) -> 16; % "地榜长度"
find(battle_life, false) -> 3; % "战场初始命数"
find(battle_buffs, false) -> [{304100005,304100001,self,[{90010003,300}]},{304100006,304100002,peer,[{90010003,300}]},{304100007,304100003,self,[{90010003,300}]}]; % "战场buff {BuffID, CostList}"
find(select_round, false) -> 8; % "海选赛共几轮"
find(select_prepare_last, false) -> 10; % "海选赛准备时长"
find(select_battle_last, false) -> 120; % "海选赛战斗时长"
find(rank_reward1, false) -> [{90010004,30000},{90010029,600},{10301,5},{100033,1},{11129,1}]; % "晋级天榜奖励"
find(rank_reward2, false) -> [{90010004,15000},{90010029,300},{10301,5},{100033,1},{11129,1}]; % "晋级地榜奖励"
find(rank_round, false) -> 4; % "争霸赛共几轮"
find(rank_prepare_last, false) -> 100; % "争霸赛准备时长"
find(rank_battle_last, false) -> 120; % "争霸赛战斗时长"
find(_, _) -> undefined.
