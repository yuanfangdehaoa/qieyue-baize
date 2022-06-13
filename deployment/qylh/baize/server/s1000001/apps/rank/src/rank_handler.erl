%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(rank_handler).

-include("game.hrl").
-include("rank.hrl").
-include("ranking.hrl").
-include("role.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 榜单列表
handle(?RANK_LIST, Tos, RoleSt) when Tos#m_rank_list_tos.id == ?RANK_ID_ARENA ->
	#role_st{role=RoleID} = RoleSt,
	#m_rank_list_tos{id=RankID, page=Page} = Tos,
	#cfg_rank{size=RankSize, page_size=PageSize0} = cfg_rank:find(RankID),
	PageSize  = ?_if(Page == 0, RankSize, PageSize0),
	{RankList, {MySort, MyData}} = arena_util:get_ranklist(RoleID),
	{Total, RankList2} = ut_misc:paginate(RankList, PageSize, max(1, Page)),
	RankList3 = [rank_util:p_ranking(Ranking) || Ranking <- RankList2],
	Mine = #p_ranking{
		rank = MySort,
		sort = MySort,
		data = MyData
	},
	?ucast(#m_rank_list_toc{
		id    = RankID,
		total = Total,
		page  = Page,
		list  = RankList3,
		mine  = Mine
	});

handle(?RANK_LIST, Tos, RoleSt) when Tos#m_rank_list_tos.id == ?RANK_ID_GUILD_GUARD ->
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	scene:route(ScenePid, guild_guard, send_ranking, RoleID);

handle(?RANK_LIST, Tos, RoleSt) ->
	#role_st{role=RoleID} = RoleSt,
	#m_rank_list_tos{id=RankID, page=Page} = Tos,
	#cfg_rank{size=RankSize, page_size=PageSize0} = cfg_rank:find(RankID),
	PageSize  = ?_if(Page == 0, RankSize, PageSize0),
	{RankList, {MySort, MyData}} = rank:get_ranklist(RankID, RoleID),
	{Total, RankList2} = ut_misc:paginate(RankList, PageSize, max(1, Page)),
	RankList3 = [rank_util:p_ranking(RankItem) || RankItem <- RankList2],
	Mine = case lists:keyfind(RoleID, #rankitem.id, RankList) of
		false   ->
			#p_ranking{
				rank = 0,
				sort = MySort,
				data = MyData
			};
		Item ->
			#p_ranking{
				rank = Item#rankitem.rank,
				sort = Item#rankitem.sort,
				data = Item#rankitem.data
			}
	end,
	?ucast(#m_rank_list_toc{
		id    = RankID,
		total = Total,
		page  = Page,
		list  = RankList3,
		mine  = Mine
	}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
