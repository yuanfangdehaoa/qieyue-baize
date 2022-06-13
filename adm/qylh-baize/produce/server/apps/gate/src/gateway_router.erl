
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(gateway_router).

-include("game.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([route/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
route(?ACTIVITY) -> activity_handler;
route(?GAME)  -> game_handler;
route(?RANK)  -> rank_handler;
route(?TASK)  -> task_handler;
route(?ROLE)  -> role_handler;
route(?BAG)   -> bag_handler;
route(?ITEM)  -> item_handler;
route(?MAIL)  -> mail_handler;
route(?EQUIP) -> equip_handler;
route(?SCENE) -> scene_handler;
route(?DUNGE) -> dunge_handler;
route(?FIGHT) -> fight_handler;
route(?GUILD) -> guild_handler;
route(?GUILD_DEPOT) -> guild_depot_handler;
route(?GUILD_SKILL) -> guild_skill_handler;
route(?CHAT)  -> chat_handler;
route(?SEARCHTREASURE) -> search_treasure_handler;
route(?MOUNT) -> mount_handler;
route(?MORPH) -> morph_handler;
route(?TRAIN) -> train_handler;
route(?SKILL) -> skill_handler;
route(?BOSS)  -> boss_handler;
route(?TEAM)  -> team_handler;
route(?MALL)  -> mall_handler;
route(?WAKE)  -> wake_handler;
route(?MAGICCARD) -> magiccard_handler;
route(?VIP)   -> vip_handler;
route(?JOBTITLE) -> jobtitle_handler;
route(?FASHION) -> fashion_handler;
route(?TITLE)  -> title_handler;
route(?MCHUNT) -> mchunt_handler;
route(?FRIEND) -> friend_handler;
route(?TARGET) -> target_handler;
route(?MARKET) -> market_handler;
route(?BEAST) -> beast_handler;
route(?DAILY) -> daily_handler;
route(?WELFARE) -> welfare_handler;
route(?WEEKLY) -> weekly_handler;
route(?REALNAME) -> realname_handler;
route(?ESCORT) -> escort_handler;
route(?GUILD_WAR) -> guild_war_handler;
route(?MELEE) -> melee_handler;
route(?CANDYROOM) -> candyroom_handler;
route(?YYLOGIN) -> yylogin_handler;
route(?AFK) -> afk_handler;
route(?ACHIEVE) -> achieve_handler;
route(?YUNYING) -> yunying_handler;
route(?PET) -> pet_handler;
route(?FIRSTPAY) -> firstpay_handler;
route(?GUILD_HOUSE) -> guild_house_handler;
route(?WANTED) -> wanted_handler;
route(?ARENA) -> arena_handler;
route(?GUILD_REDENVELOPE) -> guild_redenvelope_handler;
route(?DATING) -> dating_handler;
route(?MARRIAGE) -> marriage_handler;
route(?WEDDING) -> wedding_handler;
route(?ICON) -> icon_handler;
route(?FINDBACK) -> findback_handler;
route(?COMBAT1V1) -> combat1v1_handler;
route(?WARRIOR) -> warrior_handler;
route(?BABY) -> baby_handler;
route(?CASTHOUSE) -> casthouse_handler;
route(?TALENT) -> talent_handler;
route(?SOUL) -> soul_handler;
route(?ILLUSTRATION) -> illustration_handler;
route(?ACTPAY) -> actpay_handler;
route(?COMPETE) -> compete_handler;
route(?GOD_EQUIPS) -> god_equips_handler;
route(?TIMEBOSS) -> timeboss_handler;
route(?ACTINVEST) -> actinvest_handler;
route(?MECHA) -> mecha_handler;
route(?SIEGEWAR) -> siegewar_handler;
route(?THRONE) -> throne_handler;
route(?RICHMAN) -> yunying_richman;
route(?CROSS_GUILDWAR) -> guild_crosswar_handler;
route(?LUCKYWHEEL) -> yunying_luckywheel;
route(?ARTIFACT) -> artifact_handler;
route(?TOTEM) -> totem_handler;
route(?FLOPGIFT) -> yunying_flop_gift;
route(ModID)  ->
    ?error("unhandle package: ~w", [ModID]),
	throw(?err(?ERR_GAME_SYS_OPENED, [ModID])).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
