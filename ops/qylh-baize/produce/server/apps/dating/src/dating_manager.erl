%% @author rong
%% @doc
-module(dating_manager).

-behaviour(gen_server).

-include_lib("stdlib/include/ms_transform.hrl").
-include("game.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("role.hrl").
-include("proto.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0, paginate/3]).
-export([hook_login/1, hook_upgrade/2, receive_flower/2, receive_friend_request/1,
    set_tags/2]).

-define(SERVER, ?MODULE).
-define(ETS_DATING, ets_dating).
-define(INTERVAL, 300).
-define(NEED_LV, 75).

-record(state, {male=[], female=[]}).
-record(dating_role, {id, level, viplv, flower}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

paginate(RoleID, Gender, Page) ->
    gen_server:call(?SERVER, {paginate, RoleID, Gender, Page}).

hook_login(RoleSt) ->
    #role_info{gender=Gender, level=Level} = role_data:get(?DB_ROLE_INFO),
    Level >= ?NEED_LV andalso gen_server:cast(?SERVER, {update, RoleSt#role_st.role, Gender}).

hook_upgrade(_Lv, RoleSt) ->
    #role_info{gender=Gender, level=Level} = role_data:get(?DB_ROLE_INFO),
    Level >= ?NEED_LV andalso gen_server:cast(?SERVER, {update, RoleSt#role_st.role, Gender}).

receive_flower(RoleID, ItemID) ->
    {ok, #role_cache{gender=Gender, level=Level}} = role:get_cache(RoleID),
    gen_server:cast(?SERVER, {receive_flower, RoleID, ItemID}),
    Level >= ?NEED_LV andalso gen_server:cast(?SERVER, {update, RoleID, Gender}).

receive_friend_request(RoleID) ->
    gen_server:cast(?SERVER, {receive_friend_request, RoleID}).

set_tags(RoleID, Tags) ->
    gen_server:cast(?SERVER, {set_tags, RoleID, Tags}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    process_flag(trap_exit, true),
    ets:new(?ETS_DATING, [named_table, {keypos, #dating.id}]),
    [ets:insert(?ETS_DATING, Dating) || Dating <- db:dirty_match_all(?DB_DATING)],
    erlang:send_after(timer:minutes(15), self(), persist),
    {ok, #state{}}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(persist, State) ->
    erlang:send_after(timer:minutes(15), self(), persist),
    persist(),
    {noreply, State};

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
    persist(),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({paginate, RoleID, Gender, Page}, _From, State) ->
    List = case Gender of
        ?GENDER_MALE -> State#state.female;
        ?GENDER_FEMALE -> State#state.male
    end,
    {_Total, List2} = ut_misc:paginate(List, 9, max(1, Page)),
    {reply, {ok, p_dating(RoleID), p_dating(List2)}, State};

do_handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

% 需等待role_cache初始化
do_handle_cast(started, State) ->
    Now = ut_time:seconds(),
    MaxTime = 86400*14,
    MS = ets:fun2ms(fun(E) when 
        E#role_info.logout + MaxTime > Now,
        E#role_info.level >= ?NEED_LV  
        -> E end),
    RoleInfos = db:dirty_select(?DB_ROLE_INFO, MS),
    {Male, Female} = lists:foldl(fun(RoleInfo, {AccMale, AccFemale}) -> 
        Role = gen_dating_role(RoleInfo#role_info.id),
        case RoleInfo#role_info.gender of
            ?GENDER_MALE -> {[Role|AccMale], AccFemale};
            ?GENDER_FEMALE -> {AccMale, [Role|AccFemale]}
        end
    end, {[], []}, RoleInfos),
    erlang:send_after(timer:seconds(?INTERVAL), self(), resort),
    {noreply, State#state{male=sort(Male), female=sort(Female)}};

do_handle_cast({update, RoleID, Gender}, State) ->
    Role = gen_dating_role(RoleID),
    case Gender of
        ?GENDER_MALE -> 
            Male = lists:keystore(RoleID, #dating_role.id, State#state.male, Role),
            {noreply, State#state{male=Male}};
        ?GENDER_FEMALE ->
            Female = lists:keystore(RoleID, #dating_role.id, State#state.female, Role),
            {noreply, State#state{female=Female}}
    end;

do_handle_cast({receive_flower, RoleID, ItemID}, State) ->
    Dating = get_dating(RoleID),
    Flowers = ut_misc:maps_increase(ItemID, 1, Dating#dating.flowers),
    ets:insert(?ETS_DATING, Dating#dating{flowers=Flowers, flirted=Dating#dating.flirted+1}),
    {noreply, State};

do_handle_cast({receive_friend_request, RoleID}, State) ->
    Dating = get_dating(RoleID),
    ets:insert(?ETS_DATING, Dating#dating{flirted=Dating#dating.flirted+1}),
    {noreply, State};

do_handle_cast({set_tags, RoleID, Tags}, State) ->
    Dating = get_dating(RoleID),
    ets:insert(?ETS_DATING, Dating#dating{tags=Tags}),
    {noreply, State};

do_handle_cast(_Msg, State) ->
    {noreply, State}.

do_handle_info(resort, State) ->
    erlang:send_after(timer:seconds(?INTERVAL), self(), resort),
    {noreply, State#state{male=sort(State#state.male), female=sort(State#state.female)}};

do_handle_info(_Info, State) ->
    {noreply, State}.

sort(List) ->
    lists:sort(fun(A, B) ->
        compare([
            fun compare_online/2,
            fun compare_vip/2,
            fun compare_flower/2
        ], A, B)
    end, List).

compare([], _A, _B) ->
    true;
compare([H|T], A, B) ->
    case H(A, B) of
        next ->
            compare(T, A, B);
        Val -> Val
    end.

compare_online(A, B) ->
    AOnline = role:is_online(A#dating_role.id),
    BOnline = role:is_online(B#dating_role.id),
    if 
        AOnline == BOnline -> next;
        AOnline -> true;
        true -> false 
    end.

compare_vip(A, B) ->
    if
        A#dating_role.viplv == B#dating_role.viplv -> next;
        A#dating_role.viplv >= B#dating_role.viplv -> true;
        true -> false
    end.

compare_flower(A, B) ->
    if
        A#dating_role.flower == B#dating_role.flower -> next;
        A#dating_role.flower >= B#dating_role.flower -> true;
        true -> false
    end.

get_dating(RoleID) ->
    case ets:lookup(?ETS_DATING, RoleID) of
        [] -> 
            Dating = #dating{id=RoleID, tags=ut_rand:choose(cfg_dating_tag:list(), 3, false)},
            ets:insert(?ETS_DATING, Dating),
            Dating;
        [Dating] -> 
            Dating
    end.

calc_flower_num(RoleID) ->
    #dating{flowers=Flowers} = get_dating(RoleID),
    lists:sum(maps:values(Flowers)).

gen_dating_role(RoleID) ->
    {ok, Cache} = role:get_cache(RoleID),
    #dating_role{
        id     = Cache#role_cache.id,
        level  = Cache#role_cache.level,
        viplv  = Cache#role_cache.viplv,
        flower = calc_flower_num(RoleID)
    }.

p_dating(RoleID) when is_integer(RoleID) ->
    Dating = get_dating(RoleID),
    #p_dating{
        base      = role:get_base(RoleID), 
        tags    = Dating#dating.tags,
        flirted = Dating#dating.flirted,
        flowers = Dating#dating.flowers
    };
p_dating(List) when is_list(List) ->
    [p_dating(L#dating_role.id) || L <- List].

persist() ->
    lists:foreach(fun(R) ->
        db:dirty_write(?DB_DATING, R)
    end, ets:tab2list(?ETS_DATING)).
