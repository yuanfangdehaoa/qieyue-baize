%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%% 队伍管理进程
%%% @end
%%%=============================================================================

-module(team_server).

-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("ranking.hrl").
-include("scene.hrl").
-include("team.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("table.hrl").

-behaviour(gen_server).

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).

-export([create_team/6, get_team/1, get_team/2, apply/3, get_apply/2, invite/3, get_invite_list/1, quit_team/2, kickout/3 ]).
-export([get_team_list/2]).
-export([change_set/3]).
-export([handle_apply/5]).
-export([handle_invite/3]).
-export([get_auto_accept_invite/1]).
-export([set_auto_accept_invite/2]).
-export([join_team_handle/2]).
-export([match_teams/4]).
-export([remind_captain/2]).
-export([hook_logout/1]).
-export([hook_login/1]).
-export([hook_enter/2]).
-export([hook_upgrade/2]).
-export([enter_dunge_ask/6]).
-export([enter_dunge/2]).
-export([get_role_ids/1]).
-export([is_captain/1]).
-export([get_captain/1]).
-export([update_intimacy/1]).
-export([add_faker/2]).
-export([del_faker/1]).
-export([get_team_exp/1]).
-export([trans_captain/3]).
-export([get_team_member_ids/1]).

-define(SERVER, ?MODULE).

-record(team, {id = 0}).


%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).


create_team(RoleSt, TypeId, Minlevel, MaxLevel, IsAutoAccept, Member)->
	gen_server:call(?SERVER, {create_team, RoleSt, TypeId, Minlevel, MaxLevel, IsAutoAccept, Member}).

get_team(role_id, RoleId) ->
	gen_server:call(?SERVER, {get_team, role_id, RoleId}).

get_team(TeamId) ->
	gen_server:call(?SERVER, {get_team, TeamId}).

apply(TeamId, Member, OldTeamId) ->
	gen_server:call(?SERVER, {apply, TeamId, Member, OldTeamId}).

get_apply(RoleSt, TeamId) ->
	gen_server:call(?SERVER, {get_apply_list, RoleSt, TeamId}).

invite(RoldId, TeamId, InviteRoleId) ->
	gen_server:call(?SERVER, {invite, RoldId, TeamId, InviteRoleId}).

get_invite_list(RoleId) ->
	gen_server:call(?SERVER, {get_invite_list, RoleId}).

quit_team(TeamId, RoleId) ->
	gen_server:call(?SERVER, {quit_team, TeamId, RoleId}).

kickout(TeamId, RoleId, KickoutRoleId)->
	gen_server:call(?SERVER, {kickout, TeamId, RoleId, KickoutRoleId}).

get_team_list(RoleSt, TypeId) ->
	gen_server:call(?SERVER, {get_team_list, RoleSt, TypeId}).

change_set(TeamId, RoleId, {TypeId, MinLevel, MaxLevel, IsAutoAccept}) ->
	gen_server:call(?SERVER, {change_set, TeamId, RoleId, {TypeId, MinLevel, MaxLevel, IsAutoAccept}}).

handle_apply(TeamId, RoleId, RejectAll, HandledRoleId, IsAccept) ->
	gen_server:call(?SERVER, {handle_apply, TeamId, RoleId, RejectAll, HandledRoleId, IsAccept}).

handle_invite(Member, TeamId, RejectAll)->
	gen_server:call(?SERVER, {handle_invite, Member, TeamId, RejectAll}).

get_auto_accept_invite(RoleId)->
	gen_server:call(?SERVER, {get_auto_accept_invite, RoleId}).

set_auto_accept_invite(RoleId, Status)->
	gen_server:call(?SERVER, {set_auto_accept_invite, RoleId, Status}).

join_team_handle(TeamId, Member)->
	gen_server:call(?SERVER, {handle_join_team, TeamId, Member}).

match_teams(MatchStatus, TeamId, TypeId, Member)->
	gen_server:call(?SERVER, {match_teams, MatchStatus, TeamId, TypeId, Member}).

remind_captain(TeamId, Name)->
	gen_server:call(?SERVER, {remind_captain, TeamId, Name}).

enter_dunge_ask(RoleId, Name, TeamId, DungeID, IsAgree, Count) ->
	gen_server:call(?SERVER, {enter_dunge_ask, RoleId, Name, TeamId, DungeID, IsAgree, Count}).

get_role_ids(TeamId)->
	gen_server:call(?SERVER, {get_role_ids, TeamId}).

is_captain(RoleSt)->
	gen_server:call(?SERVER, {is_captain, RoleSt}).

enter_dunge(TeamId, DungeID)->
	gen_server:call(?SERVER, {enter_dunge, TeamId, DungeID}).

get_captain(0)->
	0;
get_captain(TeamID)->
	gen_server:call(?SERVER, {get_captain, TeamID}).

trans_captain(TeamId, RoleID, ToRoleID)->
	gen_server:call(?SERVER, {trans_captain, TeamId, RoleID, ToRoleID}).

hook_logout(RoleSt)->
	gen_server:cast(?SERVER, {logout, RoleSt}).

hook_login(RoleSt)->
	gen_server:cast(?SERVER, {login, RoleSt}).

hook_enter(RoleId, SceneId)->
	gen_server:cast(?SERVER, {hook_enter, RoleId, SceneId}).

hook_upgrade(_NewLv, RoleSt)->
	gen_server:cast(?SERVER, {upgrade, RoleSt}).

%更新亲密度
update_intimacy(RoleId)->
	gen_server:cast(?SERVER, {update_intimacy, RoleId}).

%添加机器人
add_faker(TeamId, Member)->
	gen_server:cast(?SERVER, {add_faker, TeamId, Member}).

% 剔除机器人
del_faker(TeamId) ->
	gen_server:cast(?SERVER, {del_faker, TeamId}).

%获取队伍加成
get_team_exp(Num)->
	case Num of
		2 -> 2000;
		3 -> 3000;
		_ -> 0
	end.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	{ok, #team{id=gen_team_id()} }.

handle_call(Request, From, State) ->
	try
		do_handle_call(Request, From, State)
	catch
		throw:Error ->
            {reply, Error, State};
        error:{badmatch, {error,_,_}=Error} ->
            {reply, Error, State};
        Class:Reason:Stacktrace ->
            ?stacktrace(Class, Reason, Stacktrace),
            {reply, ?err(?ERR_GAME_SYS_ERROR), State}
	end.

handle_cast(Msg, State) ->
	?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
gen_team_id()->
	game_env:get_suid() * 100000000000 + 1.

do_handle_cast({login, _RoleSt}, State)->
	{noreply, State};

do_handle_cast({logout, RoleSt}, State)->
	#role_st{team=TeamId, role=RoleId} = RoleSt,
	case get_data(TeamId) of
		undefined->ignore;
		TeamInfo = #p_team_info{members=Members,captain_id=CaptainId}->
			clear_friend_buffer(Members),
			OldMember = lists:keyfind(RoleId, 2, Members),
			OldMember2 = OldMember#p_team_member{is_online=0},
			case RoleId == CaptainId of
				false->
					Members2 = lists:keyreplace(RoleId, 2, Members, OldMember2),
					NewTeamInfo = TeamInfo#p_team_info{members=Members2},
					set_data(NewTeamInfo),
					RoleIds = get_team_member_ids(NewTeamInfo),
					send_update_team_member(RoleIds, {RoleId, 0, 0}),
					cacl_friend_buffer(NewTeamInfo);
				true->
					case set_new_captain(Members, CaptainId) of
						ignore->
							disband(TeamInfo);
						Member = #p_team_member{role=Role}->
							#p_role_base{id=RoleId2, name=Name} = Role,
							OldMember3 = OldMember2#p_team_member{is_captain=0},
							Members2 = lists:keyreplace(RoleId, 2, Members, OldMember3),
							Member2 = Member#p_team_member{is_captain=1},
							Members3 = lists:keyreplace(RoleId2, 2, Members2, Member2),
							Members4 = sort_members(Members3),
							NewTeamInfo = TeamInfo#p_team_info{members=Members4, captain_id=RoleId2},
							set_data(NewTeamInfo),
							send_to_members(NewTeamInfo),
							cacl_friend_buffer(NewTeamInfo),
							RoleIds = get_team_member_ids(NewTeamInfo),
							?notify(RoleIds, ?MSG_TEAM_CAPTAIN_CHANGE, [Name])
					end
			end
	end,
	{noreply, State};

do_handle_cast({update_intimacy, RoleId}, State)->
	case get_team_id(RoleId) of
		?nil ->
			ignore;
		TeamId->
			case get_data(TeamId) of
				?nil ->
					ignore;
				#p_team_info{members=Members} = TeamInfo ->
					clear_friend_buffer(Members),
					cacl_friend_buffer(TeamInfo)
			end
	end,
	{noreply, State};

do_handle_cast({upgrade, RoleSt}, State)->
	#role_st{role=RoleId, team=TeamId} = RoleSt,
	case get_data(TeamId) of
		undefined -> ignore;
		TeamInfo = #p_team_info{members=Members}->
			Member = lists:keyfind(RoleId, 2, Members),
			Member2 = Member#p_team_member{role=role:get_base(RoleId)},
			Members2 = lists:keyreplace(RoleId, 2, Members, Member2),
			NewTeamInfo = TeamInfo#p_team_info{members=Members2},
			set_data(NewTeamInfo)
	end,
	{noreply, State};

do_handle_cast({hook_enter, RoleId, SceneId}, State)->
	case get_team_id(RoleId) of
		undefined->ignore;
		TeamId->
			case get_data(TeamId) of
				undefined->ignore;
				TeamInfo = #p_team_info{members=Members} ->
					Member = lists:keyfind(RoleId, 2, Members),
					Member2 = Member#p_team_member{is_online=1, scene_id=SceneId},
					Members2 = lists:keyreplace(RoleId, 2, Members, Member2),
					NewTeamInfo = TeamInfo#p_team_info{members=Members2},
					set_data(NewTeamInfo),
					RoleIds = get_team_member_ids(NewTeamInfo),
					send_update_team_member(RoleIds, {RoleId, 1, SceneId}),
					clear_friend_buffer(Members2),
					cacl_friend_buffer(NewTeamInfo),
					?bcast(#m_team_update_list_toc{})
			end
	end,
	{noreply, State};

do_handle_cast({add_faker, TeamId, Member}, State)->
	case get_data(TeamId) of
		TeamInfo = #p_team_info{members=Members, captain_id=CaptainId}->
			Members2 = Members ++ [Member],
			#p_team_member{role=Role} = Member,
			#p_role_base{name=Name} = Role,
			?notify(CaptainId, ?MSG_TEAM_JOIN_TEAM, [Name]),
			TeamInfo2 = TeamInfo#p_team_info{members=Members2},
			set_data(TeamInfo2),
			send_to_members(TeamInfo2);
		_ ->
			ignore
	end,
	{noreply, State};

do_handle_cast({del_faker, TeamId}, State) ->
	case get_data(TeamId) of
		#p_team_info{members=Members} = TeamInfo ->
			NewMembers = lists:filter(fun(#p_team_member{role_id=RoleID}) ->
				not faker:is_fake(RoleID)
			end, Members),
			NewTeamInfo = TeamInfo#p_team_info{members=NewMembers},
			set_data(NewTeamInfo),
			send_to_members(NewTeamInfo);
		_->
			ignore
	end,
	{noreply, State}.

do_handle_call({create_team, RoleSt, TypeId, Minlevel, MaxLevel, IsAutoAccept, Member}, _From, #team{id=Id} = State) ->
	NewState = State#team{id=Id+1},
	#team{id=TeamId} = NewState,
	#p_team_member{role=Role} = Member,
	#p_role_base{id=RoleId} = Role,
	TeamInfo = new_team(TeamId, TypeId, Minlevel, MaxLevel, IsAutoAccept, RoleId, [Member]),
	send_team(RoleSt, TeamInfo),
	set_data(TeamInfo),
	set_team_id(RoleId, TeamId),
	{reply, TeamId, NewState};

do_handle_call({get_team, TeamId}, _From, State) ->
	case get_data(TeamId) of
		undefined ->
			{reply, teamnotfound, State};
		#p_team_info{} = TeamInfo ->
			{reply, TeamInfo, State}
	end;
do_handle_call({get_team, role_id, RoleId}, _From, State) ->
	case get_team_id(RoleId) of
		undefined->
			{reply, notinteam, State};
		TeamId->
			case get_data(TeamId) of
				undefined->
					{reply, notinteam, State};
				#p_team_info{} = TeamInfo ->
					{reply, TeamInfo, State}
			end
	end;


do_handle_call({quit_team, TeamId, RoleId}, _From, State) ->
	case get_data(TeamId) of
		#p_team_info{} = TeamInfo ->
			try_quit_team(TeamInfo, RoleId),
			{reply, ok, State};
		_->
			{reply, teamnotfound, State}
	end;

do_handle_call({get_auto_accept_invite, RoleId}, _From, State) ->
	AutoStatus = get_auto_accept_status(RoleId),
	{reply, AutoStatus, State};

do_handle_call({set_auto_accept_invite, RoleId, Status}, _From, State) ->
	set_auto_accept_status(RoleId, Status),
	{reply, Status, State};

do_handle_call({apply, TeamId, Member, OldTeamId}, _From, State) ->
	ApplyList = get_apply_list(TeamId),
	#p_team_member{role=Role} = Member,
	#p_role_base{id=RoleId, level=Level} = Role,
	?_check(ensure_not_applied(RoleId, ApplyList), ?ERR_TEAM_ALREADY_APPLIED),
	case get_data(OldTeamId) of
		#p_team_info{members=OldMembers, captain_id=OldCaptainId} = OldTeamInfo -> %%队伍申请
			?_check(OldCaptainId==RoleId, ?ERR_TEAM_NOT_CAPTAIN),
			case get_data(TeamId) of
				#p_team_info{captain_id=CaptainId, is_auto_accept=IsAutoAccept, members=Members} = TeamInfo ->
					?_check(length(OldMembers)+length(Members) =< ?MAX_TEAM_MEMBER, ?ERR_TEAM_TOTAL_NUM_OVER),
					?_check(ensure_members_level(TeamInfo, OldMembers), ?ERR_TEAM_MEMBER_LEVEL_NOT_IN_RANGE),
					do_apply(OldTeamInfo, TeamId, TeamInfo, CaptainId, IsAutoAccept, Member, OldMembers, ApplyList),
					{reply, ok, State};
				_->
					throw(?err(?ERR_TEAM_TEAM_IS_NOT_EXIST)),
					{reply, ok, State}
			end;
		_->         %%个人申请
			case get_data(TeamId) of
				#p_team_info{captain_id=CaptainId, is_auto_accept=IsAutoAccept} = TeamInfo ->
					?_check(ensure_team_not_full(TeamInfo), ?ERR_TEAM_MAX_NUM),
					?_check(ensure_team_level(TeamInfo, Level), ?ERR_TEAM_LEVEL_NOT_IN_RANGE),
					do_apply(undefined, TeamId, TeamInfo, CaptainId, IsAutoAccept, Member, [Member], ApplyList),
					{reply, ok, State};
				_->
					throw(?err(?ERR_TEAM_TEAM_IS_NOT_EXIST)),
					{reply, ok, State}
			end
	end;

do_handle_call({get_apply_list, RoleSt, TeamId}, _From, State) ->
	case get_data(TeamId) of
		#p_team_info{captain_id=CaptainId} ->
			#role_st{role=RoleId} = RoleSt,
			?_check(CaptainId == RoleId, ?ERR_TEAM_NOT_CAPTAIN),
			ApplyList = get_apply_list(TeamId),
			send_apply_list(CaptainId, ApplyList),
			{reply, ok, State};
		_->
			{reply, teamnotfound, State}
	end;

do_handle_call({invite, RoleId, TeamId, InviteRoleId}, _From, State) ->
	?_check(online_server:is_online(InviteRoleId), ?ERR_TEAM_PLAYER_IS_OFFLINE),
	case get_data(TeamId) of
		#p_team_info{type_id=TypeId, members=Members} = TeamInfo->
			?_check(ensure_team_not_full(TeamInfo), ?ERR_TEAM_MAX_NUM),
			case lists:keyfind(RoleId, 2, Members) of
				false ->
					{reply, membernotfound, State};
				#p_team_member{}=Member ->
					AutoStatus = get_auto_accept_status(InviteRoleId),
					case AutoStatus == 1 of
						false->
							InviteList = get_invite(InviteRoleId),
							OldTeamId = get_team_id(InviteRoleId),
							?_check(OldTeamId == ?nil, ?ERR_TEAM_HAD_IN_TEAM2),
							case ensure_not_invited(InviteList, TeamId) of
								true ->
									InviteItem = #p_team_invite_item{team_id=TeamId, type_id=TypeId, invitor=Member},
									NewInviteList = [InviteItem | InviteList],
									set_invite(InviteRoleId, NewInviteList),
									send_invite_list(InviteRoleId, [InviteItem], add_new),
									?notify(RoleId, ?MSG_TEAM_INVITE_SUCCESS, []);
								false ->
									#p_role_base{name=Name} = role:get_base(InviteRoleId),
									?notify(RoleId, ?MSG_TEAM_HAD_INVITED, [Name])
							end,
							{reply, ok, State};
						_->     %%自动同意邀请
							role:route(InviteRoleId, team_handler, join_team, TeamId)
					end
			end;
		_->
			{reply, teamnotfound, State}
	end;

do_handle_call({get_invite_list, RoleId}, _From, State) ->
	case get_invite(RoleId) of
		undefined->
			{reply, noinvitelist, State};
		InviteList->
			send_invite_list(RoleId, InviteList),
			{reply, ok, State}
	end;

do_handle_call({get_team_list, RoleSt, TypeId}, _From, State) ->
	#role_st{scene=SceneId} = RoleSt,
	TeamList = get_teams(TypeId, SceneId),
	?ucast(#m_team_get_team_list_toc{team_list=lists:sublist(TeamList, 20)}),
	{reply, ok, State};

do_handle_call({change_set, TeamId, RoleId, {TypeId, MinLevel, MaxLevel, IsAutoAccept}}, _From, State) ->
	case get_data(TeamId) of
		#p_team_info{captain_id=CaptainId, type_id=OldTypeId} = TeamInfo ->
			?_check(CaptainId == RoleId, ?ERR_TEAM_NOT_CAPTAIN),
			NewTeamInfo = TeamInfo#p_team_info{type_id=TypeId, min_level=MinLevel, max_level=MaxLevel, is_auto_accept=IsAutoAccept},
			set_data(NewTeamInfo),
			send_to_members(NewTeamInfo),
			RoleIds = get_team_member_ids(NewTeamInfo),
			#cfg_team_target_sub{name=Name} = cfg_team_target_sub:find(TypeId),
			case OldTypeId /= TypeId of
				true ->
					?notify(RoleIds, ?MSG_TEAM_CHANGE_TARGET, [Name]),
					?bcast(#m_team_update_list_toc{});
				false ->
					ignore
			end,
			?ucast(RoleId, #m_team_change_set_toc{}),
			{reply, ok, State};
		_ ->
			{reply, teamnotfound, State}
	end;

%%处理申请
do_handle_call({handle_apply, TeamId, RoleId, RejectAll, HandledRoleId, IsAccept}, _From, State) ->
	case get_data(TeamId) of
		#p_team_info{captain_id=CaptainId, members=Members} = TeamInfo ->
			?_check(CaptainId == RoleId, ?ERR_TEAM_NOT_CAPTAIN),
			ApplyList = get_apply_list(TeamId),
			#p_team_member{role=Role} = lists:keyfind(CaptainId, 2, Members),
			#p_role_base{name=CaptainName} = Role,
			case RejectAll == 1 of
				true ->
					lists:foreach(fun
						(Member) ->
							#p_team_member{role=Role2} = Member,
							#p_role_base{id=RejectRoleId} = Role2,
							?notify(RejectRoleId, ?MSG_TEAM_APPLY_REJECTED, [CaptainName])
					end, ApplyList),
					set_apply_list(TeamId, []),
					send_apply_list(RoleId, []);
				false ->
					case lists:keyfind(HandledRoleId, 2, ApplyList) of
						false ->
							throw(?err(?ERR_TEAM_NOT_IN_APPLY));
						#p_team_member{role=Role3} ->
							#p_role_base{level=Level} = Role3,
							case IsAccept == 1 of
								true ->  %%同意
									?_check(ensure_team_not_full(TeamInfo), ?ERR_TEAM_MAX_NUM),
									?_check(ensure_team_level(TeamInfo, Level), ?ERR_TEAM_LEVEL_NOT_IN_RANGE),
									NewApplyList = lists:keydelete(HandledRoleId, 2, ApplyList),
									set_apply_list(TeamId, NewApplyList),
									case get_team_id(HandledRoleId) of
										undefined->
											do_accpet(HandledRoleId, TeamId, CaptainName);
										OldTeamId->
											#p_team_info{members=OldMembers} = OldTeamInfo = get_data(OldTeamId),
											?_check(ensure_members_level(TeamInfo, OldMembers), ?ERR_TEAM_MEMBER_LEVEL_NOT_IN_RANGE2),
											?_check(length(Members)+length(OldMembers) =< ?MAX_TEAM_MEMBER, ?ERR_TEAM_TOTAL_NUM_OVER2),
											disband_team(OldTeamInfo),
											lists:foreach(fun
													(#p_team_member{role=Role4}) ->
														#p_role_base{id=RoleId2} = Role4,
														do_accpet(RoleId2, TeamId, CaptainName)
												end, OldMembers)
									end;
								false ->           %%拒绝
									NewApplyList = lists:keydelete(HandledRoleId, 2, ApplyList),
									set_apply_list(TeamId, NewApplyList),
									case online_server:is_online(HandledRoleId) of
										true ->
											?notify(HandledRoleId, ?MSG_TEAM_APPLY_REJECTED, [CaptainName]);
										_->
											ignore
									end
							end,
							?ucast(RoleId, #m_team_handle_apply_toc{role_id=HandledRoleId})
					end
			end,
			{reply, ok, State};
		_ ->
			{reply, teamnotfound, State}
	end;

%%处理邀请
do_handle_call({handle_invite, Member, TeamId, RejectAll}, _From, State) ->
	#p_team_member{role=Role} = Member,
	#p_role_base{id=RoleId, level=Level, name=Name} = Role,
	case RejectAll of
		1 -> %全部拒绝
			set_invite(RoleId, []),
			send_invite_list(RoleId, []),
			{reply, ok, State};
		2 -> %拒绝
			InviteList = get_invite(RoleId),
			InviteList2 = lists:keydelete(TeamId, 2, InviteList),
			set_invite(RoleId, InviteList2),
			send_invite_list(RoleId, InviteList2),
			case get_data(TeamId) of
				#p_team_info{captain_id=CaptainId} ->
					?notify(CaptainId, ?MSG_TEAM_REJECT_INVITE, [Name]);
				_->
					ignore
			end,
			{reply, ok, State};
		_ -> %同意
			case get_data(TeamId) of
				#p_team_info{} = TeamInfo ->
					InviteList = get_invite(RoleId),
					case lists:keyfind(TeamId, 2, InviteList) of
						#p_team_invite_item{}->
							?_check(ensure_team_level(TeamInfo, Level), ?ERR_TEAM_LEVEL_NOT_IN_RANGE),
							?_check(ensure_team_not_full(TeamInfo), ?ERR_TEAM_MAX_NUM),
							NewTeamInfo = join_team(TeamInfo, Member),
							set_data(NewTeamInfo),
							role:route(RoleId, team_handler, in_team, TeamId),
							send_to_members(NewTeamInfo),
							set_invite(RoleId, []),
							send_invite_list(RoleId, []),
							?ucast(RoleId, #m_team_handle_invite_toc{}),
							{reply, ok, State};
						_->
							{reply, ?err(?ERR_TEAM_NOT_IN_INVITE), State}
					end;
				_->
					{reply, ?err(?ERR_TEAM_TEAM_IS_NOT_EXIST), State}
			end
	end;

do_handle_call({handle_join_team, TeamId, Member}, _From, State) ->
	case get_data(TeamId) of
	 	#p_team_info{}=TeamInfo ->
	 		#p_team_member{role=Role} = Member,
	 		#p_role_base{level=Level} = Role,
	 		?_check(ensure_team_level(TeamInfo, Level), ?ERR_TEAM_LEVEL_NOT_IN_RANGE),
	 		NewTeamInfo = join_team(TeamInfo, Member),
	 		set_data(NewTeamInfo),
	 		send_to_members(NewTeamInfo),
	 		{reply, ok, State};
	 	_->
	 		{reply, ?err(?ERR_TEAM_TEAM_IS_NOT_EXIST), State}
	 end ;

%%队伍匹配
do_handle_call({match_teams, MatchStatus, TeamId, TypeId, Member}, _From, State)->
	#p_team_member{role=Role} = Member,
	#p_role_base{id=RoleId} = Role,
	if
		MatchStatus==0 ->  %%取消匹配
			case TeamId == 0 of
				true->
					cancel_match(role, RoleId, TypeId);
				false->
					cancel_match(team, TeamId, TypeId)
			end,
			{reply, ok, State};
		true ->           %%匹配
			case get_data(TeamId) of
				#p_team_info{captain_id=CaptainId, members=Members} = TeamInfo ->     %%队伍匹配
					?_check(RoleId==CaptainId, ?ERR_TEAM_CAPTAIN_CAN_MATCH),
					?_check(ensure_team_not_full(TeamInfo), ?ERR_TEAM_MAX_NUM),
					NeedNum = ?MAX_TEAM_MEMBER - length(Members),
					MatchedRoles = get_match_roles(TypeId, NeedNum),
					lists:foreach(fun
						(Member2) ->
							NewTeamInfo = join_team(TeamInfo, Member2),
							#p_team_member{role=Role2} = Member2,
							#p_role_base{id=RoleId2} = Role2,
							role:route(RoleId2, team_handler, in_team, TeamId),
							cancel_match(role, RoleId2, TypeId),
							set_data(NewTeamInfo)
					end, MatchedRoles),
					NewTeamInfo = get_data(TeamId),
					send_to_members(NewTeamInfo),
					MatchedNum = length(MatchedRoles),
					case MatchedNum < NeedNum of
						true ->
							add_to_match(team, TeamId, TypeId);
						false ->
							cancel_match(team, TeamId, TypeId)
					end,
					{reply, ok, State};
				_->                   %%散人
					%%首先匹配2人的队伍
					TeamIds = get_match(team, TypeId),
					case get_any_team(TeamIds, 2) of
						#p_team_info{id=MatchedTeamId} = TeamInfo ->
							NewTeamInfo = join_team(TeamInfo, Member),
							role:route(RoleId, team_handler, in_team, MatchedTeamId),
							cancel_match(team, MatchedTeamId, TypeId),
							set_data(NewTeamInfo),
							send_to_members(NewTeamInfo),
							{reply, ok, State};
						_->
							case get_any_team(TeamIds, 1) of
								#p_team_info{id=MatchedTeamId} = TeamInfo ->
									NewTeamInfo = join_team(TeamInfo, Member),
									role:route(RoleId, team_handler, in_team, MatchedTeamId),
									set_data(NewTeamInfo),
									send_to_members(NewTeamInfo),
									{reply, ok, State};
								_->
									%%散人匹配
									MatchedRoles = get_match_roles(TypeId, 2),
									case length(MatchedRoles) < 2 of
										true->
											add_to_match(role, RoleId, TypeId),
											{reply, ok, State};
										_->
											AllMembers=[Member | MatchedRoles],
											NewAllMembers = lists:sort(fun
													(#p_team_member{role=M1}, #p_team_member{role=M2}) ->
														M1#p_role_base.power < M2#p_role_base.power
												end, AllMembers),
											#team{id=AutoId} = State,
											NewState = #team{id=NewAutoId} = State#team{id=AutoId+1},
											%%todo,获取队伍目标的推荐等级
											MinLevel = 1,
											MaxLevel = 999,
											#p_team_member{role=Role3} = lists:nth(3, NewAllMembers),
											#p_role_base{id=CaptainId} = Role3,
											TeamInfo = new_team(NewAutoId, TypeId, MinLevel, MaxLevel, 0, CaptainId, NewAllMembers),
											send_to_members(TeamInfo),
											{reply, ok, NewState}
									end
							end
					end
			end
	end;

do_handle_call({kickout, TeamId, RoleId, KickoutRoleId}, _From, State)->
	case get_data(TeamId) of
		#p_team_info{captain_id=CaptainId, members=Members} = TeamInfo ->
			?_check(CaptainId==RoleId, ?ERR_TEAM_NOT_CAPTAIN),
			?_check(ensure_member(KickoutRoleId, Members), ?ERR_TEAM_NOT_TEAM_MEMBER),
			NewMembers = lists:keydelete(KickoutRoleId, 2, Members),
			NewTeamInfo = TeamInfo#p_team_info{members=NewMembers},
			set_data(NewTeamInfo),
			set_team_id(KickoutRoleId, 0),
			send_to_members(NewTeamInfo),
			case online_server:is_online(KickoutRoleId) andalso not faker:is_fake(KickoutRoleId) of
				true  ->
					#p_team_member{role=Role} = lists:keyfind(CaptainId, 2, Members),
					#p_role_base{name=CaptainName} = Role,
					?notify(KickoutRoleId, ?MSG_TEAM_MEMBER_KICKOUT, [CaptainName]),
					role:route(KickoutRoleId, team_handler, kickout, CaptainName),
					clear_friend_buffer(Members),
					cacl_friend_buffer(NewTeamInfo);
				_->
					ignore
			end,
			{reply, ok, State};
		_->
			{reply, ?err(?ERR_TEAM_NOT_IN_TEAM), State}
	end;

do_handle_call({trans_captain, TeamId, RoleID, ToRoleID}, _From, State)->
	case get_data(TeamId) of
		#p_team_info{captain_id=CaptainId, members=Members} = TeamInfo ->
			?_check(CaptainId==RoleID, ?ERR_TEAM_NOT_CAPTAIN),
			Member = lists:keyfind(ToRoleID, 2, Members),
			?_check(Member /= false, ?ERR_TEAM_NOT_TEAM_MEMBER),
			Captain = lists:keyfind(RoleID, 2, Members),
			Member2 = Member#p_team_member{is_captain=1},
			Captain2 = Captain#p_team_member{is_captain=0},
			Members2 = lists:keyreplace(RoleID, 2, Members, Captain2),
			Members3 = lists:keydelete(ToRoleID, 2, Members2),
			Members4 = [Member2] ++ Members3,
			TeamInfo2 = TeamInfo#p_team_info{captain_id=ToRoleID, members=Members4},
			set_data(TeamInfo2),
			lists:foreach(fun
				(M) ->
					role:route(M#p_team_member.role_id, role_figure, update_team, {TeamId,ToRoleID})
			end, Members4),
			send_to_members(TeamInfo2);
		_ ->
			throw(?err(?ERR_TEAM_NOT_IN_TEAM))
	end,
	{reply, ok, State};

do_handle_call({enter_dunge_ask, RoleId, Name, TeamId, DungeID, IsAgree, Count}, _From, State)->
	case get_data(TeamId) of
		#p_team_info{captain_id=CaptainId, members=Members} = TeamInfo ->
			Ids = get_team_member_ids(TeamInfo),
			case IsAgree == 1 of
				true ->
					Result2 = check_members_online(Members, Ids),
					Result = check_dunge_members(Members, DungeID, Ids),
					case Result andalso Result2 of
						false ->
							ignore;
						true->
							RoleIds = get_dunge_argee_ids(TeamId),
							case RoleId == CaptainId of
								true  -> ignore;
								false -> ?_check(length(RoleIds)>0, ?ERR_TEAM_NOT_CAPTAIN)
							end,
							RoleIds2 = RoleIds ++ [RoleId],
							set_dunge_agree_ids(TeamId, RoleIds2),
							set_dunge_merge(RoleId, Count),
							?bcast(Ids, #m_team_enter_dunge_ask_toc{
								dunge_id=DungeID,
								role_ids=RoleIds2,
								is_agree=IsAgree,
								role_id =RoleId,
								count   =Count
								})
					end;
				false ->
					set_dunge_agree_ids(TeamId, []),
					remove_dunge_merge(RoleId),
					?notify(Ids, ?MSG_TEAM_NO_ENTER_DUNGE, [Name]),
					?bcast(Ids, #m_team_enter_dunge_ask_toc{dunge_id=DungeID,is_agree=IsAgree})
			end,
			{reply, ok, State};
		_ ->
			{reply, ?err(?ERR_TEAM_NOT_IN_TEAM), State}
	end;

do_handle_call({enter_dunge, TeamId, DungeID}, _From, State)->
	case get_data(TeamId) of
		#p_team_info{members=Members} = TeamInfo ->
			RoleIds = get_dunge_argee_ids(TeamId),
			?_check(length(RoleIds)>0, ?ERR_TEAM_NOT_ALL_AGREE),
			{IsOK, Members2} = is_members_agree(Members, [], RoleIds),
			case IsOK of
				false ->
					{reply, ?err(?ERR_TEAM_NOT_ALL_AGREE), State};
				true ->
					do_enter(TeamId, Members2, DungeID),
					set_dunge_agree_ids(TeamId, []),
					Ids = get_team_member_ids(TeamInfo),
					?bcast(Ids, #m_team_enter_dunge_toc{}),
					{reply, ok, State}
			end;
		_ ->
			{reply, ?err(?ERR_TEAM_NOT_IN_TEAM), State}
	end;

%获取队伍成员id
do_handle_call({get_role_ids, TeamId}, _From, State)->
	case get_data(TeamId) of
		#p_team_info{} = TeamInfo ->
			Ids = get_team_member_ids(TeamInfo),
			{reply, Ids, State};
		_->
			{reply, [], State}
	end;

do_handle_call({get_captain, TeamId}, _From, State)->
	case get_data(TeamId) of
		#p_team_info{captain_id=CaptainId} ->
			{reply, CaptainId, State};
		_->
			{reply, ?nil, State}
	end;

%是否队长
do_handle_call({is_captain, RoleSt}, _From, State)->
	#role_st{role=RoleId, team=TeamId} = RoleSt,
	case get_data(TeamId) of
		#p_team_info{captain_id=CaptainId} ->
			{reply, CaptainId == RoleId, State};
		_ ->
			{reply, false, State}
	end;

do_handle_call({remind_captain, TeamId, Name}, _From, State) ->
	case get_data(TeamId) of
		#p_team_info{captain_id = CaptainId} ->
			?ucast(CaptainId, #m_team_remind_captain_toc{name=Name}),
			{reply, ok, State};
		_->
			{reply, ?err(?ERR_TEAM_NOT_IN_TEAM), State}
	end.

%是否所有队员都已同意进入
is_members_agree([], NewMembers, _RoleIds)->
	{true, NewMembers};
is_members_agree([Member|Members], NewMembers, RoleIds)->
	#p_team_member{role_id=RoleId} = Member,
	case lists:member(RoleId, RoleIds) orelse faker:is_fake(RoleId) of
		true ->
			NewMembers2 = NewMembers ++ [Member],
			is_members_agree(Members, NewMembers2, RoleIds);
		false ->
			{false, NewMembers}
	end.

%%从匹配池中获取队员
get_match_roles(TypeId, NeedNum)->
	Roles = get_match(role, TypeId),
	get_last_item(Roles, NeedNum, []).

%设置新队长
set_new_captain([], _OldCaptainId)->
	ignore;
set_new_captain([Member|Memebers], OldCaptainId)->
	#p_team_member{role=Role}=Member,
	#p_role_base{id=RoleId} = Role,
	case RoleId == OldCaptainId of
		true->
			set_new_captain(Memebers, OldCaptainId);
		false->
			case not faker:is_fake(RoleId) andalso online_server:is_online(RoleId) of
				true  -> Member;
				false -> set_new_captain(Memebers, OldCaptainId)
			end
	end.


get_last_item([], _Num, Result)->
	Result;
get_last_item(_List, 0, Result)->
	Result;
get_last_item([], 0, Result)->
	Result;
get_last_item(List, Num, Result)->
	Item = lists:last(List),
	NewList = lists:delete(Item, List),
	get_last_item(NewList, Num-1, [Item | Result]).

%%获取任一满足条件的队伍
get_any_team([], _Num) ->
	undefined;
get_any_team([TeamId | TeamIds], Num) ->
	case get_data(TeamId) of
		#p_team_info{members=Members} = TeamInfo ->
			case length(Members) == Num of
				true ->
					TeamInfo;
				false ->
					get_any_team(TeamIds, Num)
			end;
		_->
			get_any_team(TeamIds, Num)
	end.

do_accpet(RoleId, TeamId, CaptainName)->
	case online_server:is_online(RoleId) of
		true->
			?notify(RoleId, ?MSG_TEAM_APPLY_ACCEPTED, [CaptainName]);
		false->
			ignore
	end,
	role:route(RoleId, team_handler, join_team, TeamId).

do_apply(undefined, TeamId, TeamInfo, CaptainId, IsAutoAccept, Member, _Members, ApplyList) ->
	if
		IsAutoAccept == 0 ->
			NewApplyList = [Member | ApplyList],
			set_apply_list(TeamId, NewApplyList),
			send_apply_list(add_new, CaptainId, [Member]);
		true ->
			#p_team_member{role=Role} = Member,
			#p_role_base{id=NewRoleId} = Role,
			NewTeamInfo = join_team(TeamInfo, Member),
			?notify(NewRoleId, ?MSG_TEAM_JOIN_TEAM_SUC, []),
			set_data(NewTeamInfo),
			role:route(NewRoleId, team_handler, in_team, TeamId),
			send_to_members(NewTeamInfo)
	end;

do_apply(OldTeamInfo, TeamId, TeamInfo, CaptainId, IsAutoAccept, Member, Members, ApplyList) ->
	if
		IsAutoAccept == 0 ->
			NewApplyList = [Member | ApplyList],
			set_apply_list(TeamId, NewApplyList),
			send_apply_list(add_new, CaptainId, [Member]);
		true ->
			disband_team(OldTeamInfo),
			NewTeamInfo = members_join_team(TeamInfo, TeamId, Members),
			set_data(NewTeamInfo),
			send_to_members(NewTeamInfo)
	end.


members_join_team(TeamInfo, _TeamId, [])->
	TeamInfo;
members_join_team(TeamInfo, TeamId, [Member|Members])->
	#p_team_member{role=Role} = Member,
	#p_role_base{id=NewRoleId} = Role,
	NewTeamInfo = join_team(TeamInfo, Member),
	role:route(NewRoleId, team_handler, in_team, TeamId),
	members_join_team(NewTeamInfo, TeamId, Members).


%%加入队伍
join_team(TeamInfo, Member)->
	#p_team_info{id=TeamId, members=Members} = TeamInfo,
	#p_team_member{role=Role} = Member,
	#p_role_base{id=RoleId, name=Name} = Role,
	IsOnline = case online_server:is_online(RoleId) of
		true->1;
		false->0
	end,
	Member2 = Member#p_team_member{is_captain=0, is_online=IsOnline},
	set_team_id(RoleId, TeamId),
	Members2 = Members ++ [Member2],
	RoleIds = get_team_member_ids(TeamInfo),
	?notify(RoleIds, ?MSG_TEAM_JOIN_TEAM, [Name]),
	TeamInfo2 = TeamInfo#p_team_info{members=Members2},
	cacl_friend_buffer(TeamInfo2),
	TeamInfo2.

try_quit_team(TeamInfo, RoleId)->
	#p_team_info{id=TeamID, members=Members, captain_id=CaptainId} = TeamInfo,
	clear_friend_buffer(Members),
	NewMembers = try_quite_team2(Members, RoleId),
	case get_online_num(NewMembers) == 0 of
		true ->
			disband(TeamInfo),
			set_team_id(RoleId, 0);
		_ ->
			{NewCaptainId2, NewMembers4, CName} = case CaptainId==RoleId of %%队长退队
				true ->
					Member = #p_team_member{role=Role} = lists:last(NewMembers),
					#p_role_base{id=NewCaptainId,name=Name} = Role,
					Member2 = Member#p_team_member{is_captain=1},
					NewMembers2 = lists:keyreplace(NewCaptainId, 2, NewMembers, Member2),
					NewMembers3 = sort_members(NewMembers2),
					{NewCaptainId, NewMembers3, Name};
				false->
					{CaptainId, NewMembers, undefined}
			end,
			NewTeamInfo = TeamInfo#p_team_info{captain_id=NewCaptainId2, members=NewMembers4},
			set_data(NewTeamInfo),
			set_team_id(RoleId, 0),
			send_to_members(NewTeamInfo),
			cacl_friend_buffer(NewTeamInfo),
			case CName of
				undefined->ignore;
				_->
					RoleIds = get_team_member_ids(NewTeamInfo),
					lists:foreach(fun
						(RoleID) ->
							role:route(RoleID, role_figure, update_team, {TeamID,NewCaptainId2})
					end, RoleIds),
					?notify(RoleIds, ?MSG_TEAM_CAPTAIN_CHANGE, [CName])
			end
	end.

try_quite_team2(Members, RoleId)->
	Members2 = lists:keydelete(RoleId, 2, Members),
	lists:foldl(fun
			(Member, Acc) ->
				#p_team_member{role_id=RoleId2} = Member,
				case faker:is_fake(RoleId2) of
					true  -> lists:keydelete(RoleId2, 2, Acc);
					false -> Acc
				end
		end, Members2, Members2).

%获取在线人数
get_online_num(Members)->
	lists:foldl(fun
			(Member, Acc) ->
				#p_team_member{role_id=RoleId} = Member,
				case faker:is_fake(RoleId) or not online_server:is_online(RoleId) of
					true  -> Acc;
					false -> Acc+1
				end
		end, 0, Members).


%全部队员离线，清除队伍
disband(TeamInfo)->
	#p_team_info{members=Members} = TeamInfo,
	lists:foldl(fun
			(#p_team_member{role=Role}, Sum) ->
				set_team_id(Role#p_role_base.id, 0),
				Sum+0
		end, 0, Members),
	disband_team(TeamInfo).



%%解散队伍
disband_team(TeamInfo)->
	#p_team_info{id=TeamId, type_id=TypeId, captain_id=CaptainId} = TeamInfo,
	set_apply_list(TeamId, []),
	send_apply_list(CaptainId, []),
	case erlang:get(?k_team) of
		undefined->
			ignore;
		TeamMaps ->
			NewTeamMaps = maps:remove(TeamId, TeamMaps),
			erlang:put(?k_team, NewTeamMaps),
			cancel_match(team, TeamId, TypeId)
	end,
	?bcast(#m_team_update_list_toc{}).

get_team_member_ids(TeamInfo) ->
	#p_team_info{members = Members} = TeamInfo,
	lists:foldl(fun
			(#p_team_member{role_id=RoleID}, Acc) ->
				case faker:is_fake(RoleID) of
					true  -> Acc;
					false -> [RoleID | Acc]
				end
		end, [], Members).

%清除亲密度buff
clear_friend_buffer(Members)->
	lists:foreach(fun
			(#p_team_member{role_id=RoleId}) ->
				case online_server:is_online(RoleId) andalso not faker:is_fake(RoleId) of
					true  -> role:route(RoleId, team_handler, clear_friend_buffer);
					false -> ignore
				end
		end, Members).

%计算亲密度加成
cacl_friend_buffer2(Members, RoleId)->
	lists:foreach(fun
			(#p_team_member{role_id=RoleId2, is_online=IsOnline}) ->
				case RoleId2 /= RoleId andalso IsOnline == 1 andalso not faker:is_fake(RoleId2) of
					true  ->
						Intimacy = friend_server:get_intimacy(RoleId, RoleId2),
						role:route(RoleId, team_handler, add_friend_buffer, Intimacy),
						role:route(RoleId2, team_handler, add_friend_buffer, Intimacy);
					false ->
						ignore
				end
		end, Members).

cacl_friend_buffer(TeamInfo)->
	#p_team_info{members = Members} = TeamInfo,
	lists:foreach(fun
			(#p_team_member{role_id=RoleId, is_online=IsOnline}) ->
				case IsOnline == 1 andalso not faker:is_fake(RoleId) of
					true  -> cacl_friend_buffer2(Members, RoleId);
					false -> ignore
				end
		end, Members).


new_team(Id, TypeId, Minlevel, MaxLevel, IsAutoAccept, CaptainId, Members) ->
	#p_team_info{id=Id, type_id=TypeId, min_level=Minlevel, max_level=MaxLevel, is_auto_accept = IsAutoAccept, captain_id=CaptainId, members=Members}.

send_team(RoleSt, TeamInfo)->
	?ucast(#m_team_update_team_info_toc{team_info=TeamInfo}).

send_to_members(TeamInfo) ->
	#p_team_info{members=Members} = TeamInfo,
	Toc = #m_team_update_team_info_toc{team_info=TeamInfo},
	lists:foreach(fun
		(Member) ->
			#p_team_member{role=Role} = Member,
			#p_role_base{id=RoleID} = Role,
			?_if(not faker:is_fake(RoleID),
			?ucast(RoleID, Toc))
	end, Members).

send_apply_list(add_new, CaptainId, ApplyList) ->
	?ucast(CaptainId, #m_team_get_apply_list_toc{
		is_add_new=1,
		apply_list=ApplyList
	}).

send_apply_list(CaptainId, ApplyList) ->
	?ucast(CaptainId, #m_team_get_apply_list_toc{
		apply_list=ApplyList
	}).

%%发送邀请列表
send_invite_list(RoleId, InviteList, add_new) ->
	?ucast(RoleId, #m_team_get_invite_list_toc{
			is_add_new=1,
			invite_list = InviteList
		}).
send_invite_list(RoleId, InviteList) ->
	?ucast(RoleId, #m_team_get_invite_list_toc{
			invite_list = InviteList
		}).

send_update_team_member(RoleIds, {RoleId, IsOnline, SceneId})->
	?bcast(RoleIds, #m_team_update_team_member_toc{
		  role_id   = RoleId
		, is_online = IsOnline
		, scene_id  = SceneId
		}).

%%检查是否申请过
ensure_not_applied(RoleId, ApplyList) ->
	case ApplyList == undefined of
		true->
			true;
		false ->
			lists:keymember(RoleId, 2, ApplyList) == false
	end.

%%队伍是否已满
ensure_team_not_full(TeamInfo) ->
	#p_team_info{members=Members} = TeamInfo,
	length(Members) < ?MAX_TEAM_MEMBER.

%%确保没有邀请过
ensure_not_invited(InviteList, TeamId)->
	case InviteList == undefined of
		true->
			true;
		false->
			lists:keymember(TeamId, 2, InviteList) == false
	end.

%%确保是队员
ensure_member(RoleId, Members)->
	lists:keymember(RoleId, 2, Members).

%%确保等级
ensure_team_level(TeamInfo, Level) ->
	#p_team_info{min_level=MinLevel, max_level=MaxLevel} = TeamInfo,
	?_if(Level >= MinLevel andalso Level =< MaxLevel, true).

%%确保要加入的队员的全部等级符合
ensure_members_level(TeamInfo, Members) ->
	#p_team_info{min_level=MinLevel, max_level=MaxLevel} = TeamInfo,
	lists:all(fun
			(Member) ->
				#p_team_member{role=Role} = Member,
				#p_role_base{level=Level} = Role,
				Level >= MinLevel andalso Level =< MaxLevel
		end, Members).

%检查是否在线
check_members_online(Members, Ids)->
	Names = lists:foldl(fun
			(Member, Acc) ->
				#p_team_member{role_id=RoleID, role=Role} = Member,
				case faker:is_fake(RoleID) of
					true ->
						Acc;
					false->
						case online_server:is_online(RoleID) of
							false ->
								#p_role_base{name=Name} = Role,
								?notify(Ids, ?MSG_TEAM_MEMBER_OFFLINE, [Name]),
								[Name | Acc];
							true ->
								Acc
						end
				end
		end, [], Members),
	case length(Names) > 0 of
		true -> false;
		_    -> true
	end.

%检查队员
check_dunge_members(Members, DungeID, Ids)->
	#cfg_dunge{level=Level} = cfg_dunge:find(DungeID),
	check_dunge_member(Members, true, Level, Ids).

check_dunge_member([], Result, _Level, _Ids)->
	Result;
check_dunge_member([Member|Members], Result, Level, Ids)->
	#p_team_member{role_id=RoleID, role=Role, scene_id=SceneId} = Member,
	case faker:is_fake(RoleID) of
		true  ->
			check_dunge_member(Members, Result, Level, Ids);
		false ->
			#p_role_base{level=MyLevel, name=Name} = Role,
			%检查等级
			Result2 = case MyLevel < Level of
				true ->
					?notify(Ids, ?MSG_TEAM_LEVEL_LIMIT, [Name]),
					false;
				false ->
					true
			end,
			Result3 = Result andalso Result2,
			%检查场景
			Result4 = check_scene(Name, SceneId, Ids),
			Result5 = Result3 andalso Result4,
			check_dunge_member(Members, Result5, Level, Ids)
	end.

check_scene(_Name, 0, _Ids) ->
	true;
check_scene(Name, SceneId, Ids)->
	#cfg_scene{type=Type, name=SceneName} = cfg_scene:find(SceneId),
	?debug("SceneId------------:~w", [SceneId]),
	case Type == ?SCENE_TYPE_CITY orelse Type == ?SCENE_TYPE_FIELD of
		true ->
			true;
		false ->
			?notify(Ids, ?MSG_TEAM_NOT_IN_MAIN, [Name, SceneName]),
			false
	end.

%%取消队伍匹配
cancel_match(team, TeamId, TypeId) ->
	TeamIds = get_match(team, TypeId),
	NewTeamIds = lists:keydelete(TeamId, 2, TeamIds),
	set_match(team, NewTeamIds, TypeId);

cancel_match(role, RoleId, TypeId) ->
	Roles = get_match(role, TypeId),
	NewRoles = lists:keydelete(RoleId, 2, Roles),
	set_match(role, NewRoles, TypeId).

%%加入队伍匹配
add_to_match(team, TeamId, TypeId)->
	TeamIds = get_match(team, TypeId),
	case lists:member(TeamId, TeamIds) of
		false->
			NewTeamIds = [TeamId | TeamIds],
			set_match(team, NewTeamIds, TypeId)
	end;

add_to_match(role, Member, TypeId)->
	Roles = get_match(role, TypeId),
	case lists:member(Member, Roles) of
		false->
			Roles2 = [Member | Roles],
			set_match(role, Roles2, TypeId)
	end.

%队员排序,队长在第一个
sort_members(Members)->
	lists:foldl(fun
			(#p_team_member{is_captain=IsCaptain} = Member, Lists) ->
				case IsCaptain == 1 of
					true -> [Member] ++ Lists;
					false -> Lists ++ [Member]
				end
		end, [], Members).


set_data(TeamInfo) ->
	#p_team_info{id=TeamId} = TeamInfo,
	case erlang:get(?k_team) of
		undefined ->
			NewTeamMaps = maps:new(),
			NewTeamMaps2 = maps:put(TeamId, TeamInfo, NewTeamMaps),
			erlang:put(?k_team, NewTeamMaps2);
		TeamMaps ->
			TeamMaps2 = maps:put(TeamId, TeamInfo, TeamMaps),
			erlang:put(?k_team, TeamMaps2)
	end.

get_data(TeamId) ->
	case erlang:get(?k_team) of
		undefined ->
			undefined;
		TeamMaps ->
			maps:get(TeamId, TeamMaps, ?nil)
	end.

get_teams(TypeId, SceneId) ->
	case erlang:get(?k_team) of
		undefined ->
			[];
		TeamMaps ->
			Fun = fun(_K, V, TeamList) ->
					#p_team_info{type_id=TeamTypeId, captain_id=CaptainId} = V,
					case TypeId of
						1->
							#p_team_info{members=Members} = V,
							#p_team_member{scene_id=CSceneId} = lists:keyfind(CaptainId, 2, Members),
							case SceneId == CSceneId of
								true->
									[V | TeamList];
								false->
									TeamList
							end;
						_->
							case TypeId == 0 orelse TeamTypeId == TypeId of
								true->
									[V | TeamList];
								false->
									TeamList
							end
					end
				end,
			maps:fold(Fun, [], TeamMaps)
	end.

set_apply_list(TeamId, ApplyList) ->
	erlang:put(?apply_list, ApplyList).

get_apply_list(TeamId) ->
	case ApplyList = erlang:get(?apply_list) of
		undefined ->
			[];
		_ ->
			ApplyList
	end.

set_invite(RoleId, InviteList) ->
	erlang:put(?invite_list, InviteList).

get_invite(RoleId) ->
	case InviteList = erlang:get(?invite_list) of
		undefined ->
			[];
		_->
			InviteList
	end.

set_team_id(RoleId, TeamId) ->
	case TeamId==0 of
		true->
			erlang:erase(?team_id);
		false->
			erlang:put(?team_id, TeamId)
	end.

get_team_id(RoleId) ->
	erlang:get(?team_id).



set_auto_accept_status(RoleId, Status)->
	erlang:put(?auto_accept_invite, Status).

get_auto_accept_status(RoleId)->
	case Status = erlang:get(?auto_accept_invite) of
		undefined->
			0;
		_->
			Status
	end.

get_dunge_argee_ids(TeamId)->
	case erlang:get(?dunge_agree_ids) of
		?nil -> [];
		RoleIds -> RoleIds
	end.

set_dunge_agree_ids(TeamId, RoleIds)->
	erlang:put(?dunge_agree_ids, RoleIds).

%设置合并次数
set_dunge_merge(RoleId, Count)->
	erlang:put(?dunge_merge, Count).

remove_dunge_merge(RoleId)->
	erlang:erase(?dunge_merge) .

get_dunge_merge(RoleId)->
	case erlang:get(?dunge_merge) of
		?nil  -> 1;
		Count -> Count
	end.


set_match(team, TeamIds, TypeId)->
	erlang:put(?match_team_pool, TeamIds);
set_match(role, RoleMaps, TypeId)->
	erlang:put(?match_role_pool, RoleMaps).

get_match(team, TypeId)->
	case erlang:get(?match_team_pool) of
		undefined->
			[];
		TeamIds ->
			TeamIds
	end;
get_match(role, TypeId)->
	case erlang:get(?match_role_pool) of
		undefined->
			[];
		Roles->
			Roles
	end.

do_enter(TeamID, Members, DungeID) ->
	#cfg_dunge{scene=SceneID, floor=Floor} = cfg_dunge:find(DungeID),
	#p_team_info{captain_id=CaptainId} = get_data(TeamID),
	Opts = #{dunge=>DungeID, floor=>Floor, captain=>CaptainId},
	{ok, ScenePid} = scene:create(SceneID, TeamID, Opts),

	AttrID = calc_attrid(Members),

	lists:foldl(fun
		(#p_team_member{role_id=RoleID, role=RoleBase}, Index) ->
		    Coord = lists:nth(Index, scene_config:born(SceneID)),
			case faker:is_fake(RoleID) of
				true  ->
					scene:route(ScenePid, dunge_team, faker, {TeamID,RoleBase,Coord,AttrID});
				false ->
					Count = get_dunge_merge(RoleID),
					?debug("roleid ~p, count ~p", [RoleID, Count]),
					role:route(RoleID, dunge_team, enter, {TeamID,SceneID,DungeID,Coord,Count}),
					remove_dunge_merge(RoleID)
			end,
			Index + 1
	end, 1, Members).

calc_attrid(Members) ->
	TopList = rank:get_toplist(?RANK_ID_POWER, 10),
	case TopList == [] of
		true  ->
			Members2 = [M || M <- Members, not faker:is_fake(M#p_team_member.role_id)],
			case Members2 of
				[M] ->
					M#p_team_member.role_id;
				[M1, M2] ->
					#p_role_base{power=Power1} = M1#p_team_member.role,
					#p_role_base{power=Power2} = M2#p_team_member.role,
					case Power1 >= Power2 of
						true  -> M1#p_team_member.role_id;
						false -> M2#p_team_member.role_id
					end;
				_ ->
					0
			end;
		false ->
			(lists:last(TopList))#rankitem.id
	end.
