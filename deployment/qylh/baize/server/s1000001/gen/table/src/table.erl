%% Automatically generated, do not edit
%% Generated by parse_table.go

-module(table).

-compile([export_all]).
-compile(nowarn_export_all).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").

tabs() ->
	game_tabs() ++ guild_tabs() ++ role_tabs().


role_tabs() -> [
	#r_tab{
		name = role_info,
		rec  = role_info,
		opts = [
			{record_name, role_info},
			{type, set},
			{attributes, record_info(fields, role_info)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_attr,
		rec  = role_attr,
		opts = [
			{record_name, role_attr},
			{type, set},
			{attributes, record_info(fields, role_attr)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_site,
		rec  = role_site,
		opts = [
			{record_name, role_site},
			{type, set},
			{attributes, record_info(fields, role_site)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_bag,
		rec  = role_bag,
		opts = [
			{record_name, role_bag},
			{type, set},
			{attributes, record_info(fields, role_bag)},
			
			{disc_only_copies, [node()]}
		],
		init = role_bag
	}

	, #r_tab{
		name = role_task,
		rec  = role_task,
		opts = [
			{record_name, role_task},
			{type, set},
			{attributes, record_info(fields, role_task)},
			
			{disc_only_copies, [node()]}
		],
		init = role_task
	}

	, #r_tab{
		name = role_skill,
		rec  = role_skill,
		opts = [
			{record_name, role_skill},
			{type, set},
			{attributes, record_info(fields, role_skill)},
			
			{disc_only_copies, [node()]}
		],
		init = role_skill
	}

	, #r_tab{
		name = role_equip,
		rec  = role_equip,
		opts = [
			{record_name, role_equip},
			{type, set},
			{attributes, record_info(fields, role_equip)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_dunge,
		rec  = role_dunge,
		opts = [
			{record_name, role_dunge},
			{type, set},
			{attributes, record_info(fields, role_dunge)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = dunge_magic,
		rec  = dunge_magic,
		opts = [
			{record_name, dunge_magic},
			{type, set},
			{attributes, record_info(fields, dunge_magic)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_online,
		rec  = role_online,
		opts = [
			{record_name, role_online},
			{type, set},
			{attributes, record_info(fields, role_online)},
			
			{disc_only_copies, [node()]}
		],
		init = never
	}

	, #r_tab{
		name = role_searchtreasure,
		rec  = role_searchtreasure,
		opts = [
			{record_name, role_searchtreasure},
			{type, set},
			{attributes, record_info(fields, role_searchtreasure)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_mall,
		rec  = role_mall,
		opts = [
			{record_name, role_mall},
			{type, set},
			{attributes, record_info(fields, role_mall)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_train,
		rec  = role_train,
		opts = [
			{record_name, role_train},
			{type, set},
			{attributes, record_info(fields, role_train)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_vip,
		rec  = role_vip,
		opts = [
			{record_name, role_vip},
			{type, set},
			{attributes, record_info(fields, role_vip)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_vip2,
		rec  = role_vip2,
		opts = [
			{record_name, role_vip2},
			{type, set},
			{attributes, record_info(fields, role_vip2)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_wake,
		rec  = role_wake,
		opts = [
			{record_name, role_wake},
			{type, set},
			{attributes, record_info(fields, role_wake)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_magic_card,
		rec  = role_magic_card,
		opts = [
			{record_name, role_magic_card},
			{type, set},
			{attributes, record_info(fields, role_magic_card)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_guild,
		rec  = role_guild,
		opts = [
			{record_name, role_guild},
			{type, set},
			{attributes, record_info(fields, role_guild)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_fashion,
		rec  = role_fashion,
		opts = [
			{record_name, role_fashion},
			{type, set},
			{attributes, record_info(fields, role_fashion)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_title,
		rec  = role_title,
		opts = [
			{record_name, role_title},
			{type, set},
			{attributes, record_info(fields, role_title)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_mchunt,
		rec  = role_mchunt,
		opts = [
			{record_name, role_mchunt},
			{type, set},
			{attributes, record_info(fields, role_mchunt)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_target,
		rec  = role_target,
		opts = [
			{record_name, role_target},
			{type, set},
			{attributes, record_info(fields, role_target)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_welfare,
		rec  = role_welfare,
		opts = [
			{record_name, role_welfare},
			{type, set},
			{attributes, record_info(fields, role_welfare)},
			
			{disc_only_copies, [node()]}
		],
		init = role_welfare
	}

	, #r_tab{
		name = role_count,
		rec  = role_count,
		opts = [
			{record_name, role_count},
			{type, set},
			{attributes, record_info(fields, role_count)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_misc,
		rec  = role_misc,
		opts = [
			{record_name, role_misc},
			{type, set},
			{attributes, record_info(fields, role_misc)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_beast,
		rec  = role_beast,
		opts = [
			{record_name, role_beast},
			{type, set},
			{attributes, record_info(fields, role_beast)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_daily,
		rec  = role_daily,
		opts = [
			{record_name, role_daily},
			{type, set},
			{attributes, record_info(fields, role_daily)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_illusion,
		rec  = role_illusion,
		opts = [
			{record_name, role_illusion},
			{type, set},
			{attributes, record_info(fields, role_illusion)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_weekly,
		rec  = role_weekly,
		opts = [
			{record_name, role_weekly},
			{type, set},
			{attributes, record_info(fields, role_weekly)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_escort,
		rec  = role_escort,
		opts = [
			{record_name, role_escort},
			{type, set},
			{attributes, record_info(fields, role_escort)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_realname,
		rec  = role_realname,
		opts = [
			{record_name, role_realname},
			{type, set},
			{attributes, record_info(fields, role_realname)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_pay,
		rec  = role_pay,
		opts = [
			{record_name, role_pay},
			{type, set},
			{attributes, record_info(fields, role_pay)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_monitor,
		rec  = role_monitor,
		opts = [
			{record_name, role_monitor},
			{type, set},
			{attributes, record_info(fields, role_monitor)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_yylogin,
		rec  = role_yylogin,
		opts = [
			{record_name, role_yylogin},
			{type, set},
			{attributes, record_info(fields, role_yylogin)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_afk,
		rec  = role_afk,
		opts = [
			{record_name, role_afk},
			{type, set},
			{attributes, record_info(fields, role_afk)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_achieve,
		rec  = role_achieve,
		opts = [
			{record_name, role_achieve},
			{type, set},
			{attributes, record_info(fields, role_achieve)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_pet,
		rec  = role_pet,
		opts = [
			{record_name, role_pet},
			{type, set},
			{attributes, record_info(fields, role_pet)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_firstpay,
		rec  = role_firstpay,
		opts = [
			{record_name, role_firstpay},
			{type, set},
			{attributes, record_info(fields, role_firstpay)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_yy_gift,
		rec  = role_yy_gift,
		opts = [
			{record_name, role_yy_gift},
			{type, set},
			{attributes, record_info(fields, role_yy_gift)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_wanted,
		rec  = role_wanted,
		opts = [
			{record_name, role_wanted},
			{type, set},
			{attributes, record_info(fields, role_wanted)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_arena,
		rec  = role_arena,
		opts = [
			{record_name, role_arena},
			{type, set},
			{attributes, record_info(fields, role_arena)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_marriage,
		rec  = role_marriage,
		opts = [
			{record_name, role_marriage},
			{type, set},
			{attributes, record_info(fields, role_marriage)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_findback,
		rec  = role_findback,
		opts = [
			{record_name, role_findback},
			{type, set},
			{attributes, record_info(fields, role_findback)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_baby,
		rec  = role_baby,
		opts = [
			{record_name, role_baby},
			{type, set},
			{attributes, record_info(fields, role_baby)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_yy_lottery,
		rec  = role_yy_lottery,
		opts = [
			{record_name, role_yy_lottery},
			{type, set},
			{attributes, record_info(fields, role_yy_lottery)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_casthouse,
		rec  = role_casthouse,
		opts = [
			{record_name, role_casthouse},
			{type, set},
			{attributes, record_info(fields, role_casthouse)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_talent,
		rec  = role_talent,
		opts = [
			{record_name, role_talent},
			{type, set},
			{attributes, record_info(fields, role_talent)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_soul,
		rec  = role_soul,
		opts = [
			{record_name, role_soul},
			{type, set},
			{attributes, record_info(fields, role_soul)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_compose,
		rec  = role_compose,
		opts = [
			{record_name, role_compose},
			{type, set},
			{attributes, record_info(fields, role_compose)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = dunge_god,
		rec  = dunge_god,
		opts = [
			{record_name, dunge_god},
			{type, set},
			{attributes, record_info(fields, dunge_god)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_illustration,
		rec  = role_illustration,
		opts = [
			{record_name, role_illustration},
			{type, set},
			{attributes, record_info(fields, role_illustration)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_actpay,
		rec  = role_actpay,
		opts = [
			{record_name, role_actpay},
			{type, set},
			{attributes, record_info(fields, role_actpay)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_god_equips,
		rec  = role_god_equips,
		opts = [
			{record_name, role_god_equips},
			{type, set},
			{attributes, record_info(fields, role_god_equips)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_actinvest,
		rec  = role_actinvest,
		opts = [
			{record_name, role_actinvest},
			{type, set},
			{attributes, record_info(fields, role_actinvest)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_mecha,
		rec  = role_mecha,
		opts = [
			{record_name, role_mecha},
			{type, set},
			{attributes, record_info(fields, role_mecha)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_sub_equips,
		rec  = role_sub_equips,
		opts = [
			{record_name, role_sub_equips},
			{type, set},
			{attributes, record_info(fields, role_sub_equips)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_siegewar,
		rec  = role_siegewar,
		opts = [
			{record_name, role_siegewar},
			{type, set},
			{attributes, record_info(fields, role_siegewar)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_richman,
		rec  = role_richman,
		opts = [
			{record_name, role_richman},
			{type, set},
			{attributes, record_info(fields, role_richman)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_luckywheel,
		rec  = role_luckywheel,
		opts = [
			{record_name, role_luckywheel},
			{type, set},
			{attributes, record_info(fields, role_luckywheel)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_artifact,
		rec  = role_artifact,
		opts = [
			{record_name, role_artifact},
			{type, set},
			{attributes, record_info(fields, role_artifact)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_totem,
		rec  = role_totem,
		opts = [
			{record_name, role_totem},
			{type, set},
			{attributes, record_info(fields, role_totem)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = role_flop_gift,
		rec  = role_flop_gift,
		opts = [
			{record_name, role_flop_gift},
			{type, set},
			{attributes, record_info(fields, role_flop_gift)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

].

guild_tabs() -> [
	#r_tab{
		name = guild_info,
		rec  = guild_info,
		opts = [
			{record_name, guild_info},
			{type, set},
			{attributes, record_info(fields, guild_info)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = guild_depot,
		rec  = guild_depot,
		opts = [
			{record_name, guild_depot},
			{type, set},
			{attributes, record_info(fields, guild_depot)},
			
			{disc_only_copies, [node()]}
		],
		init = guild_depot_handler
	}

	, #r_tab{
		name = guild_redenvelope,
		rec  = guild_redenvelope,
		opts = [
			{record_name, guild_redenvelope},
			{type, set},
			{attributes, record_info(fields, guild_redenvelope)},
			
			{disc_only_copies, [node()]}
		],
		init = guild_redenvelope_handler
	}

].

game_tabs() -> [
	#r_tab{
		name = game_user,
		rec  = game_user,
		opts = [
			{record_name, game_user},
			{type, set},
			{attributes, record_info(fields, game_user)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = game_rank,
		rec  = game_rank,
		opts = [
			{record_name, game_rank},
			{type, set},
			{attributes, record_info(fields, game_rank)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = game_misc,
		rec  = game_misc,
		opts = [
			{record_name, game_misc},
			{type, set},
			{attributes, record_info(fields, game_misc)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = mailbox,
		rec  = mailbox,
		opts = [
			{record_name, mailbox},
			{type, set},
			{attributes, record_info(fields, mailbox)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = friend,
		rec  = friend,
		opts = [
			{record_name, friend},
			{type, set},
			{attributes, record_info(fields, friend)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = chat_contact,
		rec  = chat_contact,
		opts = [
			{record_name, chat_contact},
			{type, set},
			{attributes, record_info(fields, chat_contact)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = trade,
		rec  = trade,
		opts = [
			{record_name, trade},
			{type, set},
			{attributes, record_info(fields, trade)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = yy_info,
		rec  = yy_info,
		opts = [
			{record_name, yy_info},
			{type, set},
			{attributes, record_info(fields, yy_info)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = yy_role,
		rec  = yy_role,
		opts = [
			{record_name, yy_role},
			{type, set},
			{attributes, record_info(fields, yy_role)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = mirror,
		rec  = mirror,
		opts = [
			{record_name, mirror},
			{type, set},
			{attributes, record_info(fields, mirror)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = arena,
		rec  = arena,
		opts = [
			{record_name, arena},
			{type, set},
			{attributes, record_info(fields, arena)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = arena_misc,
		rec  = arena_misc,
		opts = [
			{record_name, arena_misc},
			{type, set},
			{attributes, record_info(fields, arena_misc)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = redenvelope,
		rec  = redenvelope,
		opts = [
			{record_name, redenvelope},
			{type, set},
			{attributes, record_info(fields, redenvelope)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = dating,
		rec  = dating,
		opts = [
			{record_name, dating},
			{type, set},
			{attributes, record_info(fields, dating)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = marriage,
		rec  = marriage,
		opts = [
			{record_name, marriage},
			{type, set},
			{attributes, record_info(fields, marriage)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = wedding,
		rec  = wedding,
		opts = [
			{record_name, wedding},
			{type, set},
			{attributes, record_info(fields, wedding)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = gw_field,
		rec  = gw_field,
		opts = [
			{record_name, gw_field},
			{type, set},
			{attributes, record_info(fields, gw_field)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = gw_guild,
		rec  = gw_guild,
		opts = [
			{record_name, gw_guild},
			{type, set},
			{attributes, record_info(fields, gw_guild)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = combat1v1_role,
		rec  = combat1v1_role,
		opts = [
			{record_name, combat1v1_role},
			{type, set},
			{attributes, record_info(fields, combat1v1_role)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

	, #r_tab{
		name = yy_shop_act,
		rec  = yy_shop_act,
		opts = [
			{record_name, yy_shop_act},
			{type, set},
			{attributes, record_info(fields, yy_shop_act)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

].

cross_tabs() -> [
	#r_tab{
		name = cls_node,
		rec  = cls_node,
		opts = [
			{record_name, cls_node},
			{type, set},
			{attributes, record_info(fields, cls_node)},
			
			{disc_only_copies, [node()]}
		],
		init = undefined
	}

].




init(role_info, RoleID) -> #role_info{id=RoleID};
init(role_attr, RoleID) -> #role_attr{id=RoleID};
init(role_site, RoleID) -> #role_site{id=RoleID};
init(role_bag, RoleID) -> #role_bag{id=RoleID};
init(role_task, RoleID) -> #role_task{id=RoleID};
init(role_skill, RoleID) -> #role_skill{id=RoleID};
init(role_equip, RoleID) -> #role_equip{id=RoleID};
init(role_dunge, RoleID) -> #role_dunge{id=RoleID};
init(dunge_magic, RoleID) -> #dunge_magic{id=RoleID};
init(role_online, RoleID) -> #role_online{id=RoleID};
init(role_searchtreasure, RoleID) -> #role_searchtreasure{id=RoleID};
init(role_mall, RoleID) -> #role_mall{id=RoleID};
init(role_train, RoleID) -> #role_train{id=RoleID};
init(role_vip, RoleID) -> #role_vip{id=RoleID};
init(role_vip2, RoleID) -> #role_vip2{id=RoleID};
init(role_wake, RoleID) -> #role_wake{id=RoleID};
init(role_magic_card, RoleID) -> #role_magic_card{id=RoleID};
init(role_guild, RoleID) -> #role_guild{id=RoleID};
init(role_fashion, RoleID) -> #role_fashion{id=RoleID};
init(role_title, RoleID) -> #role_title{id=RoleID};
init(role_mchunt, RoleID) -> #role_mchunt{id=RoleID};
init(role_target, RoleID) -> #role_target{id=RoleID};
init(role_welfare, RoleID) -> #role_welfare{id=RoleID};
init(role_count, RoleID) -> #role_count{id=RoleID};
init(role_misc, RoleID) -> #role_misc{id=RoleID};
init(role_beast, RoleID) -> #role_beast{id=RoleID};
init(role_daily, RoleID) -> #role_daily{id=RoleID};
init(role_illusion, RoleID) -> #role_illusion{id=RoleID};
init(role_weekly, RoleID) -> #role_weekly{id=RoleID};
init(role_escort, RoleID) -> #role_escort{id=RoleID};
init(role_realname, RoleID) -> #role_realname{id=RoleID};
init(role_pay, RoleID) -> #role_pay{id=RoleID};
init(role_monitor, RoleID) -> #role_monitor{id=RoleID};
init(role_yylogin, RoleID) -> #role_yylogin{id=RoleID};
init(role_afk, RoleID) -> #role_afk{id=RoleID};
init(role_achieve, RoleID) -> #role_achieve{id=RoleID};
init(role_pet, RoleID) -> #role_pet{id=RoleID};
init(role_firstpay, RoleID) -> #role_firstpay{id=RoleID};
init(role_yy_gift, RoleID) -> #role_yy_gift{id=RoleID};
init(role_wanted, RoleID) -> #role_wanted{id=RoleID};
init(role_arena, RoleID) -> #role_arena{id=RoleID};
init(role_marriage, RoleID) -> #role_marriage{id=RoleID};
init(role_findback, RoleID) -> #role_findback{id=RoleID};
init(role_baby, RoleID) -> #role_baby{id=RoleID};
init(role_yy_lottery, RoleID) -> #role_yy_lottery{id=RoleID};
init(role_casthouse, RoleID) -> #role_casthouse{id=RoleID};
init(role_talent, RoleID) -> #role_talent{id=RoleID};
init(role_soul, RoleID) -> #role_soul{id=RoleID};
init(role_compose, RoleID) -> #role_compose{id=RoleID};
init(dunge_god, RoleID) -> #dunge_god{id=RoleID};
init(role_illustration, RoleID) -> #role_illustration{id=RoleID};
init(role_actpay, RoleID) -> #role_actpay{id=RoleID};
init(role_god_equips, RoleID) -> #role_god_equips{id=RoleID};
init(role_actinvest, RoleID) -> #role_actinvest{id=RoleID};
init(role_mecha, RoleID) -> #role_mecha{id=RoleID};
init(role_sub_equips, RoleID) -> #role_sub_equips{id=RoleID};
init(role_siegewar, RoleID) -> #role_siegewar{id=RoleID};
init(role_richman, RoleID) -> #role_richman{id=RoleID};
init(role_luckywheel, RoleID) -> #role_luckywheel{id=RoleID};
init(role_artifact, RoleID) -> #role_artifact{id=RoleID};
init(role_totem, RoleID) -> #role_totem{id=RoleID};
init(role_flop_gift, RoleID) -> #role_flop_gift{id=RoleID};

init(guild_info, GuildID) -> #guild_info{id=GuildID};
init(guild_depot, GuildID) -> #guild_depot{id=GuildID};
init(guild_redenvelope, GuildID) -> #guild_redenvelope{id=GuildID};

init(game_user, _) -> #game_user{};
init(game_rank, _) -> #game_rank{};
init(game_misc, _) -> #game_misc{};
init(mailbox, _) -> #mailbox{};
init(friend, _) -> #friend{};
init(chat_contact, _) -> #chat_contact{};
init(trade, _) -> #trade{};
init(yy_info, _) -> #yy_info{};
init(yy_role, _) -> #yy_role{};
init(mirror, _) -> #mirror{};
init(arena, _) -> #arena{};
init(arena_misc, _) -> #arena_misc{};
init(redenvelope, _) -> #redenvelope{};
init(dating, _) -> #dating{};
init(marriage, _) -> #marriage{};
init(wedding, _) -> #wedding{};
init(gw_field, _) -> #gw_field{};
init(gw_guild, _) -> #gw_guild{};
init(combat1v1_role, _) -> #combat1v1_role{};
init(yy_shop_act, _) -> #yy_shop_act{};

init(cls_node, _) -> #cls_node{};
init(_, _) -> undefined.


cache(role_info) -> [
	{#role_info.name, #role_cache.name},{#role_info.career, #role_cache.career},{#role_info.gender, #role_cache.gender},{#role_info.level, #role_cache.level},{#role_info.wake, #role_cache.wake},{#role_info.charm, #role_cache.charm},{#role_info.figure, #role_cache.figure},{#role_info.icon, #role_cache.icon},{#role_info.login, #role_cache.login},{#role_info.logout, #role_cache.logout},{#role_info.team, #role_cache.team}
];
cache(role_attr) -> [
	{#role_attr.power, #role_cache.power}
];
cache(role_vip) -> [
	{#role_vip.level, #role_cache.viplv},{#role_vip.etime, #role_cache.vipend},{#role_vip.type, #role_cache.viptype}
];
cache(role_guild) -> [
	{#role_guild.guild, #role_cache.guild},{#role_guild.post, #role_cache.gpost}
];
cache(_) -> [].


persist(role_pay) -> now;
persist(_) -> default.
