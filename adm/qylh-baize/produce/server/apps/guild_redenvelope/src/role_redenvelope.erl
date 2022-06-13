%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_redenvelope).

-include("guild_redenvelope.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("enum.hrl").
-include("table.hrl").
-include("role.hrl").
-include("game.hrl").

%% API
-export([add_redenvelope/2]).
-export([add_redenvelope/3]).
-export([hook_login/1]).
-export([notify/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_login(_RoleSt)->
	lists:foreach(fun 
			(Id)-> 
				#cfg_guild_redenvelope{target=Target} = cfg_guild_redenvelope:find(Id),
				case Target of
					{Event, _Goal} ->
						role_event:listen(Event, ?MODULE, notify, Id);
					_ -> 
						igore
				end
		end, cfg_guild_redenvelope:ids()).



notify(Event, Id, Args, RoleSt)->
	#cfg_guild_redenvelope{target=Target, is_count=IsCount} = cfg_guild_redenvelope:find(Id),
	{_Event, Goal} = Target,
	case IsCount > 0 of
		true  -> 
			Count = role_count:get_redenvelope_times(Id),
			case Count == 0 andalso is_finish(Event, Goal, Args) of
				true ->
					role_count:add_redenvelope_times(Id),
					add_redenvelope(Id, RoleSt);
				false ->
					igore
			end;
		false ->
			case is_finish(Event, Goal, Args) of
				true ->
					add_redenvelope(Id, RoleSt);
				false ->
					igore
			end
	end.

add_redenvelope(Id, RoleSt) ->
	RedEnvelope = add_redenvelope(Id, "", RoleSt),
	send(RoleSt, RedEnvelope).

%新增红包
add_redenvelope(Id, Desc, RoleSt)->
	#role_st{guild=Guild, gpid=GuildPid, name=Name} = RoleSt,
	#cfg_guild_redenvelope{type_id=TypeId, belong=Belong, item_id=ItemId, money=Money} 
	= cfg_guild_redenvelope:find(Id),
	RedEnvelope = new(Id, Desc),
	RedEnvelopeRecord = case TypeId==1 of
		true  -> p_redenvelope_record(Name, Id, #{ItemId=>Money});
		false -> ?nil
	end,
	case Belong of
		1 ->
			case Guild > 0 of
				true ->
					guild_agent:update_redenvelope(GuildPid, RedEnvelope, RedEnvelopeRecord);
				false ->
					igore
			end;
		2 -> igore
	end,
	RedEnvelope.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%新红包
new(Id, Desc)->
	#role_info{id=RoleId, name=Name, gender=Gender} = role_data:get(?DB_ROLE_INFO),
	Role = #p_rn_role{
		  id      = RoleId
		, name    = Name
		, gender  = Gender
	},
	#p_redenvelope{
		  uid       = redenvelope_server:get_uid()
		, id        = Id
		, role      = Role
		, num       = 0
		, money     = #{}
		, gots      = []
		, time      = ut_time:seconds()
		, desc      = Desc
		, state     = ?RED_ENVELOPE_STATE_NEW
	}.

p_redenvelope_record(Name, Id, Money)->
	#p_redenvelope_record{
		  role_name = Name
		, id        = Id
		, money     = Money
		, time      = ut_time:seconds()
	}.

%更新新增红包
send(RoleSt, RedEnvelop)->
	?ucast(#m_guild_redenvelope_update_toc{redenvelope=RedEnvelop}).


is_finish(?EVENT_PAY, first_pay, {_GainGold, _TodayOld, _TodayNew})->
	true;

is_finish(?EVENT_PAY, Goal, {_GainGold, _TodayOld, TodayNew})->
	TodayNew >= Goal;

is_finish(?EVENT_VIPLV, Goal, Goal) ->
	true;

is_finish(?EVENT_INVEST, _Goal, {InvestID, _Grade}) ->
	InvestID == 0;

is_finish(_Event, _Goal, _Args) ->
	false.
