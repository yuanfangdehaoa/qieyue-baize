%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(world_level).

-behaviour(gen_server).

-include("game.hrl").
-include("ranking.hrl").
-include("enum.hrl").
-include("table.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([get_level/0]).
-export([exp_coef/1]).

-define(SERVER, ?MODULE).

-record(state, {init=false}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_level() ->
	mochiglobal:get(world_level).

exp_coef(RoleLv) ->
	case RoleLv =< 120 of
		true  -> 0;
		false -> cfg_world_level:find(RoleLv-get_level())
	end.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	{ok, #state{init=false}}.


handle_call(_Request, _From, State) ->
	{reply, {error, unknown_call}, State}.



handle_cast(started, State) ->
	case State#state.init of
		true  ->
			{noreply, State};
		false ->
			loop_update(),
			mochiglobal:put(world_level, calc_world_level()),
			gen_server:cast(cluster_local, started),
			gen_server:cast(boss_server, started),
			{noreply, State#state{init=true}}
	end;

handle_cast(_Msg, State) ->
	{noreply, State}.


handle_info(update, State) ->
	loop_update(),
	mochiglobal:put(world_level, calc_world_level()),
	{noreply, State};

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
loop_update() ->
	erlang:send_after(timer:minutes(10), self(), update).

calc_world_level() ->
	case game_env:get_type() of
		?SERVER_TYPE_LOCAL ->
			RankList = rank:get_toplist(?RANK_ID_LEVEL, 10),
			case RankList == [] of
				true  ->
					1;
				false ->
					Levels = [Lv || #rankitem{sort=Lv} <- RankList],
					lists:sum(Levels) div length(Levels)
			end;
		?SERVER_TYPE_CROSS ->
			Nodes  = cluster:get_locals(?CROSS_RULE_24_8),
			Levels = [Lv || #cls_node{level=Lv} <- Nodes, Lv > 0],
			case Levels == [] of
				true  -> 1;
				false -> lists:sum(Levels) div length(Levels)
			end
	end.
