%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(web_request).

-include("game.hrl").

%% API
-export([get/1, get/2, get/3, get/4, get/5, get/6]).
-export([async_get/1, async_get/2, async_get/3, async_get/4, async_get/5, async_get/6]).
-export([post/1, post/2, post/3, post/4, post/5, post/6]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
get(Path) ->
	get(Path, #{}, [], <<>>, []).

get(Path, Params) ->
	get(Path, Params, [], <<>>, []).

get(Path, Params, Headers) ->
	get(Path, Params, Headers, <<>>, []).

get(Path, Params, Headers, Body) ->
	get(Path, Params, Headers, Body, []).

get(Path, Params, Headers, Body, Options) ->
	Host = game_env:get_admin_host(),
	get(Host, Path, Params, Headers, Body, Options).

get("", Path, Params, _Headers, _Body, _Options) ->
	?info("host not defined, path=~p, parmas=~p", [Path, Params]),
	ignore;
get(Host, Path, Params, Headers, Body, Options) ->
	URL = format_url(Host, Path, Params),
	% [{connect_timeout,1000}]
    case hackney:request(get, URL, Headers, Body, Options) of
        {ok, 200, _, ClientRef} ->
            hackney:body(ClientRef);
        Error ->
            ?error("request error, url=~ts, ret=~p", [URL, Error]),
        	{error, bad_return}
    end.

async_get(Path) ->
	async_get(Path, #{}, [], <<>>, []).

async_get(Path, Params) ->
	async_get(Path, Params, [], <<>>, []).

async_get(Path, Params, Headers) ->
	async_get(Path, Params, Headers, <<>>, []).

async_get(Path, Params, Headers, Body) ->
	async_get(Path, Params, Headers, Body, []).

async_get(Path, Params, Headers, Body, Options) ->
	Host = game_env:get_admin_host(),
	async_get(Host, Path, Params, Headers, Body, Options).

async_get("", Path, Params, _Headers, _Body, _Options) ->
	?info("host not defined, path=~p, parmas=~p", [Path, Params]),
	ignore;
async_get(Host, Path, Params, Headers, Body, Options) ->
	URL = format_url(Host, Path, Params),
	spawn(fun() -> hackney:request(get, URL, Headers, Body, Options) end).

post(Path) ->
	post(Path, #{}, [], <<>>, []).

post(Path, Params) ->
	post(Path, Params, [], <<>>, []).

post(Path, Params, Headers) ->
	post(Path, Params, Headers, <<>>, []).

post(Path, Params, Headers, Body) ->
	post(Path, Params, Headers, Body, []).

post(Path, Params, Headers, Body, Options) ->
	Host = game_env:get_admin_host(),
	post(Host, Path, Params, Headers, Body, Options).

post("", Path, Params, _Headers, _Body, _Options) ->
	?info("host not defined, path=~p, parmas=~p", [Path, Params]),
	ignore;
post(Host, Path, Params, Headers, Body, Options) ->
	URL = format_url(Host, Path, Params),
	% [{connect_timeout,1000}]
    case hackney:request(post, URL, Headers, Body, Options) of
    	{ok, 200, _Headers, ClientRef} ->
		    hackney:body(ClientRef);
		Error ->
            ?error("request error, url=~ts, ret=~p", [URL, Error]),
			{error, bad_return}
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
format_url(Host, Path, Params) when is_list(Params) ->
	ut_conv:to_binary(lists:concat([Host, io_lib:format(Path, Params)]));
format_url(Host, Path, Params) when is_map(Params) ->
	Params2 = [K ++ "=" ++ ut_conv:to_list(V) || {K,V} <- maps:to_list(Params)],
	ut_conv:to_binary(lists:concat([Host, Path, "?", string:join(Params2, "&")])).