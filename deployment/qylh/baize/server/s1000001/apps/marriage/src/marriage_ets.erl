%% @author rong
%% @doc
-module(marriage_ets).

-include_lib("stdlib/include/ms_transform.hrl").
-include("marriage.hrl").
-include("table.hrl").

-export([init/0, get/1, set/1, all/0]).
-export([get_types/2, timeout_proposal/0]).

-define(ETS_MARRIAGE, ets_marriage).

init() ->
    ets:new(?ETS_MARRIAGE, [named_table, {keypos, #marriage.id}]),
    ok.

get(RoleID) ->
    case ets:lookup(?ETS_MARRIAGE, RoleID) of
        [] -> #marriage{id=RoleID};
        [Marriage] -> Marriage
    end.

set(Arena) ->
    ets:insert(?ETS_MARRIAGE, Arena).

all() ->
    ets:tab2list(?ETS_MARRIAGE).

get_types(RoleID, TargetID) ->
    case ?MODULE:get(RoleID) of
        #marriage{marry_with=TargetID, types=Types} -> Types;
        _ -> #{}
    end.

timeout_proposal() ->
    AutoRefuse = cfg_marriage:auto_refuse(),
    Now = ut_time:seconds(),
    MS = ets:fun2ms(fun(#marriage{be_proposed=Proposal} = E) when 
        is_record(Proposal, marriage_proposal),
        Now >= Proposal#marriage_proposal.ts + AutoRefuse -> E end),
    ets:select(?ETS_MARRIAGE, MS).
