%% @author rong
%% @doc
-module(web_app).

-behaviour(application).

-export([]).

%% application callbacks
-export([start/2, stop/1, reload_router/0]).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
start(_, _) ->
    Dispatch = dispatch(),
    {ok, Port} = application:get_env(web, port),
    {ok, _} = cowboy:start_clear(http, [{port, Port}], #{
        env => #{dispatch => Dispatch}
    }),
    web_sup:start_link().

stop(_State) ->
    ok.

dispatch() ->
    cowboy_router:compile([
        {'_', [
            {"/api/role/ban"           , web_api_handler, {web_role_api, ban}},
            {"/api/role/silent"        , web_api_handler, {web_role_api, silent}},
            {"/api/role/kick"          , web_api_handler, {web_role_api, kick}},
            {"/api/role/online"        , web_api_handler, {web_role_api, online}},
            {"/api/role/detail"        , web_api_handler, {web_role_api, detail}},
            {"/api/role/role_info"        , web_api_handler, {web_role_api, role_info}},
            
            {"/api/bag/info"           , web_api_handler, {web_bag_api, info}},
            {"/api/bag/item"           , web_api_handler, {web_bag_api, del}},
            
            {"/api/guild/notice"       , web_api_handler, {web_guild_api, notice}},
            {"/api/guild/change_notice", web_api_handler, {web_guild_api, change_notice}},
            {"/api/guild/disband"      , web_api_handler, {web_guild_api, disband}},
            
            {"/api/mail"               , web_api_handler, {web_mail_api, send}},
            
            {"/api/marquee/add"        , web_api_handler, {web_marquee_api, add}},
            {"/api/marquee/del"        , web_api_handler, {web_marquee_api, del}},
            
            {"/api/rank"               , web_api_handler, {web_rank_api, info}},
            
            {"/api/pay"                , web_api_handler, {web_pay_api, pay}},
            
            {"/api/game/kick"          , web_api_handler, {web_game_api, kick}}
        ]}
    ]).

reload_router() ->
    Dispatch = dispatch(),
    cowboy:set_env(http, dispatch, Dispatch).
