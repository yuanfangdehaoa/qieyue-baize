%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(buff_timer).

-include("buff.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API

-export([init/0]).
-export([loop/0]).
-export([add/1, add/3]).
-export([del/1, del/2]).
-export([rep/3]).
-export([ext/3]).
-export([trigger/1]).
-export([expired/1]).

% TimeWheel Ref
-define(wref, ?MODULE).
% Task Ref
-define(tref(Ref), {?MODULE, Ref}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init() ->
	ut_twheel:new(?wref).

loop() ->
	ut_twheel:tick(?wref).

add(Actor) ->
	add(Actor#actor.uid, Actor#actor.buffs, ut_time:seconds()).

add(ActorID, Buff, STime) when is_record(Buff, p_buff) ->
	do_add(ActorID, Buff, STime);
add(ActorID, Buffs, STime) when is_map(Buffs) ->
	lists:foreach(fun
		(Buff) ->
			do_add(ActorID, Buff, STime)
	end, maps:values(Buffs)).

del(Actor) ->
	del(Actor#actor.uid, Actor#actor.buffs).

del(ActorID, Group) when is_integer(Group) ->
	do_del(ActorID, Group);
del(ActorID, Buffs) when is_map(Buffs) ->
	lists:foreach(fun
		(Buff) ->
			do_del(ActorID, Buff#p_buff.group)
	end, maps:values(Buffs)).

ext(ActorID, Group, Last) ->
	ut_twheel:ext_task(?MODULE, ?tref({ActorID, Group}), Last).

rep(ActorID, Buff, STime) ->
	do_del(ActorID, Buff#p_buff.group),
	do_add(ActorID, Buff, STime).


trigger({?MODULE, Ref}) ->
	scene:route(self(), buff_effect, trigger, Ref).

expired({?MODULE, Ref}) ->
	scene:route(self(), buff_effect, expired, Ref).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_add(ActorID, Buff, STime) ->
	#p_buff{id=BuffID, etime=ETime, group=Group} = Buff,
	#cfg_buff{tick=Tick0} = cfg_buff:find(BuffID),
	Tick = Tick0 div ?LOOP_MILLIS,
	Last = ?_if(ETime == 0, 0, (ETime-STime)*1000 div ?LOOP_MILLIS),
	Ref  = {ActorID, Group},
	Hdl  = {?MODULE, ?_if(Tick >= 0, trigger, ?nil), expired},
	ut_twheel:add_task(?wref, ?tref(Ref), Last, Tick, Hdl).

do_del(ActorID, Group) ->
	ut_twheel:del_task(?wref, ?tref({ActorID, Group})).
