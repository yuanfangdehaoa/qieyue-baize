%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(mount_handler).

-include("game.hrl").
-include("item.hrl").
-include("mount.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").

%% API
-export([handle/3]).
-export([hook_sysopen/2]).
-export([get_attr/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 信息
handle(?MOUNT_INFO, Tos, RoleSt) ->
	#m_mount_info_tos{type=Type} = Tos,
	#role_train{mounts=Mounts, using=Using} = role_data:get(?DB_ROLE_TRAIN),
	Mount = maps:get(Type, Mounts, #mount{}),
	{_, Figure} = maps:get(Type, Using, {?nil,0}),
	?ucast(#m_mount_info_toc{
		type   = Type,
		order  = Mount#mount.order,
		level  = Mount#mount.level,
		exp    = Mount#mount.exp,
		train  = Mount#mount.train,
		figure = Figure
	});

%% 升阶
handle(?MOUNT_UPGRADE, Tos, RoleSt) ->
	#m_mount_upgrade_tos{type=Type, item_id=ItemID} = Tos,
	RoleTrain = #role_train{mounts=Mounts} = role_data:get(?DB_ROLE_TRAIN),
	Mount = maps:get(Type, Mounts, #mount{}),
	#mount{order=Order1, level=Level1, exp=Exp} = Mount,
	#cfg_item{stype=ItemSType, effect=ExpAdd} = cfg_item:find(ItemID),
	check_upgrade(Type, Mount, ItemSType),
	role_bag:cost([{ItemID, 1}], ?LOG_MOUNT_UPGRADE, RoleSt),
	MountMod = get_config_mod(Type, mount),
	Mount1 = Mount#mount{exp = Exp+ExpAdd},
	Mount2 = maybe_upgrade(MountMod, Mount1, RoleSt),
	role_data:set(RoleTrain#role_train{
		mounts = maps:put(Type, Mount2, Mounts)
	}),
	#mount{order=Order2, level=Level2} = Mount2,
	case Order1 < Order2 orelse Level1 /= Level2 of
		true  ->
			role_attr:recalc({?MODULE, Type}, RoleSt),
			?_if(Order2 > Order1, change_figure(Type, Order2, RoleSt)),
			role_event:event(?EVENT_TRAIN_ORDER, {Type, Order2, Level2}),

			LogType = 1107 * 1000 + Type * 100 + 1,
			Action  = #{
				train_type => Type,
				item_id    => ItemID,
				old_order  => Order1,
				new_order  => Order2,
				old_level  => Level1,
				new_level  => Level2
			},
			role_logger:log(LogType, Action, RoleSt);
		false ->
			ignore
	end,
	?ucast(#m_mount_upgrade_toc{
		type  = Type,
		order = Mount2#mount.order,
		level = Mount2#mount.level,
		exp   = Mount2#mount.exp
	});

%% 培养
handle(?MOUNT_TRAIN, Tos, RoleSt) ->
	#m_mount_train_tos{type=Type, item_id=ItemID} = Tos,
	RoleTrain = #role_train{mounts=Mounts} = role_data:get(?DB_ROLE_TRAIN),
	Mount  = maps:get(Type, Mounts, ?nil),
	?_check(Mount /= ?nil, ?ERR_MOUNT_NOT_ACTIVE, [Type]),
	check_train(Type, ItemID, Mount),
	role_bag:cost([{ItemID, 1}], ?LOG_MOUNT_TRAIN, RoleSt),
	#mount{train=Train} = Mount,
	Level2 = maps:get(ItemID, Train, 0) + 1,
	Mount2 = Mount#mount{train=maps:put(ItemID, Level2, Train)},
	role_data:set(RoleTrain#role_train{
		mounts = maps:put(Type, Mount2, Mounts)
	}),
	role_attr:recalc({?MODULE, Type}, RoleSt),

	LogType = 1107 * 1000 + Type * 100 + 1,
	Action  = #{
		train_type => Type,
		item_id    => ItemID,
		new_level  => Level2
	},
	role_logger:log(LogType, Action, RoleSt),

	?ucast(#m_mount_train_toc{type=Type, item_id=ItemID, num=Level2});

%% 切换形象
handle(?MOUNT_FIGURE, Tos, RoleSt) ->
	#m_mount_figure_tos{type=Type, order=Order} = Tos,
	#role_train{mounts=Mounts} = role_data:get(?DB_ROLE_TRAIN),
	#mount{order=CurOrder} = maps:get(Type, Mounts, #mount{}),
	?_check(Order > 0 andalso Order =< CurOrder, ?ERR_MOUNT_NOT_ACTIVE, [Type]),
	change_figure(Type, Order, RoleSt);

%% 上下坐骑
handle(?MOUNT_RIDE, Tos, RoleSt) ->
	#m_mount_ride_tos{type=Type} = Tos,
	check_ride(Type, RoleSt),
	#role_train{using=Using} = role_data:get(?DB_ROLE_TRAIN),
	ResID = case maps:find(?TRAIN_MOUNT, Using) of
		{ok, {train,Order}} ->
			cfg_mount:res(Order);
		{ok, {morph,MorID}} ->
			cfg_mount_morph:res(MorID);
		error ->
			?nil
	end,
	role_figure:update_mount(ResID, Type == 1, RoleSt),
	?ucast(#m_mount_ride_toc{type=Type}).


hook_sysopen(Type, RoleSt) ->
	RoleTrain = #role_train{mounts=Mounts} = role_data:get(?DB_ROLE_TRAIN),
	case maps:is_key(Type, Mounts) of
		true  ->
			ignore;
		false ->
			Order = 1,
			Level = 0,
			Mounts2 = maps:put(Type, #mount{type=Type, order=Order}, Mounts),
			role_data:set(RoleTrain#role_train{mounts=Mounts2}),
			change_figure(Type, Order, RoleSt),
			MountMod = get_config_mod(Type, mount),
			active_skill(MountMod, Order, Level, RoleSt),
			role_event:event(?EVENT_TRAIN_ORDER, {Type, Order, Level}),
			role_attr:recalc({?MODULE, Type}, RoleSt)
	end.

%% 升级属性 * (100%+属性丹百分比加成) + 属性丹属性(剔除百分比属性) + 天赋技能属性(升级属性*xx%)
get_attr(_AttrType, Type) ->
	#role_train{mounts=Mounts} = role_data:get(?DB_ROLE_TRAIN),
	#role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
	case maps:find(Type, Mounts) of
		{ok, Mount} ->
			#mount{order=Order, level=Level, train=Trains} = Mount,
			TrainMod = get_config_mod(Type, train),
			MountMod = get_config_mod(Type, mount),
			TrainAttrs0 = maps:fold(fun
				(TrainID, TrainLv, Acc1) ->
					lists:foldl(fun
						({Code, Val}, Acc2) ->
							ut_misc:maps_increase(Code, Val*TrainLv, Acc2)
					end, Acc1, TrainMod:attrs(TrainID))
			end, #{}, Trains),
			% 属性丹属性
			TrainAttrs   = maps:without(mod_attr:part_pro_attrs(), TrainAttrs0),
			% 属性丹百分比属性
			PartProAttrs = maps:with(mod_attr:part_pro_attrs(), TrainAttrs0),
			% 升级属性
			MountAttrs0  = MountMod:attrs(Order, Level),
			MountAttrs   = mod_attr:calc_part_pro(mod_attr:add(MountAttrs0, PartProAttrs)),
			% 天赋技能属性
			SkillAttrs = if
				Type == ?TRAIN_MOUNT, Order >= 5 ->
					SkillID = ?_if(Gender == ?GENDER_MALE, 831024, 832024),
					calc_skill_attr(MountAttrs0, SkillID);
				Type == ?TRAIN_OFFHAND ->
					SkillID = ?_if(Gender == ?GENDER_MALE, 831003, 832003),
					calc_skill_attr(MountAttrs0, SkillID);
				true ->
					#{}
			end,
			mod_attr:sum([TrainAttrs, MountAttrs, SkillAttrs]);
		error ->
			#{}
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_upgrade(Type, Mount, ItemSType) ->
	ValidSType = case Type of
		1 -> ?ITEM_STYPE_MOUNT_EXP;
		5 -> ?ITEM_STYPE_OFFHAND_EXP
	end,
	?_check(ItemSType == ValidSType, ?ERR_GAME_BAD_ARGS),
	#mount{order=Order, level=Level} = Mount,
	?_check(Order > 0, ?ERR_MOUNT_NOT_ACTIVE, [Type]),
	MountMod = get_config_mod(Type, mount),
	IsMax = Order >= MountMod:max_order() andalso
		    Level >= MountMod:max_level(Order),
	?_check(not IsMax, ?ERR_MOUNT_MAX_ORDER),
	ok.

maybe_upgrade(MountMod, Mount, RoleSt) ->
	#mount{order=Order, level=Level, exp=Exp} = Mount,
	#cfg_mount{exp=MaxExp} = MountMod:find(Order, Level),
	case Exp >= MaxExp of
		true  ->
			Mount1 = Mount#mount{exp = Exp-MaxExp},
			case Level >= MountMod:max_level(Order) of
				true  ->
					case Order >= MountMod:max_order() of
						% 最高阶
						true  ->
							Mount;
						% 升阶
						false ->
							Mount2 = upgrade_order(MountMod, Mount1, RoleSt),
							maybe_upgrade(MountMod, Mount2, RoleSt)
					end;
				false -> % 升星
					Mount2 = upgrade_level(MountMod, Mount1, RoleSt),
					maybe_upgrade(MountMod, Mount2, RoleSt)
			end;
		false ->
			Mount
	end.

upgrade_order(MountMod, Mount, RoleSt) ->
	Order2 = Mount#mount.order + 1,
	Level2 = 0,
	active_skill(MountMod, Order2, Level2, RoleSt),
	upgrade_notify(Mount#mount.type, MountMod, Order2, Level2, RoleSt),
	Mount#mount{order=Order2, level=Level2}.

upgrade_level(MountMod, Mount, RoleSt) ->
	Level2 = Mount#mount.level + 1,
	active_skill(MountMod, Mount#mount.order, Level2, RoleSt),
	Mount#mount{level=Level2}.

check_train(Type, ItemID, Mount) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	TrainMod = get_config_mod(Type, train),
	Limits = TrainMod:limit(ItemID),
	?_check(Limits /= ?nil, ?ERR_MOUNT_INVALID_TRAIN),
	Level  = maps:get(ItemID, Mount#mount.train, 0),
	MaxLv  = get_train_limit(Limits, RoleLv),
	?_check(Level < MaxLv, ?ERR_MOUNT_MAX_TRAIN),
	ok.

get_train_limit([{MinLv, MaxLv, Limit} | T], RoleLv) ->
	case MinLv =< RoleLv andalso RoleLv =< MaxLv of
		true  -> Limit;
		false -> get_train_limit(T, RoleLv)
	end.

check_ride(Type, RoleSt) ->
	#cfg_scene{mount=CanMount} = cfg_scene:find(RoleSt#role_st.scene),
	?_check(Type == 2 orelse CanMount, ?ERR_SCENE_CANNOT_MOUNT).

change_figure(Type, Order, RoleSt) ->
	RoleTrain = #role_train{using=Using} = role_data:get(?DB_ROLE_TRAIN),
	role_data:set(RoleTrain#role_train{
		using = maps:put(Type, {train,Order}, Using)
	}),
	TrainMod = get_config_mod(Type, mount),
	case Type of
		?TRAIN_MOUNT ->
			ResID = TrainMod:res(Order),
			role_figure:update_mount(ResID, ?nil, RoleSt);
		?TRAIN_OFFHAND ->
			#role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
			ResList = TrainMod:res(Order),
			ResID   = proplists:get_value(Gender, ResList),
			role_figure:update_offhand(ResID, RoleSt)
	end,
	?ucast(#m_mount_figure_toc{type=Type, order=Order, res=ResID}).

get_config_mod(?TRAIN_MOUNT, train) ->
	cfg_mount_train;
get_config_mod(?TRAIN_MOUNT, mount) ->
	cfg_mount;
get_config_mod(?TRAIN_OFFHAND, train) ->
	cfg_offhand_train;
get_config_mod(?TRAIN_OFFHAND, mount) ->
	cfg_offhand.

active_skill(MountMod, Order, Level, RoleSt) ->
	#cfg_mount{skill=SkillID} = MountMod:find(Order, Level),
	?_if(SkillID > 0, role_skill:active(SkillID, RoleSt)).

upgrade_notify(MountType, MountMod, Order, Level, RoleSt) ->
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	#cfg_mount{skill=SkillID} = MountMod:find(Order, Level),
	#cfg_skill{name=SkillName} = cfg_skill:find(SkillID),
	MsgNo = case MountType of
		?TRAIN_MOUNT   -> ?MSG_MOUNT_UPGRADE;
		?TRAIN_OFFHAND -> ?MSG_OFFHAND_UPGRADE
	end,
	?notify(MsgNo, [{role,RoleID,RoleName}, Order, SkillName]).


calc_skill_attr(Attrs, SkillID) ->
	#role_talent{skills=Skills} = role_data:get(?DB_ROLE_TALENT),
	case maps:find(SkillID, Skills) of
		{ok, SkillLv} ->
			Without = mod_attr:part_pro_attrs() ++ mod_attr:global_pro_attrs(),
			Attrs1  = maps:without(Without, maps:from_list(Attrs)),
			#cfg_skill_level{attrs=Attrs2} = cfg_skill_level:find(SkillID, SkillLv),
			mod_attr:calc_part_pro(mod_attr:add(Attrs1, Attrs2), 0);
		error ->
			#{}
	end.