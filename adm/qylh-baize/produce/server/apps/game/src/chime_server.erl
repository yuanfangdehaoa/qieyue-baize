%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(chime_server).

-behaviour(gen_server).

-include("game.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).

-define(SERVER, ?MODULE).

-define(LOOP_INTERVAL, 1).

-record(state, {time}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
    process_flag(trap_exit, true),
    loop_time(),
    {ok, #state{time=ut_time:time()}}.


handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.


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
do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(loop_time, State) ->
    loop_time(),
    {H1, _M1, _} = State#state.time,
    {H2, _M2, _} = Time = ut_time:time(),
    ?_if(H1 /= H2, hook_chime(H2)),
    {noreply, State#state{time=Time}};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.


loop_time() ->
    erlang:send_after(timer:seconds(?LOOP_INTERVAL), self(), loop_time).

hook_chime(H) ->
    case cluster:is_local() of
        true ->
            rank:hook_chime(H);
        false ->
            ignore
    end,
    case cluster:is_cross() of
        true ->
            yunying_shop_manager:hook_chime(H);
        false ->
            ignore
    end,
    yunying_manager:hook_chime(H),
    wedding_manager:hook_chime(H),
    combat1v1_settle:hook_chime(H),
    combat1v1_server:hook_chime(H),
    guild_manager:hook_chime(H),
    chat_server:hook_chime(H),
    siegewar_server:hook_chime(H),
    baby_server:hook_chime(H),
    guild_crosswar:hook_chime(H).
