%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%% 答题server
%%% @end
%%%=============================================================================

-module(guild_question_server).

-include("role.hrl").
-include("game.hrl").
-include("proto.hrl").
-include("guild_house.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("rank.hrl").
-include("ranking.hrl").
-include("msgno.hrl").

-behaviour(gen_server).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%% API
-export([start_link/0]).

-export([get_question/0]).
-export([start/0]).
-export([stop/0]).
-export([add_score/3]).
-export([can_answer/1]).
-export([got_exp/2]).
-export([is_got_exp/2]).

-define(SERVER, ?MODULE).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%获取题目
get_question()->
	gen_server:call(?SERVER, {get_question}).

add_score(RoleID, Name, Index)->
	gen_server:call(?SERVER, {add_score, RoleID, Name, Index}).

got_exp(RoleID, Index)->
	gen_server:call(?SERVER, {got_exp, RoleID, Index}).

is_got_exp(RoleID, Index)->
	gen_server:call(?SERVER, {is_got_exp, RoleID, Index}).

%是否可以答题
can_answer(RoleID)->
	gen_server:call(?SERVER, {can_answer, RoleID}).

%活动开始
start()->
	rank:clear_rank(?RANKID),
	supervisor:terminate_child(game_sup, ?MODULE),
	supervisor:delete_child(game_sup, ?MODULE),
	supervisor:start_child(game_sup, game_sup:child_spec(?MODULE)),
	gen_server:cast(?SERVER, init_data).

%活动结束
stop()->
	supervisor:terminate_child(game_sup, ?MODULE),
	supervisor:delete_child(game_sup, ?MODULE).
	% gen_server:cast(?SERVER, stop).


%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	{ok, #{}}.

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

do_handle_call({get_question}, _From, State)->
	{Index, Expire} = get_index(),
	Ids = get_ids(),
	Id = case Index > 0 of
		true ->
			lists:nth(Index, Ids);
		false ->
			0
	end,
	{reply, {Index, Id, Expire}, State};

do_handle_call({can_answer, RoleID}, _From, State)->
	{Index, _Expire} = get_index(),
	Index2 = get_answer(RoleID),
	Score = get_score(RoleID),
	{reply, {Index2 < Index, Score}, State};

do_handle_call({got_exp, RoleID, Index}, _From, State) ->
	set_exp(RoleID, Index),
	{reply, 0, State};

do_handle_call({is_got_exp, RoleID, Index}, _From, State) ->
	Index2 = get_exp(RoleID),
	{reply, Index2 >= Index, State};

do_handle_call({add_score, RoleID, Name, Index}, _From, State)->
	OldScore = get_score(RoleID),
	Rank = get_rank(),
	set_answer(RoleID, Index),
	MyRank = Rank + 1,
	AddScore = cfg_guild_question_score:score(MyRank),
	NewScore = OldScore + AddScore,
	set_score(RoleID, NewScore),
	set_rank(MyRank),
	case MyRank == 1 of
		true ->
			scene:bcast(?GUILD_HOUSE_SCENEID, #m_guild_question_first_toc{name=Name});
		false ->
			igore
	end,
	{reply, NewScore, State}.

%初始化数据
do_handle_cast(init_data, State)->
	%生成题目
	IdList = cfg_guild_question:ids(),
	Num = cfg_game:guild_question_num(),
	Ids = ut_rand:choose(IdList, Num, false),
	set_ids(Ids),
	set_index({0, 0}),
	next_question(60),
	{noreply, State};

do_handle_cast(stop, State)->
	{stop, normal, State};

do_handle_cast(Msg, State)->
	?error("unhandle cast: ~p", [Msg]),
	{noreply, State}.

do_handle_info(next_question, State)->
	{Index, _EndTime} = get_index(),
	Index2 = Index + 1,
	Num = cfg_game:guild_question_num(),
	case Index2 =< Num of
		true ->
			EndTime = ut_time:seconds()+20,
			set_index({Index2, EndTime}),
			Ids = get_ids(),
			Id = lists:nth(Index2, Ids),
			send_question(Id, Index2, EndTime),
			set_rank(0),
			next_question(25);
		false ->
			reward()
	end,
	{noreply, State};

do_handle_info(start_boss, State)->
	?notify(?MSG_GUILDHOUSE_BOSS_START, []),
	{noreply, State}.



%进入下一题
next_question(Sec)->
	erlang:send_after(timer:seconds(Sec), self(), next_question).



%发奖
reward()->
	RankList = rank:get_ranklist(?RANKID),
	lists:foreach(fun
			(#rankitem{id=RoleID, rank=Rank}) ->
				Gain = cfg_guild_question_reward:reward(Rank),
				case online_server:is_online(RoleID) of
					true ->
						Score = get_score(RoleID),
						role:route(RoleID, guild_house_handler, reward, {Rank, Score, Gain});
					false ->
						mail:send(RoleID, ?MAIL_GUILDHOUSE_QUESTION, Gain, [Rank])
				end,
				?_if(Rank =< 3, notify_rank(RoleID, Rank))
		end, RankList),
	rank:clear_rank(?RANKID),
	erlang:send_after(timer:seconds(40), self(), start_boss).

%广播题目
send_question(Id, Index, EndTime)->
	scene:bcast(?GUILD_HOUSE_SCENEID, #m_guild_house_question_toc{
		  id  = Id
		, num = Index
		, end_time = EndTime
	}).


%保存题目
set_ids(Ids)->
	erlang:put(?questions, Ids).

%获取题目
get_ids()->
	case erlang:get(?questions) of
		?nil -> [];
		Ids  -> Ids
	end.

%当前在第几题
set_index({Index, Expire})->
	erlang:put(?index, {Index, Expire}).

get_index()->
	erlang:get(?index).

%保存积分
set_score(RoleID, Score)->
	erlang:put(?score, Score).

get_score(RoleID)->
	case erlang:get(?score) of
		?nil -> 0;
		Score -> Score
	end.

%保存单题排名
set_rank(Rank)->
	erlang:put(?rank, Rank).

get_rank()->
	case erlang:get(?rank) of
		?nil -> 0;
		Rank -> Rank
	end.

%保存答题进度
set_answer(RoleID, Index)->
	erlang:put(?answer, Index).

get_answer(RoleID)->
	case erlang:get(?answer) of
		?nil -> 0;
		Index -> Index
	end.

set_exp(RoleID, Index)->
	erlang:put(?exp, Index).

get_exp(RoleID)->
	case erlang:get(?exp) of
		?nil -> 0;
		Index -> Index
	end.

%公告排名
notify_rank(RoleID, Rank) ->
	#p_role_base{name=RoleName} = role:get_base(RoleID),
	Score = get_score(RoleID),
	?notify(?MSG_GUILDHOUSE_RANK, [
		{role, RoleID, RoleName},
		Score,
		Rank]).


