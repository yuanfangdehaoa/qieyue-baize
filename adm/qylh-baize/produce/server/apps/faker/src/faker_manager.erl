%% @author rong
%% @doc 假人
-module(faker_manager).

-behaviour(gen_server).

-include("game.hrl").
-include("faker.hrl").
-include("role.hrl").
-include("proto.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0, get/1]).

-define(SERVER, ?MODULE).
-define(ETS_FAKER, ets_faker).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get(ID) ->
    hd(ets:lookup(?ETS_FAKER, ID)).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    ets:new(?ETS_FAKER, [named_table, {keypos, #faker.id}]),
    {ok, undefined}.

handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast(started, State) ->
    lists:foreach(fun(ID) ->
        Faker = gen_faker(ID),
        ets:insert(?ETS_FAKER, Faker),
        role_cache:load_faker(make_cache(Faker))
    end, cfg_faker:list()),
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
gen_faker(ID) ->
    #faker{id=ID, base=gen_base(ID)}.

gen_base(ID) ->
    Faker = cfg_faker:find(ID),
    #p_role_base{
        id     =  Faker#cfg_faker.id,
        name   =  Faker#cfg_faker.name,
        career =  Faker#cfg_faker.career,
        gender =  Faker#cfg_faker.gender,
        level  =  Faker#cfg_faker.level,
        viplv  =  Faker#cfg_faker.viplv,
        power  = 0,
        figure = maps:from_list(Faker#cfg_faker.figure),
        guild  = 0,
        gname  = "",
        charm  = 0,
        wake   = 0,
        gpost  = 0,
        marry  = 0,
        mname  = "",
        mtype  = 0,
        suid   = game_env:get_suid(),
        zoneid = 0,
        team   = 0
    }.

make_cache(Faker) ->
    #faker{base=Base} = Faker,
    #role_cache{
        id     = Base#p_role_base.id,
        name   = Base#p_role_base.name,
        career = Base#p_role_base.career,
        gender = Base#p_role_base.gender,
        level  = Base#p_role_base.level,
        power  = Base#p_role_base.power,
        viplv  = Base#p_role_base.viplv,
        guild  = Base#p_role_base.guild,
        gpost  = Base#p_role_base.gpost,
        figure = Base#p_role_base.figure,
        login  = ut_time:seconds(),
        logout = ut_time:seconds(),
        charm  = Base#p_role_base.charm,
        online = true,
        wake   = Base#p_role_base.wake,
        marry  = 0,
        mname  = "",
        mtype  = 0,
        suid   = game_env:get_suid(),
        zoneid = 0,
        team   = 0
    }.
