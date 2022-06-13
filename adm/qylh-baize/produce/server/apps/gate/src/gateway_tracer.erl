%%%=============================================================================
%%% @author z.hua
%%% @doc
%%% 打印协议信息
%%% @end
%%%=============================================================================

-module(gateway_tracer).

-include("game.hrl").
-include("proto.hrl").

%% API
-export([trace/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
-ifdef(DEBUG).

trace(RoleID, RecOrBin) ->
	TraceRole = mochiglobal:get(gateway_trace_role),
	case TraceRole == ?nil orelse lists:member(RoleID, TraceRole) of
		true  ->
			do_trace(RoleID, RecOrBin);
		false ->
			ignore
	end.

-else.

trace(RoleID, RecOrBin) ->
	TraceRole = mochiglobal:get(gateway_trace_role),
	case lists:member(RoleID, TraceRole) of
		true  ->
			do_trace(RoleID, RecOrBin);
		false ->
			ignore
	end.

-endif.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_trace(RoleID, Rec) when is_tuple(Rec) ->
	try
		{ModID, MsgID} = proto:get_msgid(element(1, Rec)),
		do_trace2(RoleID, ModID, MsgID, Rec)
	catch Class:Reason:Stacktrace ->
		?stacktrace(Class, Reason, Stacktrace)
	end;
do_trace(RoleID, Bin) when is_binary(Bin) ->
	try
		<<MsgID:32, _:32, Rest/binary>> = Bin,
		{ModID, Mod, Name} = proto:get_toc(MsgID),
		Rec = Mod:decode_msg(Rest, Name),
		do_trace2(RoleID, ModID, MsgID, Rec)
	catch Class:Reason:Stacktrace ->
		?stacktrace(Class, Reason, Stacktrace)
	end;
do_trace(_, _) ->
	ignore.

do_trace2(RoleID, ModID, MsgID, Rec) ->
	case mochiglobal:get(gateway_trace_all) of
		true  ->
			?debug("[TRACE] [~w] [~w] ~w", [RoleID, MsgID, Rec]);
		false ->
			TracePkg = mochiglobal:get(gateway_trace_pkg),
			case
				lists:member(ModID, TracePkg) orelse
				lists:member(MsgID, TracePkg)
			of
				true  ->
					?debug("[TRACE] [~w] [~w] ~w", [RoleID, MsgID, Rec]);
				false ->
					ignore
			end
	end.
