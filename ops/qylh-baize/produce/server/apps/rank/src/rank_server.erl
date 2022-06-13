%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(rank_server).

-behaviour(gen_server).

-include("game.hrl").
-include("rank.hrl").
-include("ranking.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("table.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/1]).
-export([get_ranklist/1, get_ranklist/2]).
-export([get_rank/2]).
-export([update/4]).
-export([clear/1]).
-export([load/1]).
-export([open/1]).
-export([close/1]).
-export([gm_del/2]).
-export([send_log/1]).
-export([reinit/1]).
-export([resort/1]).
-export([hook_divide/5]).

-define(SERVER, ?MODULE).

-record(state, {
	  id    % 榜单id
	, key   % 表key
	, open  % 榜单是否开启
	, timer
}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link(RankID) ->
	#cfg_rank{mode=Mode} = cfg_rank:find(RankID),
	CanStart = Mode == game_env:get_type(),
	CanStart andalso begin
		RegName = rank_util:reg_name(RankID),
		gen_server:start_link({local, RegName}, ?MODULE, {RankID}, [])
	end.

get_ranklist(RankID) ->
	gen_server:call(rank_util:reg_name(RankID), get_ranklist).

get_ranklist(RankID, RoleID) ->
	gen_server:call(rank_util:reg_name(RankID), {get_ranklist, RoleID}).

get_rank(RankID, RoleID) ->
	gen_server:call(rank_util:reg_name(RankID), {get_rank, RoleID}).

update(RankID, RoleID, Sort, Data) ->
	gen_server:cast(rank_util:reg_name(RankID), {update, RoleID, Sort, Data}).

clear(RankID) ->
	gen_server:cast(rank_util:reg_name(RankID), clear).

load(RankID) ->
	gen_server:cast(rank_util:reg_name(RankID), load).

open(RankID) ->
	gen_server:cast(rank_util:reg_name(RankID), open).

close(RankID) ->
	gen_server:cast(rank_util:reg_name(RankID), close).

gm_del(RankID, RoleID) ->
	gen_server:cast(rank_util:reg_name(RankID), {gm_del, RoleID}).

send_log(RankID) ->
	gen_server:cast(rank_util:reg_name(RankID), send_log).

reinit(RankID) ->
	gen_server:cast(rank_util:reg_name(RankID), reinit).

resort(RankID) ->
	gen_server:cast(rank_util:reg_name(RankID), resort).

%% ====== 跨服分组处理
hook_divide(LocalNode, _OldGrp, _NewGrp, OldCross, NewCross) ->
	lists:foreach(fun
		(RankID) ->
			RankRef = rank_util:reg_name(RankID),
			{ok, Data} = cluster:gen_call_node(OldCross, RankRef, {divide_old,LocalNode}),
			ok = cluster:gen_call_node(NewCross, RankRef, {divide_new,Data})
	end, cfg_rank:cross()),
	ok.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({RankID}) ->
	process_flag(trap_exit, true),
	Timer = loop_dump(),
	#cfg_rank{mode=Mode, actid=YYActID, rank_limen=RankLimen} = cfg_rank:find(RankID),
	Key = case Mode of
		?SERVER_TYPE_LOCAL ->
    		RankID;
    	?SERVER_TYPE_CROSS ->
    		{cluster_cross:get_group(?CROSS_RULE_24_8), RankID}
    end,
	load_ranklist(RankID, Key),
    ?_if(RankLimen /= [], ut_ranking:set_rank_limen(RankLimen)),
	IsOpen = case YYActID > 0 of
		true  -> yunying:is_start(YYActID);
		false -> true
	end,
	{ok, #state{id=RankID, key=Key, open=IsOpen, timer=Timer}}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, State) ->
	do_dump(State),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call(get_ranklist, _From, State) ->
	RankList = ut_ranking:get_all(State#state.id),
	{reply, RankList, State};

do_handle_call({get_ranklist, RoleID}, _From, State) ->
	RankList = ut_ranking:get_all(State#state.id),
	AllData  = do_get_alldata(),
	RoleData = maps:get(RoleID, AllData, {0, #{}}),
	{reply, {RankList, RoleData}, State};

do_handle_call({get_rank, RoleID}, _From, State) ->
	RankList = ut_ranking:get_all(State#state.id),
	Rank = case lists:keyfind(RoleID, #rankitem.id, RankList) of
		false -> 0;
		Item  -> Item#rankitem.rank
	end,
	{reply, Rank, State};

do_handle_call(copy, _From, State) ->
	RankList = ut_ranking:get_all(State#state.id),
	AllData  = do_get_alldata(),
	{reply, {ok, RankList, AllData}, State};

do_handle_call({divide_old,Node}, _From, State=#state{id=RankID}) ->
	{DelRankList, RemRankList} = lists:partition(fun
		(#rankitem{id=RoleID}) ->
			SUID = game_uid:guid2suid(RoleID),
			cluster:is_same(SUID, Node#cls_node.suid)
	end, ut_ranking:get_all(RankID)),

	{DelRankData, RemRankData} = lists:partition(fun
		({RoleID,_}) ->
			SUID = game_uid:guid2suid(RoleID),
			cluster:is_same(SUID, Node#cls_node.suid)
	end, maps:to_list(do_get_alldata())),

	#cfg_rank{size=Size, limen=Limen} = cfg_rank:find(RankID),
	ut_ranking:init(RankID, Size, Limen, ?nil, RemRankList),
	ut_ranking:resort(RankID),
	do_set_alldata(maps:from_list(RemRankData)),

	?debug("divide_old: ~p", [DelRankList]),

	Data = term_to_binary({DelRankList,maps:from_list(DelRankData)}),

	{reply, {ok,Data}, State};

do_handle_call({divide_new,Data}, _From, State=#state{id=RankID}) ->
	{AddRankList,AddRankData} = binary_to_term(Data),
	RankList = AddRankList ++ ut_ranking:get_all(RankID),
	AllData  = maps:merge(do_get_alldata(), AddRankData),
	#cfg_rank{size=Size, limen=Limen} = cfg_rank:find(RankID),
	ut_ranking:init(RankID, Size, Limen, ?nil, RankList),
	ut_ranking:resort(RankID),
	do_set_alldata(AllData),
	?debug("divide_new: ~p", [AddRankList]),
	{reply, ok, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.


do_handle_cast({update, _RoleID, _Sort, _Data}, State) when not State#state.open ->
	{noreply, State};
do_handle_cast({update, RoleID, {add,Sort}, Data}, State) ->
	AllData = do_get_alldata(),
	{OldSort, _} = maps:get(RoleID, AllData, {0, ?nil}),
	do_handle_cast({update, RoleID, OldSort+Sort, Data}, State);
do_handle_cast({update, RoleID, Sort, Data}, State) ->
	AllData  = do_get_alldata(),
	AllData2 = maps:put(RoleID, {Sort,Data}, AllData),
	do_set_alldata(AllData2),

	#cfg_rank{event=Event} = cfg_rank:find(State#state.id),
	case Event == ?EVENT_PET_TOTAL_POWER of
		true  ->
			RankList = ut_ranking:get_all(State#state.id),
			case lists:keyfind(RoleID, #rankitem.id, RankList) of
				#rankitem{sort=OldSort} when Sort =< OldSort ->
					ignore;
				_ ->
					ut_ranking:update(State#state.id, RoleID, Sort, Data)
			end;
		false ->
			ut_ranking:update(State#state.id, RoleID, Sort, Data)
	end,
	{noreply, State};

do_handle_cast(clear, State) ->
	ut_ranking:clear(State#state.id),
	do_set_alldata(#{}),
	{noreply, State};

%% 开启榜单
do_handle_cast(open, State) ->
	CfgRank = cfg_rank:find(State#state.id),
	#cfg_rank{size=Size, limen=Limen, copy=CopyID} = CfgRank,
	case CopyID > 0 andalso State#state.id /= CopyID of
		true  ->
			try
				CopyRef = rank_util:reg_name(CopyID),
				{ok, RankList, AllData} = gen_server:call(CopyRef, copy),
				RankList1 = lists:sublist(RankList, Size),
				RankList2 = [R || R <- RankList1, R#rankitem.sort >= Limen],
				ut_ranking:init(State#state.id, Size, Limen, ?nil, RankList2),
				ut_ranking:resort(State#state.id),
				do_set_alldata(AllData)
			catch Class:Reason:Stacktrace ->
				?stacktrace(Class, Reason, Stacktrace)
			end;
		false ->
			ignore
	end,
	{noreply, State#state{open=true}};

%% 关闭榜单
do_handle_cast(close, State) ->
	erlang:send_after(timer:minutes(1), self(), clear),
	{noreply, State#state{open=false}};

%% 加载榜单
do_handle_cast(load, State) ->
	load_ranklist(State#state.id, State#state.key),
	{noreply, State};

% GM剔除
do_handle_cast({gm_del, RoleID}, State) ->
	AllData  = do_get_alldata(),
	AllData2 = maps:remove(RoleID, AllData),
	do_set_alldata(AllData2),
	ut_ranking:del(State#state.id, RoleID),
	{noreply, State};

% 发送日志
do_handle_cast(send_log, State) ->
	case State#state.open of
		true ->
			RankList = ut_ranking:get_all(State#state.id),
			log_api:log_rank(State#state.id, RankList);
		false ->
			ignore
	end,
	{noreply, State};

do_handle_cast(reinit, State) ->
	RankID = State#state.id,
	#cfg_rank{size=Size, limen=Limen} = cfg_rank:find(RankID),
	case db:dirty_read(?DB_GAME_RANK, State#state.key) of
		[]  ->
			ut_ranking:init(RankID, Size, Limen, ?nil, []),
			do_set_alldata(#{});
		[#game_rank{ranklist=RankList0, alldata=AllData0}] ->
			ut_ranking:init(RankID, Size, Limen, ?nil, RankList0),
			ut_ranking:resort(RankID),
			RankList1 = ut_ranking:get_all(RankID),
			IDs = lists:map(fun(RankItem) ->
				RankItem#rankitem.id
			end, RankList1),
			AllData1 = maps:with(IDs, AllData0),
			do_set_alldata(AllData1),
			do_dump(State)
	end,
	?debug("reinit rank ~w", [RankID]),
	{noreply, State#state{open=true}};

do_handle_cast(resort, State) ->
	RankID = State#state.id,
	#cfg_rank{size=Size, limen=Limen} = cfg_rank:find(RankID),
	case db:dirty_read(?DB_GAME_RANK, State#state.key) of
		[]  ->
			ut_ranking:init(RankID, Size, Limen, ?nil, []),
			do_set_alldata(#{});
		[#game_rank{ranklist=RankList0, alldata=AllData0}] ->
			ut_ranking:init(RankID, Size, Limen, ?nil, RankList0),
			ut_ranking:resort(RankID),
			RankList1 = ut_ranking:get_all(RankID),
			IDs = lists:map(fun(RankItem) ->
				RankItem#rankitem.id
			end, RankList1),
			AllData1 = maps:with(IDs, AllData0),
			do_set_alldata(AllData1),
			do_dump(State)
	end,
	?debug("resort rank ~w", [RankID]),
	{noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(dump, State) ->
	do_dump(State),
	case State#state.open of
		true  ->
			Timer = loop_dump(),
			{noreply, State#state{timer=Timer}};
		false ->
			{noreply, State}
	end;

do_handle_info(clear, State) ->
	ut_ranking:clear(State#state.id),
	do_set_alldata(#{}),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.


load_ranklist(RankID, Key) ->
	#cfg_rank{size=Size, limen=Limen} = cfg_rank:find(RankID),
	case db:dirty_read(?DB_GAME_RANK, Key) of
		[]  ->
			ut_ranking:init(RankID, Size, Limen, ?nil, []),
			do_set_alldata(#{});
		[#game_rank{ranklist=RankList, alldata=AllData}] ->
			ut_ranking:init(RankID, Size, Limen, ?nil, RankList),
			do_set_alldata(AllData)
	end.

-define(k_alldata, k_alldata).
do_get_alldata() ->
	get(?k_alldata).

do_set_alldata(AllData) ->
	put(?k_alldata, AllData).

loop_dump() ->
	erlang:send_after(timer:minutes(15), self(), dump).

do_dump(State) ->
	db:dirty_write(?DB_GAME_RANK, #game_rank{
		id       = State#state.key,
		ranklist = ut_ranking:get_all(State#state.id),
		alldata  = do_get_alldata()
	}).
