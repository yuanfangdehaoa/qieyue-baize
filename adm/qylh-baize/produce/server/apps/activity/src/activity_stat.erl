%% @author rong
%% @doc
-module(activity_stat).

-behaviour(gen_server).

-include("game.hrl").
-include("role.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).
-export([hook_login/1, hook_start/1, hook_stop/1, join/2]).

-define(SERVER, ?MODULE).

-record(act_stat, {id, roles = #{}}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

hook_login(#role_st{role=RoleID}) ->
    gen_server:cast(?SERVER, {login, RoleID}).

hook_start(ActID) ->
    gen_server:cast(?SERVER, {activity_start, ActID}).

hook_stop(ActID) ->
    gen_server:cast(?SERVER, {activity_stop, ActID}).

join(RoleID, ActID) ->
    gen_server:cast(?SERVER, {join, RoleID, ActID}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    {ok, undefined}.

handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

do_handle_cast({login, RoleID}, State) ->
    lists:foreach(fun(ActID) ->
        case get_stat(ActID) of
            ?nil -> ignore;
            Stat ->
                case maps:get(RoleID, Stat#act_stat.roles, ?nil) of
                    ?nil ->
                        Roles = maps:put(RoleID, 0, Stat#act_stat.roles),
                        set_stat(Stat#act_stat{roles=Roles});
                    _ ->
                        ignore
                end
        end
    end, all_stat()),
    {noreply, State};

do_handle_cast({activity_start, ActID}, State) ->
    Roles = lists:foldl(fun(RoleID, Acc) ->
        maps:put(RoleID, 0, Acc)
    end, #{}, online_server:get_roles()),
    set_stat(#act_stat{id=ActID, roles=Roles}),
    {noreply, State};

do_handle_cast({activity_stop, ActID}, State) ->
    case get_stat(ActID) of
        ?nil -> ignore;
        Stat ->
            Online = maps:size(Stat#act_stat.roles),
            Join = lists:sum(maps:values(Stat#act_stat.roles)),
            log_api:log_activity(ActID, Online, Join),
            del_stat(ActID)
    end,
    {noreply, State};

do_handle_cast({join, RoleID, ActID}, State) ->
    case get_stat(ActID) of
        ?nil -> ignore;
        Stat ->
            Roles = maps:put(RoleID, 1, Stat#act_stat.roles),
            set_stat(Stat#act_stat{roles=Roles})
    end,
    {noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.

all_stat() ->
    case erlang:get(all_stat) of
        ?nil -> [];
        All -> All
    end.

get_stat(ActID) ->
    erlang:get({stat, ActID}).

set_stat(Stat) ->
    erlang:put({stat, Stat#act_stat.id}, Stat).

del_stat(ActID) ->
    erlang:erase({stat, ActID}).
