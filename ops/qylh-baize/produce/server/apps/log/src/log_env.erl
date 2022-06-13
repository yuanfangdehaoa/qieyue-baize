%% @author rong
%% @doc 
-module(log_env).

-export([vhost/0, host/0, username/0, password/0]).

vhost() ->
    get_env(virtual_host).

host() ->
    get_env(rabbit_host).

username() ->
    get_env(username).

password() ->
    get_env(password).

get_env(Key) ->
    {ok, Val} = application:get_env(log, Key),
    Val.