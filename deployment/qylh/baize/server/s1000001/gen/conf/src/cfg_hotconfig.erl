% Automatically generated, do not edit
-module(cfg_hotconfig).

-compile([export_all]).
-compile(nowarn_export_all).

client(cfg_yunying) -> db_yunying;
client(cfg_yunying_reward) -> db_yunying_reward;
client(cfg_festival) -> db_festival;
client(cfg_festival_reward) -> db_festival_reward;
client(cfg_yunying_gift) -> db_yunying_gift;
client(cfg_mall) -> db_mall;
client(cfg_yunying_lottery_rewards) -> db_yunying_lottery_rewards;
client(_) -> undefined.

all() -> [cfg_mall,cfg_yunying_lottery_rewards,cfg_yunying,cfg_yunying_reward,cfg_festival,cfg_festival_reward,cfg_yunying_gift].
