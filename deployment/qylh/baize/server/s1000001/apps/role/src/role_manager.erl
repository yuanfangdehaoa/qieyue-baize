%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_manager).

-behaviour(gen_server).

-include("game.hrl").
-include("table.hrl").
-include("errno.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([create/1]).
-export([get_roleid/1]).
-export([gen_name/1]).
-export([rename/3]).
-export([get_name/1]).
-export([is_local/1]).

-define(SERVER, ?MODULE).
-define(ETS_LOCAL_ROLE, ets_local_role).

-record(state, {id}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

create(Name) ->
    gen_server:call(?SERVER, {create, Name}).

get_roleid(Name) ->
    gen_server:call(?SERVER, {get_roleid, Name}).

gen_name(Gender) ->
    gen_server:call(?SERVER, {gen_name, Gender}).

rename(RoleID, OldName, Name) ->
    gen_server:call(?SERVER, {rename, RoleID, OldName, Name}).

is_local(RoleID) ->
    ets:member(?ETS_LOCAL_ROLE, RoleID).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
    process_flag(trap_exit, true),
    ets:new(?ETS_LOCAL_ROLE, [named_table]),
    Roles = db:dirty_match_all(?DB_ROLE_INFO),
    lists:foreach(fun
        (RoleInfo) ->
            #role_info{id=ID, name=Name} = RoleInfo,
            do_set_roleid(Name, ID)
    end, Roles),
    RoleID = case Roles == [] of
        true  ->
            game_uid:gen_guid();
        false ->
            case game_misc:read(role_id) of
                ?nil ->
                    ?info("game_misc read role id undefined"),
                    MaxRoleId = lists:foldl(fun(#role_info{id = RoleID},Acc)-> erlang:max(RoleID,Acc) end,0,Roles),
                    MaxRoleID2 = MaxRoleId + 1,
                    game_misc:write(role_id,MaxRoleID2),
                    MaxRoleID2;
%%                    ?fatal("role manager start fail"),
%%                    halt(1);
                ID   ->
                    ID
            end
    end,
    {ok, #state{id=RoleID}}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

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
do_handle_call({create, Name}, _From, State) ->
    case do_get_roleid(Name) == ?nil of
        true  ->
            RoleID = State#state.id,
            game_misc:write(role_id, RoleID+1, true),
            do_set_roleid(Name, RoleID),
            {reply, {ok, RoleID}, State#state{id=RoleID+1}};
        false ->
            {reply, ?err(?ERR_LOGIN_NAME_EXIST), State}
    end;

do_handle_call({get_roleid, Name}, _From, State) ->
    Reply = case do_get_roleid(Name) of
        ?nil   -> ?err(?ERR_LOGIN_NO_ROLE);
        RoleID -> {ok, RoleID}
    end,
    {reply, Reply, State};

do_handle_call({gen_name, Gender}, _From, State) ->
    Reply = do_gen_name(10, Gender),
    {reply, Reply, State};

do_handle_call({rename, RoleID, OldName, Name}, _From, State) ->
    case do_get_roleid(Name) == ?nil of
        true  ->
            erase({k_name, OldName}),
            do_set_roleid(Name, RoleID),
            {reply, ok, State};
        false ->
            {reply, ?err(?ERR_LOGIN_NAME_EXIST), State}
    end;

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.


do_gen_name(0, _) ->
    ?error("gen name fail"),
    ?err(?ERR_GAME_SYS_ERROR);
do_gen_name(N, Gender) ->
    FirstNames = cfg_role_name:first_name(Gender),
    LastNames  = cfg_role_name:last_name(Gender),
    Name = case LastNames == ?nil of
        true  ->
            ut_rand:choose(FirstNames);
        false ->
            lists:concat([ut_rand:choose(FirstNames), ut_rand:choose(LastNames)])
    end,
    case do_get_roleid(Name) == ?nil of
        true  -> {ok, Name};
        false -> do_gen_name(N-1, Gender)
    end.

-define(k_name, {k_name, Name}).
do_get_roleid(Name) ->
    get(?k_name).

do_set_roleid(Name, RoleID) ->
    put(?k_name, RoleID),
    ets:insert(?ETS_LOCAL_ROLE, {RoleID, Name}).

get_name(RoleID) ->
    case ets:lookup(?ETS_LOCAL_ROLE, RoleID) of
        [{RoleID, Name}] -> Name;
        _ -> ""
    end.

% del_name(Name) ->
%     erase(?k_name).