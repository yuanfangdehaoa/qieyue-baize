%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(team_handler).

-include("game.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("team.hrl").
-include("scene.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("dunge.hrl").
-include("faker.hrl").
-include("ranking.hrl").
-include("msgno.hrl").
-include("yunying.hrl").

%% API
-export([handle/3]).
-export([kickout/2]).
-export([in_team/2]).
-export([join_team/2]).
-export([add_friend_buffer/2]).
-export([clear_friend_buffer/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%创建队伍
handle(?TEAM_CREATE_TEAM, Tos, RoleSt) ->
	#role_st{team=OldTeamId, scene=SceneId,role=RoleID} = RoleSt,
	%#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	?_check(OldTeamId == 0, ?ERR_TEAM_HAD_IN_TEAM),
	#m_team_create_team_tos{
		type_id        = TypeId,
		min_level      = MinLevel,
		max_level      = MaxLevel,
		is_auto_accept = IsAutoAccept
	} = Tos,
	%?_check(Level >= MinLevel andalso Level =< MaxLevel, ?ERR_GAME_BAD_ARGS),
	check_target(TypeId),
	Member = new_team_member(RoleID, 1, SceneId),
	TeamId = team_server:create_team(
		RoleSt, TypeId, MinLevel, MaxLevel, IsAutoAccept, Member
	),
	NewRoleSt = RoleSt#role_st{team=TeamId},
	%scene:update_actor(ScenePid, RoleID, [{team, TeamId}]),
	RoleInfo = role_data:get(?DB_ROLE_INFO),
	role_data:set(RoleInfo#role_info{team=TeamId}),
	role_figure:update_team(TeamId, RoleSt),
	clear_all_invite(RoleSt),
	?bcast(#m_team_update_list_toc{}),
	{ok, #m_team_create_team_toc{team_id=TeamId}, NewRoleSt};


%%获取队伍信息
handle(?TEAM_GET_TEAM, _Tos, RoleSt) ->
	#role_st{role=RoleId, team=TeamId} = RoleSt,
	case TeamId == 0 of
		false ->
			case team_server:get_team(TeamId) of
				#p_team_info{} = TeamInfo ->
					{ok, #m_team_update_team_info_toc{team_info=TeamInfo}, RoleSt};
				_->
					ignore
			end;
		true ->
			case team_server:get_team(role_id, RoleId) of
				#p_team_info{id=TeamId2} = TeamInfo ->
					NewRoleSt = RoleSt#role_st{team=TeamId2},
					RoleInfo = role_data:get(?DB_ROLE_INFO),
					role_data:set(RoleInfo#role_info{team=TeamId2}),
					role_figure:update_team(TeamId2, RoleSt),
					{ok, #m_team_update_team_info_toc{team_info=TeamInfo}, NewRoleSt};
				_->
					RoleInfo = role_data:get(?DB_ROLE_INFO),
					role_data:set(RoleInfo#role_info{team=0}),
					role_figure:update_team(0, RoleSt),
					ignore
			end
	end;

%%申请
handle(?TEAM_APPLY, Tos, RoleSt) ->
	#role_st{team=OldTeamId, scene=SceneId,role=RoleID} = RoleSt,
	#m_team_apply_tos{team_id=TeamId, is_role=IsRole} = Tos,
	TeamId2 = case IsRole == 1 of
		true  -> 
			case team_server:get_team(role_id, TeamId) of
				#p_team_info{id=TeamId3} ->
					TeamId3;
				_ ->
					0
			end;
		false -> 
			TeamId
	end,
	?_check(TeamId2 > 0, ?ERR_TEAM_TEAM_IS_NOT_EXIST),
	?_check(OldTeamId /= TeamId2, ?ERR_TEAM_IN_SAME_TEAM),
	Member = new_team_member(RoleID, 0, SceneId),
	case team_server:apply(TeamId2, Member, OldTeamId) of
		ok->
			{ok, #m_team_apply_toc{team_id=TeamId2}, RoleSt};
		Error->
			throw(Error)
	end;


%%获取申请列表
handle(?TEAM_GET_APPLY_LIST, _Tos, RoleSt) ->
	#role_st{team=TeamId} = RoleSt,
	case TeamId == 0 of
		true ->
			ignor;
		false ->
			team_server:get_apply(RoleSt, TeamId)
	end;

%%邀请
handle(?TEAM_INVITE, Tos, RoleSt) ->
	#role_st{team=TeamId, role=RoldId} = RoleSt,
	case TeamId == 0 of
		true ->
			throw(?err(?ERR_TEAM_NOT_IN_TEAM));
		false ->
			#m_team_invite_tos{role_id=InviteRoleId} = Tos,
			case team_server:invite(RoldId, TeamId, InviteRoleId) of
				ok-> {ok, RoleSt};
				Error->throw(Error)
			end
	end;

%%获取邀请列表
handle(?TEAM_GET_INVITE_LIST, _Tos, RoleSt) ->
	#role_st{team=TeamId, role=RoldId} = RoleSt,
	case TeamId /= 0 of
		true ->
			throw(?err(?ERR_TEAM_HAD_IN_TEAM));
		false ->
			team_server:get_invite_list(RoldId)
	end;

handle(?TEAM_QUIT_TEAM, _Tos, RoleSt) ->
	#role_st{team=TeamId, role=RoleId} = RoleSt,
	case TeamId == 0 of
		true->
			throw(?err(?ERR_TEAM_NOT_IN_TEAM));
		false->
			%#role_st{spid=ScenePid, role=RoleID} = RoleSt,
			team_server:quit_team(TeamId, RoleId),
			NewRoleSt = RoleSt#role_st{team=0},
			%scene:update_actor(ScenePid, RoleID, [{team, 0}]),
			RoleInfo = role_data:get(?DB_ROLE_INFO),
			role_data:set(RoleInfo#role_info{team=0}),
			role_figure:update_team(0, RoleSt),
			{ok, #m_team_quit_team_toc{team_id=TeamId}, NewRoleSt}
	end;

handle(?TEAM_KICKOUT, Tos, RoleSt) ->
	#role_st{team=TeamId, role=RoleId} = RoleSt,
	case TeamId == 0 of
		true->
			throw(?err(?ERR_TEAM_NOT_IN_TEAM));
		false->
			#m_team_kickout_tos{role_id=KickoutRoleId} = Tos,
			case team_server:kickout(TeamId, RoleId, KickoutRoleId) of
				ok->{ok, RoleSt};
				Error-> throw(Error)
			end
	end;

handle(?TEAM_GET_TEAM_LIST, Tos, RoleSt) ->
	#m_team_get_team_list_tos{type_id=TypeId} = Tos,
	team_server:get_team_list(RoleSt, TypeId);

%%更改目标
handle(?TEAM_CHANGE_SET, Tos, RoleSt) ->
	#m_team_change_set_tos{type_id=TypeId, is_auto_accept=IsAutoAccept, min_level=MinLevel, max_level=MaxLevel} = Tos,
	check_target(TypeId),
	#role_st{team=TeamId, role=RoleId} = RoleSt,
	del_faker(TypeId, TeamId),
	team_server:change_set(TeamId, RoleId, {TypeId, MinLevel, MaxLevel, IsAutoAccept});


handle(?TEAM_HANDLE_APPLY, Tos, RoleSt) ->
	#role_st{role=RoleId, team=TeamId} = RoleSt,
	#m_team_handle_apply_tos{role_id=HandledRoleId, is_accept=IsAccept, reject_all=RejectAll} = Tos,
	case team_server:handle_apply(TeamId, RoleId, RejectAll, HandledRoleId, IsAccept) of
		ok->{ok, RoleSt};
		Error->throw(Error)
	end;

handle(?TEAM_HANDLE_INVITE, Tos, RoleSt) ->
	#role_st{team=OldTeamId, scene=SceneId,role=RoleID} = RoleSt,
	#m_team_handle_invite_tos{team_id=TeamId, reject_all=RejectAll} = Tos,
	case OldTeamId /= 0 of
		true ->
			throw(?err(?ERR_TEAM_HAD_IN_TEAM));
		_->
			Member = new_team_member(RoleID, 0, SceneId),
			case team_server:handle_invite(Member, TeamId, RejectAll) of
				ok -> {ok, RoleSt};
				Error -> throw(Error)
			end
	end;

handle(?TEAM_GET_AUTO_ACCEPT_INVITE, _Tos, RoleSt)->
	#role_st{role=RoleId} = RoleSt,
	AutoStatus = team_server:get_auto_accept_invite(RoleId),
	{ok, #m_team_get_auto_accept_invite_toc{is_auto_accept_invite=AutoStatus}, RoleSt};

handle(?TEAM_SET_AUTO_ACCEPT_INVITE, Tos, RoleSt)->
	#role_st{role=RoleId} = RoleSt,
	#m_team_set_auto_accept_invite_tos{is_auto_accept_invite=AutoStatus} = Tos,
	team_server:set_auto_accept_invite(RoleId, AutoStatus),
	{ok, #m_team_get_auto_accept_invite_toc{is_auto_accept_invite=AutoStatus}, RoleSt};

% handle(?TEAM_MATCH_TEAMS, Tos, RoleSt) ->
% 	#m_team_match_teams_tos{match_status=MatchStatus, type_id=TypeId} = Tos,
% 	#role_st{team=TeamId} = RoleSt,
% 	Member = new_team_member(0),
% 	team_server:match_teams(MatchStatus, TeamId, TypeId, Member),
% 	{ok, #m_team_match_teams_toc{match_status=MatchStatus}, RoleSt};

%进入副本请求
handle(?TEAM_ENTER_DUNGE_ASK, Tos, RoleSt)->
	#role_st{team=TeamId, role=RoleId, name=Name, state=State} = RoleSt,
	?_check(not ?is_escort(State), ?ERR_TEAM_IN_ESCORT),
	#m_team_enter_dunge_ask_tos{dunge_id=DungeID, is_agree=IsAgree, count=Count} = Tos,
	check_dunge(DungeID, RoleSt),
	case IsAgree == 1 andalso Count > 1 of
		true ->
			Costs = cfg_game:dunge_merge_cost(),
			[{_, Num}|_T] = Costs,
			Need = (Count-1) * Num,
			BGold = role_bag:get_money(?ITEM_BGOLD),
			Gold = role_bag:get_money(?ITEM_GOLD),
			?_check(BGold+Gold >= Need, ?ERR_ITEM_NOT_ENOUGH);
		false ->
			ignore
	end,
	case TeamId == 0 of
		true  ->
			throw(?err(?ERR_TEAM_NOT_IN_TEAM));
		false ->
			IsAgree == 1 andalso check_team_enter(DungeID, RoleSt),
			case team_server:enter_dunge_ask(RoleId, Name, TeamId, DungeID, IsAgree, Count) of
				ok->{ok, RoleSt};
				Error->throw(Error)
			end
	end;

%进入副本
handle(?TEAM_ENTER_DUNGE, Tos, RoleSt)->
	#role_st{team=TeamId} = RoleSt,
	#m_team_enter_dunge_tos{dunge_id=DungeID} = Tos,
	check_dunge(DungeID, RoleSt),
	case TeamId == 0 of
		true ->
			throw(?err(?ERR_TEAM_NOT_IN_TEAM));
		false ->
			TeamInfo = team_server:get_team(TeamId),
			check_enter(DungeID, TeamInfo, RoleSt),
			ok = team_server:enter_dunge(TeamId, DungeID)
	end;

handle(?TEAM_REMIND_CAPTAIN, _Tos, RoleSt) ->
	#role_st{team=TeamId, name=Name} = RoleSt,
	case TeamId == 0 of
		true->
			throw(?err(?ERR_TEAM_NOT_IN_TEAM));
		false ->
			team_server:remind_captain(TeamId, Name)
	end;

handle(?TEAM_TRANS_CAPTAIN, Tos, RoleSt)->
	#m_team_trans_captain_tos{role_id=ToRoleID} = Tos,
	#role_st{team=TeamId, role=RoleID} = RoleSt,
	case TeamId == 0 of
		true ->
			throw(?err(?ERR_TEAM_NOT_IN_TEAM));
		false ->
			team_server:trans_captain(TeamId, RoleID, ToRoleID)
	end,
	{ok, #m_team_trans_captain_toc{}, RoleSt};

handle(?TEAM_FAKER, _Tos, RoleSt)->
	#role_st{team=TeamId} = RoleSt,
	case TeamId > 0 of
		true  ->
			#p_team_info{type_id=TypeId, is_auto_accept=Auto, 
				members=Members} = team_server:get_team(TeamId),
			case Auto == 1 andalso TypeId =/= ?TARGET_DUNGE_COUPLE of
				true ->
					Length = length(Members),
					add_faker(TeamId, 3-Length);
				false ->
					ignore
			end;
		false ->
			ignore
	end.

kickout(_CaptainName, RoleSt) ->
	%#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	NewRoleSt = RoleSt#role_st{team=0},
	%scene:update_actor(ScenePid, RoleID, [{team, 0}]),
	RoleInfo = role_data:get(?DB_ROLE_INFO),
	role_data:set(RoleInfo#role_info{team=0}),
	role_figure:update_team(0, RoleSt),
	?ucast(#m_team_kickout_toc{}),
	{ok, NewRoleSt}.

in_team(TeamId, RoleSt)->
	%#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	NewRoleSt = RoleSt#role_st{team=TeamId},
	%scene:update_actor(ScenePid, RoleID, [{team, TeamId}]),
	RoleInfo = role_data:get(?DB_ROLE_INFO),
	role_data:set(RoleInfo#role_info{team=TeamId}),
	role_figure:update_team(TeamId, RoleSt),
	clear_all_invite(RoleSt),
	{ok, NewRoleSt}.

join_team(TeamId, RoleSt) ->
	#role_st{scene=SceneId, role=RoleID} = RoleSt,
	Member = new_team_member(RoleID, 0, SceneId),
	case team_server:join_team_handle(TeamId, Member) of
		ok->
			NewRoleSt = RoleSt#role_st{team=TeamId},
			%scene:update_actor(ScenePid, RoleID, [{team, TeamId}]),
			RoleInfo = role_data:get(?DB_ROLE_INFO),
			role_data:set(RoleInfo#role_info{team=TeamId}),
			role_figure:update_team(TeamId, RoleSt),
			clear_all_invite(RoleSt),
			{ok, NewRoleSt};
		_->
			{ok, RoleSt}
	end.

%增加亲密度buffer
add_friend_buffer(Intimacy, RoleSt)->
	BuffID =  cfg_flower_honey:buff_ids(Intimacy),
	buff:add([BuffID], RoleSt).

%清除好友buff
clear_friend_buffer(RoleSt) ->
	BuffIDs = cfg_flower_honey:all_buff_ids(),
	buff:del(BuffIDs, RoleSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%添加机器人
add_faker(_TeamId, 0)->
	ignore;
add_faker(TeamId, Num)->
	FakerList = faker:random(Num, false),
	#role_info{id=MyRoleID} = role_data:get(?DB_ROLE_INFO),
	MyRoleBase = role:get_base(MyRoleID),
	List = get_rank(MyRoleBase),
	lists:foldl(fun
			(#faker{id=RoleID, base=RoleBase}, Index) ->
				#p_role_base{power=Power} = lists:nth(Index, List),
				RoleBase2 = RoleBase#p_role_base{level=get_level(MyRoleBase), power=Power, team=TeamId},
				Member = #p_team_member{
					role_id    = RoleID,
					role       = RoleBase2,
					is_captain = 0,
					is_online  = 1,
					scene_id   = 0
				},
				team_server:add_faker(TeamId, Member),
				Index + 1
		end, 1, FakerList).

% 剔除机器人
del_faker(?TARGET_DUNGE_COUPLE, TeamId) ->
	team_server:del_faker(TeamId);
del_faker(_, _TeamId) ->
	ignore.

%上浮的最大等级
get_level(RoleBase)->
	#p_role_base{level=MyLevel} = RoleBase,
	List = rank:get_ranklist(1001),
	case length(List) > 0 of
		true ->
			#rankitem{id=RoleID} = lists:nth(1, List),
			#p_role_base{level=Level} = role:get_base(RoleID),
			MaxLevel = min(MyLevel+10, Level),
			MaxLevel2 = max(MyLevel, MaxLevel),
			ut_rand:random(MyLevel, MaxLevel2);
		false ->
			MyLevel
	end.

get_rank(RoleBase)->
	List = rank:get_ranklist(1002),
	Length = length(List),
	List2 = case Length >= 30 of
		true  ->
			lists:sublist(List, 20, 10);
		false ->
			case Length >= 11 of
				true  -> lists:sublist(List, Length-9, 10);
				false -> []
			end
	end,
	case length(List2) > 0 of
		true  ->
			List3 = ut_rand:choose(List2, 2, false),
			[role:get_base(RoleID) || #rankitem{id=RoleID} <- List3];
		false ->
			#p_role_base{power=Power} = RoleBase,
			Random1 = ut_rand:random(90, 95),
			Random2 = ut_rand:random(90, 95),
			Power1 = ut_math:ceil(Power*Random1/100),
			Power2 = ut_math:ceil(Power*Random2/100),
			[RoleBase#p_role_base{power=Power1}, RoleBase#p_role_base{power=Power2}]
	end.

check_target(TypeId)->
	?_check(cfg_team_target_sub:find(TypeId) =/= undefined, ?ERR_TEAM_TARGET_WRONG).

%检查副本
check_dunge(DungeID, _RoleSt)->
	#cfg_dunge{type=Type} = cfg_dunge:find(DungeID),
	?_check(Type == ?DUNGE_TYPE_TEAM, ?ERR_TEAM_DUNGE_TYPE_WRONG).

check_enter(DungeID, TeamInfo, RoleSt) ->
	#cfg_dunge{stype=SType} = cfg_dunge:find(DungeID),
	#p_team_info{captain_id=CaptainId} = TeamInfo,
	?_check(RoleSt#role_st.role == CaptainId, ?ERR_TEAM_NOT_CAPTAIN),
	check_enter_by_type(DungeID, SType, TeamInfo, RoleSt).

check_enter_by_type(_DungeID, SType = ?SCENE_STYPE_DUNGE_PET, TeamInfo, _RoleSt) ->
	case length(TeamInfo#p_team_info.members) == 1 of
		true  ->
			RestTimes = dunge_util:rest_times(SType),
			?_check(RestTimes > 0, ?ERR_SCENE_MAX_TIMES);
		false ->
			ok
	end;
check_enter_by_type(DungeID, ?SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER, _TeamInfo, RoleSt) ->
	#cfg_dunge{scene=Scene} = cfg_dunge:find(DungeID),
	#cfg_scene{reqs=Reqs} = cfg_scene:find(Scene),
	scene_change:check_enter_reqs(Scene, Reqs, RoleSt),
	yunying_dunge_limit_tower:check_captain(DungeID, RoleSt);
check_enter_by_type(_DungeID, _SType, _TeamInfo, _RoleSt) ->
	ok.

% 询问时检查自己是否满足进入条件
check_team_enter(DungeID, RoleSt) ->
	#cfg_dunge{stype=SType} = cfg_dunge:find(DungeID),
	check_team_enter_type(SType, RoleSt),
	ok.

check_team_enter_type(SType = ?SCENE_STYPE_DUNGE_COUPLE, RoleSt) ->
	#role_st{team=TeamId, role=RoleId, name=Name} = RoleSt,
	TeamInfo = team_server:get_team(TeamId),
	case length(TeamInfo#p_team_info.members) == 2 of
		true  ->
			Ids = team_server:get_team_member_ids(TeamInfo) -- [RoleId],
			% #role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
			% MemID = hd(Ids),
			% {ok, #role_cache{gender=MemGender}} = role:get_cache(MemID),
			% ?_check(Gender =/= MemGender, ?ERR_TEAM_DUNGE_COUPLE_GENDER),

			RestTimes = dunge_util:rest_times(SType),
			RestTimes =< 0 andalso begin 
				?notify(Ids, ?MSG_TEAM_DUNGE_MAX_TIMES, [Name]),
				throw(?err(?ERR_SCENE_MAX_TIMES))
			end;
		false ->
			throw(?err(?ERR_TEAM_DUNGE_COUPLE_MEM_NUM))
	end, 
	ok;
check_team_enter_type(_SType, _RoleSt) ->
	ok.

clear_all_invite(RoleSt)->
	#role_st{role=RoleID, scene=SceneId} = RoleSt,
	Member = new_team_member(RoleID, 0, SceneId),
	team_server:handle_invite(Member, 0, 1).

%%新建一个成员
new_team_member(RoleID, IsCaptain, SceneId) ->
	#p_team_member{
		role_id    = RoleID,
		role       = role:get_base(RoleID),
		is_captain = IsCaptain,
		is_online  = 1,
		scene_id   = SceneId
	}.



