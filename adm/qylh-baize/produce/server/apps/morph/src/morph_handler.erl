%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(morph_handler).

-include("game.hrl").
-include("item.hrl").
-include("morph.hrl").
-include("role.hrl").
-include("skill.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").

%% API
-export([handle/3]).
-export([get_attr/2]).
-export([get_morph_res/2]).
-export([get_morph_model/2]).
-export([change_figure/3]).
-export([putoff_weapon/0]).
-export([power_event/1]).
-export([get_actives/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 已激活列表
handle(?MORPH_LIST, Tos, RoleSt) ->
	#m_morph_list_tos{type=Type} = Tos,
	RoleTrain = role_data:get(?DB_ROLE_TRAIN),
	#role_train{morphs=Morphs, using=Using} = RoleTrain,
	{UsedType, UsedID0} = maps:get(Type, Using, {?nil, 0}),
	UsedID = ?_if(UsedType == morph, UsedID0, 0),
	?ucast(#m_morph_list_toc{
		type    = Type,
		morphs  = maps:get(Type, Morphs, []),
		used_id = UsedID
	});

%% 激活
handle(?MORPH_ACTIVE, Tos, RoleSt) ->
	#m_morph_active_tos{type=Type, id=ID} = Tos,
	RoleTrain = role_data:get(?DB_ROLE_TRAIN),
	check_active(Type, ID, RoleTrain),
	#cfg_morph{name=MorphName, cost=Cost, msgno=MsgNo} = get_morph_config(Type, ID),
	role_bag:cost(Cost, ?LOG_MORPH_ACTIVE, RoleSt),
	#role_train{morphs=Morphs} = RoleTrain,
	Morph = #p_morph{id=ID, star=0, exp=0},
	RoleTrain2 = RoleTrain#role_train{
		morphs = ut_misc:maps_append(Type, Morph, Morphs)
	},
	role_data:set(RoleTrain2),
	role_attr:recalc({?MODULE, Type}, RoleSt),
	role_event:event(?EVENT_MORPH_STAR, {Type, ID, 0}),
	ModelID = case Type == ?TRAIN_OFFHAND of
		true  -> get_morph_model(Type, ID);
		false -> get_morph_res(Type, ID)
	end,
	change_figure(Type, ModelID, RoleSt),
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	case MsgNo > 0 of
		true when Type == ?TRAIN_MOUNT; Type == ?TRAIN_OFFHAND ->
			?notify(MsgNo, [{role,RoleID,RoleName}, MorphName]);
		true when Type == ?TRAIN_WING ->
			?notify(?MSG_MORPH_WING_ACTIVE, [{role,RoleID,RoleName}, MorphName]);
		true when Type == ?TRAIN_WEAPON ->
			?notify(?MSG_MORPH_WEAPON_ACTIVE, [{role,RoleID,RoleName}, MorphName]);
		true when Type == ?TRAIN_TALIS ->
			?notify(?MSG_MORPH_TALIS_ACTIVE, [{role,RoleID,RoleName}, MorphName]);
		_ ->
			ignore
	end,

	LogType = 1108 * 1000 + Type * 100 + 1,
	Action  = #{
		train_type => Type,
		morph_id   => ID
	},
	role_logger:log(LogType, Action, RoleSt),

	?ucast(#m_morph_active_toc{type=Type, id=ID});

%% 坐骑升星
handle(?MORPH_UPSTAR, Tos, RoleSt)
when Tos#m_morph_upstar_tos.type == ?TRAIN_MOUNT
orelse Tos#m_morph_upstar_tos.type == ?TRAIN_OFFHAND ->
	#m_morph_upstar_tos{type=Type, id=ID, item_id=ItemID} = Tos,
	#cfg_item{stype=SType, effect=ExpAdd} = cfg_item:find(ItemID),
	IsValid = (Type == ?TRAIN_MOUNT andalso SType == ?ITEM_STYPE_MOUNT_EXP)
	   orelse (Type == ?TRAIN_OFFHAND andalso SType == ?ITEM_STYPE_OFFHAND_EXP),
	?_check(IsValid, ?ERR_GAME_BAD_ARGS),
	RoleTrain = role_data:get(?DB_ROLE_TRAIN),
	check_upstar(Type, ID, RoleTrain),
	role_bag:cost([{ItemID,1}], ?LOG_MORPH_UPSTAR, RoleSt),
	#role_train{morphs=Morphs} = RoleTrain,
	MList  = maps:get(Type, Morphs),
	Morph  = #p_morph{star=Star1} = lists:keyfind(ID, #p_morph.id, MList),
	Morph1 = Morph#p_morph{exp=Morph#p_morph.exp+ExpAdd},
	Mod = ?_if(Type == ?TRAIN_MOUNT, cfg_mount_star, cfg_offhand_star),
	Morph2 = #p_morph{star=Star2} = mount_upstar(Type, Mod, Morph1, RoleSt),
	MList2 = lists:keystore(ID, #p_morph.id, MList, Morph2),
	RoleTrain2 = RoleTrain#role_train{morphs=maps:put(Type, MList2, Morphs)},
	role_data:set(RoleTrain2),
	?_if(Star2 > Star1, role_event:event(?EVENT_MORPH_STAR, {Type, ID, Star2})),
	role_attr:recalc({?MODULE, Type}, RoleSt),

	LogType = 1108 * 1000 + Type * 100 + 2,
	Action  = #{
		train_type => Type,
		morph_id   => ID,
		old_star   => Star1,
		new_star   => Star2
	},
	role_logger:log(LogType, Action, RoleSt),

	?ucast(#m_morph_upstar_toc{type=Type, morph=Morph2, item_id=ItemID});

%% 神灵升星激活
handle(?MORPH_UPSTAR, Tos, RoleSt) when Tos#m_morph_upstar_tos.type == ?TRAIN_GOD ->
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	#m_morph_upstar_tos{type=Type, id=ID} = Tos,
	RoleTrain = role_data:get(?DB_ROLE_TRAIN),
	check_upstar(Type, ID, RoleTrain),
	#role_train{morphs=Morphs} = RoleTrain,
	MList = maps:get(Type, Morphs),
	{ok, Morph = #p_morph{star=Star1}} = get_morph(RoleTrain, Type, ID),
	#cfg_morph_star{cost=Cost} = get_star_config(Type, ID, Star1),
	role_bag:cost(Cost, ?LOG_MORPH_UPSTAR, RoleSt),
	Star2  = Star1 + 1,
	Morph2 = Morph#p_morph{star=Star2},
	MList2 = lists:keystore(ID, #p_morph.id, MList, Morph2),
	RoleTrain2 = RoleTrain#role_train{morphs=maps:put(Type, MList2, Morphs)},
	role_data:set(RoleTrain2),
	active_skill(Type, ID, Star2, RoleSt),
	role_event:event(?EVENT_MORPH_STAR, {Type, ID, Star2}),
	role_attr:recalc({?MODULE, Type}, RoleSt),
	power_event(Type),
	#cfg_morph{name=MorphName, color=Color} = get_morph_config(Type, ID),
	Star2 == ?GOD_ACTIVE_STAR andalso
		?notify(?MSG_MORPH_GOD_ACTIVE, [{role,RoleID,RoleName}, ut_color:format(MorphName, Color)]),
	Star2 >= 18 andalso Star2 rem ?GOD_ACTIVE_STAR == 0 andalso
		?notify(?MSG_MORPH_GOD_UPSTAR, [{role,RoleID,RoleName}, MorphName, (Star2 div ?GOD_ACTIVE_STAR) - 1]),

	LogType = 1108 * 1000 + Type * 100 + 2,
	Action  = #{
		train_type => Type,
		morph_id   => ID,
		old_star   => Star1,
		new_star   => Star2
	},
	role_logger:log(LogType, Action, RoleSt),

	?ucast(#m_morph_upstar_toc{type=Type, morph=Morph2});

%% 升星
handle(?MORPH_UPSTAR, Tos, RoleSt) ->
	#m_morph_upstar_tos{type=Type, id=ID} = Tos,
	RoleTrain = role_data:get(?DB_ROLE_TRAIN),
	check_upstar(Type, ID, RoleTrain),
	#role_train{morphs=Morphs} = RoleTrain,
	MList = maps:get(Type, Morphs),
	Morph = #p_morph{star=Star1} = lists:keyfind(ID, #p_morph.id, MList),
	#cfg_morph_star{cost=Cost} = get_star_config(Type, ID, Star1),
	role_bag:cost(Cost, ?LOG_MORPH_UPSTAR, RoleSt),
	Star2  = Star1 + 1,
	Morph2 = Morph#p_morph{star=Star2},
	MList2 = lists:keystore(ID, #p_morph.id, MList, Morph2),
	RoleTrain2 = RoleTrain#role_train{morphs=maps:put(Type, MList2, Morphs)},
	role_data:set(RoleTrain2),
	active_skill(Type, ID, Star2, RoleSt),
	role_event:event(?EVENT_MORPH_STAR, {Type, ID, Star2}),
	role_attr:recalc({?MODULE, Type}, RoleSt),
	upstar_notify(Type, ID, Star2),

	LogType = 1108 * 1000 + Type * 100 + 2,
	Action  = #{
		train_type => Type,
		morph_id   => ID,
		old_star   => Star1,
		new_star   => Star2
	},
	role_logger:log(LogType, Action, RoleSt),

	?ucast(#m_morph_upstar_toc{type=Type, morph=Morph2});

%% 幻化形象
handle(?MORPH_FIGURE, Tos, RoleSt) ->
	#m_morph_figure_tos{type=Type, id=ID} = Tos,
	RoleTrain = #role_train{using=Using} = role_data:get(?DB_ROLE_TRAIN),
	check_figure(Type, ID, RoleTrain),
	ResID   = get_morph_res(Type, ID),
	ModelID = case Type == ?TRAIN_OFFHAND of
		true  -> get_morph_model(Type, ID);
		false -> ResID
	end,
	change_figure(Type, ModelID, RoleSt),
	{_, OldID} = maps:get(Type, Using, {morph,0}),
	role_data:set(RoleTrain#role_train{
		using = maps:put(Type, {morph,ID}, Using)
	}),
	case Type == ?TRAIN_WEAPON of
		true  -> fashion_handler:putoff_weapon(RoleSt);
		false -> ignore
	end,
	replace_skill(Type, OldID, ID, RoleSt),
	power_event(Type),
	?ucast(#m_morph_figure_toc{type=Type, id=ID, res=ModelID}).


get_attr(_AttrType, Type) ->
	#role_train{morphs=Morphs} = role_data:get(?DB_ROLE_TRAIN),
	#role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
	case maps:find(Type, Morphs) of
		{ok, MorphList} ->
			BaseAttrs = lists:foldl(fun(Morph, Acc) ->
				#p_morph{id=ID, star=Star} = Morph,
				case get_star_config(Type, ID, Star) of
					?nil -> Acc;
					Conf -> mod_attr:add(Acc, Conf#cfg_morph_star.attrs)
				end
			end, #{}, MorphList),

			case {Type, Gender} of
				{?TRAIN_WING, ?GENDER_MALE} ->
					SkillID  = 831015,
					MorphMin = 21003;
				{?TRAIN_WING, ?GENDER_FEMALE} ->
					SkillID  = 832015,
					MorphMin = 22003;
				{?TRAIN_TALIS, ?GENDER_MALE} ->
					SkillID  = 831006,
					MorphMin = 30003;
				{?TRAIN_TALIS, ?GENDER_FEMALE} ->
					SkillID  = 832006,
					MorphMin = 30003;
				_ ->
					SkillID  = 0,
					MorphMin = 0
			end,

			SkillAttrs = case SkillID > 0 of
				true  ->
					IsActive = lists:any(fun
						(Morph) ->
							Morph#p_morph.id >= MorphMin
					end, MorphList),
					case IsActive of
						true  -> calc_skill_attr(BaseAttrs, SkillID);
						false -> #{}
					end;
				false ->
					#{}
			end,
			mod_attr:add(BaseAttrs, SkillAttrs);
		error ->
			#{}
	end.

%脱下神兵
putoff_weapon()->
	RoleTrain = #role_train{using=Using} = role_data:get(?DB_ROLE_TRAIN),
	role_data:set(RoleTrain#role_train{
		using = maps:remove(?TRAIN_WEAPON, Using)
	}).

power_event(Type = ?TRAIN_GOD) ->
	Attr = mod_attr:sum([
		get_sub_morph_attr(Type),
		train_handler:get_attr(?nil, Type),
		get_power_attr(Type)
	]),
	Power = mod_attr:power(Attr),
	role_event:event(?EVENT_GOD_TOTAL_POWER, Power);
power_event(_) ->
	ignore.

get_actives(Type = ?TRAIN_GOD) ->
	#role_train{morphs=Morphs} = role_data:get(?DB_ROLE_TRAIN),
	case maps:find(Type, Morphs) of
		{ok, MorphList} ->
			lists:filtermap(fun(Morph) ->
				case Morph#p_morph.star >= ?GOD_ACTIVE_STAR of
					true -> {true, Morph#p_morph.id};
					false -> false
				end
			end, MorphList);
		error ->
			[]
	end;
get_actives(_) ->
	not_supported_yet.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_active(Type, ID, RoleTrain) ->
	#role_train{morphs=Morphs} = RoleTrain,
	MList   = maps:get(Type, Morphs, []),
	Actived = lists:keymember(ID, #p_morph.id, MList),
	?_check(not Actived, ?ERR_MORPH_HAD_ACTIVED),
	#cfg_morph{reqs=Reqs} = get_morph_config(Type, ID),
	check_reqs(Reqs, RoleTrain),
	ok.

check_reqs([{wake, WakeLim} | T], RoleTrain) ->
	#role_info{wake=WakeLv} = role_data:get(?DB_ROLE_INFO),
	case WakeLv >= WakeLim of
		true  -> check_reqs(T, RoleTrain);
		false -> throw(?err(?ERR_MORPH_LOW_WAKE))
	end;
check_reqs([{gender, GenderLim} | T], RoleTrain) ->
	#role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
	case Gender == GenderLim of
		true  -> check_reqs(T, RoleTrain);
		false -> throw(?err(?ERR_MORPH_BAD_GENDER))
	end;
check_reqs([], _) ->
	ok.

check_upstar(Type, ID, RoleTrain) ->
	{ok, Morph} = get_morph(RoleTrain, Type, ID),
	MaxStar = get_max_star(Type, ID),
	?_check(Morph#p_morph.star < MaxStar, ?ERR_MORPH_MAX_STAR),
	ok.

get_morph(RoleTrain, ?TRAIN_GOD=Type, ID) ->
	Morphs = maps:get(Type, RoleTrain#role_train.morphs, []),
	case lists:keyfind(ID, #p_morph.id, Morphs) of
		false -> {ok, #p_morph{id=ID, star=0, exp=0}};
		Morph -> {ok, Morph}
	end;
get_morph(RoleTrain, Type, ID) ->
	Morphs = maps:get(Type, RoleTrain#role_train.morphs, []),
	case lists:keyfind(ID, #p_morph.id, Morphs) of
		false -> ?err(?ERR_MORPH_NOT_ACTIVED);
		Morph -> {ok, Morph}
	end.

get_morph_config(Type, ID) ->
	(mod_morph(Type)):find(ID).

get_morph_res(Type, ID) ->
	(mod_morph(Type)):res(ID).

get_morph_model(Type, ID) ->
	#role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
	proplists:get_value(Gender, (mod_morph(Type)):model(ID)).

get_star_config(Type, ID, Star) ->
	(mod_star(Type)):find(ID, Star).

get_max_star(Type, ID) ->
	(mod_star(Type)):max(ID).

mod_morph(Type) ->
	case Type of
		?TRAIN_MOUNT   -> cfg_mount_morph;
		?TRAIN_WING    -> cfg_wing_morph;
		?TRAIN_TALIS   -> cfg_talis_morph;
		?TRAIN_WEAPON  -> cfg_weapon_morph;
		?TRAIN_OFFHAND -> cfg_offhand_morph;
		?TRAIN_GOD     -> cfg_god_morph;
		_ -> throw(?err(?ERR_GAME_BAD_ARGS))
	end.

mod_star(Type) ->
	case Type of
		?TRAIN_MOUNT   -> cfg_mount_star;
		?TRAIN_WING    -> cfg_wing_star;
		?TRAIN_TALIS   -> cfg_talis_star;
		?TRAIN_WEAPON  -> cfg_weapon_star;
		?TRAIN_OFFHAND -> cfg_offhand_star;
		?TRAIN_GOD     -> cfg_god_star;
		_ -> throw(?err(?ERR_GAME_BAD_ARGS))
	end.

mount_upstar(Type, Mod, Morph, RoleSt) ->
	#p_morph{id=ID, star=Star, exp=Exp} = Morph,
	#cfg_morph_star{exp=MaxExp} = Mod:find(ID, Star),
	case Exp >= MaxExp of
		true  ->
			case Star >= Mod:max(ID) of
				true  ->
					Morph;
				false ->
					Star2  = Star+1,
					Morph2 = Morph#p_morph{star=Star2, exp=Exp-MaxExp},
					Result = active_skill(Type, ID, Star2, RoleSt),
					?_if(Result /= no_skill, upstar_notify(Type, ID, Star2)),
					mount_upstar(Type, Mod, Morph2, RoleSt)
			end;
		false ->
			Morph
	end.

check_figure(?TRAIN_GOD=Type, ID, RoleTrain) ->
	?_if(ID > 0, ({ok, _} = get_morph(RoleTrain, Type, ID))),
	case get_morph(RoleTrain, Type, ID) of
		{ok, Morph} when Morph#p_morph.star >= ?GOD_ACTIVE_STAR ->
			ok;
		_ ->
			throw(?err(?ERR_MORPH_NOT_ACTIVED))
	end,
	{_, UsedID} = maps:get(Type, RoleTrain#role_train.using, {?nil,0}),
	?_check(ID /= UsedID, ?ERR_MORPH_IS_USING),
	ok;
check_figure(Type, ID, RoleTrain) ->
	?_if(ID > 0, ({ok, _} = get_morph(RoleTrain, Type, ID))),
	{_, UsedID} = maps:get(Type, RoleTrain#role_train.using, {?nil,0}),
	?_check(ID /= UsedID, ?ERR_MORPH_IS_USING),
	ok.

change_figure(?TRAIN_MOUNT, ResID, RoleSt) ->
	role_figure:update_mount(ResID, ?nil, RoleSt);
change_figure(?TRAIN_WING, ResID, RoleSt) ->
	role_figure:update_wing(ResID, RoleSt);
change_figure(?TRAIN_TALIS, ResID, RoleSt) ->
	role_figure:update_talis(ResID, RoleSt);
change_figure(?TRAIN_WEAPON, ResID, RoleSt) ->
	role_figure:update_weapon(ResID, RoleSt);
change_figure(?TRAIN_OFFHAND, ResID, RoleSt) ->
	role_figure:update_offhand(ResID, RoleSt);
change_figure(?TRAIN_GOD, ResID, RoleSt) ->
	role_figure:update_god(ResID, RoleSt).

active_skill(?TRAIN_GOD = Type, ID, Star, RoleSt) ->
	#cfg_morph_star{skill=Skills} = get_star_config(Type, ID, Star),
	ActiveSkills = proplists:get_value(2, Skills, []),
	role_skill:active(ActiveSkills, RoleSt);
active_skill(Type, ID, Star, RoleSt) ->
	#cfg_morph_star{skill=SkillID} = get_star_config(Type, ID, Star),
	case SkillID of
		_ when is_integer(SkillID), SkillID > 0 -> role_skill:active(SkillID, RoleSt);
		_ when is_list(SkillID) -> role_skill:active(SkillID, RoleSt);
		_ -> no_skill
	end.

replace_skill(?TRAIN_GOD, OldID, ID, RoleSt) ->
	ActiveSkills = proplists:get_value(1, cfg_god_star:skills(ID), []),
	role_skill:active(ActiveSkills, RoleSt),
	RemoveSkills = proplists:get_value(1, cfg_god_star:skills(OldID), []),
	role_skill:remove(RemoveSkills, RoleSt);
replace_skill(_Type, _OldID, _ID, _RoleSt) ->
	ignore.

upstar_notify(Type, ID, Star) ->
	#cfg_morph_star{skill=SkillID} = get_star_config(Type, ID, Star),
	#role_info{id=RoleID, name=RoleName} = role_data:get(?DB_ROLE_INFO),
	#cfg_morph{name=MorphName} = get_morph_config(Type, ID),
	case Type of
		?TRAIN_MOUNT ->
			#cfg_skill{name=SkillName} = cfg_skill:find(SkillID),
			?notify(?MSG_MORPH_MOUNT_UPSTAR, [{role,RoleID,RoleName}, MorphName, Star, SkillName]);
		?TRAIN_OFFHAND ->
			#cfg_skill{name=SkillName} = cfg_skill:find(SkillID),
			?notify(?MSG_MORPH_OFFHAND_UPSTAR, [{role,RoleID,RoleName}, MorphName, Star, SkillName]);
		?TRAIN_WING ->
			?notify(?MSG_MORPH_WING_UPSTAR, [{role,RoleID,RoleName}, MorphName, Star]);
		?TRAIN_WEAPON ->
			?notify(?MSG_MORPH_WEAPON_UPSTAR, [{role,RoleID,RoleName}, MorphName, Star]);
		?TRAIN_TALIS ->
			?notify(?MSG_MORPH_TALIS_UPSTAR, [{role,RoleID,RoleName}, MorphName, Star])
	end.

get_power_attr(Type = ?TRAIN_GOD) ->
	#role_train{morphs=Morphs} = role_data:get(?DB_ROLE_TRAIN),
	MorphList = maps:get(Type, Morphs),
	lists:foldl(fun(Morph, Acc) ->
		#p_morph{id=ID, star=Star} = Morph,
		case get_star_config(Type, ID, Star) of
			?nil ->
				Acc;
			Conf ->
				mod_attr:add(Acc, Conf#cfg_morph_star.power)
		end
	end, #{}, MorphList);
get_power_attr(_) ->
	#{}.

% 用于计算单个神灵属性
get_sub_morph_attr(Type) ->
	#role_train{morphs=Morphs} = role_data:get(?DB_ROLE_TRAIN),
	case maps:find(Type, Morphs) of
		{ok, MorphList} ->
			lists:foldl(fun(Morph, Acc) ->
				#p_morph{id=ID, star=Star} = Morph,
				case get_star_config(Type, ID, Star) of
					?nil ->
						Acc;
					Conf ->
						mod_attr:add(Acc, mod_attr:calc_global_pro(Conf#cfg_morph_star.attrs))
				end
			end, #{}, MorphList);
		error ->
			#{}
	end.

calc_skill_attr(Attrs, SkillID) ->
	#role_talent{skills=Skills} = role_data:get(?DB_ROLE_TALENT),
	case maps:find(SkillID, Skills) of
		{ok, SkillLv} ->
			Without = mod_attr:part_pro_attrs() ++ mod_attr:global_pro_attrs(),
			Attrs1  = maps:without(Without, Attrs),
			#cfg_skill_level{attrs=Attrs2} = cfg_skill_level:find(SkillID, SkillLv),
			mod_attr:calc_part_pro(mod_attr:add(Attrs1, Attrs2), 0);
		error ->
			#{}
	end.