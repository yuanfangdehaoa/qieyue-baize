%% @author rong
%% @doc
-module(marquee_manager).

-behaviour(gen_server).

-include_lib("stdlib/include/ms_transform.hrl").
-include("game.hrl").
-include("marquee.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("table.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0, add/1, del/1, add/2, get/1]).

-define(SERVER, ?MODULE).
-define(ETS_MARQUEE, ets_marquee).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

add(Marquee) ->
    gen_server:cast(?SERVER, {add, Marquee}).

add(ID, RoleSt) ->
    #role_st{user=User} = RoleSt,
    #game_user{gamechan=GameChan} = User,
    case ets:lookup(?ETS_MARQUEE, ID) of
        [Marquee] ->
            case lists:member(GameChan, Marquee#r_marquee.gcids) of
                true ->
                    ?ucast(#m_game_marquee_update_toc{add=#p_marquee{
                        id         = Marquee#r_marquee.id,
                        type       = Marquee#r_marquee.type,
                        start_time = Marquee#r_marquee.start_time,
                        end_time   = Marquee#r_marquee.end_time,
                        content    = Marquee#r_marquee.content,
                        interval   = Marquee#r_marquee.interval,
                        ext        = Marquee#r_marquee.ext
                    }});
                false ->
                    ignore
            end;
        _ ->
            ignore
    end.

del(ID) ->
    gen_server:cast(?SERVER, {del, ID}).

get(GameChan) ->
    Now = ut_time:seconds(),
    MS = ets:fun2ms(fun(#r_marquee{end_time=EndTime} = E) when
        EndTime > Now -> E end),
    List0 = ets:select(?ETS_MARQUEE, MS),
    lists:filtermap(fun(Marquee) ->
        case lists:member(GameChan, Marquee#r_marquee.gcids) of
            true ->
                {true, #p_marquee{
                    id         = Marquee#r_marquee.id,
                    type       = Marquee#r_marquee.type,
                    start_time = Marquee#r_marquee.start_time,
                    end_time   = Marquee#r_marquee.end_time,
                    content    = Marquee#r_marquee.content,
                    interval   = Marquee#r_marquee.interval,
                    ext        = Marquee#r_marquee.ext
                }};
            false ->
                false
        end
    end, List0).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    ets:new(?ETS_MARQUEE, [named_table, {keypos, #r_marquee.id}]),
    {ok, undefined}.

handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast({add, Marquee}, State) ->
    ets:insert(?ETS_MARQUEE, Marquee),
    game_pool:bc_to_role(online_server:get_roles(),
        {route, ?MODULE, add, Marquee#r_marquee.id}),
    {noreply, State};

handle_cast({del, ID}, State) ->
    ets:delete(?ETS_MARQUEE, ID),
    ?bcast(#m_game_marquee_update_toc{del=ID}),
    {noreply, State};

handle_cast(started, State) ->
    case web_request:get("/api/server/marquee", #{"sid"=>game_env:get_suid()}) of
        {ok, Resp} ->
            Marquees = jiffy:decode(Resp, [return_maps]),
            [begin
                ets:insert(?ETS_MARQUEE, #r_marquee{
                    id         = ut_conv:to_integer(maps:get(<<"id">>, Marquee)),
                    start_time = ut_conv:to_integer(maps:get(<<"start_time">>, Marquee)),
                    end_time   = ut_conv:to_integer(maps:get(<<"end_time">>, Marquee)),
                    content    = ut_conv:to_list(maps:get(<<"content">>, Marquee)),
                    interval   = ut_conv:to_integer(maps:get(<<"interval">>, Marquee)),
                    gcids      = [ut_conv:to_list(GC) || GC <- maps:get(<<"gcids">>, Marquee)],
                    type       = 0
                })
            end || Marquee <- Marquees];
        Error ->
            ?fatal("marquee error ~p", [Error])
    end,
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
