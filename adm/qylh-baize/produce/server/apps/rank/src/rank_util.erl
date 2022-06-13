%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(rank_util).

-include("game.hrl").
-include("rank.hrl").
-include("ranking.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([reg_name/1]).
-export([get_pid/1]).
-export([hook_login/1]).
-export([notify/4]).
-export([p_ranking/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
reg_name(RankID) ->
	Name = reg_name_only(RankID),
	#cfg_rank{mode=Mode} = cfg_rank:find(RankID),
	case Mode == ?SERVER_TYPE_CROSS of
    	true  ->
    		case cluster:is_local() of
    			true  ->
						{Name, cluster:get_cross(?CROSS_RULE_24_8)};
    			false -> Name
    		end;
    	false ->
    		Name
    end.

reg_name_only(RankID) ->
	ut_conv:to_atom( lists:concat(["rank-", RankID]) ).

get_pid(RankID) ->
	Name = reg_name_only(RankID),
	#cfg_rank{mode=Mode} = cfg_rank:find(RankID),
	case cluster:is_local() andalso Mode == ?SERVER_TYPE_CROSS of
		true  ->
			try
				CrossNode = cluster:get_cross(?CROSS_RULE_24_8),
				rpc:call(CrossNode, erlang, whereis, [Name])
			catch Class:Reason:Stacktrace ->
				?stacktrace(Class, Reason, Stacktrace),
				?fatal("fatal error : ~n", []),
				?nil
			end;
		false ->
			erlang:whereis(Name)
	end.

hook_login(_RoleSt) ->
	lists:foreach(fun
		({Event, ?nil, RankID}) ->
			role_event:listen(Event, ?MODULE, notify, RankID);
		({Event, Args, RankID}) ->
			role_event:listen(Event, ?MODULE, notify, {RankID, Args})
	end, cfg_rank:events()).

notify(?EVENT_TRAIN_ORDER, {RankID, Type1}, {Type2, Order, Level}, RoleSt) ->
	case Type1 == Type2 of
		true  ->
			ID = case Type1 of
				?TRAIN_MOUNT   -> cfg_mount:id(Order, Level);
				?TRAIN_OFFHAND -> cfg_offhand:id(Order, Level)
			end,
			rank:update_rank(RankID, ID, RoleSt);
		false ->
			ignore
	end;
notify(?EVENT_PAY, RankID, _Args, RoleSt) ->
	#cfg_rank{actid=YYActID} = cfg_rank:find(RankID),
	case yunying:get_act_time(YYActID) of
		{ok, STime, ETime} ->
			Gold = role_pay:calc(STime, ETime),
			rank:update_rank(RankID, Gold, RoleSt);
		error ->
			ignore
	end;
notify(?EVENT_CONSUME, RankID, Args, RoleSt) ->
	rank:update_rank(RankID, {add,Args}, RoleSt);
notify(?EVENT_YY_SEARCH, RankID, Times, RoleSt) ->
	rank:update_rank(RankID, {add,Times}, RoleSt);
notify(_Event, RankID, Args, RoleSt) ->
	rank:update_rank(RankID, Args, RoleSt).


p_ranking(RankItem) when RankItem#rankitem.id =< 3000 ->
	#p_ranking{
		base = arena_util:get_robot_base(RankItem#rankitem.rank, RankItem#rankitem.id),
		rank = RankItem#rankitem.rank,
		sort = RankItem#rankitem.sort,
		data = RankItem#rankitem.data
	};
p_ranking(RankItem) ->
	#p_ranking{
		base = role:get_base(RankItem#rankitem.id),
		rank = RankItem#rankitem.rank,
		sort = RankItem#rankitem.sort,
		data = RankItem#rankitem.data
	}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
