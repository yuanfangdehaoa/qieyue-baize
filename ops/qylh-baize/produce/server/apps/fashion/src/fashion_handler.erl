%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fashion_handler).

-include("equip.hrl").
-include("game.hrl").
-include("fashion.hrl").
-include("item.hrl").
-include("role.hrl").
-include("table.hrl").
-include("log.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("msgno.hrl").


%% API
-export([handle/3]).
-export([get_attr/1]).
-export([putoff_weapon/1]).
-export([hook_sysopen/1, hook_sysopen/2]).
-export([expire/2]).
-export([hook_login/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_login(RoleSt)->
	RoleFashion = #role_fashion{fashions=Fashions, putons=Putons} = role_data:get(?DB_ROLE_FASHION),
	{Fashions2, Putons2} = maps:fold(fun
			(K, PFashion, {Acc, Acc2}) ->
				#p_fashion{end_time=EndTime} = PFashion,
				case EndTime > 0 of
					true ->
						Now = ut_time:seconds(),
						case EndTime > Now of
							true ->
								#role_st{role=RoleId} = RoleSt,
								role_timer:rep_task({RoleId, ?MODULE, K, expire}, EndTime-Now, ?MODULE, expire),
								{maps:put(K, PFashion, Acc), Acc2};
							false ->
								#cfg_fashion{type_id=Locus} = cfg_fashion:find(K),
								OldId = maps:get(Locus, Acc2, 0),
								Acc3 = case OldId == K of
									true  ->
										role_figure:update_fashion(Locus, 0, RoleSt),
										maps:remove(Locus, Acc2);
									false ->
										Acc2
								end,
								{Acc, Acc3}
						end;
					false ->
						{maps:put(K, PFashion, Acc), Acc2}
				end
		end, {#{}, Putons}, Fashions),
	role_data:set(RoleFashion#role_fashion{fashions=Fashions2, putons=Putons2}),
	case maps:size(Fashions) /= maps:size(Fashions2) of
		true  -> role_attr:recalc(?MODULE, RoleSt);
		false -> ignore
	end.

%过期
expire({_, _, Id, _}, RoleSt)->
	RoleFashion =#role_fashion{fashions=Fashions, putons=Putons} = role_data:get(?DB_ROLE_FASHION),
	PFashion = maps:get(Id, Fashions, ?nil),
	case PFashion of
		?nil ->
			ignore;
		_ ->
			Fashions2 = maps:remove(Id, Fashions),
			#cfg_fashion{type_id=Locus} = cfg_fashion:find(Id),
			OldId = maps:get(Locus, Putons, 0),
			Putons2 = case OldId == Id of
				true  ->
					role_figure:update_fashion(Locus, 0, RoleSt),
					maps:remove(Locus, Putons);
				false ->
					Putons
			end,
			role_data:set(RoleFashion#role_fashion{fashions=Fashions2, putons=Putons2}),
			role_attr:recalc(?MODULE, RoleSt)
	end.

hook_sysopen(RoleSt)->
	[hook_sysopen2(Type, RoleSt) || Type <- [
		?FASHION_STATE_TYPE_CLOTHES,
		?FASHION_STATE_TYPE_HEAD,
		?FASHION_STATE_TYPE_WEAPON
	]].

hook_sysopen(Type, RoleSt) ->
	hook_sysopen2(Type, RoleSt).

get_attr(_AttrType)->
	#role_fashion{fashions=Fashions} = role_data:get(?DB_ROLE_FASHION),
	maps:fold(fun
			(_K, #p_fashion{id=Id, star=Star}, Attr) ->
				case cfg_fashion_star:find(Id, Star) of
					?nil ->
						Attr;
					#cfg_fashion_star{attrib=Attrib} ->
						mod_attr:add(Attr, Attrib)
				end
		end, #{}, Fashions).

%获取信息
handle(?FASHION_INFO, _Tos, RoleSt)->
	RoleFashion = role_data:get(?DB_ROLE_FASHION),
	#role_fashion{fashions=Fashions,putons=Putons} = RoleFashion,
	{ok, #m_fashion_info_toc{fashions=Fashions, puton_id=Putons}, RoleSt};


%激活
handle(?FASHION_ACTIVE, Tos, RoleSt)->
	#role_st{role=RoleId, name=RoleName} = RoleSt,
	#m_fashion_active_tos{id=Id} = Tos,
	RoleFashion = role_data:get(?DB_ROLE_FASHION),
	#role_fashion{fashions=Fashions, putons=Putons} = RoleFashion,
	case maps:get(Id, Fashions, ?nil) of
		?nil->
			#cfg_fashion{
				cost=Cost, type_id=Locus, time=Duration, msgno=MsgNo
			} = cfg_fashion:find(Id),
			role_bag:cost(Cost, ?LOG_FASHION_ACTIVE, RoleSt),
			EndTime = case Duration > 0 of
				true  ->
					role_timer:rep_task({RoleId, ?MODULE, Id, expire}, Duration, ?MODULE, expire),
					ut_time:seconds()+Duration;
				false ->
					0
			end,
			Fashion = #p_fashion{id=Id, star=0, end_time=EndTime},
			Fashions2 = maps:put(Id, Fashion, Fashions),
			Putons2 = maps:put(Locus, Id, Putons),
			role_data:set(RoleFashion#role_fashion{fashions=Fashions2, putons=Putons2}),
			UpFashion = #{Id=>Fashion},
			?ucast(#m_fashion_info_toc{fashions=UpFashion, puton_id=Putons2}),
			Model = get_model(Id),
			role_figure:update_fashion(Locus, Model, RoleSt),
			%武器的时候，和神兵互斥
			case Locus == ?FASHION_STATE_TYPE_WEAPON of
				true ->
					morph_handler:putoff_weapon();
				false ->
					ignore
			end,
			role_attr:recalc(?MODULE, RoleSt),
			#cfg_item{color=ItemColor, name=ItemName} = cfg_item:find(Id),
			?_if(MsgNo > 0, ?notify(MsgNo, [
				{role,RoleId,RoleName},
				{color,ItemName,ItemColor}
			]));
		_->
			throw(?err(?ERR_FASHION_IS_ACTIVED))
	end,
	{ok, #m_fashion_active_toc{}, RoleSt};

%穿戴
handle(?FASHION_PUTON, Tos, RoleSt)->
	#m_fashion_puton_tos{id=Id} = Tos,
	RoleFashion = #role_fashion{fashions=Fashions, putons=Putons} = role_data:get(?DB_ROLE_FASHION),
	case maps:get(Id, Fashions, ?nil) of
		?nil -> throw(?err(?ERR_FASHION_IS_NOT_EXIST));
		_    ->	ignore
	end,
	#cfg_fashion{type_id=Locus} = cfg_fashion:find(Id),
	FId = maps:get(Locus, Putons, 0),
	?_check(FId /= Id, ?ERR_FASHION_IS_PUTON),
	Putons2 = maps:put(Locus, Id, Putons),
	role_data:set(RoleFashion#role_fashion{putons=Putons2}),
	?ucast(#m_fashion_info_toc{puton_id=Putons2}),
	Model = get_model(Id),
	role_figure:update_fashion(Locus, Model, RoleSt),
	%武器的时候，和神兵互斥
	case Locus == ?FASHION_STATE_TYPE_WEAPON of
		true ->
			morph_handler:putoff_weapon();
		false ->
			ignore
	end,
	{ok, #m_fashion_puton_toc{}, RoleSt};

% %脱下
% handle(?FASHION_PUTOFF, Tos, RoleSt)->
% 	#m_fashion_putoff_tos{id=Id} = Tos,
% 	RoleFashion = #role_fashion{putons=Putons} = role_data:get(?DB_ROLE_FASHION),
% 	#cfg_fashion{type_id=Locus} = cfg_fashion:find(Id),
% 	?_check(maps:get(Locus, Putons, 0) > 0, ?ERR_FASHION_IS_NOT_PUTON),
% 	Putons2 = maps:remove(Locus, Putons),
% 	role_data:set(RoleFashion#role_fashion{putons=Putons2}),
% 	role_figure:update_fashion(Locus, 0, RoleSt),
% 	{ok, #m_fashion_putoff_toc{id=Id}, RoleSt};


%升星
handle(?FASHION_UPSTAR, Tos, RoleSt)->
	#m_fashion_upstar_tos{id=Id} = Tos,
	RoleFashion = #role_fashion{fashions=Fashions} = role_data:get(?DB_ROLE_FASHION),
	case maps:get(Id, Fashions, ?nil) of
		?nil->
			throw(?err(?ERR_FASHION_IS_NOT_EXIST));
		Fashion = #p_fashion{star=Star}->
			NextStar = Star + 1,
			FashionStarCfg = cfg_fashion_star:find(Id, NextStar),
			?_check(FashionStarCfg /= ?nil, ?ERR_FASHION_IS_MAX_STAR),
			#cfg_fashion_star{cost=Cost, msgno=MsgNo} = FashionStarCfg,
			role_bag:cost(Cost, ?LOG_FASHION_UPSTAR, RoleSt),
			Fashion2 = Fashion#p_fashion{star=NextStar},
			Fashions2 = maps:put(Id, Fashion2, Fashions),
			role_data:set(RoleFashion#role_fashion{fashions=Fashions2}),
			UpFashion = #{Id=>Fashion2},
			?ucast(#m_fashion_info_toc{fashions=UpFashion}),
			role_attr:recalc(?MODULE, RoleSt),
			#role_st{role=RoleId, name=RoleName} = RoleSt,
			#cfg_item{color=ItemColor, name=ItemName} = cfg_item:find(Id),
			?_if(MsgNo > 0, ?notify(MsgNo, [
				{role,RoleId,RoleName},
				{color,ItemName,ItemColor},
				NextStar
			]))
	end,
	{ok, #m_fashion_upstar_toc{}, RoleSt}.


%脱下武器时装
putoff_weapon(_RoleSt)->
	RoleFashion = #role_fashion{putons=Putons} = role_data:get(?DB_ROLE_FASHION),
	Putons2 = maps:remove(?FASHION_STATE_TYPE_WEAPON, Putons),
	role_data:set(RoleFashion#role_fashion{putons=Putons2}).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_model(Id)->
	#role_info{career = Career} = role_data:get(?DB_ROLE_INFO),
	#cfg_fashion{man_model=ManModel, girl_model=GirlModel} = cfg_fashion:find(Id),
	case Career of
		1 -> ManModel;
		_ -> GirlModel
	end.

hook_sysopen2(Type, RoleSt) ->
	RoleFashion = role_data:get(?DB_ROLE_FASHION),
	#role_fashion{fashions=Fashions, putons=Putons} = RoleFashion,
	FasionID = cfg_fashion:default(Type),
	#cfg_fashion{type_id=Locus} = cfg_fashion:find(FasionID),
	Fashion = #p_fashion{id=FasionID, star=0, end_time=0},
	ModelID = get_model(FasionID),
	role_figure:update_fashion(Locus, ModelID, RoleSt),
	role_data:set(RoleFashion#role_fashion{
		fashions = maps:put(FasionID, Fashion, Fashions),
		putons   = maps:put(Locus, FasionID, Putons)
	}).