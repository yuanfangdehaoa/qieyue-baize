%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_vip).

-include("buff.hrl").
-include("game.hrl").
-include("item.hrl").
-include("vip.hrl").
-include("role.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").

%% API
-export([hook_login/1]).
-export([hook_reset/3]).
-export([post_reset/3]).
-export([active/2]).
-export([expire/2]).
-export([add_exp/2, add_exp/3]).
-export([get_level/0, get_level/1, get_level/3]).
-export([add_expool/1]).
-export([get_attr/1]).
-export([get_vip_buff/1]).

-define(TASTE_CARD, 1).
-define(TASTE_CARD2, 6).

-define(VIP_BUFF, 130110000).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_login(RoleSt=#role_st{role=RoleID}) ->
	is_update_vip_etime(RoleSt),
	V = #role_vip{exp = Exp, etime=ETime} = role_data:get(?DB_ROLE_VIP),
	role_data:set(V#role_vip{exp = round(Exp)}),
	NTime = ut_time:seconds(),
	case NTime >= ETime of
		true  ->
			expire({RoleID,?MODULE}, RoleSt);
		false ->
			Last = ETime - NTime,
		    role_timer:add_task({RoleID,?MODULE}, Last, 0, role_vip, ?nil, expire)
	end.

hook_reset(_, _, RoleSt) ->
	calc_mcard_fetch(RoleSt),
	give_exceed_money(RoleSt).

post_reset(_, _, _RoleSt) ->
	ok.
	% auto_add_exp(RoleSt).

%% 激活 vip
active(CardID, RoleSt) ->
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	RoleVip = role_data:get(?DB_ROLE_VIP),
	#role_vip{level=OldLv, rebate=Rebate, taste=Taste} = RoleVip,
	CfgCard = cfg_vip_card:find(CardID),
	NowTime = ut_time:seconds(),
	#cfg_vip_card{item=ItemID, level=CfgLv, last=Last} = CfgCard,
	RoleVip1 = case OldLv < CfgLv of
		true  -> % vip 直升
			upgrade(RoleVip, NowTime, CfgCard);
		false -> % vip 延期
			addtime(RoleVip, NowTime, CfgCard)
	end,
	RoleVip2 = case Rebate == ?nil andalso CardID == 4 of
		true  ->
			Rebate2 = #r_vip_rebate{
				time  = NowTime + cfg_game:vip_rebate(),
				fetch = 0
			},
			?ucast(#m_vip_rebate_info_toc{
				time  = Rebate2#r_vip_rebate.time,
				fetch = false
			}),
			RoleVip1#role_vip{rebate=Rebate2};
		false ->
			RoleVip1
	end,
	RoleVip3 = case Taste == ?nil andalso CardID == 1 of
		true  ->
			Taste2 = #r_vip_taste{
				stime = NowTime,
				etime = NowTime + Last
			},
			?ucast(#m_vip_taste_info_toc{
				stime = NowTime,
				etime = NowTime + Last
			}),
			RoleVip2#role_vip{taste=Taste2};
		false ->
			RoleVip2
	end,
	role_data:set(RoleVip3),
	#role_vip{type=NewType, level=NewLv, exp=NewExp, etime=NewEnd} = RoleVip3,
    role_timer:rep_task({RoleID,?MODULE}, NewEnd-NowTime, 0, role_vip, ?nil, expire),
	role_attr:recalc(?MODULE, RoleSt),
	add_vip_buff(RoleVip3, RoleSt),
	role_event:event(?EVENT_VIP_CARD, CardID),
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	case RoleLv >= cfg_game:vip_exppool_auto() of
		true  -> vip_handler:fetch_exp_pool(RoleVip3, true, RoleSt);
		false -> ignore
	end,
	UpInt1 = #{"viptype"=>NewType, "vipexp"=>NewExp, "vipend"=>NewEnd},
	UpInt2 = case NewLv > OldLv of
		true  -> UpInt1#{"viplv"=>NewLv};
		false -> UpInt1
	end,
	#cfg_item{name=ItemName, color=Color} = cfg_item:find(ItemID),
	?notify(?MSG_VIP_ACTIVE, [
		{role,RoleID,RoleName},
		ut_color:format(ItemName, Color)
	]),
	?ucast(#m_role_update_toc{upint=UpInt2}).

%% vip 过期
expire(_, RoleSt=#role_st{role=RoleID}) ->
	% RoleVip = role_data:get(?DB_ROLE_VIP),
	% role_data:set(RoleVip#role_vip{type=?VIP_TYPE_NONE}),
	role_cache:update(RoleID, [{#role_cache.viplv, 0}]),
	role_attr:recalc(?MODULE, RoleSt).

%% 增加 vip 经验
add_exp(ExpAdd, RoleSt) ->
	RoleVip = role_data:get(?DB_ROLE_VIP),
	add_exp(RoleVip, ExpAdd, RoleSt).

add_exp(RoleVip, ExpAdd, RoleSt) ->
	#role_vip{level=OldLv, exp=OldExp,etime=ETime} = RoleVip,
	NewExp   = OldExp + ExpAdd,
	RoleVip2 = maybe_upgrade(RoleVip#role_vip{exp=NewExp}),
	role_data:set(RoleVip2),
	#role_vip{level=NewLv} = RoleVip2,
	?_if(NewLv > OldLv, add_vip_buff(RoleVip2, RoleSt)),
	case NewLv > OldLv of
		true ->
			?_if(NewLv>=4 andalso ETime=<2047483647,add_vip_buff(RoleVip2#role_vip{etime = ETime + 2047483647}, RoleSt),add_vip_buff(RoleVip2, RoleSt)),  %vip4永久buff
			role_attr:recalc(?MODULE, RoleSt),
			dating_manager:hook_upgrade(?nil, RoleSt);
		false ->
			ignore
	end,
	UpInt = case NewLv > OldLv of
		true  -> #{"viplv"=>NewLv, "vipexp"=>NewExp};
		false -> #{"vipexp"=>NewExp}
	end,
	?ucast(#m_role_update_toc{upint=UpInt}).

get_level() ->
	RoleVip = role_data:get(?DB_ROLE_VIP),
	get_level(RoleVip).

get_level(RoleVip) ->
	#role_vip{level=VipLv, type=VipType, etime=VipETime} = RoleVip,
	get_level(VipLv, VipType, VipETime).

get_level(VipLv, VipType, VipETime) ->
	case VipType == ?VIP_TYPE_NONE of
		true  ->
			0;
		false ->
			case ut_time:seconds() >= VipETime of
				true  -> 0;
				false -> VipLv
			end
	end.

add_expool(ExpDrop) ->
	RoleVip = role_data:get(?DB_ROLE_VIP),
	#role_vip{level=VipLv, type=VipType, pool=ExpPool} = RoleVip,
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	MaxExp = cfg_role_level:pool(RoleLv),
	case ExpPool < MaxExp andalso VipLv > 0 andalso VipType == ?VIP_TYPE_NONE of
		true  ->
			Exp2 = min(MaxExp, ut_math:floor(ExpPool + ExpDrop*0.3)),
			role_data:set(RoleVip#role_vip{pool=Exp2});
		false ->
			0
	end.

get_attr(_AttrType) ->
	VipLv = get_level(),
	#cfg_vip_level{attrs=Attrs} = cfg_vip_level:find(VipLv),
	Attrs.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
upgrade(RoleVip, NowTime, CfgCard) ->
	#role_vip{type=OldType, exp=VipExp, etime=ETime, card=CardID1} = RoleVip,
	case CardID1 == 0 of
		true  ->
			MaxExp1 = 0;
		false ->
			#cfg_vip_card{level=Level1} = cfg_vip_card:find(CardID1),
			#cfg_vip_level{exp=MaxExp1} = cfg_vip_level:find(Level1)
	end,
	#cfg_vip_card{id=CardID2, level=Level2, exp=ExpAdd, last=Last} = CfgCard,
	#cfg_vip_level{exp=MaxExp2} = cfg_vip_level:find(Level2),
	NewType = case OldType /= ?VIP_TYPE_NORM andalso (CardID2 == ?TASTE_CARD orelse CardID2 == ?TASTE_CARD2) of
		true  -> ?VIP_TYPE_TASTE;
		false -> ?VIP_TYPE_NORM
	end,
	role_event:event(?EVENT_VIPLV, Level2),
	RoleVip#role_vip{
		level = Level2,
		exp   = MaxExp2 + ?_if(CardID1 == 0, 0, ExpAdd) + (VipExp-MaxExp1),
		etime = max(ETime, NowTime) + Last,
		type  = NewType,
		card  = max(CardID1, CardID2)
	}.

addtime(RoleVip, NowTime, CfgCard) ->
	#role_vip{type=OldType, exp=VipExp, etime=ETime, card=CardID1} = RoleVip,
	#cfg_vip_card{id=CardID2, last=Last, exp=ExpAdd} = CfgCard,
	NewType = case OldType /= ?VIP_TYPE_NORM andalso (CardID2 == ?TASTE_CARD orelse CardID2 == ?TASTE_CARD2) of
		true  -> ?VIP_TYPE_TASTE;
		false -> ?VIP_TYPE_NORM
	end,
	RoleVip2 = RoleVip#role_vip{
		exp   = VipExp + ExpAdd,
		etime = max(ETime, NowTime) + Last,
		type  = NewType,
		card  = max(CardID1, CardID2)
	},
	maybe_upgrade(RoleVip2).

maybe_upgrade(RoleVip) ->
	#role_vip{level=VipLv, exp=VipExp} = RoleVip,
	case cfg_vip_level:find(VipLv+1) of
		#cfg_vip_level{exp=MaxExp} when VipExp >= MaxExp ->
			role_event:event(?EVENT_VIPLV, VipLv+1),
			maybe_upgrade(RoleVip#role_vip{level=VipLv+1});
		_ ->
			RoleVip
	end.

%% 计算月卡领取
calc_mcard_fetch(_RoleSt) ->
	RoleVip = role_data:get(?DB_ROLE_VIP),
	#role_vip{mcard=MCard, mfetch=MFetch0} = RoleVip,
	case MCard of
		true ->
			MaxDay = lists:max(maps:keys(MFetch0)),
			Max = lists:max(cfg_vip_mcard:all()),
			case {maps:find(MaxDay, MFetch0), MaxDay == Max} of
				{{ok, true}, false} ->
					MFetch = maps:put(MaxDay+1, false, MFetch0),
					role_data:set(RoleVip#role_vip{mfetch=MFetch});
				_ ->
					ignore
			end;
		false ->
			ignore
	end.

% 发放超出的元宝/绑元
give_exceed_money(RoleSt) ->
	VipLv = get_level(),
	#cfg_vip_level{gold=MaxGold, bgold=MaxBGold} = cfg_vip_level:find(VipLv),
	RoleBag = #role_bag{exceed=Exceed} = role_data:get(?DB_ROLE_BAG),
	ExceedGold  = maps:get(?ITEM_GOLD, Exceed, 0),
	ExceedBGold = maps:get(?ITEM_BGOLD, Exceed, 0),

	GiveGold  = min(ExceedGold, MaxGold),
	?_if(GiveGold > 0, give_exceed_money2(?ITEM_GOLD, GiveGold, RoleSt)),

	GiveBGold = min(ExceedBGold, MaxBGold),
	?_if(GiveBGold > 0, give_exceed_money2(?ITEM_BGOLD, GiveBGold, RoleSt)),

	RoleBag2 = RoleBag#role_bag{
		exceed = #{
			?ITEM_GOLD  => max(0, ExceedGold - MaxGold),
			?ITEM_BGOLD => max(0, ExceedBGold - MaxBGold)
		}
	},
	role_data:set(RoleBag2).

give_exceed_money2(MoneyID, Num, RoleSt) ->
	{Title, Text} = cfg_mail:find(?MAIL_MONEY_EXCEED_GIVE),
    #cfg_item{name=Name} = cfg_item:find(MoneyID),
    Title2 = io_lib:format(Title, [Name]),
    mail:send(RoleSt#role_st.role, Title2, Text, [{MoneyID,Num}]).

%% 自动领取vip经验
% auto_add_exp(RoleSt) ->
% 	RoleVip = #role_vip{auto=IsAuto} = role_data:get(?DB_ROLE_VIP),
% 	VipLv   = get_level(RoleVip),
% 	CntKey  = {?ROLE_COUNT_VIP_WELFARE, ?VIP_WELFARE_DAILY_EXP},
% 	Times   = role_count:get_times(CntKey),
% 	case VipLv > 0 andalso Times == 0 andalso IsAuto of
% 		true  ->
% 			#cfg_vip_level{vipexp=ExpAdd} = cfg_vip_level:find(VipLv),
% 			add_exp(RoleVip, ExpAdd, RoleSt),
% 			role_count:add_times(CntKey);
% 		false ->
% 			ignore
% 	end.

add_vip_buff(RoleVip, RoleSt) ->
	buff:add(get_vip_buff(RoleVip), RoleSt).

get_vip_buff(RoleVip) ->
	VipLv = get_level(RoleVip),
	Opts  = #{etime=>RoleVip#role_vip.etime},
	#cfg_vip_level{buffs=Buffs} = cfg_vip_level:find(VipLv),
	[{ID, Opts} || ID <- Buffs].

is_update_vip_etime(RoleSt) ->
	NTime = ut_time:seconds(),
	V = #role_vip{etime=ETime,level = Level} = role_data:get(?DB_ROLE_VIP),
	case Level >= 4 andalso NTime =< 2047483647 of  % 只加一次
		true ->
			RoleVip2 = V#role_vip{etime = ETime + 2047483647},
			role_data:set(RoleVip2),
			add_vip_buff(RoleVip2,RoleSt);
		false -> ignore
	end.