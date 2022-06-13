%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(cluster_hook).

-include("cluster.hrl").
-include("game.hrl").
-include("table.hrl").

%% API
-export([hook_conn/0]).
-export([hook_divide/3]).
-export([post_divide/0]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_conn() ->
	lists:foreach(fun
		(ServRef) ->
            gen_server:cast(ServRef, connected)
	end, [
	]).

hook_divide(LocalNode, OldGrp, NewGrp) ->
	OldCross = get_cross_by_group(OldGrp),
	NewCross = get_cross_by_group(NewGrp),
	?debug(
		"hook_divide: old_group=~w, new_group=~w, local=~p, old_cross=~p, new_cross=~p",
		[OldGrp, NewGrp, LocalNode, OldCross, NewCross]
	),
	case is_record(OldCross, cls_node) andalso is_record(NewCross, cls_node) of
		true  ->
			lists:foreach(fun
				(Mod) ->
					try
						Mod:hook_divide(LocalNode, OldGrp, NewGrp, OldCross, NewCross)
					catch Class:Reason:Stacktrace ->
						?stacktrace(Class, Reason, Stacktrace)
					end
			end, [
				  rank_server
				, compete_server
				, guild_crosswar
			]);
		false ->
			ignore
	end.

post_divide() ->
	lists:foreach(fun
		(Mod) ->
			Mod:post_divide()
	end, [
		timeboss_server
	  , siegewar_server
	]).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_cross_by_group(GroupID) ->
	case ets:lookup(?ETS_CLUSTER_GROUP, GroupID) of
		[#cls_group{cross=Cross}] ->
			case ets:lookup(?ETS_CLUSTER_NODES, Cross) of
				[N] -> N;
				[]  -> ?nil
			end;
		[] ->
			?nil
	end.
