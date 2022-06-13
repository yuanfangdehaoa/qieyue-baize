%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_redenvelope_handler).

-include("game.hrl").
-include("guild.hrl").
-include("guild_redenvelope.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("msgno.hrl").

%% API
-export([handle/3]).
-export([init/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(GuildID) ->
	GuildRedEnvelope = #guild_redenvelope{
		id            = GuildID,
		red_envelopes = #{},
		records       = []
	},
	guild_data:set(GuildRedEnvelope).


%获取红包列表
handle(?GUILD_REDENVELOPE_LIST, _Tos, RoleSt)->
	#role_st{guild=Guild, gpid=GuildPid} = RoleSt,
	Lists = redenvelope_server:get_redenvelopes(),
	Lists2 = case Guild > 0 of
		true  -> guild_agent:get_redenvelopes(GuildPid);
		false -> []
	end,
	{ok, #m_guild_redenvelope_list_toc{redenvelopes=Lists, guild_redenvelopes=Lists2}, RoleSt};

%发红包
handle(?GUILD_REDENVELOPE_SEND, Tos, RoleSt)->
	#role_st{guild=Guild, gpid=GuildPid, role=RoleID, name=RoleName} = RoleSt,
	#m_guild_redenvelope_send_tos{num=Num, uid=UId, id=Id, money=Money, desc=Desc} = Tos,
	#cfg_guild_redenvelope{
		type_id = TypeId, 
		belong  = Belong, 
		item_id = ItemId, 
		cost    = Cost, 
		money   = Money2,
		limit   = Limit,
		msgno   = MsgNo
	} = cfg_guild_redenvelope:find(Id),
	case Belong of
		1 -> ?_check(Guild>0, ?ERR_GUILD_NOT_JOIN);
		_ -> igore
	end,
	RealMoney = cost(Cost, Money, Money2, RoleSt),
	RedEnvelope = case UId == 0 of
		true -> %手动红包
			?_check(TypeId == 2, ?ERR_REDENVELOPE_TYPE_WRONG),
			?_check(RealMoney >= Num, ?ERR_REDENVELOPE_NUM_WRONG),
			check_limit(Limit),
			role_redenvelope:add_redenvelope(Id, Desc, RoleSt);
		false ->
			get_redenvelope(UId, GuildPid, Belong)
	end,
	?_check(RedEnvelope /= ?nil, ?ERR_REDENVELOPE_NOT_EXIST),
	%检查状态
	?_check(RedEnvelope#p_redenvelope.state == ?RED_ENVELOPE_STATE_NEW, ?ERR_REDENVELOPE_STATE_WRONG),
	RedEnvelope2 = RedEnvelope#p_redenvelope{
		  num   = Num
		, money = #{ItemId => RealMoney}
		, time  = ut_time:seconds()
		, state = ?RED_ENVELOPE_STATE_SEND
	},
	?ucast(#m_guild_redenvelope_update_toc{redenvelope=RedEnvelope2}),
	send(RedEnvelope2, Guild, Belong),
	update_redenvelope(RedEnvelope2, GuildPid, Belong),
	?_if(MsgNo > 0, ?notify(?MSG_REDENVELOP_SEND, [{role, RoleID, RoleName}, RealMoney])),
	role_event:event(?EVENT_SEND_REDENVELOPE, TypeId),
	{ok, #m_guild_redenvelope_send_toc{uid=RedEnvelope2#p_redenvelope.uid}, RoleSt};

%抢红包
handle(?GUILD_REDENVELOPE_SNATCH, Tos, RoleSt)->
	#m_guild_redenvelope_snatch_tos{uid=UId} = Tos,
	#role_st{gpid=GuildPid, guild=Guild} = RoleSt,
	?_check(Guild > 0, ?ERR_GUILD_NOT_JOIN),
	RedEnvelope = snatch_redenvelope(UId, GuildPid, RoleSt),
	?ucast(#m_guild_redenvelope_update_toc{redenvelope=RedEnvelope}),
	{ok, #m_guild_redenvelope_snatch_toc{uid = UId}, RoleSt};

%获取红包记录
handle(?GUILD_REDENVELOPE_RECORD, _Tos, RoleSt)->
	#role_st{gpid=GuildPid, guild=Guild} = RoleSt,
	?_check(Guild > 0, ?ERR_GUILD_NOT_JOIN),
	Records = guild_agent:redenvelope_records(GuildPid),
	{ok, #m_guild_redenvelope_record_toc{records=Records}, RoleSt}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%获取红包
get_redenvelope(UId, GuildPid, Belong)->
	case Belong of
		1 -> guild_agent:get_redenvelope(GuildPid, UId);
		2 -> redenvelope_server:get_redenvelope(UId)
	end.

%更新红包
update_redenvelope(RedEnvelope, GuildPid, Belong)->
	case Belong of
 		1 -> guild_agent:update_redenvelope(GuildPid, RedEnvelope, ?nil);
 		2 -> redenvelope_server:update(RedEnvelope)
	end.

%抢红包
snatch_redenvelope(UId, GuildPid, RoleSt)->
	RedEnvelope = guild_agent:get_redenvelope(GuildPid, UId),
	#role_info{id=RoleId, name=Name, gender=Gender} = role_data:get(?DB_ROLE_INFO),
	RedEnvelope2 = case RedEnvelope == ?nil of
		true  -> redenvelope_server:get_redenvelope(UId);
		false -> RedEnvelope
	end,
	?_check(RedEnvelope2 /= ?nil, ?ERR_GUILD_REDENVELOPE_NOT_EXIST),
	#p_redenvelope{id=Id, gots=Gots, state=State, num=Num} = RedEnvelope2,
	%检查状态
	?_check(State /= ?RED_ENVELOPE_STATE_NEW, ?ERR_GUILD_REDENVELOPE_STATE_WRONG),
	case length(Gots) < Num of
		true ->
			%检查是否抢过
			?_check(not redenvelope_util:is_snatched(RoleId, Gots), ?ERR_GUILD_REDENVELOPE_SNATCHED),
			#cfg_guild_redenvelope{item_id=ItemId, belong=Belong} = cfg_guild_redenvelope:find(Id),
			RedEnvelopeGot = p_redenvelope_got(RoleId, Name, Gender),
			{RedEnvelope3, RedEnvelopeGot2} = case Belong of
				1 -> guild_agent:snatch_redenvelope(GuildPid, UId, RedEnvelopeGot);
				2 -> redenvelope_server:snatch(UId, RedEnvelopeGot)
			end,
			#p_redenvelope_got{money=Money} = RedEnvelopeGot2,
			case Money > 0 of
				true ->
					role_bag:gain([{ItemId, RedEnvelopeGot2#p_redenvelope_got.money}], 
						?LOG_GUILD_REDENVELOPE_SNATCH, RoleSt);
				false ->
					igore
			end,
			RedEnvelope3;
		false ->
			RedEnvelope2
	end.

check_limit(Limit)->
	case Limit of 
		{vip, NeedVipLv} ->
			VipLv = role_vip:get_level(),
			?_check(VipLv >= NeedVipLv, ?ERR_VIP_NOT_ENOUGH);
		{activity, ActivityID} ->
			?_check(activity:is_start(ActivityID), ?ERR_SCENE_NO_ACTIVITY);
		_ ->
			igore
	end.

%红包消耗
cost(Cost, Money, Money2, RoleSt)->
	RealMoney = case Money2 == 0 of
		true  -> Money;
		false -> Money2
	end,
	?_check(RealMoney > 0, ?ERR_REDENVELOPE_MONEY_WRONG),
	case Cost > 0 of
		true -> 
			role_bag:cost([{Cost, RealMoney}], ?LOG_GUILD_REDENVELOPE_SEND, RoleSt);
		false -> 
			igore
	end,
	RealMoney.

%更新给所有成员
send(RedEnvelop, Guild, Belong)->
	case Belong of
		1 ->
			Ids = guild:get_membids(Guild),
			?bcast(Ids, #m_guild_redenvelope_update_toc{redenvelope=RedEnvelop});
		_ ->
			?bcast(#m_guild_redenvelope_update_toc{redenvelope=RedEnvelop})
	end.

p_redenvelope_got(RoleId, Name, Gender)->
	Role = #p_rn_role{
		  id      = RoleId
		, name    = Name
		, gender  = Gender
	},
	#p_redenvelope_got{
		  role  = Role
		, money = 0
	}.

