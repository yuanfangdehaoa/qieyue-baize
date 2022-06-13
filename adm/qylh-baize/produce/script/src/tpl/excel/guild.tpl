-include("guild.hrl").
-include("enum.hrl").

{{ row . `find('level') -> #cfg_guild{
	level = 'level',
	memb  = 'memb',
	post  = #{
		?GUILD_POST_VICE  => 'vice',
		?GUILD_POST_ELDER => 'elder',
		?GUILD_POST_BABY  => 'baby'
	},
	fund  = 'fund',
	reqs  = 'reqs',
	cost  = 'cost'
};` }}
find(_) -> undefined.

{{ row . `boon('level') -> #cfg_guild_boon{
	level = 'level',
	daily = 'boon',
	baby  = 'baby_boon',
	post  = 'post_boon'
};` }}
boon(_) -> undefined.

max() -> {{ max . "level" }}.
