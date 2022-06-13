%% @author rong
%% @doc
-module(web_rank_api).

-include("game.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("ranking.hrl").
-include("role.hrl").

-export([info/1]).

% 获取玩家背包信息
info(Req) ->
    #{rank_type := RankType} = cowboy_req:match_qs([{rank_type, int}], Req),
    web_util:validate_sign([RankType], Req),
    RankList = rank_server:get_ranklist(RankType),

    Data = lists:map(fun(RankItem) ->
        {ok, Cache} = role:get_cache(RankItem#rankitem.id),
        #{
            <<"rank">>    => RankItem#rankitem.rank,
            <<"role_id">> => ut_conv:to_binary(RankItem#rankitem.id),
            <<"name">>    => ut_conv:to_binary(Cache#role_cache.name),
            <<"level">>   => Cache#role_cache.level,
            <<"career">>  => Cache#role_cache.career,
            <<"num">>     => RankItem#rankitem.sort,
            <<"time">>    => RankItem#rankitem.time
        }
    end, RankList),
    web_reply:ok(Data, Req).
