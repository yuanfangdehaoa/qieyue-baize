% Automatically generated, do not edit
-module(cfg_guild).

-compile([export_all]).
-compile(nowarn_export_all).

-include("guild.hrl").
-include("enum.hrl").

find(1) -> #cfg_guild{
	level = 1,
	memb  = 20,
	post  = #{
		?GUILD_POST_VICE  => 3,
		?GUILD_POST_ELDER => 5,
		?GUILD_POST_BABY  => 1
	},
	fund  = 550000,
	reqs  = [{level,85},{vip,12},{recharge,50}],
	cost  = [{11104,1}]
};
find(2) -> #cfg_guild{
	level = 2,
	memb  = 23,
	post  = #{
		?GUILD_POST_VICE  => 3,
		?GUILD_POST_ELDER => 5,
		?GUILD_POST_BABY  => 1
	},
	fund  = 1000000,
	reqs  = [{level,85},{vip,14},{recharge,50}],
	cost  = [{90010003,5000}]
};
find(3) -> #cfg_guild{
	level = 3,
	memb  = 26,
	post  = #{
		?GUILD_POST_VICE  => 3,
		?GUILD_POST_ELDER => 5,
		?GUILD_POST_BABY  => 1
	},
	fund  = 2000000,
	reqs  = [],
	cost  = []
};
find(4) -> #cfg_guild{
	level = 4,
	memb  = 29,
	post  = #{
		?GUILD_POST_VICE  => 3,
		?GUILD_POST_ELDER => 5,
		?GUILD_POST_BABY  => 1
	},
	fund  = 4200000,
	reqs  = [],
	cost  = []
};
find(5) -> #cfg_guild{
	level = 5,
	memb  = 32,
	post  = #{
		?GUILD_POST_VICE  => 3,
		?GUILD_POST_ELDER => 5,
		?GUILD_POST_BABY  => 1
	},
	fund  = 7000000,
	reqs  = [],
	cost  = []
};
find(6) -> #cfg_guild{
	level = 6,
	memb  = 35,
	post  = #{
		?GUILD_POST_VICE  => 3,
		?GUILD_POST_ELDER => 5,
		?GUILD_POST_BABY  => 1
	},
	fund  = 14000000,
	reqs  = [],
	cost  = []
};
find(7) -> #cfg_guild{
	level = 7,
	memb  = 38,
	post  = #{
		?GUILD_POST_VICE  => 3,
		?GUILD_POST_ELDER => 5,
		?GUILD_POST_BABY  => 1
	},
	fund  = 30000000,
	reqs  = [],
	cost  = []
};
find(8) -> #cfg_guild{
	level = 8,
	memb  = 41,
	post  = #{
		?GUILD_POST_VICE  => 3,
		?GUILD_POST_ELDER => 5,
		?GUILD_POST_BABY  => 1
	},
	fund  = 0,
	reqs  = [],
	cost  = []
};
find(_) -> undefined.

boon(1) -> #cfg_guild_boon{
	level = 1,
	daily = [{11004,1}],
	baby  = [{11000,1}],
	post  = []
};
boon(2) -> #cfg_guild_boon{
	level = 2,
	daily = [{11004,1}],
	baby  = [{11000,1}],
	post  = []
};
boon(3) -> #cfg_guild_boon{
	level = 3,
	daily = [{11004,1}],
	baby  = [{11000,1}],
	post  = []
};
boon(4) -> #cfg_guild_boon{
	level = 4,
	daily = [{11004,1}],
	baby  = [{11000,1}],
	post  = []
};
boon(5) -> #cfg_guild_boon{
	level = 5,
	daily = [{11004,1}],
	baby  = [{11000,1}],
	post  = []
};
boon(6) -> #cfg_guild_boon{
	level = 6,
	daily = [{11004,1}],
	baby  = [{11000,1}],
	post  = []
};
boon(7) -> #cfg_guild_boon{
	level = 7,
	daily = [{11004,1}],
	baby  = [{11000,1}],
	post  = []
};
boon(8) -> #cfg_guild_boon{
	level = 8,
	daily = [{11004,1}],
	baby  = [{11000,1}],
	post  = []
};
boon(_) -> undefined.

max() -> 8.
