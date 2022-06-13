%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(redenvelope_server).

-include("game.hrl").
-include("table.hrl").
-include("guild_redenvelope.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").

-behaviour(gen_server).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%% API
-export([start_link/0]).

-export([get_uid/0]).
-export([get_redenvelope/1]).
-export([get_redenvelopes/0]).
-export([snatch/2]).
-export([update/1]).

-define(SERVER, ?MODULE).

-define(ETS_REDENVELOPE, ets_redenvelope).


-record(state, {uid}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%获取红包id
get_uid()->
	gen_server:call(?SERVER, {get_uid}).

%获取所有红包列表
get_redenvelopes()->
	RedEnvelopes = ets:tab2list(?ETS_REDENVELOPE),
	Now = ut_time:seconds(),
	lists:foreach(fun
			(RedEnvelope)->
				#p_redenvelope{uid=UId, time=Time} = RedEnvelope,
				case Now - Time >= ?redenvelope_expire of
					true  -> ets:delete(?ETS_REDENVELOPE, UId);
					false -> igore
				end
		end, RedEnvelopes),
	ets:tab2list(?ETS_REDENVELOPE).

get_redenvelope(UId)->
	case ets:lookup(?ETS_REDENVELOPE, UId) of
		[R] -> R;
		[]  -> ?nil
	end.

%抢红包
snatch(UId, RedEnvelopeGot)->
	gen_server:call(?SERVER, {snatch, UId, RedEnvelopeGot}).

%更新红包
update(RedEnvelope)->
	gen_server:call(?SERVER, {update, RedEnvelope}).


%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	UId = game_misc:read(redenvelope_id, game_uid:gen_guid()),
	ets:new(?ETS_REDENVELOPE, [named_table,
        {keypos, #p_redenvelope.uid}, {read_concurrency, true}]),
    RedEnvelopes = db:dirty_match_all(?DB_REDENVELOPE),
    Now = ut_time:seconds(),
    RedEnvelopes2 = lists:filter(fun
    		(#p_redenvelope{time=Time}) ->
    			case Now - Time >= ?redenvelope_expire of
    				true -> false;
    				_    -> true
    			end
    	end, RedEnvelopes),
    ets:insert(?ETS_REDENVELOPE, RedEnvelopes2),
    erlang:send_after(timer:seconds(900), self(), write_data),
	{ok, #state{uid=UId}}.

handle_call(Request, From, State) ->
	?try_handle_call(do_handle_call(Request, From, State), State).

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(Info, State) ->
	?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
	write_to_db(),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

do_handle_call({get_uid}, _From, State)->
	#state{uid=UId} = State,
	UId2 = UId + 1,
	game_misc:write(redenvelope_id, UId2),
	{reply, UId, #state{uid=UId2}};


do_handle_call({snatch, UId, RedEnvelopeGot}, _From, State)->
	RedEnvelope = get_redenvelope(UId),
	#p_redenvelope{gots=Gots, num=Num} = RedEnvelope,
	#p_redenvelope_got{role=Role} = RedEnvelopeGot,
	?_check(not redenvelope_util:is_snatched(Role#p_rn_role.id, Gots), ?ERR_GUILD_REDENVELOPE_SNATCHED),
	{RedEnvelope3, RedEnvelopeGot3} = case length(Gots) < Num of
		true ->
			{RedEnvelope2, RedEnvelopeGot2} = redenvelope_util:snatch(RedEnvelope, RedEnvelopeGot),
			ets:insert(?ETS_REDENVELOPE, RedEnvelope2),
			{RedEnvelope2, RedEnvelopeGot2};
		false ->
			{RedEnvelope, RedEnvelopeGot}
	end,
	{reply, {RedEnvelope3, RedEnvelopeGot3}, State};

do_handle_call({update, RedEnvelope}, _From, State)->
	ets:insert(?ETS_REDENVELOPE, RedEnvelope),
	{reply, ok, State}.

do_handle_info(write_data, State)->
	write_to_db(),
	erlang:send_after(timer:seconds(900), self(), write_data),
	{noreply, State}.

write_to_db()->
	db:clear_table(?DB_REDENVELOPE),
	lists:foreach(fun
		(RedEnvelope) ->
			db:dirty_write(?DB_REDENVELOPE, RedEnvelope)
	end, ets:tab2list(?ETS_REDENVELOPE)).

