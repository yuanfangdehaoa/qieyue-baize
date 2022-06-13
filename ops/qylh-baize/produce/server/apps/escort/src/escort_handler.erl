%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(escort_handler).

-include("escort.hrl").
-include("game.hrl").
-include("table.hrl").
-include("log.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("msgno.hrl").
-include("role.hrl").

%% API
-export([handle/3]).
-export([expire/2]).
%-export([hook_login/1]).
-export([post_reset/3]).
% -export([apply_support/2]).
% -export([accept_apply/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%刷新品质
handle(?ESCORT_REFRESH, _Tos, RoleSt)->
	#role_st{scene=SceneID,coord=Coord,role=RoleID} = RoleSt,
	EscortCount = role_count:get_times(?ROLE_COUNT_ESCORT_COUNT),
	#cfg_escort{attend=Attend, max_quality=MaxQuality} = cfg_escort:find(1),
	?_check(EscortCount < Attend, ?ERR_ESCORT_COUNT_IS_MAX),
	%检查是否在npc点
	#cfg_escort_road{start=Start,second=Second} = cfg_escort_road:find(1),
	?_check(check_poses(Coord, SceneID, [Start, Second]), ?ERR_SCENE_NPC_TOO_FAR),
	Fresh = role_count:get_times(?ROLE_COUNT_ESCORT_FRESH),
	RoleEscort = #role_escort{quality = OldQuality} = role_data:get(?DB_ROLE_ESCORT),
	?_check(OldQuality<MaxQuality, ?ERR_ESCORT_QUALITY_IS_MAX),
	Quality = fresh_quality(OldQuality, Fresh, RoleSt),
	Quality2 = case Quality =< OldQuality of
		true ->
			?notify(RoleID, ?MSG_ESCORT_REFRESH_FAIL, []),
			OldQuality;
		false ->
			Quality
	end,
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	RoleEscort2 = RoleEscort#role_escort{quality=Quality2, level=Level},
	role_data:set(RoleEscort2),
	{ok, #m_escort_refresh_toc{
			  quality       = Quality2
			, escort_count  = EscortCount
%			, rob_count     = RobCount
			, refresh_count = role_count:get_times(?ROLE_COUNT_ESCORT_FRESH)
	     }, RoleSt};

%申请支援
% handle(?ESCORT_SUPPORT, Tos, RoleSt)->
% 	#m_escort_support_tos{role_id=RoleId} = Tos,
% 	#role_st{guild=Guild, role=ApplyRoleId} = RoleSt,
% 	?_check(Guild > 0, ?ERR_GAME_BAD_ARGS),
% 	?_check(online_server:is_online(RoleId), ?ERR_GAME_BAD_ARGS),
% 	?_check(not escort_server:is_apply(ApplyRoleId, RoleId),?ERR_GAME_BAD_ARGS),
% 	%是否以有支援
% 	#role_escort{support=Support, quality=Quality}= role_data:get(?DB_ROLE_ESCORT),
% 	?_check(Support == 0, ?ERR_GAME_BAD_ARGS),
% 	role:route(RoleId, escort_handler, apply_support, {ApplyRoleId, Quality, Guild});

%处理请求
% handle(?ESCORT_HANDLE_REQUEST, Tos, RoleSt)->
% 	#m_escort_handle_request_tos{role_id=ApplyRoleId, is_accept=IsAccpet} = Tos,
% 	#role_st{role=RoleId, name=Name} = RoleSt,
% 	?_check(escort_server:is_apply(ApplyRoleId, RoleId), ?ERR_GAME_BAD_ARGS),
% 	case IsAccpet == 1 of
% 		true ->
% 			check_support_count(),
% 			check_guild(ApplyRoleId, RoleId),
% 			?_check(online_server:is_online(ApplyRoleId), ?ERR_GAME_BAD_ARGS),
% 			role:route(ApplyRoleId, escort_handler, accept_apply, {RoleId, Name});
% 		false ->
% 			?notify(ApplyRoleId, ?MSG_ESCORT_REFUSE_SUPPORT, [Name])
% 	end,
% 	escort_server:delete_apply(ApplyRoleId, RoleId),
% 	{ok, #m_escort_handle_request_toc{role_id=ApplyRoleId,is_accept=IsAccpet}, RoleSt};

%开始护送
handle(?ESCORT_START, _Tos, RoleSt)->
	#role_st{scene=SceneID, coord=Coord, role=RoleId, state=State} = RoleSt,
	#cfg_escort{duration=Duration,buff=Buff} = cfg_escort:find(1),
	%检查是否在npc点
	#cfg_escort_road{start=Start} = cfg_escort_road:find(1),
	?_check(check_pos(Coord, SceneID, Start), ?ERR_SCENE_NPC_TOO_FAR),
	RoleEscort = role_data:get(?DB_ROLE_ESCORT),
	#role_escort{end_time=EndTime, quality=Quality} = RoleEscort,
	?_check(Quality > 0, ?ERR_ESCORT_HAVE_NOT_ESCORT),
	?_check(EndTime == 0, ?ERR_ESCORT_HAVE_NOT_ESCORT),
	IsDouble = case activity:is_start(10101) orelse activity:is_start(10102) of
		true -> 1;
		false -> 0
	end,
	EndTime2 = ut_time:seconds() + Duration,
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	RoleEscort2 = RoleEscort#role_escort{
		  end_time  = EndTime2
		, is_double = IsDouble
		, level     = Level
	},
	%增加过期处理
	role_timer:rep_task({RoleId, ?MODULE, expire}, Duration, ?MODULE, expire),
	role_data:set(RoleEscort2),
	role_count:add_times(?ROLE_COUNT_ESCORT_COUNT),
	%添加到护送列表
	%escort_server:add_escort(RoleEscort2),
	Buff2 = lists:nth(Quality, Buff),
	buff:add(Buff2, RoleSt),
	?ucast(get_escort_message(RoleEscort2)),
	NewRoleSt = RoleSt#role_st{state=?_bis(State, ?ROLE_STATE_ESCORT)},
	activity:is_start(10101) andalso activity_stat:join(RoleSt#role_st.role, 10101),
	activity:is_start(10102) andalso activity_stat:join(RoleSt#role_st.role, 10102),
	log_api:plat_stat(?PLAY_STAT_ESCORT, ?PLAY_OP_PART, 1, RoleSt),
	{ok, #m_escort_start_toc{}, NewRoleSt};

%获取护送信息
handle(?ESCORT_INFO, _Tos, RoleSt=#role_st{state=State})->
	RoleSt2 = case check_expire(RoleSt) of
		true  -> RoleSt#role_st{state=?_bic(State, ?ROLE_STATE_ESCORT)};
		false -> RoleSt#role_st{state=?_bis(State, ?ROLE_STATE_ESCORT)};
		_     -> RoleSt
	end,
	RoleEscort = role_data:get(?DB_ROLE_ESCORT),
	{ok, get_escort_message(RoleEscort), RoleSt2};

%获取护送列表
% handle(?ESCORT_LIST, _Tos, RoleSt)->
% 	#role_st{role=RoleId} = RoleSt,
% 	RobCount = role_count:get_times(?ROLE_COUNT_ESCORT_ROB),
% 	#cfg_escort{robcount=Rob, max_quality=MaxQuality} = cfg_escort:find(1),
% 	?_check(RobCount < Rob, ?ERR_GAME_BAD_ARGS),
% 	EscortList = escort_server:get_escort_list(RoleId),
% 	EscortList2 = [#p_escort{
% 		  role    = role:get_base(RoleEscort#role_escort.id)
% 		, quality = RoleEscort#role_escort.quality
% 		, level   = RoleEscort#role_escort.level
% 		} || RoleEscort <- EscortList],
% 	{ok, #m_escort_list_toc{escorts=EscortList2}, RoleSt};

%获取位置
% handle(?ESCORT_GET_POST, Tos, RoleSt)->
% 	#role_st{role=RoleId} = RoleSt,
% 	#m_escort_get_pos_tos{role_id=RobbedId} = Tos,
% 	?_check(online_server:is_online(RobbedId), ?ERR_ROLE_OFFLINE),
% 	role:route(RobbedId, escort_handler, Fun, Args)
% 	;

% %劫掠
% handle(?ESCORT_ROB, Tos, RoleSt)->
% 	#m_escort_rob_tos{role_id=RobbedId} = Tos,
% 	Escort = escort_server:get_escort(RobbedId),
% 	?_check(Escort /= ?nil, ?ERR_GAME_BAD_ARGS),
% 	?_check(online_server:is_online(RobbedId), ?ERR_ROLE_OFFLINE),
% 	#role_escort{quality=Quality,end_time=EndTime} = Escort,
% 	?_check(Quality > 0, ?ERR_GAME_BAD_ARGS),
% 	?_check(EndTime >= ut_time:seconds(), ?ERR_GAME_BAD_ARGS),
% 	%todo检查2人的距离
% 	%todo,传送进战场
% 	;

%提交护送
handle(?ESCORT_FINISH, Tos, RoleSt)->
	#m_escort_finish_tos{progress=Progress} = Tos,
	#role_st{role=RoleId, scene=SceneID,coord=Coord} = RoleSt,
	RoleEscort = role_data:get(?DB_ROLE_ESCORT),
	#role_escort{quality=Quality, end_time=EndTime, level=Level, progress=Progress2} = RoleEscort,
	?_check(Quality > 0, ?ERR_ESCORT_HAVE_NOT_ESCORT),
	?_check(EndTime >= ut_time:seconds(), ?ERR_ESCORT_HAVE_NOT_ESCORT),
	#cfg_escort_road{second=Second,end_npc=EndNpc} = cfg_escort_road:find(1),
	{{RoleEscort2, Gain}, NewRoleSt}= case Progress of
		1 ->
			?_check(Progress2 == 0, ?ERR_ESCORT_PROGRESS_WRONG),
			%检查是否在npc点
			?_check(check_pos(Coord, SceneID, Second), ?ERR_SCENE_NPC_TOO_FAR),
			{middle_finish(RoleEscort, RoleSt), RoleSt};
		2 ->
			?_check(Progress2 == 1, ?ERR_ESCORT_PROGRESS_WRONG),
			%检查是否在npc点
			?_check(check_pos(Coord, SceneID, EndNpc), ?ERR_SCENE_NPC_TOO_FAR),
			{escort_finish(1, RoleEscort, Quality, Level, RoleSt), RoleSt#role_st{state=?ROLE_STATE_NORMAL}};
		_ ->
			throw(?err(?ERR_ESCORT_PROGRESS_WRONG))
	end,
	role_data:set(RoleEscort2),
	%escort_server:delete_escort(RoleId),
	?_if(Progress == 2, role_timer:del_task({RoleId, ?MODULE, expire})),
	{ok, #m_escort_finish_toc{result=1,progress=Progress,rewards=Gain}, NewRoleSt}.

%请求支援
% apply_support({ApplyRoleId, Quality, Guild}, RoleSt)->
% 	#role_st{name=Name,role=RoleId, guild=Guild2} = RoleSt,
% 	case Guild == Guild2 of
% 		true  -> ignor;
% 		false -> ?notify(ApplyRoleId, ?MSG_ESCORT_NOT_SAME_GUILD)
% 	end,
% 	SupportCount = role_count:get_times(?ROLE_COUNT_ESCORT_SUPP),
% 	#cfg_escort{support=Support} = cfg_escort:find(1),
% 	case SupportCount < Support of
% 		true ->
% 			escort_server:add_apply(ApplyRoleId, RoleId),
% 			?ucast(#m_escort_request_support_toc{
% 					  sender = role:get_base(ApplyRoleId)
% 					, quality = Quality
% 				});
% 		false ->
% 			?notify(ApplyRoleId, ?MSG_ESCORT_SUPPORT_MAX, [Name])
% 	end,
% 	?ucast(ApplyRoleId, #m_escort_support_toc{role_id=RoleId}).

% %同意支援
% accept_apply({AcceptRoleId, AcceptName}, RoleSt)->
% 	#role_st{name=Name, role=RoleId} = RoleSt,
% 	RoleEscort = #role_escort{support=Support} = role_data:get(?DB_ROLE_ESCORT),
% 	case Support > 0 of
% 		true ->
% 			?notify(AcceptRoleId, ?MSG_ESCORT_HAVE_SUPPORT, [Name]);
% 		false ->
% 			RoleEscort2 = RoleEscort#role_escort{support=AcceptRoleId},
% 			role_data:set(RoleEscort2),
% 			?notify(RoleId, ?MSG_ESCORT_ACCEPT_SUPPORT, [AcceptName]),
% 			?ucast(get_escort_message(RoleEscort2))
% 	end.


%过期
expire({_, _, _}, RoleSt)->
	RoleEscort = role_data:get(?DB_ROLE_ESCORT),
	#role_escort{quality=Quality, level=Level} = RoleEscort,
	{RoleEscort2, Gain}= escort_finish(0, RoleEscort, Quality, Level, RoleSt),
	role_data:set(RoleEscort2),
	?ucast(#m_escort_finish_toc{result=0, rewards=Gain}),
	{ok, RoleSt#role_st{state=?ROLE_STATE_NORMAL}}.


post_reset(_DoW, _Hour, RoleSt)->
	EscortCount = role_count:get_times(?ROLE_COUNT_ESCORT_COUNT),
	?ucast(#m_escort_count_toc{escort_count=EscortCount}).

% hook_login(RoleSt)->
% 	RoleEscort = role_data:get(?DB_ROLE_ESCORT),
% 	#role_escort{quality=Quality, end_time=EndTime} = RoleEscort,
% 	case Quality > 0 andalso EndTime > ut_time:seconds() of
% 		true  ->
% 			#cfg_escort{buff=Buff} = cfg_escort:find(1),
% 			Buff2 = lists:nth(Quality, Buff),
% 			buff:add(Buff2, RoleSt);
% 		false ->
% 			ignore
% 	end.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%刷新品质
fresh_quality(OldQuality, FreshCount, RoleSt)->
	#cfg_escort{
		  show    = Show
		, fresh   = Fresh
		, refresh = FreeCount
		, price   = Cost
		} = cfg_escort:find(1),
	Quality2 = case OldQuality == 0 of
		true ->
			ut_rand:weight(Show);
		false->
			case FreshCount >= FreeCount of
				true->
					role_bag:cost(Cost, ?LOG_ESCORT_REFRESH, RoleSt);
				false->
					ignor
			end,
			Quality = ut_rand:weight(Fresh),
			role_count:add_times(?ROLE_COUNT_ESCORT_FRESH),
			Quality
	end,
	Quality2.

%检查位置
check_poses(_Coord, _SceneID, []) ->
	false;
check_poses(Coord, SceneID, [NpcId|NpcIds])->
	case check_pos(Coord, SceneID, NpcId) of
		true  -> true;
		false -> check_poses(Coord, SceneID, NpcIds)
	end.

check_pos(Coord, SceneID, NpcId)->
	Npcs = scene_config:npcs(SceneID),
	case lists:keyfind(NpcId, 1, Npcs) of
        false ->
            false;
        {_, Coord2} ->
            scene_util:is_nearby(Coord, Coord2)
    end.

%中间点完成
middle_finish(RoleEscort, RoleSt)->
	#cfg_escort{random=Random} = cfg_escort:find(1),
	Gain = ut_rand:weight(Random, 1),
	role_bag:gain(Gain, ?LOG_ESCORT_REWARD, RoleSt),
	{RoleEscort#role_escort{progress=1}, maps:from_list(Gain)}.

%护送完成
escort_finish(Result, RoleEscort, Quality, Level, RoleSt)->
	#role_escort{is_double=IsDouble} = RoleEscort,
	CfgEscortProduct = cfg_escort_product:find(Quality, Level),
	?_check(CfgEscortProduct /= ?nil, ?ERR_ESCORT_PRODUCT_NO_EXIST),
	#cfg_escort_product{complete=Gain, failure=Gain2} = CfgEscortProduct,
	NewGain = case Result == 1 of
		true  -> Gain;
		false -> Gain2
	end,
	NewGain2 = case IsDouble == 1 of
		true  -> [ {K, V*2} || {K, V} <- NewGain ];
		false -> NewGain
	end,
	role_bag:gain(NewGain2, ?LOG_ESCORT_REWARD, RoleSt),
	#cfg_escort{buff=Buff} = cfg_escort:find(1),
	Buff2 = lists:nth(Quality, Buff),
	buff:del(Buff2, RoleSt),
	role_event:event(?EVENT_ESCORT, {Quality, IsDouble}),
	{RoleEscort#role_escort{quality=0,end_time=0,level=0,progress=0,is_double=0}, maps:from_list(NewGain2)}.

%检查是否过期
check_expire(RoleSt)->
	#role_st{role=RoleId} = RoleSt,
	RoleEscort = role_data:get(?DB_ROLE_ESCORT),
	#role_escort{quality=Quality, end_time=EndTime, level=Level} = RoleEscort,
	case Quality > 0 andalso EndTime > 0 of
		true ->
			case EndTime =< ut_time:seconds() of
				true ->
					{RoleEscort2, Gain}= escort_finish(0, RoleEscort, Quality, Level, RoleSt),
					role_data:set(RoleEscort2),
					?ucast(#m_escort_finish_toc{result=0, rewards=Gain}),
					true;
				false ->
					Duration = EndTime - ut_time:seconds(),
					role_timer:rep_task({RoleId, ?MODULE, expire}, Duration, ?MODULE, expire),
					false
			end;
		false ->
			ignore
	end.

%检查支援次数
% check_support_count()->
% 	SupportCount = role_count:get_times(?ROLE_COUNT_ESCORT_SUPP),
% 	#cfg_escort{support=Support} = cfg_escort:find(1),
% 	?_check(SupportCount < Support, ?ERR_GAME_BAD_ARGS).

%检查帮会
% check_guild(RoleId, RoleId2)->
% 	#role_cache{guild=Guild} = role:get_cache(RoleId),
% 	#role_cache{guild=Guild2} = role:get_cache(RoleId2),
% 	?_check(Guild==Guild2, ?ERR_GAME_BAD_ARGS).


% new_escort(RoleId, Level, Quality, Support, Progress, EndTime)->
% 	#escort{
% 		  id       = RoleId
% 		, quality  = Quality
% 		, support  = Support
% 		, progress = Progress
% 		, end_time = EndTime
% 		, level    = Level
% 	}.

get_escort_message(RoleEscort)->
	#m_escort_info_toc{
		  quality   = RoleEscort#role_escort.quality
		%, supporter = role:get_base(RoleEscort#role_escort.support)
		, progress  = RoleEscort#role_escort.progress
		, end_time  = RoleEscort#role_escort.end_time
		, level     = RoleEscort#role_escort.level
		, is_double = RoleEscort#role_escort.is_double
		, escort_count = role_count:get_times(?ROLE_COUNT_ESCORT_COUNT)
		, refresh_count = role_count:get_times(?ROLE_COUNT_ESCORT_FRESH)
	}.

