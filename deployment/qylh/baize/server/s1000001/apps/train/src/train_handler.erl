%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(train_handler).

-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("skill.hrl").
-include("train.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("attr.hrl").
-include("morph.hrl").

%% API
-export([handle/3]).
-export([hook_sysopen/2]).
-export([get_attr/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 培养信息
handle(?TRAIN_INFO, Tos, RoleSt) ->
	#m_train_info_tos{type=Type} = Tos,
	#role_train{trains=Trains} = role_data:get(?DB_ROLE_TRAIN),
	case maps:find(Type, Trains) of
		{ok, Train} ->
			?ucast(#m_train_info_toc{train=Train});
		error ->
			ignore
	end;

%% 升级
handle(?TRAIN_UPGRADE, Tos, RoleSt) ->
	#m_train_upgrade_tos{type=Type, item_id=ItemID} = Tos,
	RoleTrain = role_data:get(?DB_ROLE_TRAIN),
	#cfg_item{stype=SType, effect=ExpAdd} = cfg_item:find(ItemID),
	check_upgrade(Type, SType, RoleTrain),
	role_bag:cost([{ItemID,1}], ?LOG_TRAIN_UPGRADE, RoleSt),
	#role_train{trains=Trains} = RoleTrain,
	Train  = #p_train{level=Level1, exp=Exp} = maps:get(Type, Trains),
	Train1 = Train#p_train{exp=Exp+ExpAdd},
	Train2 = #p_train{level=Level2} = maybe_upgrade(Train1, RoleSt),
	role_data:set(RoleTrain#role_train{
		trains = maps:put(Type, Train2, Trains)
	}),
	?_if(Level2 > Level1, role_event:event(?EVENT_TRAIN_ORDER, {Type,0,Level2})),
	role_attr:recalc({?MODULE, Type}, RoleSt),
	morph_handler:power_event(Type),

	LogType = 1109 * 1000 + Type * 100 + 1,
	Action  = #{
		train_type => Type,
		item_id    => ItemID,
		old_level  => Level1,
		new_level  => Level2
	},
	role_logger:log(LogType, Action, RoleSt),

	?ucast(#m_train_upgrade_toc{train=Train2});

%% 属性培养
handle(?TRAIN_ATTR, Tos, RoleSt) ->
	#m_train_attr_tos{type=Type, item_id=ItemID} = Tos,
	RoleTrain = #role_train{trains=Trains} = role_data:get(?DB_ROLE_TRAIN),
	Train = maps:get(Type, Trains, ?nil),
	check_train(Type, ItemID, Train),
	role_bag:cost([{ItemID, 1}], ?LOG_TRAIN_ATTR, RoleSt),
	#p_train{train=TrainInfo} = Train,
	Level2 = maps:get(ItemID, TrainInfo, 0) + 1,
	Train2 = Train#p_train{train=maps:put(ItemID, Level2, TrainInfo)},
	role_data:set(RoleTrain#role_train{
		trains = maps:put(Type, Train2, Trains)
	}),
	role_attr:recalc({?MODULE, Type}, RoleSt),
	morph_handler:power_event(Type),

	LogType = 1109 * 1000 + Type * 100 + 2,
	Action  = #{
		train_type => Type,
		item_id    => ItemID,
		new_level  => Level2
	},
	role_logger:log(LogType, Action, RoleSt),

	?ucast(#m_train_attr_toc{type=Type, item_id=ItemID, level=Level2}).

hook_sysopen(Type, RoleSt) ->
	RoleTrain = role_data:get(?DB_ROLE_TRAIN),
	#role_train{trains=Trains, morphs=Morphs, using=Using} = RoleTrain,
	case maps:is_key(Type, Trains) of
		true  ->
			ignore;
		false ->
			#role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
			DiffGender = [?TRAIN_WING, ?TRAIN_WEAPON],
			Level = 1,
			Train = #p_train{type=Type, level=Level, exp=0},
			MorID = Type*10000 + ?_if(lists:member(Type, DiffGender), Gender*1000, 0),
			Morph = case Type of
				?TRAIN_GOD -> #p_morph{id=MorID, star=?GOD_ACTIVE_STAR, exp=0};
				_ -> #p_morph{id=MorID, star=0, exp=0}
			end,
			Trains2 = maps:put(Type, Train, Trains),
			Morphs2 = ut_misc:maps_append(Type, Morph, Morphs),
			Using2  = maps:put(Type, {morph,MorID}, Using),
			RoleTrain2 = RoleTrain#role_train{
				trains=Trains2, morphs=Morphs2, using=Using2
			},
			role_data:set(RoleTrain2),
			active_skills(Type, Level, RoleSt),
			role_attr:recalc({?MODULE, Type}, RoleSt),
			ResID = case Type == ?TRAIN_OFFHAND of
				true  -> morph_handler:get_morph_model(Type, MorID);
				false -> morph_handler:get_morph_res(Type, MorID)
			end,
			morph_handler:change_figure(Type, ResID, RoleSt),
			morph_handler:power_event(Type),
			?ucast(#m_train_info_toc{train=Train})
	end.


get_attr(_AttrType, Type) ->
	#role_train{trains=Trains} = role_data:get(?DB_ROLE_TRAIN),
	case maps:find(Type, Trains) of
		{ok, Train} ->
			#p_train{level=Level, train=TrainInfo} = Train,
			#cfg_train{attrs=Attrs0} = get_config(Type, Level),
			TrainMod    = get_train_mod(Type),
			TrainAttrs0 = maps:fold(fun
				(TrainID, TrainLv, Acc1) ->
					lists:foldl(fun
					({Code, Val}, Acc2) ->
						ut_misc:maps_increase(Code, Val*TrainLv, Acc2)
				end, Acc1, TrainMod:attrs(TrainID))
			end, #{}, TrainInfo),
			TrainAttrs   = maps:without(mod_attr:part_pro_attrs(), TrainAttrs0),
			PartProAttrs = maps:with(mod_attr:part_pro_attrs(), TrainAttrs0),
			ConfigAttrs   = maps:without(mod_attr:part_pro_attrs(), mod_attr:to_map(Attrs0)),
			ConfigProAttrs = maps:with(mod_attr:part_pro_attrs(), mod_attr:to_map(Attrs0)),
			Add0 = mod_attr:add(TrainAttrs,ConfigAttrs),
			Add1 = mod_attr:add(PartProAttrs,ConfigProAttrs),
			mod_attr:calc_part_pro(mod_attr:add(Add0,Add1));
	
		error ->
			 #{}
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_upgrade(Type, SType, RoleTrain) ->
	ValidSType = case Type of
		?TRAIN_WING   -> ?ITEM_STYPE_WING_EXP;
		?TRAIN_TALIS  -> ?ITEM_STYPE_TALIS_EXP;
		?TRAIN_WEAPON -> ?ITEM_STYPE_WEAPON_EXP;
		?TRAIN_GOD 	  -> ?ITEM_STYPE_GOD_EXP;
		_ -> throw(?err(?ERR_GAME_BAD_ARGS))
	end,
	?_check(SType == ValidSType, ?ERR_GAME_BAD_ARGS),
	#role_train{trains=Trains} = RoleTrain,
	case maps:find(Type, Trains) of
		{ok, Train} ->
			MaxLv = get_max(Type),
			?_check(Train#p_train.level < MaxLv, ?ERR_TRAIN_MAX_LEVEL);
		error ->
			throw(?err(?ERR_TRAIN_NOT_ACTIVED))
	end.

maybe_upgrade(Train, RoleSt) ->
	#p_train{type=Type, level=Level, exp=Exp} = Train,
	#cfg_train{exp=MaxExp} = get_config(Type, Level),
	case Exp >= MaxExp of
		true  ->
			case Level >= get_max(Type) of
				true  ->
					Train;
				false ->
					Level2 = Level + 1,
					Train2 = Train#p_train{level=Level2, exp=Exp-MaxExp},
					hook_upgrade(Type, Level2, RoleSt),
					maybe_upgrade(Train2, RoleSt)
			end;
		false ->
			Train
	end.

check_train(Type, ItemID, Train) ->
	?_check(Train /= ?nil, ?ERR_TRAIN_NOT_ACTIVED),
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	TrainMod = get_train_mod(Type),
	Limits = TrainMod:limit(ItemID),
	?_check(Limits /= ?nil, ?ERR_MOUNT_INVALID_TRAIN),
	Level  = maps:get(ItemID, Train#p_train.train, 0),
	MaxLv  = get_train_limit(Limits, RoleLv),
	?_check(Level < MaxLv, ?ERR_TRAIN_MAX_TRAIN),
	ok.

get_train_mod(?TRAIN_WING) ->
	cfg_wing_train;
get_train_mod(?TRAIN_TALIS) ->
	cfg_talis_train;
get_train_mod(?TRAIN_WEAPON) ->
	cfg_weapon_train;
get_train_mod(?TRAIN_GOD) ->
	cfg_god_train;
get_train_mod(_) ->
	throw(?err(?ERR_GAME_BAD_ARGS)).

get_train_limit([{MinLv, MaxLv, Limit} | T], RoleLv) ->
	case MinLv =< RoleLv andalso RoleLv =< MaxLv of
		true  -> Limit;
		false -> get_train_limit(T, RoleLv)
	end.

get_config(Type, TrainLv) ->
	(get_mod(Type)):find(TrainLv).

get_max(Type) ->
	(get_mod(Type)):max().

get_mod(?TRAIN_WING) ->
	cfg_wing;
get_mod(?TRAIN_TALIS) ->
	cfg_talis;
get_mod(?TRAIN_WEAPON) ->
	cfg_weapon;
get_mod(?TRAIN_GOD) ->
	cfg_god;
get_mod(_) ->
	throw(?err(?ERR_GAME_BAD_ARGS)).

hook_upgrade(Type, Level, RoleSt) ->
	#cfg_train{skill=SkillID} = get_config(Type, Level),
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	case is_integer(SkillID) andalso SkillID > 0 of
		true  ->
			role_skill:active(SkillID, RoleSt),
			#cfg_skill{name=SkillName} = cfg_skill:find(SkillID),
			MsgNo = case Type of
				?TRAIN_WING   -> ?MSG_TRAIN_WING_UPGRADE2;
				?TRAIN_WEAPON -> ?MSG_TRAIN_WEAPON_UPGRADE2;
				?TRAIN_TALIS  -> ?MSG_TRAIN_TALIS_UPGRADE2
			end,
			?notify(MsgNo, [{role,RoleID,RoleName}, Level, SkillName]);
		false when Level rem 50 == 0 ->
			MsgNo = case Type of
				?TRAIN_WING   -> ?MSG_TRAIN_WING_UPGRADE1;
				?TRAIN_WEAPON -> ?MSG_TRAIN_WEAPON_UPGRADE1;
				?TRAIN_TALIS  -> ?MSG_TRAIN_TALIS_UPGRADE1;
				?TRAIN_GOD    -> ?MSG_TRAIN_GOD_UPGRADE1
			end,
			?notify(MsgNo, [{role,RoleID,RoleName}, Level]);
		false ->
			ignore
	end.

active_skills(Type, Level, RoleSt) ->
	#cfg_train{skill=SkillID} = get_config(Type, Level),
	case SkillID of
		_ when is_integer(SkillID), SkillID > 0 ->
			role_skill:active(SkillID, RoleSt);
		_ when is_list(SkillID), length(SkillID) > 0 ->
			role_skill:active(SkillID, RoleSt);
		_ ->
			ignore
	end.
