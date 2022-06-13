%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_handler).

-include("game.hrl").
-include("guild.hrl").
-include("role.hrl").
-include("table.hrl").
-include("yunying.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").

%% API
-export([handle/3]).
-export([approve/2]).
-export([reject/2]).
-export([kickout/2]).
-export([demise/2]).
-export([appoint/2]).
-export([dismiss/2]).
-export([rename/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 帮派列表
handle(?GUILD_LIST, _Tos, RoleSt) ->
	#role_guild{apply=Applied} = role_data:get(?DB_ROLE_GUILD),
	Guilds = lists:map(fun
		(Base = #p_guild_base{id=GuildID}) ->
			IsApply  = lists:member(GuildID, Applied),
			GuildWar = guild_war_server:get_zone(GuildID),
			Base#p_guild_base{
				apply = IsApply,
				ext   = #{
					"guild_war_field" => GuildWar
				}
			}
	end, guild:get_guilds()),
	?ucast(#m_guild_list_toc{guilds=Guilds});

%% 帮派查询
handle(?GUILD_QUERY, Tos, RoleSt) ->
	#m_guild_query_tos{guild_id=GuildID} = Tos,
	guild_util:ensure_exist(GuildID),
	{ok, [GuildInfo]} = guild:get_data(GuildID, [?DB_GUILD_INFO]),
	Membs = [guild_util:p_guild_member(M) || M <- GuildInfo#guild_info.membs],
	?ucast(#m_guild_query_toc{
		guild_id = GuildID,
		name     = GuildInfo#guild_info.name,
		rank     = GuildInfo#guild_info.rank,
		level    = GuildInfo#guild_info.level,
		power    = GuildInfo#guild_info.power,
		members  = Membs
	});

%% 帮派信息
handle(?GUILD_INFO, _Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#role_st{guild=GuildID, gpid=GuildPid} = RoleSt,
	GuildInfo = get_guild_info(GuildPid),
	DailyWelfare = role_count:get_guild_welfare(?GUILD_WELFARE_DAILY),
	BabyWelfare  = role_count:get_guild_welfare(?GUILD_WELFARE_BABY),
	PostWelfare  = role_count:get_guild_welfare(?GUILD_WELFARE_POST),
	Membs = [guild_util:p_guild_member(M) || M <- GuildInfo#guild_info.membs],
	?ucast(#m_guild_info_toc{
		guild_id = GuildID,
		name     = GuildInfo#guild_info.name,
		rank     = GuildInfo#guild_info.rank,
		level    = GuildInfo#guild_info.level,
		power    = GuildInfo#guild_info.power,
		fund     = GuildInfo#guild_info.fund,
		notice   = GuildInfo#guild_info.notice,
		modify   = GuildInfo#guild_info.modify,
		members  = Membs,
		welfare  = #{
			?GUILD_WELFARE_DAILY => DailyWelfare,
			?GUILD_WELFARE_BABY  => BabyWelfare,
			?GUILD_WELFARE_POST  => PostWelfare
		},
		impeach  = false
	});

%% 帮派成员
handle(?GUILD_MEMBERS, _Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#role_st{gpid=GuildPid} = RoleSt,
	#guild_info{membs=Membs} = get_guild_info(GuildPid),
	Membs2 = [guild_util:p_guild_member(M) || M <- Membs],
	?ucast(#m_guild_members_toc{members=Membs2});

%% 创建帮派
handle(?GUILD_CREATE, Tos, RoleSt) ->
	#m_guild_create_tos{name=GuildName, level=GuildLv} = Tos,
	check_create(GuildName, GuildLv, RoleSt),
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	Power = role_util:get_power(),
	#cfg_guild{cost=Cost} = cfg_guild:find(GuildLv),
	Succ = fun() ->
		{ok, GuildID, GuildPid} = guild_manager:create(
			RoleID, RoleName, Power, GuildName, GuildLv
		),
		{GuildID, GuildPid}
	end,
	{ok, _, {GuildID, GuildPid}} =
		role_bag:cost(Cost, ?LOG_GUILD_CREATE, Succ, RoleSt),
	RoleGuild = role_data:get(?DB_ROLE_GUILD),
	lists:foreach(fun
		(ApplyGuild) ->
			guild_agent:cancel(guild:get_ref(ApplyGuild), RoleID)
	end, RoleGuild#role_guild.apply),
	role_data:set(RoleGuild#role_guild{
		guild = GuildID,
		post  = ?GUILD_POST_CHIEF,
		apply = []
	}),
	?notify(?MSG_GUILD_CREATE, [
		{role, RoleID, RoleName},
		GuildName
	]),
	RoleSt2 = RoleSt#role_st{guild=GuildID, gpid=GuildPid},
	role_event:event(?EVENT_GUILD_CREATE),
	hook_guild_change(GuildID, GuildName, ?GUILD_POST_CHIEF, RoleSt2, true),
	{ok, #m_guild_create_toc{guild_id=GuildID}, RoleSt2};

%% 解散帮派
handle(?GUILD_DISBAND, _Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	ok = guild_agent:disband(GuildPid, RoleID),
	RoleGuild = role_data:get(?DB_ROLE_GUILD),
	role_data:set(RoleGuild#role_guild{guild=0, post=0, score=0}),
	RoleSt2 = RoleSt#role_st{gpid=?nil, guild=0},
	hook_guild_change(0, "", 0, RoleSt2, false),
	{ok, #m_guild_disband_toc{}, RoleSt2};

%% 转让帮主
handle(?GUILD_DEMISE, Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#m_guild_demise_tos{to=ToRole} = Tos,
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	ok = guild_agent:demise(GuildPid, RoleID, ToRole),
	RoleGuild = role_data:get(?DB_ROLE_GUILD),
	role_data:set(RoleGuild#role_guild{post=?GUILD_POST_MEMB}),
	guild_war_server:del_chief_buff(RoleSt),
	yunying_task:reset(?YYACT_GUILD, RoleSt);

%% 退出帮派
handle(?GUILD_QUIT, _Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	check_quit(RoleSt),
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	ok = guild_agent:quit(GuildPid, RoleID),
	RoleGuild = role_data:get(?DB_ROLE_GUILD),
	role_data:set(RoleGuild#role_guild{guild=0, post=0, score=0}),
	RoleSt2 = RoleSt#role_st{gpid=?nil, guild=0},
	hook_guild_change(0, "", 0, RoleSt2, false),
	{ok, #m_guild_quit_toc{}, RoleSt2};

%% 申请加入
handle(?GUILD_APPLY, Tos, RoleSt = #role_st{role=RoleID}) ->
	#m_guild_apply_tos{guild_id=GuildID} = Tos,
	RoleGuild = #role_guild{apply=Applied} = role_data:get(?DB_ROLE_GUILD),
	check_apply(GuildID, Applied, RoleSt),
	Applient = guild_util:p_guild_apply(RoleID, ?GUILD_POST_MEMB, ut_time:seconds()),
	GuildPid = guild:get_pid(GuildID),
	Result = guild_agent:apply(GuildPid, Applient),
	case Result of
		{ok, true}  ->
			approve({GuildPid,GuildID,0}, RoleSt);
		{ok, false} ->
			role_data:set(RoleGuild#role_guild{apply=[GuildID | Applied]}),
			?ucast(#m_guild_apply_toc{guild_id=GuildID});
		_ ->
			throw(Result)
	end;

%% 取消申请
handle(?GUILD_CANCEL, Tos, RoleSt = #role_st{role=RoleID}) ->
	#m_guild_cancel_tos{guild_id=GuildID} = Tos,
	RoleGuild = #role_guild{apply=Applied} = role_data:get(?DB_ROLE_GUILD),
	check_cancel(GuildID, Applied),
	ok = guild_agent:cancel(guild:get_ref(GuildID), RoleID),
	RoleGuild2 = RoleGuild#role_guild{apply=lists:delete(GuildID, Applied)},
	role_data:set(RoleGuild2),
	?ucast(#m_guild_cancel_toc{guild_id=GuildID});

%% 同意入帮申请
handle(?GUILD_APPROVE, Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#m_guild_approve_tos{role_id = ApplyID} = Tos,
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	ok = guild_agent:approve(GuildPid, RoleID, ApplyID);

%% 拒绝入帮申请
handle(?GUILD_REJECT, Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#m_guild_reject_tos{role_id=ApplyID} = Tos,
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	ok = guild_agent:reject(GuildPid, RoleID, ApplyID),
	?ucast(#m_guild_reject_toc{role_id=ApplyID});

%% 踢出帮派
handle(?GUILD_KICKOUT, Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#m_guild_kickout_tos{role_id=MembID} = Tos,
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	?_check(RoleID /= MembID, ?ERR_GUILD_OPERATE_SELF),
	ok = guild_agent:kickout(GuildPid, RoleID, MembID);

%% 职位任命
handle(?GUILD_APPOINT, Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#m_guild_appoint_tos{role_id=MembID, post=Post} = Tos,
	enum:check_guild_post(Post),
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	?_check(RoleID /= MembID, ?ERR_GUILD_OPERATE_SELF),
	ok = guild_agent:appoint(GuildPid, RoleID, MembID, Post);

%% 解除职位
handle(?GUILD_DISMISS, Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#m_guild_dismiss_tos{role_id=MembID} = Tos,
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	?_check(RoleID /= MembID, ?ERR_GUILD_OPERATE_SELF),
	ok = guild_agent:dismiss(GuildPid, RoleID, MembID);

%% 职位竞选
handle(?GUILD_RUNFOR, Tos, RoleSt) ->
	#m_guild_runfor_tos{post=Post} = Tos,
	check_runfor(Post, RoleSt),
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	ok = guild_agent:runfor(GuildPid, RoleID, Post, ut_time:seconds()),
	?ucast(#m_guild_runfor_toc{post=Post});

%% 同意职位申请
handle(?GUILD_AGREE, Tos, RoleSt) ->
	#m_guild_agree_tos{role_id=RunforID} = Tos,
	guild_util:ensure_had_join(RoleSt),
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	ok = guild_agent:agree(GuildPid, RoleID, RunforID);

%% 拒绝职位申请
handle(?GUILD_REFUSE, Tos, RoleSt) ->
	#m_guild_refuse_tos{role_id=RunforID} = Tos,
	guild_util:ensure_had_join(RoleSt),
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	ok = guild_agent:refuse(GuildPid, RoleID, RunforID),
	?ucast(#m_guild_refuse_toc{role_id=RunforID});

%% 帮派升级
handle(?GUILD_UPGRADE, _Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#role_st{role=RoleID, gpid=GuildPid, guild=GuildID} = RoleSt,
	{ok, NewLv} = guild_agent:upgrade(GuildPid, RoleID),
	GuildName = guild:get_name(GuildID),
	?notify(?MSG_GUILD_UPGRADE, [GuildName, NewLv]),
	?ucast(#m_guild_upgrade_toc{level=NewLv});

%% 帮派改名
handle(?GUILD_RENAME, Tos, RoleSt) ->
	#m_guild_rename_tos{name=Name} = Tos,
	check_rename(Name, RoleSt),
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	Succ = fun() ->
		ok = guild_agent:rename(GuildPid, RoleID, Name)
	end,
	Cost = cfg_game:guild_rename(),
	role_bag:cost(Cost, ?LOG_GUILD_RENAME, Succ, RoleSt),
	?ucast(#m_guild_rename_toc{name=Name});

%% 修改公告
handle(?GUILD_NOTICE, Tos, RoleSt) ->
	#m_guild_notice_tos{notice=Notice, inform=Inform} = Tos,
	check_notice(Notice, RoleSt),
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	#guild_info{modify=MTimes} = get_guild_info(GuildPid),
	{MaxTimes, Cost} = cfg_game:guild_modify(),
	case Inform andalso MTimes >= MaxTimes of
		true  ->
			Succ = fun() ->
				ok = guild_agent:notice(GuildPid, RoleID, Notice, Inform, MTimes)
			end,
			role_bag:cost(Cost, ?LOG_GUILD_NOTICE, Succ, RoleSt);
		false ->
			ok = guild_agent:notice(GuildPid, RoleID, Notice, Inform, MTimes)
	end;

%% 弹劾
handle(?GUILD_IMPEACH, Tos, RoleSt) ->
	#m_guild_impeach_tos{type=Type} = Tos,
	IsValid = (Type == 1) orelse (Type == 2) orelse (Type == 3),
	?_check(IsValid, ?ERR_GAME_BAD_ARGS),
	guild_util:ensure_had_join(RoleSt),
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	ok = guild_agent:impeach(GuildPid, Type, RoleID);

%% 领取福利
handle(?GUILD_WELFARE, Tos, RoleSt) ->
	#m_guild_welfare_tos{type=Type} = Tos,
	guild_util:ensure_had_join(RoleSt),
	enum:check_guild_welfare(Type),
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	GuildInfo = get_guild_info(GuildPid),
	#guild_info{level=GuildLv, membs=Membs} = GuildInfo,
	#guild_memb{post=Post} = lists:keyfind(RoleID, #guild_memb.id, Membs),
	CfgBoon = cfg_guild:boon(GuildLv),
	Gain = case Type of
		?GUILD_WELFARE_DAILY -> % 每日福利
			CfgBoon#cfg_guild_boon.daily;
		?GUILD_WELFARE_BABY  -> % 宝贝福利
			?_check(Post == ?GUILD_POST_BABY, ?ERR_GUILD_NOT_BABY),
			CfgBoon#cfg_guild_boon.baby;
		?GUILD_WELFARE_POST -> % 职位福利
			CfgBoon#cfg_guild_boon.post
	end,
	Times = role_count:get_times({?ROLE_COUNT_GUILD_WELFARE, Type}),
	?_check(Times == 0, ?ERR_GUILD_HAD_FETCH),
	role_bag:gain(Gain, ?LOG_GUILD_WELFARE, RoleSt),
	role_count:add_times({?ROLE_COUNT_GUILD_WELFARE, Type}),
	?ucast(#m_guild_welfare_toc{type=Type});

%% 申请人信息
handle(?GUILD_APPLIANTS, _Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#role_st{gpid=GuildPid} = RoleSt,
	GuildInfo = get_guild_info(GuildPid),
	#guild_info{apply=Apply, runfor=Runfor} = GuildInfo,
	Appliants = [
		guild_util:p_guild_apply(ID, ?GUILD_POST_MEMB, Time) || {ID, Time} <- Apply
	] ++ [
		guild_util:p_guild_apply(ID, Post, Time) || {ID, Post, Time} <- Runfor
	],
	?ucast(#m_guild_appliants_toc{appliants=Appliants});

%% 帮派设置信息
handle(?GUILD_SETTING, _Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#role_st{gpid=GuildPid} = RoleSt,
	GuildInfo = get_guild_info(GuildPid),
	Auto  = maps:get("auto", GuildInfo#guild_info.setting, false),
	Level = maps:get("level", GuildInfo#guild_info.setting, 0),
	Power = maps:get("power", GuildInfo#guild_info.setting, 0),
	?ucast(#m_guild_setting_toc{auto=Auto, level=Level, power=Power});

%% 帮派设置
handle(?GUILD_SETUP, Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#m_guild_setup_tos{auto=Auto, level=Level, power=Power} = Tos,
	?_check(is_boolean(Auto), ?ERR_GAME_BAD_ARGS),
	?_check(is_integer(Level) andalso Level >= 0, ?ERR_GAME_BAD_ARGS),
	?_check(is_integer(Power) andalso Power >= 0, ?ERR_GAME_BAD_ARGS),
	#role_st{gpid=GuildPid, role=RoleID} = RoleSt,
	ok = guild_agent:setup(GuildPid, RoleID, Auto, Level, Power),
	?ucast(#m_guild_setup_toc{auto=Auto, level=Level, power=Power});

%% 帮派日志
handle(?GUILD_LOG, _Tos, RoleSt) ->
	Logs = guild_util:get_guild_logs(RoleSt#role_st.guild),
	?ucast(#m_guild_log_toc{logs=Logs}).


%% 申请通过
approve({GuildPid, GuildID, ApproveID}, RoleSt=#role_st{role=RoleID}) ->
	case RoleSt#role_st.guild == 0 of
		true  ->
			RoleGuild = role_data:get(?DB_ROLE_GUILD),
			role_data:set(RoleGuild#role_guild{
				guild = GuildID,
				post  = ?GUILD_POST_MEMB,
				apply = []
			}),
			guild_agent:join(GuildPid, RoleID),
			GuildName = guild:get_name(GuildID),
			RoleSt2 = RoleSt#role_st{gpid=GuildPid, guild=GuildID},
			hook_guild_change(GuildID, GuildName, ?GUILD_POST_MEMB, RoleSt2, true),
			?ucast(#m_guild_join_toc{guild_id=GuildID}),
			{ok, RoleSt2};
		false ->
			?_if(
				ApproveID > 0, begin
					?ucast(ApproveID, #m_game_error_toc{errno=?ERR_GUILD_HAD_JOIN_OTHER}),
					?ucast(ApproveID, #m_guild_reject_toc{role_id=RoleID})
				end
			),
			guild_agent:cancel(GuildPid, RoleID)
	end.

%% 被拒绝
reject(GuildID, RoleSt) ->
	RoleGuild  = #role_guild{apply=Applied} = role_data:get(?DB_ROLE_GUILD),
	RoleGuild2 = RoleGuild#role_guild{apply=lists:delete(GuildID, Applied)},
	role_data:set(RoleGuild2),
	?ucast(#m_guild_reject_toc{guild_id=GuildID}).

%% 被踢出帮派
kickout(_GuildID, RoleSt) ->
	RoleGuild = role_data:get(?DB_ROLE_GUILD),
	?ucast(#m_role_update_toc{upint=#{"guild"=>0}}),
	role_data:set(RoleGuild#role_guild{guild=0, post=0, score=0}),
	RoleSt2 = RoleSt#role_st{guild=0, gpid=?nil},
	hook_guild_change(0, "", 0, RoleSt2, false),
	{ok, RoleSt2}.

%% 被转让帮主
demise(GuildID, RoleSt) ->
	case RoleSt#role_st.guild == GuildID of
		true  ->
			RoleGuild = role_data:get(?DB_ROLE_GUILD),
			role_data:set(RoleGuild#role_guild{post=?GUILD_POST_CHIEF}),
			case guild_war_server:is_winner(GuildID) of
				true  -> guild_war_server:add_chief_buff(RoleSt);
				false -> ignore
			end,
			hook_post_change(?GUILD_POST_CHIEF, RoleSt);
		false ->
			ignore
	end.

%% 被任命职位
appoint({GuildID, Post}, RoleSt) ->
	case RoleSt#role_st.guild == GuildID of
		true  ->
			RoleGuild = role_data:get(?DB_ROLE_GUILD),
			role_data:set(RoleGuild#role_guild{post=Post}),
			hook_post_change(Post, RoleSt);
		false ->
			ok
	end.

%% 被解除职位
dismiss(GuildID, RoleSt) ->
	case RoleSt#role_st.guild == GuildID of
		true  ->
			RoleGuild = role_data:get(?DB_ROLE_GUILD),
			role_data:set(RoleGuild#role_guild{post=?GUILD_POST_MEMB}),
			hook_post_change(?GUILD_POST_MEMB, RoleSt);
		false ->
			ok
	end.

%% 帮派改名
rename({GuildID, GuildName}, RoleSt) ->
	case RoleSt#role_st.guild == GuildID of
		true  ->
			#role_guild{post=GuildPost} = role_data:get(?DB_ROLE_GUILD),
			hook_guild_change(GuildID, GuildName, GuildPost, RoleSt, false);
		false ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_create(Name, Level, RoleSt) ->
	ValidLv = Level == 1 orelse Level == 2,
	?_check(ValidLv, ?ERR_GAME_BAD_ARGS),
	guild_util:ensure_not_join(RoleSt),
	check_name(Name),
	#cfg_guild{reqs=Reqs} = cfg_guild:find(Level),
	check_reqs(Reqs, RoleSt),
	ok.

check_reqs([{recharge,Money} | T],RoleSt) ->
	AllFee = role_pay:calc(),
	case AllFee >= Money of
		true -> check_reqs(T,RoleSt);
		false -> throw(?err(?ERR_GUILD_NO_PAY))
	end;

check_reqs([{level, LevelLim} | T], RoleSt) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	case RoleLv >= LevelLim of
		true  -> check_reqs(T, RoleSt);
		false -> throw(?err(?ERR_GUILD_LOW_LEVEL))
	end;
check_reqs([{vip, VipLim} | T], RoleSt) ->
	VipLv = role_vip:get_level(),
	case VipLv >= VipLim of
		true  -> check_reqs(T, RoleSt);
		false -> throw(?err(?ERR_GUILD_LOW_VIPLV))
	end;
check_reqs([], _RoleSt) ->
	ok.

check_name(Name) ->
	{Min, Max} = cfg_game:guild_name(),
    Len = ut_str:len(Name),
    ?_check(Len >= Min andalso Len =< Max, ?ERR_GUILD_BAD_LENGTH),
    % 敏感词检测
    % Sensitive = ut_word:is_sensitive(Name, fun cfg_name_filter:find/1),
    % ?_check(not Sensitive, ?ERR_GUILD_BAD_NAME),
    ok.

check_apply(GuildID, Applied, RoleSt) ->
	guild_util:ensure_not_join(RoleSt),
	MaxApply = cfg_game:guild_apply(),
	?_check(length(Applied) < MaxApply, ?ERR_GUILD_APPLY_LIMIT),
	?_check(not lists:member(GuildID, Applied), ?ERR_GUILD_HAD_APPLY),
	guild_util:ensure_exist(GuildID),
	ok.

check_cancel(GuildID, Applied) ->
	?_check(lists:member(GuildID, Applied), ?ERR_GUILD_NOT_APPLY),
	ok.

check_quit(_RoleSt) ->
	LimitActs = cfg_game:guild_quit_limit(),
	lists:foreach(fun
		(ActID) ->
			?_check(not activity:is_start(ActID), ?ERR_GUILD_QUIT_LIMIT)
	end, LimitActs),
	ok.

check_notice(_Notice, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	ok.

check_runfor(Post, RoleSt) ->
	enum:check_guild_post(Post),
	guild_util:ensure_had_join(RoleSt),
	ok.

check_rename(Name, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	check_name(Name),
	ok.

get_guild_info(GuildPid) ->
	{ok, [GuildInfo]} = guild_agent:get_data(GuildPid, [?DB_GUILD_INFO]),
	GuildInfo.

hook_guild_change(GuildID, GuildName, GuildPost, RoleSt, UpdateTimes) ->
	case UpdateTimes of
		true  ->
			role_count:add_times(?ROLE_COUNT_GUILD_JOIN),
			role_event:event(?EVENT_GUILD_JOIN);
		false ->
			ignore
	end,
	role_task:update_guild_task(RoleSt),
	?ucast(#m_role_update_toc{
		upint = #{"guild"=>GuildID},
		upstr = #{"gname"=>GuildName}
	}),
	?_if(GuildID == 0, guild_war_server:del_chief_buff(RoleSt)),
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	Update = [{guild, GuildID, GuildName, GuildPost}],
	scene:update_actor(ScenePid, RoleID, Update),
	role_cache:update(RoleID, [{#role_cache.gname, GuildName}]),
	case GuildID > 0 andalso role_count:get_times(?ROLE_COUNT_GUILD_JOIN) == 1 of
		true  ->
			#role_st{user=User, ip=IP, sdk=SDKArgs} = RoleSt,
			log_junhai:log_guild(User, IP, SDKArgs, {GuildID,GuildName});
		false ->
			ignore
	end.

hook_post_change(Post, RoleSt) ->
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	Update = [{guild_post, Post}],
	scene:update_actor(ScenePid, RoleID, Update).
