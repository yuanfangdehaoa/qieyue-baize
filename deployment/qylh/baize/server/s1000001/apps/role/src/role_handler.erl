%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_handler).

-include("bag.hrl").
-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("faker.hrl").
-include("log.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 角色信息
handle(?ROLE_DETAIL, _Tos, RoleSt) ->
	?ucast(#m_role_detail_toc{role=p_role_info(RoleSt)});

%% 查看其他角色
handle(?ROLE_QUERY, Tos, RoleSt) ->
	#m_role_query_tos{role_id=RoleID} = Tos,
	case faker:is_fake(RoleID) of
		true ->
			?ucast(#m_role_query_toc{role=role:get_base(RoleID), equips=[]});
		false ->
			?_check(role:is_role(RoleID), ?ERR_ROLE_NOT_EXIST),
			?_check(RoleID /= RoleSt#role_st.role, ?ERR_ROLE_QUERY_SELF),
			case role_util:is_local(RoleID) of
				true  ->
					Keys = [{bag,?BAG_ID_EQUIP}],
					{ok, [Equips]} = role:get_data(RoleID, Keys),
					?ucast(#m_role_query_toc{
						role   = role:get_base(RoleID),
						equips = [item_util:p_item(E) || E <- maps:values(Equips)]
					});
				false ->
					{ok, Cache, Equips} = cluster_cache:get_role(RoleID),
					?ucast(#m_role_query_toc{
						role   = role:get_base(Cache),
						equips = [item_util:p_item(E) || E <- maps:values(Equips)]
					})
			end

	end;

%% 改名
handle(?ROLE_RENAME, Tos, RoleSt) ->
	#role_st{role=RoleID, spid=ScenePid} = RoleSt,
	#m_role_rename_tos{name=Name} = Tos,
	login_handler:check_name(Name),
	Cost = cfg_game:role_rename(),
	Succ = fun(Deal) ->
		#role_info{name=OldName} = Deal#deal.roleinfo,
		#role_guild{guild=Guild} = role_data:get(?DB_ROLE_GUILD),
		ok = role_manager:rename(RoleID, OldName, Name),
		?_if(Guild > 0, guild_agent:memb_rename(guild:get_ref(Guild), RoleID, Name)),
		role_marriage:rename(RoleID, Name),
		?ucast(#m_role_rename_toc{name=Name}),
		?ucast(#m_role_update_toc{upstr=#{"name"=>Name}}),
		scene:update_actor(ScenePid, RoleID, [{name, Name}]),
		[mail:send(RID, ?MAIL_ROLE_RENAME, [], [OldName, Name])
			|| RID <- friend_server:get_friend_list(RoleID)]
	end,
	role_bag:cost(Cost, ?LOG_ROLE_RENAME, Succ, RoleSt),
	RoleInfo  = role_data:get(?DB_ROLE_INFO),
	RoleInfo2 = RoleInfo#role_info{name=Name},
	role_data:set(RoleInfo2),
	db:dirty_write(?DB_ROLE_INFO, RoleInfo2),
	{ok, RoleSt#role_st{name=Name}}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
p_role_info(RoleSt) ->
	RoleInfo = role_data:get(?DB_ROLE_INFO),
	RoleAttr = role_data:get(?DB_ROLE_ATTR),
	RoleVip  = role_data:get(?DB_ROLE_VIP),
	#role_bag{money=Money} = role_data:get(?DB_ROLE_BAG),
	{Marry, MName, MType} = role_marriage:get_info(RoleSt#role_st.role),
	#p_role_info{
		id      = RoleSt#role_st.role,
		name    = RoleInfo#role_info.name,
		career  = RoleInfo#role_info.career,
		gender  = RoleInfo#role_info.gender,
		level   = RoleInfo#role_info.level,
		exp     = RoleInfo#role_info.exp,
		power   = role_util:get_power(),
		figure  = RoleInfo#role_info.figure,
		viptype = RoleVip#role_vip.type,
		viplv   = RoleVip#role_vip.level,
		vipexp  = RoleVip#role_vip.exp,
		vipend  = RoleVip#role_vip.etime,
		gold    = maps:get(?ITEM_GOLD, Money, 0),
		bgold   = maps:get(?ITEM_BGOLD, Money, 0),
		coin    = maps:get(?ITEM_COIN, Money, 0),
		bcoin   = maps:get(?ITEM_BCOIN, Money, 0),
		pkmode  = RoleInfo#role_info.pkmode,
		attr    = mod_attr:p_attr(RoleAttr#role_attr.attr),
		buffs   = [B#p_buff{attrs=[]} || B <- maps:values(RoleAttr#role_attr.buffs)],
		guild   = RoleSt#role_st.guild,
		gname   = guild:get_name(RoleSt#role_st.guild),
		scene   = RoleSt#role_st.scene,
		suid    = game_env:get_suid(),
		wake    = RoleInfo#role_info.wake,
		ctime   = RoleInfo#role_info.ctime,
		marry   = Marry,
		mname   = MName,
		mtype   = MType,
		money   = Money,
		icon    = RoleInfo#role_info.icon
	}.
