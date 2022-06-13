%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_title).

-include("game.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("title.hrl").
-include("role.hrl").

%% API
-export([add_title/2]).
-export([expire/2]).
-export([hook_login/1]).
-export([get_attr/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

get_attr(_AttrType)->
	#role_title{titles=Titles} = role_data:get(?DB_ROLE_TITLE),
	maps:fold(fun
			(_K, #p_title{id=TitleId, etime=ETime}, Attr) ->
				case ETime == 0 orelse ETime >= ut_time:seconds() of
					true ->
						#cfg_title{attrib=Attrib}=cfg_title:find(TitleId),
						mod_attr:add(Attr, Attrib);
					false ->
						Attr
				end
		end, #{}, Titles).

hook_login(RoleSt)->
	#role_st{role=RoleId} = RoleSt,
	RoleTitle = #role_title{titles=Titles, puton_id=PutOnId} = role_data:get(?DB_ROLE_TITLE),
	Titles2 = check_expire(RoleId, Titles),
	PutOnId2 = case maps:get(PutOnId, Titles2, ?nil) of
		?nil ->
			role_figure:update_title(0, RoleSt),
			0;
		_ -> PutOnId
	end,
	role_data:set(RoleTitle#role_title{titles=Titles2, puton_id=PutOnId2}).

add_title(Id, RoleSt)->
	#role_st{role=RoleId} = RoleSt,
	RoleTitle = role_data:get(?DB_ROLE_TITLE),
	#role_title{titles=Titles} = RoleTitle,
	#cfg_title{expire=Expire} = cfg_title:find(Id),
	ETime = case Expire > 0 of
		true  ->
			ETime2 = ut_time:seconds() + Expire,
			role_timer:rep_task({RoleId, ?MODULE, Id, expire}, Expire, ?MODULE, expire),
			ETime2;
		false -> 0
	end,
	PTitle = #p_title{id=Id, etime=ETime},
	Titles2 = maps:put(Id, PTitle, Titles),
	role_data:set(RoleTitle#role_title{titles=Titles2, puton_id=Id}),
	role_figure:update_title(Id, RoleSt),
	UpTitle = #{Id=>PTitle},
	?ucast(#m_title_info_toc{titles=UpTitle, puton_id=Id}),
	role_attr:recalc(?MODULE, RoleSt).

%过期
expire({_, _, Id, _}, RoleSt)->
	RoleTitle = #role_title{titles=Titles,puton_id=PutOnId} = role_data:get(?DB_ROLE_TITLE),
	Titles2 = maps:remove(Id, Titles),
	PutOnId2 = case Id == PutOnId of
		true  ->
			role_figure:update_title(0, RoleSt),
			0;
		false -> PutOnId
	end,
	role_data:set(RoleTitle#role_title{titles=Titles2,puton_id=PutOnId2}),
	role_attr:recalc(?MODULE, RoleSt).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

%检查过期
check_expire(RoleId, Titles)->
	maps:fold(fun
			(K, PTitle=#p_title{id=Id, etime=ETime}, Maps)->
				case ETime > 0 of
					true ->
						Now = ut_time:seconds(),
						case ETime > Now of
							true->
								role_timer:rep_task({RoleId, ?MODULE, Id, expire}, ETime-Now, ?MODULE, expire),
								maps:put(K, PTitle, Maps);
							false->
								Maps
						end;
					false ->
						maps:put(K, PTitle, Maps)
				end
		end, #{}, Titles).
