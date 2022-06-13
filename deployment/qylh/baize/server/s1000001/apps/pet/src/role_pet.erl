%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_pet).

-include("attr.hrl").
-include("pet.hrl").
-include("game.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("equip.hrl").
-include("skill.hrl").
-include("bag.hrl").
-include("item.hrl").
-include("msgno.hrl").

%% API
-export([get_fight/0]).
-export([check_skill/1]).
-export([get_attr/1]).
-export([add_egg_records/3]).
-export([get_egg_records/0]).
-export([hook_expire/2]).
-export([delete_skills/3]).
-export([add_skills/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_expire(Item, RoleSt) ->
    case Item#p_item.bag == ?BAG_ID_PET_ASSIST of
        true  ->
        	RolePet = #role_pet{fight=Fight, pets=Pets} = role_data:get(?DB_ROLE_PET),
        	PetID =  maps:get(Fight, Pets, 0),
        	case PetID == Item#p_item.uid of
        		true  ->
        			delete_skills(Fight, Item#p_item.extra, RoleSt),
        			Fight2 = get_top_pet(Pets),
        			ItemId = case Fight2 > 0 of
        				true  ->
        					PetID2 = maps:get(Fight2, Pets, 0),
        					{ok, Item2} = role_bag:get_item(PetID2),
        					add_skills(Fight2, Item2#p_item.extra, RoleSt),
        					Item2#p_item.id;
        				false ->
        					0
        			end,
        			role_figure:update_pet(ItemId, RoleSt),
        			role_data:set(RolePet#role_pet{fight=Fight2}),
        			?ucast(#m_pet_info_toc{fight_order=Fight2});
        		false ->
        			ignore
        	end,
            role_attr:recalc(role_pet, RoleSt);
        false ->
            ignore
    end.

get_attr(_AttrType)->
	#role_pet{fight=Fight, pets=Pets} = role_data:get(?DB_ROLE_PET),
	{TotalAttr, TotalPower} = get_order_attr(Pets),
	UId = maps:get(Fight, Pets, 0),
	Attr = case UId > 0 of
		true ->
			{ok, #p_item{extra=Evolution}} = role_bag:get_item(UId),
			#cfg_pet_evolution{fight_attr=FightAttr} = cfg_pet_evolution:find(Fight, Evolution),
			FightAttr;
		false ->
			#{}
	end,
	TotalAttr2 = mod_attr:sum([TotalAttr, Attr]),
	role_event:event(?EVENT_PET_TOTAL_POWER, TotalPower),
	TotalAttr2.

%删除技能
delete_skills(Order, Evolution, RoleSt)->
	#cfg_pet_evolution{normal_atk=NSkills, change_atk=CSkills, profound=PSkills, passive=Passive}
	= cfg_pet_evolution:find(Order, Evolution),
	Skills = lists:merge3(NSkills, PSkills, Passive),
	Skills2 = lists:merge(Skills, CSkills),
	role_skill:remove(Skills2, RoleSt),
	Buffs2 = lists:foldl(fun
			(SkillID, Acc) ->
				#cfg_skill_level{buffs=Buffs} = cfg_skill_level:find(SkillID, 1),
				lists:merge(Acc, Buffs)
		end, [], Skills2),
	buff:del(Buffs2, RoleSt),
	%删除buffer
	case length(PSkills) > 0 of
		true ->
			[PSkill] = PSkills,
			#cfg_skill_level{effect=Effect} = cfg_skill_level:find(PSkill, 1),
			lists:foreach(fun
					(Item) ->
						case Item of
							{buff, atker, Buff} ->
								buff:del([Buff], RoleSt);
							_ ->
								igore
						end
				end, Effect);
		false ->
			ignore
	end.

%增加技能
add_skills(Order, Evolution, RoleSt)->
	#cfg_pet_evolution{normal_atk=NSkills, change_atk=CSkills, profound=PSkills, passive=Passive}
	= cfg_pet_evolution:find(Order, Evolution),
	Skills = lists:merge3(NSkills, PSkills, CSkills),
	Skills2 = lists:merge(Skills, Passive),
	role_skill:active(Skills2, RoleSt),
	%设置cd
	set_skills_cd(Skills, RoleSt).



% 获取正在出战的宠物
get_fight()->
	#role_pet{fight=Fight, pets=Pets} = role_data:get(?DB_ROLE_PET),
	case maps:find(Fight, Pets)	 of
		{ok, PetID} ->
			role_bag:get_item(PetID);
		error ->
			?nil
	end.

%检查是否变身后技能
check_skill(SkillID)->
	#cfg_skill{pos=Pos} = cfg_skill:find(SkillID),
	Pos == ?SKILL_POS_PET_TRANS_NOR orelse Pos == ?SKILL_POS_PET_TRANS_PRO.

%增加开蛋记录
add_egg_records(ItemId, Pets, RoleSt)->
	#role_st{role=RoleId, name=RoleName} = RoleSt,
	lists:foreach(fun
			(Item) ->
				#p_item{id=PetId} = Item,
				CacheId = item_cache:add_cache(Item),
				PetMap = maps:put(CacheId, integer_to_list(PetId), #{}),
				EggRecord = #p_egg_record{
					  role_id   = RoleId
					, role_name = RoleName
					, item_id   = ItemId
					, pets      = PetMap
					, time      = ut_time:seconds()
				},
				game_logger:add_log(?MODULE, EggRecord),
				#cfg_pet{order=Order, quality=Quality} = cfg_pet:find(PetId),
				case Order >= 400 andalso Quality>=5 of
					true ->
						#role_st{role=RoleID, name=RoleName} = RoleSt,
						ItemMap = #{ItemId => 0},
						PItemMap = #{CacheId => PetId},
						?notify(?MSG_PET_GET_NOTICE, [{role, RoleID, RoleName},
							{item, ItemMap}, {pitem, PItemMap}]);
					false ->
						ignore
				end,
				?ucast(#m_pet_show_toc{pet=item_util:p_item(Item)})
		end, Pets).


get_egg_records()->
	game_logger:get_logs(?MODULE).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
calc_equip(Item)->
	#p_item{id=Id, pet=Pet} = Item,
	#cfg_pet{order=Order} = cfg_pet:find(Id),
	#role_pet{strong=Strong, strong_attr=StrongAttr} = role_data:get(?DB_ROLE_PET),
	Cross = maps:get(Order, Strong, 0),
	OrderStrongAttr = maps:get(Order, StrongAttr, #{}),
	Pet2 = Pet#p_pet{cross=Cross, strong=OrderStrongAttr},
	Item2 = Item#p_item{pet=Pet2},
	role_bag:set_item(Item2),
	Item2.

%计算宠物总属性
calc_pet_attr(Order, Item, Evolution)->
	#p_item{pet=Pet, score=Score} = Item,
	#p_pet{
		base   = BaseAttr,
		rare1  = RareAttr1,
		rare2  = RareAttr2,
		rare3  = RareAttr3,
		cross  = Cross,
		strong = StrongAttr
	} = Pet,
	#cfg_pet_strong{percent=_Percent,plus_percent=PlusPercent} = cfg_pet_strong:find(Order, Cross),
	% StrongAttr2 = mod_attr:to_rec(maps:to_list(StrongAttr)),
	TotalBase  = mod_attr:sum([BaseAttr, StrongAttr]),
	%TotalBase2 = mod_attr:to_list(TotalBase),
	% TotalBase3 = lists:foldl(fun
	% 		({K, V}, List) ->
	% 			case is_integer(V) of
	% 				true ->
	% 					[{K, ut_math:floor(V * (1+Percent/10000))}|List];
	% 				false ->
	% 					List
	% 			end
	% 	end, [], TotalBase2),
	#cfg_pet_evolution{attr=EvoAttr} = cfg_pet_evolution:find(Order, Evolution),
	BaseAttrList = mod_attr:to_list(BaseAttr),
	BaseAttrMap = maps:from_list(BaseAttrList),
	PlusBaseAttrs = lists:foldl(fun
			({K, V}, Attr) ->
				Value = maps:get(K, BaseAttrMap, 0),
				[{K, ut_math:floor(Value * (V/10000))} | Attr]
		end, [], PlusPercent),
	TotalAttr = mod_attr:sum([TotalBase, RareAttr1, RareAttr2, RareAttr3, EvoAttr, PlusBaseAttrs]),
	#cfg_pet_evolution{fight_attr=FightAttr} = cfg_pet_evolution:find(Order, Evolution),
	PowerAttr = mod_attr:sum([StrongAttr, EvoAttr, PlusBaseAttrs, FightAttr]),
	Power = mod_attr:power(PowerAttr),
	Power2 = Power + Score,
	role_event:event(?EVENT_PET_POWER, Power2),
	Pet2 = Pet#p_pet{power=Power2},
	role_bag:set_item(Item#p_item{pet=Pet2}),
	{TotalAttr, Power2}.


%获取助战属性
get_order_attr(Pets)->
	maps:fold(fun
			(_Order, UId, {Attr, TotalPower}) ->
				{ok, Item} = role_bag:get_item(UId),
				#p_item{etime=ETime, extra=Evolution, id=Id} = Item,
				case ETime == 0 orelse ETime > ut_time:seconds() of
					true ->
						#cfg_pet{order=Order} = cfg_pet:find(Id),
						Item2 = calc_equip(Item),
						{TotalAttr, Power} = calc_pet_attr(Order, Item2, Evolution),
						{mod_attr:sum([TotalAttr, Attr]), TotalPower+Power};
					false ->
						{Attr, TotalPower}
			    end
		end, {#{}, 0}, Pets).

%获取战力最高宠物
get_top_pet(Pets)->
	List = maps:fold(fun
			(Order, UId, Acc) ->
				 {ok, Item} = role_bag:get_item(UId),
				 #p_item{etime=ETime, pet=#p_pet{power=Power}} = Item,
				 case ETime == 0 orelse ETime > ut_time:seconds()+1 of
				 	true  -> [{Order, Power}|Acc];
				 	false -> Acc
				 end
		end, [], Pets),
	List2 = lists:keysort(2, List),
	Length = length(List2),
	case Length > 0 of
		true  ->
			{Order, _} = lists:nth(Length, List2),
			Order;
		false ->
			0
	end.

set_skills_cd(SkillIDs, RoleSt)->
	RoleSkill = role_data:get(?DB_ROLE_SKILL),
    #role_skill{skills=Skills, endcd=EndCDs} = RoleSkill,
    EndCDs2 = lists:foldl(fun
    		(SkillID, Maps)->
    			SkillLv = maps:get(SkillID, Skills),
			    #cfg_skill_level{cd=CD} = cfg_skill_level:find(SkillID, SkillLv),
			    Millis = ut_time:milliseconds(),
			    NewCD  = CD + Millis,
			    maps:put(SkillID, NewCD, Maps)
    	end, EndCDs, SkillIDs),
    role_data:set(RoleSkill#role_skill{
        endcd = EndCDs2
    }),
    role_skill:update_cds(EndCDs2, RoleSt).

