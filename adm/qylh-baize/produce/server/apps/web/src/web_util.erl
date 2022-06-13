%% @author rong
%% @doc
-module(web_util).

-include("game.hrl").
-include("errno.hrl").

-export([validate_sign/2, validate_sign/3]).
-export([boolean/2, int_list/2, string/2, str_list/2, double/2]).
-export([to_str_list/1, to_int_list/1]).

validate_sign(Keys, Params) when is_list(Params) ->
    Ts = proplists:get_value(<<"_ts">>, Params),
    Sign = proplists:get_value(<<"_sign">>, Params),
    validate_sign(Keys, ut_conv:to_integer(Ts), ut_conv:to_list(Sign));

validate_sign(Keys, Req) ->
    #{'_ts' := Ts, '_sign' := Sign} = cowboy_req:match_qs([{'_ts', int, 0}, {'_sign', nonempty, ""}], Req),
    validate_sign(Keys, Ts, Sign).

validate_sign(Keys, Ts, Sign) ->
    Keys2 = [ut_conv:to_list(Key)||Key<-Keys],
    Str = lists:concat(Keys2 ++ [Ts, game_env:get_admin_key()]),
    case ut_str:md5(Str) == ut_conv:to_list(Sign) of
        true ->
            ok;
        false ->
            throw(?err(?ERR_WEB_SIGN_INVALID))
    end.

% query string constraint
boolean(_Type, <<"true">>) ->
    {ok, true};
boolean(_Type, <<"false">>) ->
    {ok, false};
boolean(Type, _) when Type =/= format_error ->
    {error, not_boolean};
boolean(format_error, {not_boolean, Value}) ->
    io_lib:format("The value ~p is not boolean.", [Value]).

int_list(_Type, <<>>) ->
    {ok, []};
int_list(Type, Value) when Type =/= format_error ->
    List = string:tokens(ut_conv:to_list(Value), ","),
    {ok, [ut_conv:to_integer(I)||I<-List]};
int_list(Type, _) when Type =/= format_error ->
    {error, not_int_list};
int_list(format_error, {not_int_list, Value}) ->
    io_lib:format("The value ~p is not int_list.", [Value]).

string(_Type, Bin) ->
    {ok, ut_conv:to_list(Bin)}.

str_list(_Type, <<>>) ->
    {ok, []};
str_list(Type, Value) when Type =/= format_error ->
    List = string:tokens(ut_conv:to_list(Value), ","),
    {ok, List};
str_list(Type, _) when Type =/= format_error ->
    {error, not_str_list};
str_list(format_error, {not_str_list, Value}) ->
    io_lib:format("The value ~p is not str_list.", [Value]).

to_str_list(Data) ->
    [ut_conv:to_list(D) || D <- Data].

to_int_list(Data) ->
    [ut_conv:to_integer(D) || D <- Data].

double(_Type, Bin) ->
    try
        {ok, ut_conv:to_integer(Bin)}
    catch _:_:_ ->
        {ok, erlang:list_to_float(erlang:binary_to_list(Bin))}
    end.