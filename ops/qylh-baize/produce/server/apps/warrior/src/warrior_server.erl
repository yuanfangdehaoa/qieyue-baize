%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(warrior_server).

-include("warrior.hrl").
-include("game.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("ranking.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("msgno.hrl").
-include("activity.hrl").
-include("role.hrl").

-behaviour(gen_server).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%% API
-export([start_link/0]).

-export([hook_start/1]).
-export([hook_stop/1]).
-export([get_kill/1]).
-export([set_kill/2]).
-export([is_floor_gain/2]).
-export([floor_gain/2]).
-export([get_entry/3]).
-export([get_c_kill/1]).
-export([set_c_kill/2]).
-export([update_rank/4]).
-export([get_ranklist/2]).
-export([get_ranklist_cross/2]).
-export([set_room/3]).

-define(SERVER, ?MODULE).


%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_entry(ActID, _SceneID, RoleSt)->
	#cfg_activity{type=Type} = cfg_activity:find(ActID),
	#role_st{role=RoleID} = RoleSt,
	Opts = #{bctype => ?BCTYPE_SCENE},
	case get_room(Type, RoleID) of
		{SceneID, Room} -> Opts#{scene=>SceneID, room=>Room};
		_               -> Opts#{room =>1}
	end.


%活动开始
hook_start(ActID)->
	?debug("hook_start ~p", [ActID]),
	supervisor:start_child(game_sup, game_sup:child_spec(?MODULE)),
	create_scenes(ActID),
	?_if(cluster:is_local(), ?notify(?MSG_WARRIOR_START)).

%活动结束
hook_stop(ActID)->
	?debug("hook_stop:~p", [ActID]),
	over(ActID).

set_room(RoleID, SceneID, Room)->
	gen_server:cast(?SERVER, {set_room, RoleID, SceneID, Room}).

get_room(Type, RoleID)->
	Req = {get_room, RoleID},
	case Type of
		?ACTIVITY_TYPE_LOCAL -> gen_server:call(?SERVER, Req);
		?ACTIVITY_TYPE_CROSS -> cluster:gen_call_cross(?CROSS_RULE_24_8, ?SERVER, Req)
	end.

%获取击杀数
get_kill(RoleID)->
	gen_server:call(?SERVER, {get_kill, RoleID}).

set_kill(RoleID, Num)->
	gen_server:cast(?SERVER, {set_kill, RoleID, Num}).

%获取连杀
get_c_kill(RoleID)->
	gen_server:call(?SERVER, {get_c_kill, RoleID}).

set_c_kill(RoleID, Num)->
	gen_server:cast(?SERVER, {set_c_kill, RoleID, Num}).

%是否已获得层奖励
is_floor_gain(RoleID, SceneID)->
	gen_server:call(?SERVER, {is_floor_gain, RoleID, SceneID}).

%保存已领奖励
floor_gain(RoleID, SceneID)->
	gen_server:cast(?SERVER, {floor_gain, RoleID, SceneID}).

%更新排行榜
update_rank(LineID, RoleID, Score, Data)->
	gen_server:cast(?SERVER, {update_rank, RoleID, LineID, Score, Data}).


%获取排行榜
get_ranklist(LineID, RoleID)->
	gen_server:call(?SERVER, {get_ranklist, LineID, RoleID}).

%获取排行榜
get_ranklist_cross(LineID, RoleID)->
	Req = {get_ranklist, LineID, RoleID},
	cluster:gen_call_cross(?CROSS_RULE_24_8, ?SERVER, Req).

over(ActID)->
	gen_server:cast(?SERVER, {over, ActID}).



%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	{ok, undefined}.

handle_call(Request, From, State) ->
	?try_handle_call(do_handle_call(Request, From, State), State).

handle_cast(Msg, State) ->
	?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
	?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({get_kill, RoleID}, _From, State)->
	{reply, get_data(RoleID), State};

do_handle_call({get_c_kill, RoleID}, _From, State)->
	{reply, get_ckill(RoleID), State};


do_handle_call({get_ranklist, LineID, RoleID}, _From, State)->
	RankList = get_ranking(LineID, RoleID),
	RankItem = lists:keyfind(RoleID, #rankitem.id, RankList),
	{Sort, Data} = case RankItem of
		false    -> {0, #{}};
		RankItem -> {RankItem#rankitem.sort, RankItem#rankitem.data}
	end,
	{reply, {RankList, {Sort, Data}}, State};

do_handle_call({get_room, RoleID}, _From, State)->
	R = case erlang:get(?last_scene) of
		{SceneID, Room} -> {SceneID, Room};
		_               -> ?nil
	end,
	{reply, R, State};

do_handle_call({is_floor_gain, RoleID, SceneID}, _From, State)->
	{reply, get_floor_gain(RoleID, SceneID), State}.


do_handle_cast({over, ActID}, State)->
	?debug("do_handle_cast in over"),
	in_over(ActID),
	{noreply, State};

do_handle_cast({set_kill, RoleID, Num}, State)->
	set_data(RoleID, Num),
	{noreply, State};

do_handle_cast({set_c_kill, RoleID, Num}, State)->
	set_ckill(RoleID, Num),
	{noreply, State};

%更新榜单
do_handle_cast({update_rank, RoleID, LineID, Score, Data}, State)->
	RankList = get_ranking(LineID, RoleID),
	RankItem = lists:keyfind(RoleID, #rankitem.id, RankList),
	RankItem2 = case RankItem of
		false    -> #rankitem{id=RoleID, sort=Score, data=Data, time=ut_time:seconds()};
		RankItem -> RankItem#rankitem{sort=Score, data=Data}
	end,
	RankList2 = lists:keystore(RoleID, #rankitem.id, RankList, RankItem2),
	RankList3 = sorting(RankList2),
	save_ranking(LineID, RoleID, RankList3),
	{noreply, State};

%设置当前所在场景
do_handle_cast({set_room, RoleID, SceneID, Room}, State)->
	erlang:put(?last_scene, {SceneID, Room}),
	{noreply, State};

do_handle_cast({floor_gain, RoleID, SceneID}, State)->
	set_floor_gain(RoleID, SceneID),
	{noreply, State}.


do_handle_info({stop_server, ActID}, State)->
	?debug("ActID ~p", [ActID]),
	Floors = cfg_warrior_floor:floors(),
	lists:foreach(fun
			(Floor) ->
				#cfg_warrior_floor{scene_id=SceneIDList} = cfg_warrior_floor:find(Floor),
				{_, SceneID} = lists:keyfind(ActID, 1, SceneIDList),
				scene:destroy(SceneID, Floor)
		end, Floors),
	{stop, normal, State}.



%结算
in_over(ActID)->
	Maps = get_rank_map(),
	maps:fold(fun
			(_K, RankList, Acc) ->
				reward(RankList),
				Acc
		end, 0, Maps),
	erlang:send_after(timer:seconds(30), self(), {stop_server, ActID}).



reward(RankList)->
	lists:foreach(fun
			(#rankitem{id=RoleID, rank=Rank, sort=Score, data=Data}) ->
				{Gain, IsCross} = case cluster:is_local() of
					true  -> {cfg_warrior_reward:gain(Rank), 0};
					false -> {cfg_warrior_reward:cross_gain(Rank), 1}
				end,
				mail:send(RoleID, ?MAIL_WARRIOR_RANK, Gain, [Score, Rank]),
				Floor = maps:get("floor", Data, 1),
				?ucast(RoleID, #m_warrior_end_toc{rank=Rank, score=Score, floor=Floor, is_cross=IsCross})
		end, RankList).

%保存
set_floor_gain(RoleID, SceneID)->
	erlang:put(?floor_gain, true).

get_floor_gain(RoleID, SceneID)->
	IsGain = erlang:get(?floor_gain),
	case IsGain of
		true -> true;
		_    -> false
	end.


%保存击杀数
set_data(RoleID, Num)->
	erlang:put(?kill_num, Num).

%获取击杀数
get_data(RoleID)->
	Num = erlang:get(?kill_num),
	case Num of
		?nil -> 0;
		_    -> Num
	end.

%保存连杀数
set_ckill(RoleID, Num)->
	erlang:put(?ckill_num, Num).

%获取连杀数
get_ckill(RoleID)->
	Num = erlang:get(?ckill_num),
	case Num of
		?nil -> 0;
		_    -> Num
	end.


get_rank_map()->
	case erlang:get({?MODULE, rank}) of
		?nil ->	#{};
		Map  ->	Map
	end.

get_ranking(Line, RoleID)->
	Line2 = get_line(RoleID, Line),
	Map = get_rank_map(),
	maps:get(Line2, Map, []).


save_ranking(Line, RoleID, RankList)->
	Line2 = get_line(RoleID, Line),
	Map = get_rank_map(),
	Map2 = maps:put(Line2, RankList, Map),
	erlang:put({?MODULE, rank}, Map2).


get_line(RoleID, Line)->
	case erlang:get({?MODULE, RoleID}) of
		?nil    ->
			erlang:put({?MODULE, RoleID}, Line),
			Line;
		OldLine ->
			OldLine
	end.


sorter(RankList) ->
	lists:sort(fun
			(Item1, Item2) ->
				case Item1#rankitem.sort == Item2#rankitem.sort of
					true  -> Item1#rankitem.time > Item2#rankitem.time;
					false -> Item1#rankitem.sort < Item2#rankitem.sort
				end
		end, RankList).

%排序
sorting(RankList)->
	RankList1 = sorter(RankList),
	sorting2(RankList1, length(RankList1), []).

sorting2([Item | T], Rank, RankList) ->
	sorting2(T, Rank-1, [Item#rankitem{rank=Rank} | RankList]);
sorting2([], _Rank, RankList) ->
	RankList.


create_scenes(ActID)->
	Floors = cfg_warrior_floor:floors(),
	lists:foreach(fun
			(Floor) ->
				#cfg_warrior_floor{scene_id=SceneIDList} = cfg_warrior_floor:find(Floor),
				{_, SceneID} = lists:keyfind(ActID, 1, SceneIDList),
				?debug("sceneid ~p ~p", [SceneID, Floor]),
				scene:create(SceneID, Floor, #{etime=>activity:etime(ActID), floor=>Floor, act_id=>ActID})
		end, Floors).


