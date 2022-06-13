%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_agent).

-include("game.hrl").
-include("guild.hrl").
-include("role.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("scene.hrl").
-include("guild_house.hrl").


-behaviour(gen_server).

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/1]).
-export([get_data/2]).
-export([disband/2]).
-export([demise/3]).
-export([apply/2]).
-export([cancel/2]).
-export([approve/3]).
-export([join/2]).
-export([reject/3]).
-export([quit/2]).
-export([kickout/3]).
-export([appoint/4]).
-export([dismiss/3]).
-export([runfor/4]).
-export([agree/3]).
-export([refuse/3]).
-export([upgrade/2]).
-export([rename/3]).
-export([notice/5]).
-export([impeach/3]).
-export([setup/5]).
-export([donate/5]).
-export([exch/6]).
-export([destroy/3]).
-export([add_ctrb/3]).
-export([add_fund/2]).
-export([get_redenvelopes/1]).
-export([get_redenvelope/2]).
-export([update_redenvelope/3]).
-export([snatch_redenvelope/3]).
-export([redenvelope_records/1]).
-export([update_guild_rank/3]).
-export([memb_rename/3]).
-export([hook_chime/2]).
-export([get_chief/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link(GuildID) ->
	RegName = guild_util:reg_name(GuildID),
	gen_server:start_link({local, RegName}, ?MODULE, {GuildID}, []).

%% 获取帮派数据
get_data(GuildRef, Keys) ->
	call(GuildRef, {get_data, Keys}).

%% 解散帮派
disband(GuildRef, RoleID) ->
	call(GuildRef, {disband, RoleID}).

%% 转让帮主
demise(GuildRef, RoleID, MembID) ->
	call(GuildRef, {demise, RoleID, MembID}).

%% 申请加入
apply(GuildRef, Applient) ->
	call(GuildRef, {apply, Applient}).

%% 取消入帮申请
cancel(GuildRef, ApplyID) ->
	cast(GuildRef, {cancel, ApplyID}).

%% 同意入帮申请
approve(GuildRef, RoleID, ApplyID) ->
	call(GuildRef, {approve, RoleID, ApplyID}).

%% 拒绝入帮申请
reject(GuildRef, RoleID, ApplyID) ->
	call(GuildRef, {reject, RoleID, ApplyID}).

%% 退出帮派
quit(GuildRef, RoleID) ->
	call(GuildRef, {quit, RoleID}).

%% 踢出帮派
kickout(GuildRef, RoleID, MembID) ->
	call(GuildRef, {kickout, RoleID, MembID}).

%% 职位任命
appoint(GuildRef, RoleID, MembID, Post) ->
	call(GuildRef, {appoint, RoleID, MembID, Post}).

%% 解除职位
dismiss(GuildRef, RoleID, MembID) ->
	call(GuildRef, {dismiss, RoleID, MembID}).

%% 职位竞选
runfor(GuildRef, RoleID, Post, Time) ->
	call(GuildRef, {runfor, RoleID, Post, Time}).

%% 同意职位申请
agree(GuildRef, RoleID, RunforID) ->
	call(GuildRef, {agree, RoleID, RunforID}).

%% 拒绝职位申请
refuse(GuildRef, RoleID, RunforID) ->
	call(GuildRef, {refuse, RoleID, RunforID}).

%% 帮派升级
upgrade(GuildRef, RoleID) ->
	call(GuildRef, {upgrade, RoleID}).

%% 帮派改名
rename(GuildRef, RoleID, Name) ->
	call(GuildRef, {rename, RoleID, Name}).

%% 修改公告
notice(GuildRef, RoleID, Notice, Inform, MTimes) ->
	call(GuildRef, {notice, RoleID, Notice, Inform, MTimes}).

%% 弹劾
impeach(GuildRef, Type, RoleID) ->
	call(GuildRef, {impeach, Type, RoleID}).

%% 设置
setup(GuildRef, RoleID, Auto, Level, Power) ->
	call(GuildRef, {setup, RoleID, Auto, Level, Power}).

%% 捐献
donate(GuildRef, RoleID, RoleName, Item, Score) ->
	call(GuildRef, {donate, RoleID, RoleName, Item, Score}).

%% 兑换
exch(GuildRef, Type, RoleID, RoleName, Item, Score) ->
	call(GuildRef, {exch, Type, RoleID, RoleName, Item, Score}).

%% 销毁
destroy(GuildRef, RoleID, UIDs) ->
	call(GuildRef, {destroy, RoleID, UIDs}).

%% 增加贡献
add_ctrb(GuildRef, RoleID, Num) ->
	cast(GuildRef, {add_ctrb, RoleID, Num}).

%% 增加资金
add_fund(GuildRef, Num) ->
	cast(GuildRef, {add_fund, Num}).

% 玩家改名
memb_rename(GuildRef, RoleID, Name) ->
	cast(GuildRef, {memb_rename, RoleID, Name}).

%% 玩家加入帮会
join(GuildRef, RoleID) ->
	cast(GuildRef, {join, RoleID}).

update_guild_rank(GuildID, Rank, Power) ->
	GuildRef = guild_util:reg_name(GuildID),
	case whereis(GuildRef) of
		?nil ->
			Key = {guild_rank_lastest, GuildID},
			case erlang:get(Key) of
				{Rank, Power} ->
					ok;
				_ ->
					case db:dirty_read(?DB_GUILD_INFO, GuildID) of
						[GuildInfo = #guild_info{}] ->
							db:dirty_write(GuildInfo#guild_info{rank = Rank, power = Power}),
							erlang:put(Key, {Rank, Power});
						_ ->
							ok
					end
			end;
		GuildPid ->
			gen_server:cast(GuildPid, {rank, Rank, Power})
	end.


hook_chime(GuildRef, Hour) ->
	case whereis(GuildRef) of
		?nil ->
			ignore;
		GuildPid ->
			cast(GuildPid, {chime, Hour})
	end.



%%%-----------------帮派红包部分------------------------
%获取帮派红包列表
get_redenvelopes(GuildRef)->
	call(GuildRef, {get_redenvelopes}).

%获取单个红包
get_redenvelope(GuildRef, UId)->
	call(GuildRef, {get_redenvelope, UId}).


%更新红包
update_redenvelope(GuildRef, RedEnvelope, RedEnvelopeRecord)->
	call(GuildRef, {update_redenvelope, RedEnvelope, RedEnvelopeRecord}).

%抢红包
snatch_redenvelope(GuildRef, UId, RedEnvelopeGot)->
	call(GuildRef, {snatch_redenvelope, UId, RedEnvelopeGot}).

%红包记录
redenvelope_records(GuildRef)->
	call(GuildRef, {redenvelope_records}).

call(GuildRef,Msg) ->
	GuildPid = get_guild_pid(GuildRef),
	gen_server:call(GuildPid, Msg).

cast(GuildRef,Msg) ->
	GuildPid = get_guild_pid(GuildRef),
	gen_server:cast(GuildPid, Msg).

get_guild_pid(0) ->
	?nil;
get_guild_pid(GuildRef) when is_atom(GuildRef) ->
	case guild_util:reg_name(0) of
		GuildRef ->
			?nil;
		_ ->
			case erlang:whereis(GuildRef)  of
				?nil ->
					GuildId = guild_util:get_guild_id(GuildRef),
					{ok, GuildPid} = guild_agent_sup:start_guild(GuildId),
					GuildPid;
				_ ->
					GuildRef
			end
	end;

get_guild_pid(GuildId) when is_integer(GuildId) ->
	GuildRef = guild_util:reg_name(GuildId),
	get_guild_pid(GuildRef);

get_guild_pid(GuildPid) when is_pid(GuildPid) ->
	GuildPid.


%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({GuildID}) ->
	process_flag(trap_exit, true),
	loop_dump(),
	guild_data:init(GuildID),
	{ok, #guild_st{guild=GuildID,active_time = ut_time:seconds()}}.


handle_call(Req, From, GuildSt) ->
  case Req of
    {get_data, _Keys} ->
      ok;
    _ ->
	    erlang:put(guild_active,{Req,ut_time:seconds()})
  end,
	?try_handle_call(do_handle_call(Req, From, GuildSt), GuildSt).


handle_cast(Msg, GuildSt) ->
		case Msg of
			{chime, _Hour} ->
				ok;
			{rank, _Rank, _Power} ->
				ok;
			_ ->
				erlang:put(guild_active,{Msg,ut_time:seconds()})
		end,
		?try_handle_cast(do_handle_cast(Msg, GuildSt), GuildSt).


handle_info(dump, GuildSt) ->
	loop_dump(),
	guild_data:dump(),
	{noreply, GuildSt};


handle_info(stop, GuildSt) ->
	?debug("stop guild process"),
	{stop, normal, GuildSt};

handle_info(_Info, GuildSt) ->
	{noreply, GuildSt}.

terminate(_Reason, _GuildSt) ->
	guild_data:dump(),
	ok.

code_change(_OldVsn, GuildSt, _Extra) ->
	{ok, GuildSt}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

%% 获取帮派数据
do_handle_call({get_data, Keys}, _From, GuildSt) ->
	Data = [guild_data:get(Key) || Key <- Keys],
	{reply, {ok, Data}, GuildSt};

%% 解散帮派
do_handle_call({disband, RoleID}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{membs=Membs} = GuildInfo,
	?_check(length(Membs) == 1, ?ERR_GUILD_NOT_EMPTY),
	ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_DISBAND),
	guild_data:set(GuildInfo#guild_info{membs=[]}),
	guild_manager:disband(GuildSt#guild_st.guild),
	guild_house:delete_scene(GuildSt#guild_st.guild),
	{stop, normal, ok, GuildSt};

%% 转让帮主
do_handle_call({demise, RoleID, MembID}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{membs=Membs} = GuildInfo,
	Memb1 = lists:keyfind(MembID, #guild_memb.id, Membs),
	?_check(Memb1 /= false, ?ERR_GUILD_NO_MEMBER),
	Memb2 = lists:keyfind(RoleID, #guild_memb.id, Membs),
	?_check(Memb2#guild_memb.post == ?GUILD_POST_CHIEF, ?ERR_GUILD_NOT_CHIEF),
	do_demise(GuildInfo, Memb1, Memb2),
	Toc = #m_guild_demise_toc{from=RoleID, to=MembID},
	inform(Membs, ?GUILD_PERM_NORMAL, Toc),
	{reply, ok, GuildSt};

%% 申请加入
do_handle_call({apply, Applient}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	ensure_not_full(GuildInfo),
	#guild_info{apply=Applied, membs=Membs, setting=Setting} = GuildInfo,
	#p_guild_apply{base=RoleBase, time=Time} = Applient,
	#p_role_base{id=RoleID, level=RoleLv, power=RolePower} = RoleBase,
	?_check(not lists:keymember(RoleID, 1, Applied), ?ERR_GUILD_HAD_APPLY),
	Auto  = maps:get("auto", Setting, false),
	Level = maps:get("level", Setting, 0),
	Power = maps:get("power", Setting, 0),
	?_check(RoleLv >= Level, ?ERR_GUILD_LACK_LEVEL),
	?_check(RolePower >= Power, ?ERR_GUILD_LACK_POWER),
	Toc = #m_guild_apply_toc{appliant=Applient},
	inform(Membs, ?GUILD_PERM_APPROVE, Toc),
	GuildInfo1 = GuildInfo#guild_info{apply=[{RoleID, Time} | Applied]},
	GuildInfo2 = case Auto of
		true  -> approve_one(RoleID, 0, GuildInfo1);
		false -> GuildInfo1
	end,
	guild_data:set(GuildInfo2),
	{reply, {ok, Auto}, GuildSt};

%% 同意申请
do_handle_call({approve, RoleID, ApplyID}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{apply=Applied} = GuildInfo,
	ensure_not_full(GuildInfo),
	ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_APPROVE),
	GuildInfo2 = case ApplyID == 0 of
		true  -> % 同意所有
			?_check(length(Applied) > 0, ?ERR_GUILD_NO_APPLY),
			approve_all(Applied, RoleID, GuildInfo);
		false ->
			ensure_had_apply(ApplyID, Applied),
			approve_one(ApplyID, RoleID, GuildInfo)
	end,
	guild_data:set(GuildInfo2),
	{reply, ok, GuildSt};

%% 拒绝申请
do_handle_call({reject, RoleID, ApplyID}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{apply=Applied} = GuildInfo,
	ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_APPROVE),
	GuildInfo2 = case ApplyID == 0 of
		true  -> % 拒绝所有
			?_check(length(Applied) > 0, ?ERR_GUILD_NO_APPLY),
			reject_all(Applied, GuildInfo);
		false ->
			ensure_had_apply(ApplyID, Applied),
			reject_one(ApplyID, GuildInfo)
	end,
	guild_data:set(GuildInfo2),
	{reply, ok, GuildSt};

%% 退出帮派
do_handle_call({quit, RoleID}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{id=GuildID, membs=Membs, runfor=Runfor, impeach=Impeach} = GuildInfo,
	Membs2   = lists:keydelete(RoleID, #guild_memb.id, Membs),
	Impeach2 = case Impeach /= ?nil andalso RoleID == element(1, Impeach) of
		true  -> ?nil;
		false -> Impeach
	end,
	GuildInfo2 = GuildInfo#guild_info{
		membs   = Membs2,
		runfor  = lists:keydelete(RoleID, 1, Runfor),
		impeach = Impeach2,
		power   = guild_util:calc_guild_power(Membs2)
	},
	guild_data:set(GuildInfo2),
	guild_manager:del_memb(GuildID, length(Membs2), GuildInfo2#guild_info.power),
	guild_util:add_guild_log(GuildID, ?GUILD_LOG_QUIT, RoleID, ?nil),
	Toc = #m_guild_quit_toc{role_id=RoleID},
	inform(Membs2, ?GUILD_PERM_NORMAL, Toc),
	{reply, ok, GuildSt};

%% 踢出帮派
do_handle_call({kickout, RoleID, MembID}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{membs=Membs} = GuildInfo,
	ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_KICKOUT),
	Memb1 = lists:keyfind(MembID, #guild_memb.id, Membs),
	?_check(Memb1 /= false, ?ERR_GUILD_NO_MEMBER),
	Memb2 = lists:keyfind(RoleID, #guild_memb.id, Membs),
	IsHigher = Memb2#guild_memb.post > Memb1#guild_memb.post,
	?_check(IsHigher, ?ERR_GUILD_PERM_DENY),
	do_kickout(GuildInfo, MembID),
	{reply, ok, GuildSt};

%% 职位任命
do_handle_call({appoint, RoleID, MembID, Post}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{id=GuildID, membs=Membs} = GuildInfo,
	ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_APPOINT),
	Memb1 = lists:keyfind(MembID, #guild_memb.id, Membs),
	?_check(Memb1 /= false, ?ERR_GUILD_NO_MEMBER),
	?_check(Memb1#guild_memb.post /= Post, ?ERR_GUILD_SAME_POST),
	Memb2 = lists:keyfind(RoleID, #guild_memb.id, Membs),
	?_check(Memb2#guild_memb.post > Post, ?ERR_GUILD_PERM_DENY),
	GuildInfo2 = do_appoint(GuildInfo, Memb1, Post),
	guild_util:add_guild_log(GuildID, ?GUILD_LOG_APPROVE, MembID, Post),
	Toc = #m_guild_appoint_toc{role_id=MembID, post=Post},
	inform(Membs, ?GUILD_PERM_NORMAL, Toc),
	PostName = cfg_guild_post:find(Post),
	?notify(
		[M#guild_memb.id || M <- GuildInfo2#guild_info.membs],
		?MSG_GUILD_APPOINT,
		[
			{role, MembID, Memb1#guild_memb.name},
			PostName
		]
	),
	mail:send(MembID, ?MAIL_GUILD_APPOINT, [], [PostName]),
	{reply, ok, GuildSt};

%% 解除职位
do_handle_call({dismiss, RoleID, MembID}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{membs=Membs} = GuildInfo,
	ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_DISMISS),
	Memb1 = lists:keyfind(MembID, #guild_memb.id, Membs),
	?_check(Memb1 /= false, ?ERR_GUILD_NO_MEMBER),
	Memb2 = lists:keyfind(RoleID, #guild_memb.id, Membs),
	IsHigher = Memb2#guild_memb.post > Memb1#guild_memb.post,
	?_check(IsHigher, ?ERR_GUILD_PERM_DENY),
	do_dismiss(GuildInfo, Memb1),
	{reply, ok, GuildSt};

%% 职位竞选
do_handle_call({runfor, RoleID, Post, Time}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{runfor=Runfor, membs=Membs} = GuildInfo,
	Memb = lists:keyfind(RoleID, #guild_memb.id, Membs),
	?_check(Memb#guild_memb.post /= Post, ?ERR_GUILD_SAME_POST),
	guild_data:set(GuildInfo#guild_info{
		runfor = lists:keystore(RoleID, 1, Runfor, {RoleID, Post, Time})
	}),
	Toc = #m_guild_runfor_toc{
		appliant = guild_util:p_guild_apply(RoleID, Post, Time)
	},
	inform(Membs, ?GUILD_PERM_APPOINT, Toc),
	{reply, ok, GuildSt};

%% 同意职位申请
do_handle_call({agree, RoleID, MembID}, _From, GuildSt) ->
	{ok, GuildInfo, Memb, Post} = check_runfor_perm(RoleID, MembID),
	do_appoint(GuildInfo, Memb, Post),
	Toc = #m_guild_agree_toc{role_id=MembID, post=Post},
	inform(GuildInfo#guild_info.membs, ?GUILD_PERM_NORMAL, Toc),
	{reply, ok, GuildSt};

%% 拒绝职位申请
do_handle_call({refuse, RoleID, MembID}, _From, GuildSt) ->
	{ok, GuildInfo, _Memb, _Post} = check_runfor_perm(RoleID, MembID),
	#guild_info{runfor=Runfor} = GuildInfo,
	Runfor2 = lists:keydelete(MembID, 1, Runfor),
	guild_data:set(GuildInfo#guild_info{runfor=Runfor2}),
	{reply, ok, GuildSt};

%% 帮派升级
do_handle_call({upgrade, RoleID}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_UPGRADE),
	#guild_info{id=GuildID, level=Level, fund=Fund, membs=Membs} = GuildInfo,
	?_check(Level < cfg_guild:max(), ?ERR_GUILD_MAX_LEVEL),
	#cfg_guild{fund=FundNeed} = cfg_guild:find(Level),
	?_check(Fund >= FundNeed, ?ERR_GUILD_LACK_FUND),
	NewLv = Level + 1,
	GuildInfo2 = GuildInfo#guild_info{level=NewLv, fund=Fund-FundNeed},
	guild_data:set(GuildInfo2),
	guild_manager:upgrade(GuildID, NewLv),
	guild_util:add_guild_log(GuildID, ?GUILD_LOG_UPGRADE, RoleID, ?nil),
	Toc = #m_guild_upgrade_toc{level=NewLv},
	inform(Membs, ?GUILD_PERM_NORMAL, Toc),

	#guild_memb{id=ChiefID} = get_chief(GuildInfo2),
	role_event:event(ChiefID, ?EVENT_GUILD_LEVEL, NewLv),
	{reply, {ok, NewLv}, GuildSt};

%% 帮派改名
do_handle_call({rename, RoleID, Name}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{id=GuildID, membs=Membs} = GuildInfo,
	ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_RENAME),
	ok = guild_manager:rename(GuildID, Name),
	guild_data:set(GuildInfo#guild_info{name=Name}),
	lists:foreach(fun
		(#guild_memb{id=MembID}) ->
			role:route(MembID, guild_handler, rename, {GuildID, Name})
	end, Membs),
	{reply, ok, GuildSt};

%% 修改公告
do_handle_call({notice, RoleID, Notice, Inform, MTimes1}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	RoleID > 0 andalso ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_NOTICE),
	#guild_info{membs=Membs, modify=MTimes2} = GuildInfo,
	case Inform of
		true  ->
			?_check(MTimes1 == MTimes2, ?ERR_GUILD_MODIFY_BY_OTHERS),
			guild_data:set(GuildInfo#guild_info{notice=Notice, modify=MTimes2+1}),
			{Title, _} = cfg_mail:find(?MAIL_GUILD_NOTICE),
			MembIDs = [MembID || #guild_memb{id=MembID} <- Membs],
			mail:batch_send(MembIDs, Title, Notice, []);
		false ->
			guild_data:set(GuildInfo#guild_info{notice=Notice})
	end,
	Toc = #m_guild_notice_toc{notice=Notice, inform=Inform},
	inform(Membs, ?GUILD_PERM_NORMAL, Toc),
	{reply, ok, GuildSt};

%% 发起弹劾
do_handle_call({impeach, 1, RoleID}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{membs=Membs, impeach=Impeach} = GuildInfo,
	?_check(Impeach == ?nil, ?ERR_GUILD_HAD_IMPEACH),
	Chief = lists:keyfind(?GUILD_POST_CHIEF, #guild_memb.post, Membs),
	{ok, Cache} = role:get_cache(Chief),
	#role_cache{online=Online, logout=Logout} = Cache,
	ImpeachTime = cfg_game:guild_impeach(),
	CanImpeach  = (not Online) andalso (ut_time:seconds()-Logout > ImpeachTime),
	?_check(CanImpeach, ?ERR_GUILD_CANNOT_IMPEACH),
	guild_data:set(GuildInfo#guild_info{impeach={RoleID, 0}}),
	Toc = #m_guild_impeach_toc{type=1, role_id=RoleID},
	inform(Membs, RoleID, ?GUILD_PERM_NORMAL, Toc),
	{reply, ok, GuildSt};

%% 同意弹劾
do_handle_call({impeach, Type, RoleID}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{membs=Membs, impeach=Impeach} = GuildInfo,
	?_check(Impeach /= ?nil, ?ERR_GUILD_NO_IMPEACH),
	{OriginID, AgreeMembs} = Impeach,
	?_check(RoleID /= OriginID, ?ERR_GUILD_THE_ORIGIN),
	?_check(not lists:member(RoleID, AgreeMembs), ?ERR_GUILD_IMPEACH_BEFORE),
	AgreeMembs2 = [RoleID | AgreeMembs],
	case Type of
		2 when length(AgreeMembs2) < 3 ->
			guild_data:set(GuildInfo#guild_info{impeach={OriginID, AgreeMembs2}});
		2 ->
			GuildInfo2 = GuildInfo#guild_info{impeach=?nil},
			Memb1 = lists:keyfind(OriginID, #guild_memb.id, Membs),
			Memb2 = lists:keyfind(?GUILD_POST_CHIEF, #guild_memb.post, Membs),
			do_demise(GuildInfo2, Memb1, Memb2);
		3 ->
			ignore
	end,
	{reply, ok, GuildSt};

%% 设置
do_handle_call({setup, RoleID, Auto, Level, Power}, _From, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_SETUP),
	Setting   = #{"auto"=>Auto, "level"=>Level, "power"=>Power},
	guild_data:set(GuildInfo#guild_info{setting=Setting}),
	{reply, ok, GuildSt};

%% 捐献
do_handle_call({donate, RoleID, RoleName, Item, Score}, _From, GuildSt) ->
	GuildDepot = guild_data:get(?DB_GUILD_DEPOT),
	#guild_depot{cells=Cells, items=Items} = GuildDepot,
	?_check(Cells /= [], ?ERR_GUILD_DEPOT_NO_SPACE),

	[CellID | T] = Cells,
	Item2 = Item#p_item{uid=CellID},
	guild_data:set(GuildDepot#guild_depot{
		cells = T,
		items = maps:put(CellID, Item2, Items)
	}),

	#guild_info{membs=Membs} = guild_data:get(?DB_GUILD_INFO),
	Toc = #m_guild_depot_donate_toc{
		role_id   = RoleID,
		role_name = RoleName,
		item      = item_util:p_item(Item2),
		score     = Score,
		time      = ut_time:seconds()
	},
	inform(Membs, ?GUILD_PERM_NORMAL, Toc),
	{reply, {ok, Item2}, GuildSt};

%% 兑换
do_handle_call({exch, Type, RoleID, RoleName, Item1, Score}, _From, GuildSt) ->
	#guild_info{membs=Membs} = guild_data:get(?DB_GUILD_INFO),
	case Type of
		1 ->
			GuildDepot = guild_data:get(?DB_GUILD_DEPOT),
			#guild_depot{cells=Cells, items=Items} = GuildDepot,
			Item2 = maps:get(Item1#p_item.uid, Items, ?nil),
			?_check(Item1 == Item2, ?ERR_GUILD_DEPOT_NO_ITEM),
			guild_data:set(GuildDepot#guild_depot{
				cells = [Item1#p_item.uid | Cells],
				items = maps:remove(Item1#p_item.uid, Items)
			}),
			Toc = #m_guild_depot_exch_toc{
				role_id   = RoleID,
				role_name = RoleName,
				item      = item_util:p_item(Item1),
				score     = Score,
				time      = ut_time:seconds()
			},
			inform(Membs, ?GUILD_PERM_NORMAL, Toc);
		2 ->
			Toc = #m_guild_depot_buy_toc{
				role_id   = RoleID,
				role_name = RoleName,
				item      = item_util:p_item(Item1),
				score     = Score,
				time      = ut_time:seconds()
			},
			inform(Membs, ?GUILD_PERM_NORMAL, Toc)
	end,
	{reply, ok, GuildSt};

%% 销毁
do_handle_call({destroy, RoleID, UIDs}, _From, GuildSt) ->
	GuildInfo = #guild_info{membs=Membs} = guild_data:get(?DB_GUILD_INFO),
	ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_DESTROY),
	GuildDepot = guild_data:get(?DB_GUILD_DEPOT),
	#guild_depot{cells=Cells, items=Items} = GuildDepot,
	AllExist = lists:all(fun(UID) -> maps:is_key(UID, Items) end, UIDs),
	?_check(AllExist, ?ERR_GUILD_DEPOT_NO_ITEM),
	guild_data:set(GuildDepot#guild_depot{
		cells = UIDs ++ Cells,
		items = maps:without(UIDs, Items)
	}),
	Toc = #m_guild_depot_destroy_toc{uids=UIDs},
	inform(Membs, ?GUILD_PERM_NORMAL, Toc),
	{reply, ok, GuildSt};

do_handle_call({get_redenvelopes}, _From, GuildSt) ->
	GuildRedEnvelope = guild_data:get(?DB_GUILD_REDENVELOPE),
	#guild_redenvelope{red_envelopes=RedEnvelopes} = GuildRedEnvelope,
	%过滤过期的
	RedEnvelopes2 = redenvelope_util:filter_expire(RedEnvelopes),
	guild_data:set(GuildRedEnvelope#guild_redenvelope{
	    red_envelopes = RedEnvelopes2
	}),
	RedEnvelopeList = maps:values(RedEnvelopes2),
	{reply, RedEnvelopeList, GuildSt};

do_handle_call({get_redenvelope, UId}, _From, GuildSt)->
	GuildRedEnvelope = guild_data:get(?DB_GUILD_REDENVELOPE),
	#guild_redenvelope{red_envelopes=RedEnvelopes} = GuildRedEnvelope,
	RedEnvelope = maps:get(UId, RedEnvelopes, ?nil),
	{reply, RedEnvelope, GuildSt};

do_handle_call({update_redenvelope, RedEnvelope, RedEnvelopeRecord}, _From, GuildSt)->
	GuildRedEnvelope = guild_data:get(?DB_GUILD_REDENVELOPE),
	#guild_redenvelope{red_envelopes=RedEnvelopes, records=Records} = GuildRedEnvelope,
	RedEnvelopes2 = maps:put(RedEnvelope#p_redenvelope.uid, RedEnvelope, RedEnvelopes),
	Records2 = case RedEnvelopeRecord /= ?nil of
		true  ->
			TmpRecords = case length(Records) >= 15 of
				true  -> lists:delete(lists:last(Records), Records);
				false -> Records
			end,
			[RedEnvelopeRecord|TmpRecords];
		false ->
			Records
	end,
	guild_data:set(GuildRedEnvelope#guild_redenvelope{
		  red_envelopes = RedEnvelopes2
		, records       = Records2
	}),
	{reply, ok, GuildSt};

do_handle_call({snatch_redenvelope, UId, RedEnvelopeGot}, _From, GuildSt)->
	GuildRedEnvelope = guild_data:get(?DB_GUILD_REDENVELOPE),
	#guild_redenvelope{red_envelopes=RedEnvelopes} = GuildRedEnvelope,
	RedEnvelope = maps:get(UId, RedEnvelopes, ?nil),
	#p_redenvelope{gots=Gots, num=Num} = RedEnvelope,
	#p_redenvelope_got{role=Role} = RedEnvelopeGot,
	?_check(not redenvelope_util:is_snatched(Role#p_rn_role.id, Gots), ?ERR_GUILD_REDENVELOPE_SNATCHED),
	{RedEnvelope3, RedEnvelopeGot3} = case length(Gots) < Num of
		false ->
			{RedEnvelope, RedEnvelopeGot};
		true ->
			{RedEnvelope2, RedEnvelopeGot2} = redenvelope_util:snatch(RedEnvelope, RedEnvelopeGot),
			RedEnvelopes2 = maps:put(RedEnvelope2#p_redenvelope.uid, RedEnvelope2, RedEnvelopes),
			guild_data:set(GuildRedEnvelope#guild_redenvelope{
					red_envelopes = RedEnvelopes2
				}),
			{RedEnvelope2, RedEnvelopeGot2}
	end,
	{reply, {RedEnvelope3, RedEnvelopeGot3}, GuildSt};


do_handle_call({redenvelope_records}, _From, GuildSt)->
	GuildRedEnvelope = guild_data:get(?DB_GUILD_REDENVELOPE),
	#guild_redenvelope{records=Records} = GuildRedEnvelope,
	{reply, Records, GuildSt};

do_handle_call(Req, _From, GuildSt) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, GuildSt}.


do_handle_cast({join, ApplyID}, GuildSt) ->
	GuildInfo = #guild_info{apply=Applied} = guild_data:get(?DB_GUILD_INFO),
	case lists:keymember(ApplyID, 1, Applied) of
		true  ->
			GuildInfo2 = post_approve(ApplyID, GuildInfo),
			guild_data:set(GuildInfo2);
		false ->
			ignore
	end,
	{noreply, GuildSt};

%% 增加贡献度
do_handle_cast({add_ctrb, RoleID, Num}, GuildSt) ->
	GuildInfo = #guild_info{membs=Membs} = guild_data:get(?DB_GUILD_INFO),
	Memb  = lists:keyfind(RoleID, #guild_memb.id, Membs),
	Memb2 = Memb#guild_memb{ctrb=Memb#guild_memb.ctrb+Num},
	guild_data:set(GuildInfo#guild_info{
		membs = lists:keystore(RoleID, #guild_memb.id, Membs, Memb2)
	}),
	{noreply, GuildSt};

%% 增加贡献度
do_handle_cast({add_fund, Num}, GuildSt) ->
	GuildInfo = #guild_info{fund=Fund} = guild_data:get(?DB_GUILD_INFO),
	guild_data:set(GuildInfo#guild_info{fund=Fund+Num}),
	{noreply, GuildSt};

%% 取消申请
do_handle_cast({cancel, ApplyID}, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{apply=Applied, membs=Membs} = GuildInfo,
	guild_data:set(GuildInfo#guild_info{
		apply = lists:keydelete(ApplyID, 1, Applied)
	}),
	Toc = #m_guild_cancel_toc{role_id=ApplyID},
	inform(Membs, ?GUILD_PERM_APPROVE, Toc),
	{noreply, GuildSt};

%% 更新排名
do_handle_cast({rank, Rank, Power}, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	guild_data:set(GuildInfo#guild_info{rank=Rank, power=Power}),
	{noreply, GuildSt};

do_handle_cast({memb_rename, RoleID, Name}, GuildSt) ->
	GuildInfo = #guild_info{membs=Membs} = guild_data:get(?DB_GUILD_INFO),
	case lists:keyfind(RoleID, #guild_memb.id, Membs) of
		false ->
			ignore;
		Memb  ->
			Memb2  = Memb#guild_memb{name=Name},
			Membs2 = lists:keystore(RoleID, #guild_memb.id, Membs, Memb2),
			guild_data:set(GuildInfo#guild_info{membs=Membs2})
	end,
	{noreply, GuildSt};

%% 路由转发
do_handle_cast({route, Mod, Fun}, GuildSt) ->
    case Mod:Fun(GuildSt) of
        {ok, GuildSt2} when is_record(GuildSt2, guild_st) ->
            {noreply, GuildSt2};
        _ ->
            {noreply, GuildSt}
    end;

do_handle_cast({route, Mod, Fun, Args}, GuildSt) ->
    case Mod:Fun(Args, GuildSt) of
        {ok, GuildSt2} when is_record(GuildSt2, guild_st) ->
            {noreply, GuildSt2};
        _ ->
            {noreply, GuildSt}
    end;

do_handle_cast({func, Fun}, GuildSt) when is_function(Fun, 0) ->
    Fun(),
    {noreply, GuildSt};

do_handle_cast({func, Fun}, GuildSt) when is_function(Fun, 1) ->
    case Fun(GuildSt) of
        {ok, GuildSt2} when is_record(GuildSt2, guild_st) ->
            {noreply, GuildSt2};
        _ ->
            {noreply, GuildSt}
    end;

do_handle_cast({chime, Hour}, GuildSt) ->
	if
		Hour == 0 ->
			check_active(),
			auto_demise();
		true ->
			ignore
	end,
	{noreply, GuildSt};

do_handle_cast(gm_disband, GuildSt) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{id=GuildID, name=GuildName, membs=Membs} = GuildInfo,
	lists:foreach(fun
		(#guild_memb{id=MembID}) ->
			role:route(MembID, guild_handler, kickout, GuildID, GuildID),
			mail:send(MembID, ?MAIL_GUILD_KICKOUT, [], [GuildName])
	end, Membs),
	guild_data:set(GuildInfo#guild_info{membs=[]}),
	guild_manager:disband(GuildID),
	guild_house:delete_scene(GuildID),
	{stop, normal, GuildSt};

do_handle_cast(Msg, GuildSt) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, GuildSt}.


loop_dump() ->
	erlang:send_after(timer:minutes(15), self(), dump).

check_active() ->
  case erlang:get(guild_active) of
    ?nil ->
      erlang:send(self(),stop);
    ActiveTime0 ->
      ActiveTime2 =
        case ActiveTime0 of
          {_,ActiveTime} -> ActiveTime;
          ActiveTime1 -> ActiveTime1
        end,
      ?_if((ut_time:seconds() - ActiveTime2) > 86164,erlang:send(self(),stop))  %判断一天内是否活跃
  end.


do_kickout(GuildInfo, MembID) ->
	#guild_info{
		id=GuildID, name=GuildName, membs=Membs, runfor=Runfor, impeach=Impeach
	} = GuildInfo,
	Membs2   = lists:keydelete(MembID, #guild_memb.id, Membs),
	Impeach2 = case Impeach /= ?nil andalso element(1, Impeach) == MembID of
		true  -> ?nil;
		false -> Impeach
	end,
	GuildInfo2 = GuildInfo#guild_info{
		membs   = Membs2,
		runfor  = lists:keydelete(MembID, 1, Runfor),
		impeach = Impeach2,
		power   = guild_util:calc_guild_power(Membs2)
	},
	guild_data:set(GuildInfo2),
	role:route(MembID, guild_handler, kickout, GuildID, GuildID),
	guild_manager:del_memb(GuildID, length(Membs2), GuildInfo2#guild_info.power),
	mail:send(MembID, ?MAIL_GUILD_KICKOUT, [], [GuildName]),
	Toc = #m_guild_kickout_toc{role_id=MembID},
	inform(Membs2, ?GUILD_PERM_NORMAL, Toc).

approve_all([{ApplyID, _} | T], ApproveID, GuildInfo) ->
	case is_full(GuildInfo) of
		true  -> GuildInfo;
		false -> approve_all(T, ApproveID, approve_one(ApplyID, ApproveID, GuildInfo))
	end;
approve_all([], _ApproveID, GuildInfo) ->
	GuildInfo.

approve_one(ApplyID, ApproveID, GuildInfo) ->
	#guild_info{id=GuildID, membs=Membs, apply=Applied} = GuildInfo,
	?_check(not lists:keymember(ApplyID, #guild_memb.id, Membs), ?ERR_GUILD_IS_MEMBER),
	case role:is_alive(ApplyID) of
		true  ->
			role:route(ApplyID, guild_handler, approve, {self(), GuildID, ApproveID}),
			GuildInfo;
		false ->
			case guild_manager:approve(GuildID, ApplyID) of
				ok  ->
					GuildInfo2 = post_approve(ApplyID, GuildInfo),
					guild_data:set(GuildInfo2);
				Err ->
					GuildInfo2 = GuildInfo#guild_info{
						apply = lists:keydelete(ApplyID, 1, Applied)
					},
					guild_data:set(GuildInfo2),
					?_if(
						ApproveID > 0,
						?ucast(ApproveID, #m_guild_reject_toc{role_id=ApplyID})
					),
					throw(Err)
			end,
			GuildInfo2
	end.


post_approve(ApplyID, GuildInfo) ->
	#guild_info{id=GuildID, name=GuildName, membs=Membs, apply=Applied} = GuildInfo,
	{ok, #role_cache{name=ApplyName}} = role:get_cache(ApplyID),
	Memb   = guild_util:new_member(ApplyID, ApplyName, ?GUILD_POST_MEMB),
	Membs2 = [Memb | Membs],
	GuildInfo2 = GuildInfo#guild_info{
		membs = Membs2,
		apply = lists:keydelete(ApplyID, 1, Applied),
		power = guild_util:calc_guild_power(Membs2)
	},
	guild_manager:add_memb(GuildID, length(Membs2), GuildInfo2#guild_info.power),
	guild_util:add_guild_log(GuildID, ?GUILD_LOG_JOIN, ApplyID, ?nil),
	Toc = #m_guild_approve_toc{member=guild_util:p_guild_member(Memb)},
	inform(Membs, ?GUILD_PERM_NORMAL, Toc),
	?notify(
		[M#guild_memb.id || M <- Membs2],
		?MSG_GUILD_JOIN,
		[{role, ApplyID, ApplyName}]
	),
	mail:send(ApplyID, ?MAIL_GUILD_APPLY_SUCC, [], [GuildName]),
	GuildInfo2.


reject_all([{ApplyID, _} | T], GuildInfo) ->
	reject_all(T, reject_one(ApplyID, GuildInfo));
reject_all([], GuildInfo) ->
	GuildInfo.

reject_one(ApplyID, GuildInfo) ->
	#guild_info{id=GuildID, name=GuildName, apply=Applied} = GuildInfo,
	role:route(ApplyID, guild_handler, reject, GuildID, GuildID),
	mail:send(ApplyID, ?MAIL_GUILD_APPLY_FAIL, [], [GuildName]),
	GuildInfo#guild_info{apply=lists:keydelete(ApplyID, 1, Applied)}.


do_appoint(GuildInfo, Memb, Post) ->
	#guild_info{id=GuildID, level=Level, membs=Membs, runfor=Runfor} = GuildInfo,
	#guild_memb{id=MembID} = Memb,
	CurNum = length([M || M <- Membs, M#guild_memb.post == Post]),
	#cfg_guild{post=PostNum} = cfg_guild:find(Level),
	MaxNum = maps:get(Post, PostNum, 0),
	?_check(CurNum < MaxNum, ?ERR_GUILD_POST_FULL),
	Memb2   = Memb#guild_memb{post=Post},
	Membs2  = lists:keystore(MembID, #guild_memb.id, Membs, Memb2),
	Runfor2 = lists:keydelete(MembID, 1, Runfor),
	GuildInfo2 = GuildInfo#guild_info{membs=Membs2, runfor=Runfor2},
	guild_data:set(GuildInfo2),
	role_cache:update(MembID, [{#role_cache.gpost, Post}]),
	role:route(MembID, guild_handler, appoint, {GuildID, Post}, {GuildID, Post}),
	GuildInfo2.

do_dismiss(GuildInfo, Memb) ->
	#guild_info{id=GuildID, membs=Membs} = GuildInfo,
	#guild_memb{id=MembID} = Memb,
	Memb2  = Memb#guild_memb{post=?GUILD_POST_MEMB},
	Membs2 = lists:keystore(MembID, #guild_memb.id, Membs, Memb2),
	guild_data:set(GuildInfo#guild_info{membs=Membs2}),
	Toc = #m_guild_dismiss_toc{role_id=MembID},
	inform(Membs, ?GUILD_PERM_NORMAL, Toc),
	role_cache:update(MembID, [{#role_cache.gpost, ?GUILD_POST_MEMB}]),
	role:route(MembID, guild_handler, dismiss, GuildID, GuildID).


check_runfor_perm(RoleID, MembID) ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	#guild_info{runfor=Runfor, membs=Membs} = GuildInfo,
	Memb1 = lists:keyfind(MembID, #guild_memb.id, Membs),
	?_check(Memb1 /= false, ?ERR_GUILD_NO_MEMBER),
	Info  = lists:keyfind(MembID, 1, Runfor),
	?_check(Info /= false, ?ERR_GUILD_NOT_RUNFOR),
	ensure_perm_enough(GuildInfo, RoleID, ?GUILD_PERM_APPOINT),
	Post  = element(2, Info),
	Memb2 = lists:keyfind(RoleID, #guild_memb.id, Membs),
	?_check(Memb2#guild_memb.post > Post, ?ERR_GUILD_PERM_DENY),
	{ok, GuildInfo, Memb1, Post}.


do_demise(GuildInfo, ToMemb, FromMemb) ->
	#guild_info{id=GuildID, membs=Membs, runfor=Runfor} = GuildInfo,
	ToMemb2 = ToMemb#guild_memb{post=?GUILD_POST_CHIEF},
	Membs1  = lists:keystore(
		ToMemb#guild_memb.id, #guild_memb.id, Membs, ToMemb2
	),
	FromMemb2 = FromMemb#guild_memb{post=?GUILD_POST_MEMB},
	Membs2    = lists:keystore(
		FromMemb#guild_memb.id, #guild_memb.id, Membs1, FromMemb2
	),
	guild_data:set(GuildInfo#guild_info{
		membs  = Membs2,
		runfor = lists:keydelete(ToMemb#guild_memb.id, 1, Runfor)
	}),
	guild_manager:demise(GuildID, ToMemb2),
	role:route(ToMemb#guild_memb.id, guild_handler, demise, GuildID, GuildID).

ensure_not_full(GuildInfo) ->
	?_check(not is_full(GuildInfo), ?ERR_GUILD_HAD_FULL).

is_full(GuildInfo) ->
	#guild_info{level=Level, membs=Membs} = GuildInfo,
	#cfg_guild{memb=Cap} = cfg_guild:find(Level),
	length(Membs) >= Cap.

ensure_had_apply(RoleID, Applied) ->
	?_check(lists:keymember(RoleID, 1, Applied), ?ERR_GUILD_NEVER_APPLY).


ensure_perm_enough(GuildInfo, RoleID, Perm) ->
	Member  = lists:keyfind(RoleID, #guild_memb.id, GuildInfo#guild_info.membs ),
	PostLim = cfg_guild_perm:find(Perm),
	?_check(Member#guild_memb.post >= PostLim, ?ERR_GUILD_PERM_DENY).

inform(Membs, Perm, Toc) ->
	inform(Membs, [], Perm , Toc).

inform(Membs, Except, Perm, Toc) ->
	PostNeed = cfg_guild_perm:find(Perm),
	lists:foreach(fun
		(Memb) ->
			#guild_memb{id=MembID, post=Post} = Memb,
			case lists:member(MembID, Except) of
				true  -> ignore;
				false -> ?_if(Post >= PostNeed, ?ucast(MembID, Toc))
			end
	end, Membs).

get_chief(GuildInfo) ->
	lists:keyfind(?GUILD_POST_CHIEF, #guild_memb.post, GuildInfo#guild_info.membs).

auto_demise() ->
	GuildInfo = guild_data:get(?DB_GUILD_INFO),
	case get_chief(GuildInfo) of
		false ->
			?error(
				"no chief in guild: ~w",
				[{GuildInfo#guild_info.id, GuildInfo#guild_info.membs}]
			);
		Chief ->
			#guild_memb{id =ChiefID} = Chief,
			case role:is_online(ChiefID) of
				true  ->
					ignore;
				false ->
					[#role_info{logout=Logout}] = db:dirty_read(?DB_ROLE_INFO, ChiefID),
					MaxTime = cfg_game:guild_demise(),
					NowTime = ut_time:seconds(),
					case NowTime - Logout >= MaxTime of
						true  -> auto_demise2(GuildInfo, Chief, NowTime, MaxTime);
						false -> ignore
					end
			end
	end.

auto_demise2(GuildInfo, Chief, NowTime, MaxTime) ->
	Membs1 = lists:filter(fun
		(Memb) ->
			case Memb#guild_memb.post == ?GUILD_POST_CHIEF of
				true  ->
					false;
				false ->
					case role:is_online(Memb#guild_memb.id) of
						true  ->
							true;
						false ->
							{ok, Cache} = role:get_cache(Memb#guild_memb.id),
							NowTime - Cache#role_cache.logout < MaxTime
					end
			end
	end, GuildInfo#guild_info.membs),

	Membs2 = lists:sort(fun
		(Memb1, Memb2) ->
			#guild_memb{id=MembID1, post=Post1, ctrb=Contrib1} = Memb1,
			#guild_memb{id=MembID2, post=Post2, ctrb=Contrib2} = Memb2,
			case Post1 == Post2 of
				true  ->
					case Contrib1 == Contrib2 of
						true  ->
							{ok, Cache1} = role:get_cache(MembID1),
							{ok, Cache2} = role:get_cache(MembID2),
							#role_cache{power=Power1, login=Login1} = Cache1,
							#role_cache{power=Power2, login=Login2} = Cache2,
							case Power1 == Power2 of
								true  -> Login1 > Login2;
								false -> Power1 > Power2
							end;
						false ->
							Contrib1 > Contrib2
					end;
				false ->
					Post1 > Post2
			end
	end, Membs1),

	case Membs2 of
		[Memb | _] ->
			#guild_memb{id=ChiefID, name=ChiefName} = Chief,
			#guild_memb{name=MembName} = Memb,
			Args = {GuildInfo#guild_info.id, ?GUILD_POST_MEMB},
			role:route(ChiefID, guild_handler, appoint, Args, Args),
			do_demise(GuildInfo, Memb, Chief),
			mail:send(ChiefID, ?MAIL_GUILD_AUTO_DEMISE1, [], [MembName]),
			lists:foreach(fun
				(#guild_memb{id=MembID2}) ->
					mail:send(
						MembID2,
						?MAIL_GUILD_AUTO_DEMISE2,
						[],
						[ChiefName, MembName]
					)
			end, Membs1);
		_ ->
			ignore
	end.