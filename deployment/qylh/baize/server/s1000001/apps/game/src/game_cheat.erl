%%%=============================================================================
%%% @author z.hua
%%% @doc
%%% GM 秘籍
%%% @end
%%%=============================================================================

-module(game_cheat).

-include("activity.hrl").
-include("attr.hrl").
-include("bag.hrl").
-include("buff.hrl").
-include("cluster.hrl").
-include("equip.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("vip.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("combat1v1.hrl").
-include("mount.hrl").

%% API
-export([handle/3]).
-export([nodes_run/3, get_nodes/0, set_time/2, time_clear/0]).
-export([start_activity/3, stop_activity/1, reloadyy/0]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(_, Tos, RoleSt) ->
	#m_game_cheat_tos{cmd=Cmd} = Tos,
	try
		Cmd2 = string:strip(Cmd),
		do_cheat(string:tokens(string:strip(Cmd2), "-"), RoleSt)
	catch
		throw:{error, Errno, Args} ->
		    ?ucast(#m_game_error_toc{errno=Errno, args=Args});
		error:{badmatch, {error, Errno, Args}}:_ ->
		    ?ucast(#m_game_error_toc{errno=Errno, args=Args});
		Class:Reason:Stacktrace ->
			?stacktrace(Class, Reason, Stacktrace),
			throw(?err(?ERR_GAME_BAD_ARGS))
	end.


do_cheat(["divide"], _RoleSt) ->
	game_misc:delete(siegewar_divide_rule),
	Center = cluster:get_center(),
	erlang:send({cluster_center, Center}, divide),
	siegewar_server:hook_chime(0);
do_cheat(["compete_stop"], _RoleSt) ->
	compete_server:gm_stop();
% %% @usage 查询账号
%% acc-角色名称
do_cheat(["acc", Name], RoleSt) ->
	Account = user_default:name2acc(Name),
	case Account == not_found of
		true  ->
			show_in_chat("不存在该玩家", RoleSt);
		false ->
			show_in_chat(Account, RoleSt)
	end;
%% @usage 获取道具
%% item-道具id
do_cheat(["item", ItemID0], RoleSt) ->
	ItemID = ut_conv:to_integer(ItemID0),
	role_bag:gain([{ItemID, 1, #{bind=>false}}], ?LOG_GM_CHEAT, RoleSt);
%% @usage 获取道具
%% item-道具id-道具数量
do_cheat(["item", ItemID0, Num0], RoleSt) ->
	ItemID = ut_conv:to_integer(ItemID0),
	Num    = ut_conv:to_integer(Num0),
	role_bag:gain([{ItemID, Num, #{bind=>false}}], ?LOG_GM_CHEAT, RoleSt);
%% @usage 获取道具
%% items-道具id列表
do_cheat(["items", ItemIDs0, Num0], RoleSt) ->
	Num   = ut_conv:to_integer(Num0),
	Items = lists:map(fun
		(ID) ->
			{ut_conv:to_integer(ID), Num, #{bind=>false}}
	end, string:tokens(ItemIDs0, ",")),
	role_bag:gain(Items, ?LOG_GM_CHEAT, RoleSt);
%% @usage 获取金钱
%% rich
do_cheat(["rich"], RoleSt) ->
	set_money(?ITEM_GOLD, 100000, RoleSt),
	set_money(?ITEM_BGOLD, 100000, RoleSt),
	set_money(?ITEM_COIN, 100000, RoleSt),
	set_money(?ITEM_BCOIN, 100000, RoleSt);
%% @usage 清除金钱
%% poor
do_cheat(["poor"], RoleSt) ->
	set_money(?ITEM_GOLD, 0, RoleSt),
	set_money(?ITEM_BGOLD, 0, RoleSt),
	set_money(?ITEM_COIN, 0, RoleSt),
	set_money(?ITEM_BCOIN, 0, RoleSt);
%% @usage 加强防御
%% tank
do_cheat(["tank"], RoleSt) ->
	set_attr([
		{?ATTR_HP,1000000000000},
		{?ATTR_HPMAX,1000000000000},
		{?ATTR_DEF,1000000000000},
		{?ATTR_TOUGH,1000000000000}
	], RoleSt);
%% @usage 加强输出
%% dps
do_cheat(["dps"], RoleSt) ->
	set_attr([
		{?ATTR_ATT,1000000000000},
		{?ATTR_WRECK,1000000000000},
		{?ATTR_HIT,1000000000000},
		{?ATTR_CRIT,1000000000000}
	], RoleSt);
%% @usage 设置元宝
%% gold-元宝数量
do_cheat(["gold", Num0], RoleSt) ->
	set_money(?ITEM_GOLD, ut_conv:to_integer(Num0), RoleSt);
%% @usage 设置绑元
%% bgold-绑元数量
do_cheat(["bgold", Num0], RoleSt) ->
	set_money(?ITEM_BGOLD, ut_conv:to_integer(Num0), RoleSt);
%% @usage 设置金币
%% coin-金币数量
do_cheat(["coin", Num0], RoleSt) ->
	set_money(?ITEM_COIN, ut_conv:to_integer(Num0), RoleSt);
%% @usage 设置绑金
%% bcoin-绑金数量
do_cheat(["bcoin", Num0], RoleSt) ->
	set_money(?ITEM_BCOIN, ut_conv:to_integer(Num0), RoleSt);
%% @usage 获取元宝
%% gold-元宝数量
do_cheat(["addgold", Num0], RoleSt) ->
	Num = ut_conv:to_integer(Num0),
	role_bag:gain([{?ITEM_GOLD, Num}], ?LOG_GM_CHEAT, RoleSt);
%% @usage 获取绑元
%% bgold-绑元数量
do_cheat(["addbgold", Num0], RoleSt) ->
	Num = ut_conv:to_integer(Num0),
	role_bag:gain([{?ITEM_BGOLD, Num}], ?LOG_GM_CHEAT, RoleSt);
%% @usage 获取金币
%% coin-金币数量
do_cheat(["addcoin", Num0], RoleSt) ->
	Num = ut_conv:to_integer(Num0),
	role_bag:gain([{?ITEM_COIN, Num}], ?LOG_GM_CHEAT, RoleSt);
%% @usage 获取绑金
%% bcoin-绑金数量
do_cheat(["addbcoin", Num0], RoleSt) ->
	Num = ut_conv:to_integer(Num0),
	role_bag:gain([{?ITEM_BCOIN, Num}], ?LOG_GM_CHEAT, RoleSt);
%% @usage 升级
%% level-等级
do_cheat(["level", Level0], RoleSt) ->
	Level = ut_conv:to_integer(Level0),
	role_bag:gain([{?ITEM_LEVEL, Level}], ?LOG_GM_CHEAT, RoleSt);
%% @usage 升级
%% level-等级
do_cheat(["setlevel", Level0], _RoleSt) ->
	Level = ut_conv:to_integer(Level0),
	RoleInfo = role_data:get(?DB_ROLE_INFO),
	role_data:set(RoleInfo#role_info{level=Level});
%% @usage 快速建号
%% quick-等级
do_cheat(["quick", Level0], RoleSt) ->
	role_bag:gain([
		{?ITEM_LEVEL, ut_conv:to_integer(Level0)}
	], ?LOG_GM_CHEAT, RoleSt),
	TaskIDs = cfg_task:trigger_by_type(?TASK_TYPE_MAIN),
	lists:foreach(fun
		(TaskID) ->
			role_task:gm_finish(TaskID, RoleSt)
	end, lists:sort(TaskIDs));
%% @usage 快速创建帮会
%% guild-帮会名称
do_cheat(["guild", GuildName], RoleSt) ->
	role_bag:gain([
		{11104,1},
		{?ITEM_GOLD, 100000},
		{?ITEM_BGOLD, 100000},
		{?ITEM_COIN, 100000},
		{?ITEM_LEVEL, 200}
	], ?LOG_GM_CHEAT, RoleSt),
	TaskIDs = cfg_task:trigger_by_type(?TASK_TYPE_MAIN),
	lists:foreach(fun
		(TaskID) ->
			role_task:gm_finish(TaskID, RoleSt)
	end, lists:sort(TaskIDs)),
	Tos = #m_guild_create_tos{name=GuildName, level=1},
	guild_handler:handle(?GUILD_CREATE, Tos, RoleSt);
%% @usage 加经验
%% level-经验
do_cheat(["exp", Num0], RoleSt) ->
	Num = ut_conv:to_integer(Num0),
	role_bag:gain([{?ITEM_EXP, Num}], ?LOG_GM_CHEAT, RoleSt);
%% @usage 给自己发邮件
%% mail-标题-内容-附件
do_cheat(["mail", Title, Text, Items0], RoleSt) ->
	Items  = ut_conv:string_to_term(Items0),
	mail:send(RoleSt#role_st.role, Title, Text, Items);
%% @usage 给别人发邮件
%% mail-玩家id-标题-内容-附件
do_cheat(["mail", RoleID0, Title, Text, Items0], _RoleSt) ->
	RoleID = ut_conv:to_integer(RoleID0),
	Items  = ut_conv:string_to_term(Items0),
	mail:send(RoleID, Title, Text, Items);
%% @usage 查看buff
%% buff
do_cheat(["buff"], RoleSt) ->
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	{ok, Actor} = scene:get_actor(ScenePid, RoleID),
	StrList = maps:fold(fun
		(_Group, Buff, Acc) ->
			#cfg_buff{name=Name} = cfg_buff:find(Buff#p_buff.id),
			[io_lib:format("~n~ts: id=~w, value=~w, etime=~s", [
				Name,
				Buff#p_buff.id,
				Buff#p_buff.value,
				ut_time:seconds_to_string(Buff#p_buff.etime)
			]) | Acc]
	end, [], Actor#actor.buffs),
	Content = string:join(StrList, "\n"),
	show_in_chat(Content, RoleSt);
%% @usage 查看属性
%% attr
do_cheat(["attr"], RoleSt) ->
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	{ok, Actor} = scene:get_actor(ScenePid, RoleID),
	AttrList = lists:keysort(1, maps:to_list(Actor#actor.attr)),
	StrList  = lists:foldl(fun
		({Code, Val}, Acc) ->
			[io_lib:format("~n~w: ~w", [Code, Val]) | Acc]
	end, [], AttrList),
	Content = string:join(StrList, "\n"),
	show_in_chat(Content, RoleSt);
%% @usage 查看属性
%% attr-属性
do_cheat(["attr", Code0], RoleSt) ->
	Code = ut_conv:to_integer(Code0),
	#role_attr{attr=Attr} = role_data:get(?DB_ROLE_ATTR),
	Val  = ?_attr(Attr, Code),
	show_in_chat(ut_conv:term_to_string(Val), RoleSt);
%% @usage 设置属性
%% attr-属性-值
do_cheat(["attr", Code0, Val0], RoleSt) ->
	Code = ut_conv:to_integer(Code0),
	Val  = ut_conv:to_integer(Val0),
	set_attr([{Code,Val}], RoleSt);
%% @usage 清理背包
%% clear-背包id
do_cheat(["clear", BagID0], RoleSt) ->
	BagID = ut_conv:to_integer(BagID0),
	#role_bag{cells=Cells} = role_data:get(?DB_ROLE_BAG),
	#cell{used=CellIDs} = maps:get(BagID, Cells),
	Cost = [{cellid,CellID} || CellID <- CellIDs],
	role_bag:cost(Cost, 0, RoleSt);
%% @usage 召唤怪物
%% creep-怪物id
do_cheat(["creep", CreepID0], RoleSt) ->
	CreepID = ut_conv:to_integer(CreepID0),
	creep:add([{CreepID,RoleSt#role_st.coord}], RoleSt);
%% @usage 切换场景
%% scene-场景id
do_cheat(["scene", SceneID0], RoleSt) ->
	SceneID = ut_conv:to_integer(SceneID0),
	Coord   = scene_util:get_born(SceneID),
	{ok, RoleSt2} = scene_change:change(
		?SCENE_CHANGE_SERVER, SceneID, 0, Coord, [], #{}, RoleSt
	),
	{ok, RoleSt2};
%% @usage 切换场景
%% scene-场景id-房间id
do_cheat(["scene", SceneID0, RoomID0], RoleSt) ->
	SceneID = ut_conv:to_integer(SceneID0),
	RoomID  = ut_conv:to_integer(RoomID0),
	Coord   = scene_util:get_born(SceneID),
	{ok, RoleSt2} = scene_change:change(
		?SCENE_CHANGE_SERVER, SceneID, RoomID, Coord, [], #{}, RoleSt
	),
	{ok, RoleSt2};
%% @usage 查看开服天数
%% opdays
do_cheat(["opdays"], RoleSt) ->
	Days = game_env:get_opened_days(),
	show_in_chat(ut_conv:to_list(Days), RoleSt);
%% @usage 设置开服天数
%% opdays-天数
do_cheat(["opdays", Days0], RoleSt) ->
	Days = ut_conv:to_integer(Days0),
	?_check(Days > 0, ?ERR_GAME_BAD_ARGS),
	{Date, Time} = game_env:get_env(opened),
	Date2 = ut_time:add_days(Date, Days-1),
	set_time(Date2, Time, RoleSt),
	Center = game_env:get_center(),
	SUID = game_env:get_suid(),
	Data = #{
		otime => game_env:get_opened_time(),
		level => world_level:get_level()
	},
	cluster_center:push(Center, SUID, Data);
%% @usage 设置开服时间
%% otime-Days0
do_cheat(["otime", Days0], _RoleSt) ->
	Days = ut_conv:to_integer(Days0),
	?_check(Days > 0, ?ERR_GAME_BAD_ARGS),
	{Date, Time} = ut_time:datetime(),
	Date2 = ut_time:add_days(Date, 1-Days),
	application:set_env(game_env, opened, {Date2,Time}),
	Center = game_env:get_center(),
	SUID = game_env:get_suid(),
	Data = #{
		otime => game_env:get_opened_time(),
		level => world_level:get_level()
	},
	cluster_center:push(Center, SUID, Data);
%% @usage 查看服务器时间
%% time
do_cheat(["time"], RoleSt) ->
	DateTime = ut_time:datetime(),
	show_in_chat(ut_conv:term_to_string(DateTime), RoleSt);
%% @usage 清除服务器时间设置
%% timeclear
do_cheat(["timeclear"], _RoleSt) ->
	nodes_run(?MODULE, time_clear, []);
%% @usage 设置服务器时间
%% time-时间
%% time-20.09.10
do_cheat(["time", Time0], RoleSt) ->
	Time = ut_time:string_to_time(Time0, "."),
	set_time(ut_time:date(), Time, RoleSt);
%% @usage 设置服务器时间
%% time-日期-时间
%% time-2019.12.01-20.09.10
do_cheat(["time", Date0, Time0], RoleSt) ->
	Date = ut_time:string_to_date(Date0, "."),
	Time = ut_time:string_to_time(Time0, "."),
	set_time(Date, Time, RoleSt);
%% @usage 设置玩家速度
%% speed-速度
do_cheat(["speed", Speed0], RoleSt) ->
	Speed = ut_conv:to_integer(Speed0),
	?ucast(#m_role_update_toc{upint=#{"attr.speed"=>Speed}});
%% @usage 设置vip等级
%% vip-vip等级
do_cheat(["vip", Vip0], RoleSt) ->
	VipLv  = ut_conv:to_integer(Vip0),
	#cfg_vip_level{exp=VipExp} = cfg_vip_level:find(VipLv),
	VipEnd = ut_time:seconds() + 24*60*60,
	RoleVip = role_data:get(?DB_ROLE_VIP),
	role_data:set(RoleVip#role_vip{
		level = VipLv,
		exp   = VipExp,
		type  = ?VIP_TYPE_NORM,
		etime = VipEnd,
		card  = 1
	}),
	role_event:event(?EVENT_VIPLV, VipLv),
	UpInt = #{
		"viptype" => ?VIP_TYPE_NORM,
		"viplv"   => VipLv,
		"vipexp"  => VipExp,
		"vipend"  => VipEnd
	},
	?ucast(#m_role_update_toc{upint=UpInt});
%% @usage 完成当前所有主线任务
%% fintask
do_cheat(["fintask"], RoleSt) ->
	TaskIDs = cfg_task:trigger_by_type(?TASK_TYPE_MAIN),
	lists:foreach(fun
		(TaskID) ->
			role_task:gm_finish(TaskID, RoleSt)
	end, lists:sort(TaskIDs));
%% @usage 完成指定任务
%% fintask-TaskID
do_cheat(["fintask", TaskID0], RoleSt) ->
	TaskID = ut_conv:to_integer(TaskID0),
	role_task:gm_finish(TaskID, RoleSt);
%% @usage 接受任务
%% addtask-任务id
do_cheat(["addtask", TaskID0], RoleSt) ->
	TaskID = ut_conv:to_integer(TaskID0),
	role_task:remove(TaskID),
	?ucast(#m_task_update_toc{del=[TaskID]}),
	role_task:gm_trigger(TaskID, RoleSt);
%% @usage 删除任务
%% deltask-任务id
do_cheat(["deltask", TaskID0], RoleSt) ->
	TaskID = ut_conv:to_integer(TaskID0),
	role_task:remove(TaskID),
	?ucast(#m_task_update_toc{del=[TaskID]});
%% @usage 清除任务
%% clrtask
do_cheat(["clrtask"], RoleSt) ->
	role_data:set(#role_task{id=RoleSt#role_st.role});
%% @usage 完成公会任务
%% guildtask
do_cheat(["guildtask"], RoleSt) ->
	#role_task{accept=Accepted} = role_data:get(?DB_ROLE_TASK),
	TaskIDs = cfg_task:trigger_by_type(?TASK_TYPE_GUILD),
	lists:foreach(fun
		(TaskID) ->
			role_task:gm_finish(TaskID, RoleSt)
	end, maps:keys(maps:with(TaskIDs, Accepted)));
%% @usage 踢玩家下线
%% kick-RoleID
do_cheat(["kick", RoleID0], _RoleSt) ->
	RoleID = ut_conv:to_integer(RoleID0),
	role:kickout(RoleID, ?ERR_GAME_KICKOUT);
%% @usage 重新加载活动配置
%% reload
do_cheat(["reload"], _RoleSt) ->
	activity_manager:reload(),
	nodes_run(activity_manager, reload, []);
%% @usage 开启活动
%% start-ActID-持续时长(秒)
do_cheat(["start", ActID0, Last0], _RoleSt) ->
	ActID = ut_conv:to_integer(ActID0),
	Last  = ut_conv:to_integer(Last0),
	?_if(activity:is_start(ActID), throw(?err(?ERR_GAME_BAD_ARGS))),
	Date  = ut_time:date(),
	STime = ut_time:add_seconds(ut_time:time(), 5),
	ETime = ut_time:add_seconds(ut_time:time(), 5+Last),
	Start = ut_time:datetime_to_seconds({Date, STime}),
	Stop  = ut_time:datetime_to_seconds({Date, ETime}),
	nodes_run(?MODULE, start_activity, [ActID, Start, Stop]);

%% @usage 关闭活动
%% stop-ActID
do_cheat(["stop", ActID0], _RoleSt) ->
	ActID = ut_conv:to_integer(ActID0),
	nodes_run(?MODULE, stop_activity, [ActID]);

%% @usage 开启运营活动
%% startyy-ActID-持续时长(秒)
do_cheat(["startyy", ActID0, Last0], _RoleSt) ->
	ActID = ut_conv:to_integer(ActID0),
	Last  = ut_conv:to_integer(Last0),
	?_if(activity:is_start(ActID), throw(?err(?ERR_GAME_BAD_ARGS))),
	Date  = ut_time:date(),
	STime = ut_time:add_seconds(ut_time:time(), 5),
	ETime = ut_time:add_seconds(ut_time:time(), 5+Last),
	Start = ut_time:datetime_to_seconds({Date, STime}),
	Stop  = ut_time:datetime_to_seconds({Date, ETime}),
	yunying_manager:gm_start(ActID, Start, Stop);
%% @usage 关闭运营活动
%% stopyy-ActID
do_cheat(["stopyy", ActID0], _RoleSt) ->
	ActID = ut_conv:to_integer(ActID0),
	yunying_manager:gm_stop(ActID);
%% @usage 重新加载运营活动配置
%% reloadyy
do_cheat(["reloadyy"], _RoleSt) ->
	nodes_run(?MODULE, reloadyy, []);
%% @usage 清理运营活动数据
%% clearyy-ActID
do_cheat(["clearyy", ActID0], _RoleSt) ->
	ActID = ut_conv:to_integer(ActID0),
	yunying_manager:set_yy_info(#yy_info{id=ActID}),
	yunying_agent:gm_stop(ActID);
%% @usage 设置离线挂机时长
%% afk-时长(秒)
do_cheat(["afk", Last0], _RoleSt) ->
	Last    = ut_conv:to_integer(Last0),
	RoleAFK = role_data:get(?DB_ROLE_AFK),
	role_data:set(RoleAFK#role_afk{time=Last});
%% @usage 进入副本
%% dunge-副本id
do_cheat(["dunge", Dunge0], _RoleSt) ->
	Dunge = ut_conv:to_integer(Dunge0),
	Mod = gateway_router:route(1203),
	Tos = #m_dunge_enter_tos{stype=0, id=Dunge, floor=0},
	role:cast(self(), {pt, Mod, 1203002, Tos});
%% @usage 离开副本
%% leave
do_cheat(["leave"], _RoleSt) ->
	Mod = gateway_router:route(1200),
	Tos = #m_scene_leave_tos{},
	role:cast(self(), {pt, Mod, 1200003, Tos});
%% @usage 查看技能列表
%% skill
do_cheat(["skill"], RoleSt) ->
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	{ok, Actor} = scene:get_actor(ScenePid, RoleID),
	SkillList = lists:keysort(1, maps:to_list(Actor#actor.skills)),
	StrList = lists:foldl(fun
		({SkillID, SkillLv}, Acc) ->
			#cfg_skill{name=Name} = cfg_skill:find(SkillID),
			[io_lib:format("~w(~ts) -> ~w", [SkillID, Name, SkillLv]) | Acc]
	end, [], SkillList),
	Content = string:join(StrList, "\n"),
	show_in_chat(Content, RoleSt);
%% @usage 技能新增
%% addskill-技能id
do_cheat(["addskill", SkillID0], RoleSt) ->
	SkillID = ut_conv:to_integer(SkillID0),
	role_skill:active(SkillID, RoleSt);
%% @usage 技能删除
%% delskill-技能id
do_cheat(["delskill", SkillID0], RoleSt) ->
	SkillID = ut_conv:to_integer(SkillID0),
	role_skill:remove(SkillID, RoleSt);
%% @usage 魔法塔
%% tower-层数
do_cheat(["tower", Floor0], RoleSt) ->
	Floor = ut_conv:to_integer(Floor0),
	role_data:set(#dunge_magic{
		id          = RoleSt#role_st.role,
		clear_floor = Floor
	});
%% @usage 模拟充值
%% pay-GoodsID
do_cheat(["pay", GoodsID0], RoleSt) ->
	GoodsID = ut_conv:to_integer(GoodsID0),
	{ok, OrderID} = order_server:new_order(RoleSt#role_st.role),
	Price = cfg_recharge:price(GoodsID),
	Params = #{
        sdk_order  => OrderID,
        app_order  => OrderID,
        role_id    => RoleSt#role_st.role,
        goods_id   => GoodsID,
        total_fee  => Price,
        pay_type   => 1,
        game_gold  => 0,
        extra_gold => 0,
        is_real    => false
    },
	role_pay:pay(Params, RoleSt);
%% @usage 设置世界等级
%% worldlv-Level0
do_cheat(["worldlv", Level0], _RoleSt) ->
	Level = ut_conv:to_integer(Level0),
	mochiglobal:put(world_level, Level);
%% @usage 设置跨服世界等级
%% crosslv-Level0
do_cheat(["crosslv", Level0], _RoleSt) ->
	Level = ut_conv:to_integer(Level0),
	cluster:rpc_call_cross(?CROSS_RULE_24_8, mochiglobal, put, [world_level, Level]);
%% @usage 中断采集
%% break
do_cheat(["break"], RoleSt) ->
	fight_collect:break(RoleSt);
%% @usage 模拟发包
%% pt-协议id
do_cheat(["pt", MsgID0], _RoleSt) ->
	MsgID = ut_conv:to_integer(MsgID0),
	Mod   = gateway_router:route(MsgID div 1000),
	Tos   = list_to_tuple([element(3, proto:get_tos(MsgID))]),
	role:cast(self(), {pt, Mod, MsgID, Tos});
%% @usage 模拟发包
%% pt-协议id-协议内容
%% pt-1100002-RoleID
do_cheat(["pt", MsgID0, Args0], _RoleSt) ->
	MsgID = ut_conv:to_integer(MsgID0),
	Args  = ut_conv:string_to_term(lists:concat(["[", Args0, "]"])),
	Mod   = gateway_router:route(MsgID div 1000),
	Tos   = list_to_tuple([element(3, proto:get_tos(MsgID)) | Args]),
	role:cast(self(), {pt, Mod, MsgID, Tos});
%% @usage 查看场景信息
%% scene
do_cheat(["scene"], RoleSt) ->
	#role_st{scene=SceneID, room=RoomID, line=LineID} = RoleSt,
	Content = io_lib:format(
		"~ts: ~w, ~ts: ~w, ~ts: ~w",
		[
			"当前场景", SceneID,
			"当前房间", RoomID,
			"当前分线", LineID
		]
	),
	show_in_chat(Content, RoleSt);
%% @usage 查看分线信息
%% line
do_cheat(["line"], RoleSt) ->
	#role_st{scene=SceneID, room=RoomID} = RoleSt,
	{ok, Lines} = scene_manager:get_lines(SceneID, RoomID),
	Content = maps:fold(fun
		(LineID, Line, Acc) ->
			[io_lib:format("~w : ~w~n", [LineID, Line#line.num]) | Acc]
	end, [], Lines),
	show_in_chat(Content, RoleSt);
%% @usage 查看玩家数据
%% role-Key
do_cheat(["role", Key0], RoleSt) ->
	Key = ut_conv:to_atom(Key0),
	Val = role_data:get(Key),
	show_in_chat(ut_conv:term_to_string(Val), RoleSt);
% @usage 查看场景对象信息
% actor
do_cheat(["actor"], RoleSt) ->
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	{ok, Actor} = scene:get_actor(ScenePid, RoleID),
	show_actor(Actor, RoleSt);
%% @usage 查看场景对象信息
%% actor-对象ID
do_cheat(["actor", ActorID0], RoleSt) ->
	ActorID = ut_conv:to_integer(ActorID0),
	{ok, Actor} = scene:get_actor(RoleSt#role_st.spid, ActorID),
	show_actor(Actor, RoleSt);
%% @usage 日常进度添加活跃度
%% daily-活跃度
do_cheat(["daily", Num0], RoleSt) ->
	Num = ut_conv:to_integer(Num0),
	#role_daily{total=Total} = RoleDaily = role_data:get(?DB_ROLE_DAILY),
	role_data:set(RoleDaily#role_daily{total = Total+Num}),
	daily_handler:handle(?DAILY_INFO, ?nil, RoleSt);
%% @usage 日常幻化添加经验
%% daily_illusion-经验
do_cheat(["daily_illusion", Num0], _RoleSt) ->
	Num = ut_conv:to_integer(Num0),
	role_illusion:add_exp(Num);
%% @usage 登录奖励，设置累计登录天数
%% yylogin-天数
do_cheat(["yylogin", Day0], _RoleSt) ->
	Day = ut_conv:to_integer(Day0),
	Login = role_data:get(?DB_ROLE_YYLOGIN),
    role_data:set(Login#role_yylogin{days=Day});
%% @usage 获得BUFF
%% addbuff-BUFFID
do_cheat(["addbuff", BuffID0], RoleSt) ->
	BuffID = ut_conv:to_integer(BuffID0),
	buff:add([BuffID], RoleSt);
%% @usage 删除BUFF
%% delbuff-BUFFID
do_cheat(["delbuff", BuffID0], RoleSt) ->
	BuffID = ut_conv:to_integer(BuffID0),
	buff:del([BuffID], RoleSt);
%发送系统公告
do_cheat(["notice", Content], _RoleSt)->
	chat_server:notice(Content, 1);
%% @usage 清除次数
%% count
do_cheat(["count"], _RoleSt) ->
	RoleCount = role_data:get(?DB_ROLE_COUNT),
	role_data:set(RoleCount#role_count{counter=#{}, reset=0});
%% @usage 清除技能cd
%% skillcd
do_cheat(["skillcd"], RoleSt) ->
	erase(k_attack_time),
	role_skill:refresh(RoleSt);
%% @usage 升值VIP月卡天数
%% vip_mcard-Day
do_cheat(["vip_mcard", Day0], RoleSt) ->
	Day = ut_conv:to_integer(Day0),
	#role_vip{mfetch=MFetch0} = RoleVip = role_data:get(?DB_ROLE_VIP),
	Max = lists:max(cfg_vip_mcard:all()),
	MFetch1 = lists:foldl(fun(D, Acc) ->
		maps:put(D+1, true, Acc)
	end, MFetch0, lists:seq(0, min(Max, Day-1))),
	MFetch = maps:put(Day, false, MFetch1),
	role_data:set(RoleVip#role_vip{mcard=true, mfetch=MFetch}),
	vip_handler:handle(?VIP_MCARD, ?nil, RoleSt);
%% @usage 开启婚礼
%% wedding
do_cheat(["wedding"], RoleSt) ->
	case role_marriage:wtime(RoleSt#role_st.role) of
		{STime, _ETime} ->
			{Date, Time} = ut_time:seconds_to_datetime(STime-wedding_util:pre()),
			set_time(Date, Time, RoleSt),
			activity_manager:reload(cfg_marriage:activity());
		_ ->
			ignore
	end;
%% @usage 清空今天的婚礼预约
%% weddingclear
do_cheat(["weddingclear"], RoleSt) ->
	wedding_manager:gm_clear(),
	do_cheat(["stop", cfg_marriage:activity()], RoleSt),
	do_cheat(["timeclear"], RoleSt),
	activity_manager:reload(cfg_marriage:activity());
%% @usage 掉落
%% drop-Min-Max
do_cheat(["drop", Seq0, Num0], RoleSt) ->
	Seq = ut_conv:to_integer(Seq0),
	Num = ut_conv:to_integer(Num0),
	DropList = [{cfg_drop:seq2id(Seq), Num}],
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	Gain = creep_drop:calc(RoleLv, DropList),
	Total = lists:foldl(fun({ID, Num1, _}, Acc) ->
		ut_misc:maps_increase(ID, Num1, Acc)
	end, #{}, Gain),
	?debug("~w", [Total]),
	role_bag:gain(Gain, ?LOG_GM_CHEAT, RoleSt);
%% @usage 巅峰1v1段位
%% combat1v1_grade-Grade
do_cheat(["combat1v1_grade", Grade0], RoleSt) ->
	Grade = ut_conv:to_integer(Grade0),
	combat1v1_server:gm_set_grade(RoleSt#role_st.role, Grade);
%% @usage 巅峰1v1设置功勋
%% combat1v1_merit-Merit
do_cheat(["combat1v1_merit", Merit0], RoleSt) ->
	Merit = ut_conv:to_integer(Merit0),
	combat1v1_server:gm_set_merit(RoleSt#role_st.role, Merit);
%% @usage 重置神灵之路
%% resetgod
do_cheat(["resetgod"], RoleSt) ->
	role_data:set(#dunge_god{id=RoleSt#role_st.role});
%% @usage 设置神灵之路关卡
%% setgodwave-Wave
do_cheat(["setgodwave",Wave0], _RoleSt) ->
	Wave = ut_conv:to_integer(Wave0),
	DungeGod = role_data:get(?DB_DUNGE_GOD),
	role_data:set(DungeGod#dunge_god{cur_wave = Wave});
%% @usage 重置大富豪
%% richman
do_cheat(["richman"], RoleSt) ->
	role_data:set(#role_richman{id=RoleSt#role_st.role});
%% @usage 获取套装
%% equip-Gender-Order-Color
do_cheat(["equip", Career0, Order0, Color0], RoleSt) ->
	Career = ut_conv:to_integer(Career0),
	Order  = ut_conv:to_integer(Order0),
	Color  = ut_conv:to_integer(Color0),
	Items1 = cfg_equip:equips(Order),
	Items2 = cfg_item:items_with_color(Color),
	Gain = lists:filtermap(fun
		(ItemID) ->
			#cfg_equip{career=Careers} = cfg_equip:find(ItemID),
			case lists:member(Career, Careers) andalso lists:member(ItemID, Items2) of
				true  -> {true, {ItemID,1}};
				false -> false
			end
	end, Items1),
	role_bag:gain(Gain, ?LOG_GM_CHEAT, RoleSt);
%% @usage 666
%% 666
do_cheat(["666"], RoleSt) ->
	#role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
	Trains = #{
		?TRAIN_WING => #p_train{
			type  = ?TRAIN_WING,
			exp   = 0,
			level = cfg_wing:max()
		},
		?TRAIN_TALIS => #p_train{
			type  = ?TRAIN_TALIS,
			exp   = 0,
			level = cfg_talis:max()
		},
		?TRAIN_WEAPON => #p_train{
			type  = ?TRAIN_WEAPON,
			exp   = 0,
			level = cfg_weapon:max()
		},
		?TRAIN_GOD => #p_train{
			type  = ?TRAIN_GOD,
			exp   = 0,
			level = cfg_god:max()
		}
	},
	Mounts = #{
		?TRAIN_MOUNT   => #mount{
			type  = ?TRAIN_MOUNT,
			order = cfg_mount:max_order(),
			level = cfg_mount:max_level(cfg_mount:max_order()),
			exp   = 0
		},
		?TRAIN_OFFHAND => #mount{
			type  = ?TRAIN_OFFHAND,
			order = cfg_offhand:max_order(),
			level = cfg_offhand:max_level(cfg_offhand:max_order()),
			exp   = 0
		}
	},
	Morphs = #{
		?TRAIN_MOUNT => [#p_morph{
			id   = ID,
			star = 1
		} || ID <- cfg_mount_morph:list()],
		?TRAIN_OFFHAND => [#p_morph{
			id   = ID,
			star = 1
		} || ID <- cfg_offhand_morph:list()],
		?TRAIN_WING => [#p_morph{
			id   = ID,
			star = 1
		} || ID <- cfg_wing_morph:list()],
		?TRAIN_TALIS => [#p_morph{
			id   = ID,
			star = 1
		} || ID <- cfg_talis_morph:list()],
		?TRAIN_WEAPON => [#p_morph{
			id   = ID,
			star = 1
		} || ID <- cfg_weapon_morph:list()],
		?TRAIN_GOD => [#p_morph{
			id   = ID,
			star = 1
		} || ID <- cfg_god_morph:list()]
	},
	Using = #{
		?TRAIN_MOUNT   => {train,1},
		?TRAIN_OFFHAND => {train,1},
		?TRAIN_WING    => {morph,?TRAIN_WING*10000+Gender*1000},
		?TRAIN_WEAPON  => {morph,?TRAIN_WEAPON*10000+Gender*1000},
		?TRAIN_TALIS   => {morph,?TRAIN_WING*10000+Gender*0},
		?TRAIN_GOD     => {morph,?TRAIN_WING*10000+Gender*0}
	},
	RoleTrain = #role_train{
		id     = RoleSt#role_st.role,
		trains = Trains,
		mounts = Mounts,
		morphs = Morphs,
		using  = Using
	},
	role_data:set(RoleTrain);
%觉醒
do_cheat(["wake", Wake], RoleSt)->
	Wake2 = ut_conv:to_integer(Wake),
	RoleInfo = role_data:get(?DB_ROLE_INFO),
	Grid = case Wake2 of
		4 -> 12;
		5 -> 47;
		6 -> 137;
		_ -> 0
	end,
	role_data:set(RoleInfo#role_info{wake=Wake2}),
	RoleWake = role_data:get(?DB_ROLE_WAKE),
	role_data:set(RoleWake#role_wake{grid = Grid}),
	UpInt = #{"wake"=>Wake2},
	role_hook:hook_wake(Wake2, RoleSt),
	?ucast(#m_role_update_toc{upint=UpInt, upstr=#{}});

%聊天机器人
do_cheat(["faker_chat"], _RoleSt)->
	chat_server:gm_faker_chat();

%勇者圣坛跳层
do_cheat(["warrior_floor", Floor], RoleSt)->
	Floor2 = ut_conv:to_integer(Floor),
	SceneID = case Floor2 =< 6 of
		true  -> 30391;
		false -> 30392
	end,
	Opts = #{act_id=>10231, bctype => ?BCTYPE_SCENE},
	Coord = scene_util:get_born(SceneID),
	scene_change:change(4, SceneID, Floor2, Coord, [], Opts, RoleSt);

do_cheat(["warrior_floor_cross", Floor], RoleSt)->
	Floor2 = ut_conv:to_integer(Floor),
	SceneID = case Floor2 =< 6 of
		true  -> 30393;
		false -> 30394
	end,
	Opts = #{act_id=>10232, bctype => ?BCTYPE_SCENE},
	Coord = scene_util:get_born(SceneID),
	?debug("change ~p ~p", [SceneID, Floor2]),
	scene_change:change(4, SceneID, Floor2, Coord, [], Opts, RoleSt);

do_cheat(["cgw"], _RoleSt) ->
	cluster:rpc_call_cross(?CROSS_RULE_24_8, guild_crosswar, hook_start, [12001]),
	cluster:rpc_call_cross(?CROSS_RULE_24_8, guild_crosswar, hook_stop, [12001]),
	cluster:rpc_call_cross(?CROSS_RULE_24_8, guild_crosswar, hook_start, [12002]),
	cluster:rpc_call_cross(?CROSS_RULE_24_8, guild_crosswar, hook_stop, [12002]),
	ok;

do_cheat(["cgwclear"], _RoleSt) ->
	cluster:rpc_call_cross(?CROSS_RULE_24_8, guild_crosswar, hook_start, [12001]),
	cluster:rpc_call_cross(?CROSS_RULE_24_8, guild_crosswar, hook_stop, [12001]),
	cluster:rpc_call_cross(?CROSS_RULE_24_8, guild_crosswar, hook_start, [12002]),
	cluster:rpc_call_cross(?CROSS_RULE_24_8, guild_crosswar, hook_stop, [12002]),
	cluster:rpc_call_cross(?CROSS_RULE_24_8, guild_crosswar, hook_start, [12003]),
	cluster:rpc_call_cross(?CROSS_RULE_24_8, guild_crosswar, hook_stop, [12003]),
	ok;
do_cheat(Cmd, _RoleSt) ->
	?debug("invalid cheat command: ~s", [Cmd]).

show_actor(Actor, RoleSt) ->
	Fields = record_info(fields, actor),
	Values = tl(tuple_to_list(Actor)),
	KVList = lists:zipwith(fun
		(Field, Value) ->
			io_lib:format('~w : ~p', [Field, Value])
	end, Fields, Values),
	show_in_chat(string:join(KVList, "\n"), RoleSt).

show_in_chat(Content, RoleSt) ->
	?ucast(#m_chat_channel_toc{
		channel_id = 1,
		content    = Content,
		sender     = role:get_base(RoleSt#role_st.role),
		ids        = #{}
	}).

set_money(ItemID, Num, RoleSt) ->
	RoleBag = #role_bag{money=Money} = role_data:get(?DB_ROLE_BAG),
	Money2  = maps:put(ItemID, Num, Money),
	role_data:set(RoleBag#role_bag{money=Money2}),
	?ucast(#m_role_update_toc{money=#{ItemID=>Num}}).

set_time(Date, Time, RoleSt) ->
	set_time(Date, Time, RoleSt, true).

set_time(Date, Time, RoleSt, SetAll) ->
	nodes_run(?MODULE, set_time, [Date, Time], SetAll),
	?ucast(#m_game_time_toc{
		time = ut_time:milliseconds(),
		tz   = ut_time:timezone()
	}),
	#role_st{role=RoleID, name=Name} = RoleSt,
	?notify(?MSG_CHANGE_TIME, [{role,RoleID,Name}]).

set_time(Date, Time) ->
	NowTime = erlang:system_time(second),
	SetTime = ut_time:datetime_to_seconds({Date,Time}),
	game_misc:write(gm_time, {SetTime, NowTime}),
	mochiglobal:put(gm_time, {SetTime, NowTime}),
	is_pid(erlang:whereis(combat1v1_settle)) andalso combat1v1_settle:gm_change_opend().

time_clear() ->
	game_misc:delete(gm_time),
	mochiglobal:put(gm_time, ?nil),
	is_pid(erlang:whereis(combat1v1_settle)) andalso combat1v1_settle:gm_change_opend().

start_activity(ActID, Start, Stop) ->
	#cfg_activity{type=Type} = cfg_activity:find(ActID),
	case Type of
		?ACTIVITY_TYPE_LOCAL ->
			ActID == 10125 andalso game_misc:write(?COMBAT1V1_MISC_MODE, local),
			activity_manager:gm_start(ActID, Start, Stop);
		?ACTIVITY_TYPE_CROSS ->
			ActID == 10126 andalso game_misc:write(?COMBAT1V1_MISC_MODE, cross),
			activity_manager:gm_start(ActID, Start, Stop)
	end.

stop_activity(ActID) ->
	#cfg_activity{type=Type} = cfg_activity:find(ActID),
	case Type of
		?ACTIVITY_TYPE_LOCAL ->
			ActID == 10125 andalso game_misc:write(?COMBAT1V1_MISC_MODE,
				game_misc:dirty_read(?COMBAT1V1_MISC_MODE)),
			activity_manager:gm_stop(ActID);
		?ACTIVITY_TYPE_CROSS ->
			ActID == 10126 andalso game_misc:write(?COMBAT1V1_MISC_MODE,
				game_misc:dirty_read(?COMBAT1V1_MISC_MODE)),
			activity_manager:gm_stop(ActID)
	end.

reloadyy() ->
	catch yunying_manager:reload().

nodes_run(Mod, Fun, Args) ->
	nodes_run(Mod, Fun, Args, true).

nodes_run(Mod, Fun, Args, SetAll) ->
	erlang:apply(Mod, Fun, Args),
	?_if(SetAll, [rpc:call(Node, Mod, Fun, Args) || Node <- get_nodes()]).

get_nodes() ->
	Center = cluster:get_center(),
	case Center == ?nil of
		true  ->
			[];
		false ->
			Nodes = [Node#cls_node.name ||
				#cls_index{node=Node} <- ets:tab2list(?ETS_CLUSTER_INDEX),
				Node#cls_node.name =/= node()
			],
			[Center | Nodes]
	end.

set_attr(Attrs, RoleSt) ->
	RoleAttr = #role_attr{attr=Attr} = role_data:get(?DB_ROLE_ATTR),
	Attr2 = mod_attr:set(Attr, Attrs),
	Power2 = mod_attr:power(Attr2),
	role_data:set(RoleAttr#role_attr{attr=Attr2}),
	role_util:set_power(Power2),
	#role_st{role=RoleID, spid=ScenePid} = RoleSt,
	scene:update_actor(ScenePid, RoleID, [{attr, Attr2, Power2}]),
	?ucast(#m_role_upattr_toc{
		attr  = mod_attr:p_attr(Attr2),
		power = Power2
	}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
