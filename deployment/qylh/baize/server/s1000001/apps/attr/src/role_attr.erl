%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_attr).

-include("attr.hrl").
-include("figure.hrl").
-include("game.hrl").
-include("morph.hrl").
-include("mount.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("table.hrl").
-include("proto.hrl").

%% API
-export([recalc/2]).
-export([init/1]).
-export([speed/0]).
-export([del_cache/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%%-----------------------------------------------
%% @doc 初始化玩家属性
-spec init(#role_st{}) ->
	no_return().
%%-----------------------------------------------
init(RoleSt) ->
	calc_attr(false, RoleSt).


%%-----------------------------------------------
%% @doc 重算属性
-spec recalc(any(), #role_st{}) ->
	no_return().
%%-----------------------------------------------
recalc(Module, RoleSt) ->
	case Module == role_equip of
		true  ->
			del_cache({role_equip, ?ATTR_TYPE_WEAPON}),
			del_cache({role_equip, ?ATTR_TYPE_ARMOR}),
			del_cache({role_equip, ?ATTR_TYPE_JEWEL}),
			del_cache({role_equip, ?ATTR_TYPE_NORMAL}),
			del_cache(role_equip_other);
		false ->
			del_cache(Module)
	end,
	case calc_attr(true, RoleSt) of
		{_Power, _Power} ->
			igore;
		{OldPower,NewPower} ->
			role_cache:update(RoleSt#role_st.role, [{#role_cache.power, NewPower}]),
			log_api:log_power(RoleSt,Module,OldPower,NewPower)
	end.



-define(k_attr_cache, {k_attr_cache, Key}).
get_cache(Key) ->
	get(?k_attr_cache).

set_cache(Key, Attr) ->
	put(?k_attr_cache, Attr).

del_cache(Key) ->
	erase(?k_attr_cache).

%% 计算玩家速度
speed() ->
	#role_info{figure=Figure} = role_data:get(?DB_ROLE_INFO),
	IsShow = case maps:find(?FIGURE_MOUNT, Figure) of
		{ok, Aspect} ->
			Aspect#p_aspect.show;
		error ->
			false
	end,

	case IsShow == true of
		true  ->
			#role_train{using=Using} = role_data:get(?DB_ROLE_TRAIN),
			case maps:find(?TRAIN_MOUNT, Using) of
				{ok, {train,Order}} ->
					#cfg_mount{speed=MountSpeed} = cfg_mount:find(Order, 1);
				{ok, {morph,MorID}} ->
					#cfg_morph{speed=MountSpeed} = cfg_mount_morph:find(MorID);
				error ->
					MountSpeed = 0
			end,
			cfg_game:role_speed() + MountSpeed;
		false ->
			cfg_game:role_speed()
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
calc_attr(Notify, RoleSt) ->
	#role_st{role=RoleID, name=RoleName, spid=ScenePid} = RoleSt,
	RoleAttr = #role_attr{power=OldPower} = role_data:get(?DB_ROLE_ATTR),
	Attr1 = calc_without_gp(),
	Attr2 = Attr1#{
		?ATTR_SPEED   => ?MODULE:speed(),
		?ATTR_DMG_RED => mod_attr:calc_dmg_red(Attr1),
		?ATTR_PVP_RED => mod_attr:calc_pvp_red(Attr1)
	},
	Attr3 = mod_attr:calc_global_pro(Attr2),
	NewPower  = mod_attr:power(Attr3) + ?_attr(Attr3, ?ATTR_POWER, 0),
	RoleAttr2 = RoleAttr#role_attr{
		attr  = Attr3,
		power = max(OldPower, NewPower)
	},
    role_data:set(RoleAttr2),
    role_util:set_attr(Attr2),
    role_util:set_power(NewPower),
    role_cache:update(RoleID, [{#role_cache.power, NewPower}]),
    catch compete_server:update_power(RoleID, RoleName, NewPower),
	role_event:event(?EVENT_ATTR, Attr3),
	role_event:event(?EVENT_POWER, NewPower),
	% 全局属性百分比的计算不传到场景
	?_if(Notify, scene:update_actor(ScenePid, RoleID, [{attr,Attr2,NewPower}])),
	{OldPower,NewPower}.

calc_without_gp() ->
	% 基础系统
	BaseAttr1  = do_calc(get_base_mods(), ?ATTR_TYPE_BASE),
	% 武器系统
	WeapAttr1  = do_calc(get_weapon_mods(), ?ATTR_TYPE_WEAPON),
	% 防具系统
	ArmorAttr1 = do_calc(get_armor_mods(), ?ATTR_TYPE_ARMOR),
	% 饰品系统
	JewelAttr1 = do_calc(get_jewel_mods(), ?ATTR_TYPE_JEWEL),
	% 普通系统
	OtherAttr1 = do_calc(get_normal_mods(), ?ATTR_TYPE_NORMAL),

	FinalAttr1 = mod_attr:sum(
		[BaseAttr1, WeapAttr1, ArmorAttr1, JewelAttr1, OtherAttr1]
	),

	BaseAttr2  = BaseAttr1#{
		?ATTR_HPMAX => ?_attr(BaseAttr1,?ATTR_HPMAX) * (1+?_attrper(FinalAttr1,?ATTR_HPMAX_BP)),
		?ATTR_ATT   => ?_attr(BaseAttr1,?ATTR_ATT)   * (1+?_attrper(FinalAttr1,?ATTR_ATT_BP)),
		?ATTR_DEF   => ?_attr(BaseAttr1,?ATTR_DEF)   * (1+?_attrper(FinalAttr1,?ATTR_DEF_BP)),
		?ATTR_WRECK => ?_attr(BaseAttr1,?ATTR_WRECK) * (1+?_attrper(FinalAttr1,?ATTR_WRECK_BP))
	},

	WeapAttr2  = WeapAttr1#{
		?ATTR_ATT   => ?_attr(WeapAttr1,?ATTR_ATT)   * (1+?_attrper(FinalAttr1,?ATTR_ATT_WP)),
		?ATTR_WRECK => ?_attr(WeapAttr1,?ATTR_WRECK) * (1+?_attrper(FinalAttr1,?ATTR_WRECK_WP))
	},

	ArmorAttr2 = ArmorAttr1#{
		?ATTR_HPMAX => ?_attr(ArmorAttr1,?ATTR_HPMAX) * (1+?_attrper(FinalAttr1,?ATTR_HPMAX_AP)),
		?ATTR_DEF   => ?_attr(ArmorAttr1,?ATTR_DEF)   * (1+?_attrper(FinalAttr1,?ATTR_DEF_AP))
	},

	JewelAttr2 = JewelAttr1#{
		?ATTR_ATT => ?_attr(JewelAttr1,?ATTR_ATT) * (1+?_attrper(FinalAttr1,?ATTR_ATT_JP))
	},

	% 特殊属性
	SpecialAttr = calc_spec_attr(FinalAttr1),

	FinalAttr2 = mod_attr:sum(
		[BaseAttr2, WeapAttr2, ArmorAttr2, JewelAttr2, OtherAttr1, SpecialAttr]
	),

	FinalAttr2.

calc_spec_attr(Attr) ->
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	EquipAtt   = ?_attr(Attr,?ATTR_EQUIP_ATT) * (Level div 3),
	EquipDef   = ?_attr(Attr,?ATTR_EQUIP_DEF) * (Level div 3),
	EquipHpMax = ?_attr(Attr,?ATTR_EQUIP_HPMAX) * (Level div 3),

	TargetAtt  = ?_attr(Attr,?ATTR_TARGET_ATT) * Level,
	TargetBossAmp = ?_attr(Attr,?ATTR_TARGET_BOSS_AMP) * (Level div 50),
	#{
		?ATTR_ATT      => EquipAtt + TargetAtt,
		?ATTR_DEF      => EquipDef,
		?ATTR_HPMAX    => EquipHpMax,
		?ATTR_BOSS_AMP => TargetBossAmp
	}.

do_calc(ModList, AttrType) ->
	lists:foldl(fun
		(Mod, Acc) ->
			CacheKey = case Mod == role_equip of
				true  -> {Mod, AttrType};
				false -> Mod
			end,
			Attr1 = case get_cache(CacheKey) of
				?nil  ->
					case Mod of
						{Mod2, Args} ->
							Mod2:get_attr(AttrType, Args);
						_ ->
							Mod:get_attr(AttrType)
					end;
				Attr0 ->
					Attr0
			end,
			Attr2 = mod_attr:calc_part_pro(Attr1),
			set_cache(CacheKey, Attr2),
			mod_attr:add(Acc, Attr2)
	end, #{}, ModList).


%% 基础系统
get_base_mods() ->
	[
          role_level
 		, role_wake
 		, role_jobtitle
	].

%% 武器系统
get_weapon_mods() ->
	[
		  role_equip
	].

%% 防具系统
get_armor_mods() ->
	[
		  role_equip
	].

%% 饰品系统
get_jewel_mods() ->
	[
		  role_equip
	].

%% 普通系统
get_normal_mods() ->
	[
	      role_illusion
	    , beast_handler
	    , {mount_handler, ?TRAIN_MOUNT}
	    , {mount_handler, ?TRAIN_OFFHAND}
	    , {train_handler, ?TRAIN_WING}
	    , {train_handler, ?TRAIN_TALIS}
	    , {train_handler, ?TRAIN_WEAPON}
	    , {train_handler, ?TRAIN_GOD}
	 	, role_title
	 	, fashion_handler
	 	, {morph_handler, ?TRAIN_MOUNT}
	 	, {morph_handler, ?TRAIN_OFFHAND}
	 	, {morph_handler, ?TRAIN_WING}
	 	, {morph_handler, ?TRAIN_TALIS}
	 	, {morph_handler, ?TRAIN_WEAPON}
	 	, {morph_handler, ?TRAIN_GOD}
	 	, role_equip
	 	, role_skill
	 	, role_magiccard
	 	, role_vip
	 	, role_pet
	 	, baby_handler
	 	, role_equip_other
	 	, role_talent
	 	, role_soul
	 	, illustration_handler
	 	, god_equips_handler
	 	, mecha_handler
	 	, pet_equip_handler
	 	, artifact_handler
		, totem_handler
	].
