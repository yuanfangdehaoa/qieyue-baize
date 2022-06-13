%% @author rong
%% @doc
-module(marriage_manager).

-behaviour(gen_server).

-include("game.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("marriage.hrl").
-include("role.hrl").
-include("enum.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).
-export([target_info/2, propose/5, get_request/1, divorce/1]).
-export([accept/2, refuse/3]).
-export([book/3, clear_wtime/2, compensate_wedding/1, clear_all_wtime/0]).

-define(SERVER, ?MODULE).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

target_info(RoleID, TargetID) ->
    {ok, marriage_ets:get_types(RoleID, TargetID)}.

propose(RoleID, TargetID, Type, IsAA, Cost) ->
    gen_server:call(?SERVER, {propose, RoleID, TargetID, Type, IsAA, Cost}).

get_request(RoleID) ->
    Marriage = marriage_ets:get(RoleID),
    {ok, Marriage#marriage.be_proposed}.

divorce(RoleID) ->
    gen_server:call(?SERVER, {divorce, RoleID}).

accept(RoleID, TargetID) ->
    gen_server:call(?SERVER, {accept, RoleID, TargetID}).

refuse(RoleID, RoleName, TargetID) ->
    gen_server:cast(?SERVER, {refuse, RoleID, RoleName, TargetID}).

book(StartTime, EndTime, Couple) ->
    gen_server:cast(?SERVER, {book, StartTime, EndTime, Couple}).

clear_wtime(Couple, WTime) ->
    gen_server:cast(?SERVER, {clear_wtime, Couple, WTime}).

compensate_wedding(Couple) ->
    gen_server:cast(?SERVER, {compensate_wedding, Couple}).

clear_all_wtime() ->
    gen_server:cast(?SERVER, clear_all_wtime).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    process_flag(trap_exit, true),
    marriage_ets:init(),
    [marriage_ets:set(Marriage) || Marriage <- db:dirty_match_all(?DB_MARRIAGE)],
    erlang:send_after(timer:minutes(15), self(), persist),
    {ok, ?nil}.

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
do_handle_call({propose, RoleID, TargetID, Type, IsAA, Cost}, _From, State) ->
    % 当前是否已经有请求
    % 当前是否被人求婚
    % 对方是否被人求婚
    % 对方是否正在求婚
    % 是否同一人的再次结婚
    Marriage = marriage_ets:get(RoleID),
    ?_check(Marriage#marriage.be_proposed == ?nil, ?ERR_MARRIAGE_BE_PROPOSED),
    ?_check(Marriage#marriage.propose_to == 0, ?ERR_MARRIAGE_PROPOSE_TO),

    TargetMarriage = marriage_ets:get(TargetID),
    case TargetMarriage#marriage.be_proposed of
        #marriage_proposal{proposer=Proposer} ->
            {ok, Cache1} = role:get_cache(TargetID),
            {ok, Cache2} = role:get_cache(Proposer),
            throw(?err(?ERR_MARRIAGE_TARGET_BE_PROPOSED,
                [Cache1#role_cache.name, Cache2#role_cache.name]));
        _ ->
            ok
    end,
    ?_check(TargetMarriage#marriage.propose_to == 0, ?ERR_MARRIAGE_TARGET_PROPOSE_TO),

    case {Marriage#marriage.marry_with, TargetMarriage#marriage.marry_with} of
        {0, 0} -> ok;
        {TargetID, RoleID} -> ok;
        {A, _} when A =/= 0 -> throw(?err(?ERR_MARRIAGE_ALREADY_MARRY));
        {_, B} when B =/= 0 -> throw(?err(?ERR_MARRIAGE_TARGET_ALREADY_MARRY))
    end,

    marriage_ets:set(Marriage#marriage{propose_to=TargetID}),
    marriage_ets:set(TargetMarriage#marriage{
        be_proposed = #marriage_proposal{proposer=RoleID, type=Type,
            is_aa=IsAA, gold=Cost, ts=ut_time:seconds()}
    }),
    {reply, ok, State};

do_handle_call({accept, RoleID, TargetID}, _From, State) ->
    Marriage = marriage_ets:get(RoleID),
    case Marriage#marriage.be_proposed of
        #marriage_proposal{proposer=TargetID, type=Type} ->
            TargetMarriage = marriage_ets:get(TargetID),
            MarryDate = if
                Marriage#marriage.marry_date == ?nil ->
                    ut_time:today();
                true ->
                    Marriage#marriage.marry_date
            end,
            Types = case Type == 1 andalso maps:get(Type, Marriage#marriage.types, 0) >= 1 of
                true ->
                    Marriage#marriage.types;
                false ->
                    ut_misc:maps_increase(Type, 1, Marriage#marriage.types)
            end,
            marriage_ets:set(TargetMarriage#marriage{marry_with=RoleID,
                propose_to=0, marry_date=MarryDate, types=Types, has_marry=true}),
            marriage_ets:set(Marriage#marriage{marry_with=TargetID,
                be_proposed=?nil, marry_date=MarryDate, types=Types, has_marry=true}),
            {reply, {ok, Type, lists:max(maps:keys(Types))}, State};
        _ ->
            throw(?err(?ERR_MARRIAGE_NOT_PROPOSE)),
            {reply, error, State}
    end;

do_handle_call({divorce, RoleID}, _From, State) ->
    Marriage = marriage_ets:get(RoleID),
    case Marriage#marriage.marry_with of
        TargetID when TargetID > 0 ->
            ?_check(Marriage#marriage.wtime == ?nil, ?ERR_MARRIAGE_DIVORCE_HAS_APPOINTMENT),
            TargetMarriage = marriage_ets:get(TargetID),
            marriage_ets:set(TargetMarriage#marriage{
                marry_with=0, marry_date=?nil, types=#{}}),
            marriage_ets:set(Marriage#marriage{
                marry_with=0, marry_date=?nil, types=#{}}),
            {reply, {ok, TargetID}, State};
        _ ->
            throw(?err(?ERR_MARRIAGE_NOT_MARRY)),
            {reply, error, State}
    end;

do_handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

do_handle_cast(started, State) ->
    erlang:send_after(timer:seconds(60), self(), auto_refuse),
    {noreply, State};

do_handle_cast({refuse, RoleID, RoleName, TargetID}, State) ->
    Marriage = marriage_ets:get(RoleID),
    case Marriage#marriage.be_proposed of
        #marriage_proposal{proposer=TargetID, gold=Gold} ->
            TargetMarriage = marriage_ets:get(TargetID),
            marriage_ets:set(TargetMarriage#marriage{propose_to=0}),
            marriage_ets:set(Marriage#marriage{be_proposed=?nil}),
            mail:send(TargetID, ?MAIL_MARRIAGE_REFUSE, [Gold], [RoleName]),
            ok;
        _ ->
            ignore
    end,
    {noreply, State};

do_handle_cast({book, StartTime, EndTime, Couple}, State) ->
    [begin
        Marriage = marriage_ets:get(RoleID),
        marriage_ets:set(Marriage#marriage{
            wcount=Marriage#marriage.wcount+1, wtime={StartTime, EndTime}})
    end || RoleID <- Couple],
    {noreply, State};

do_handle_cast({clear_wtime, Couple, WTime}, State) ->
    [begin
        case marriage_ets:get(RoleID) of
            #marriage{wtime=WTime} = Marriage ->
                marriage_ets:set(Marriage#marriage{wtime=?nil});
            _ ->
                ignore
        end
    end || RoleID <- Couple],
    {noreply, State};

do_handle_cast({compensate_wedding, Couple}, State) ->
    [begin
        case marriage_ets:get(RoleID) of
            #marriage{wcount=WCount} = Marriage ->
                marriage_ets:set(Marriage#marriage{wtime=?nil, wcount=max(0, WCount-1)});
            _ ->
                ignore
        end
    end || RoleID <- Couple],
    {noreply, State};

do_handle_cast(clear_all_wtime, State) ->
    [begin
        marriage_ets:set(Marriage#marriage{wcount=0, wtime=?nil})
    end || Marriage <- marriage_ets:all()],
    {noreply, State};

do_handle_cast(_Msg, State) ->
    {noreply, State}.

do_handle_info(auto_refuse, State) ->
    erlang:send_after(timer:seconds(60), self(), auto_refuse),
    [begin
        #marriage{id=RoleID, be_proposed=#marriage_proposal{proposer=TargetID}} = Marriage,
        {ok, #role_cache{name=RoleName}} = role:get_cache(RoleID),
        do_handle_cast({refuse, RoleID, RoleName, TargetID}, State)
    end || Marriage <- marriage_ets:timeout_proposal()],
    {noreply, State};

do_handle_info(_Info, State) ->
    {noreply, State}.

persist() ->
    lists:foreach(fun(R) ->
        db:dirty_write(?DB_MARRIAGE, R)
    end, marriage_ets:all()).
