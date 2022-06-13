% Automatically generated, do not edit
-module(cfg_welfare_notice_reward).

-compile([export_all]).
-compile(nowarn_export_all).

-include("welfare.hrl").

find(1) -> #cfg_welfare_notice_reward{
	id         = 1,
	reward     = [{11140,2,1},{10015,2,1},{55000,5,1}],
	start_time = "2019-01-14 00:00:00",
	end_time   = "2020-01-16 23:59:59",
	state      = 1
};
find(2) -> #cfg_welfare_notice_reward{
	id         = 2,
	reward     = [],
	start_time = "2019-01-14 00:00:00",
	end_time   = "2020-01-16 23:59:59",
	state      = 1
};
find(3) -> #cfg_welfare_notice_reward{
	id         = 3,
	reward     = [],
	start_time = "2019-01-14 00:00:00",
	end_time   = "2020-01-16 23:59:59",
	state      = 1
};
find(_) -> undefined.
