%% @author rong
%% @doc
-module(web_guild_api).

-include("game.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("guild.hrl").

-export([notice/1, change_notice/1, disband/1]).

% 获取公告
notice(Req) ->
    web_util:validate_sign([], Req),
    Guilds = guild:get_guilds(),
    Data = [begin
        {ok, [GuildInfo]} = guild:get_data(Guild#p_guild_base.id, [?DB_GUILD_INFO]),
        Chief = guild_agent:get_chief(GuildInfo),
        #{
            <<"id">>   => Guild#p_guild_base.id,
            <<"guild_name">> => ut_conv:to_binary(Guild#p_guild_base.name),
            <<"chief_id">>   => Chief#guild_memb.id,
            <<"chief_name">> => ut_conv:to_binary(Chief#guild_memb.name),
            <<"notice">>     => ut_conv:to_binary(GuildInfo#guild_info.notice)
        }
    end || Guild <- Guilds],
    web_reply:ok(Data, Req).

change_notice(Req) ->
    {ok, Params, Req1} = cowboy_req:read_urlencoded_body(Req),
    GuildID = ut_conv:to_integer(proplists:get_value(<<"id">>, Params)),
    Notice = ut_conv:to_list(proplists:get_value(<<"notice">>, Params)),
    web_util:validate_sign([GuildID], Params),
    guild_agent:notice(guild:get_ref(GuildID), 0, Notice, false, 0),
    web_reply:ok(Req1).

disband(Req) ->
    #{id:=GuildID} = cowboy_req:match_qs([{id, int}], Req),
    case cowboy_req:method(Req) of
        <<"DELETE">> ->
            web_util:validate_sign([GuildID], Req),
            guild:gm_disband(GuildID),
            web_reply:ok(Req);
        _ ->
            web_reply:error(Req)
    end.
