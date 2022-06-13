%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(ut_conv).

%% API
-export([to_atom/1]).
-export([to_list/1]).
-export([to_binary/1]).
-export([to_integer/1]).
-export([term_to_string/1]).
-export([string_to_term/1]).
-export([term_to_bitstring/1]).
-export([bitstring_to_term/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
to_atom(Atom) when is_atom(Atom)   -> Atom;
to_atom(Int)  when is_integer(Int) -> list_to_atom2( integer_to_list(Int) );
to_atom(List) when is_list(List)   -> list_to_atom2(List);
to_atom(Bin)  when is_binary(Bin)  -> list_to_atom2( binary_to_list(Bin) );
to_atom(_) -> throw(bad_value).

to_list(List)  when is_list(List)   -> List;
to_list(Int)   when is_integer(Int) -> integer_to_list(Int);
to_list(Float) when is_float(Float) -> float_to_string(Float);
to_list(Atom)  when is_atom(Atom)   -> atom_to_list(Atom);
to_list(Bin)   when is_binary(Bin)  -> unicode:characters_to_list(Bin);
to_list(_) -> throw(bad_value).

to_binary(Bin)   when is_binary(Bin)  -> Bin;
to_binary(List)  when is_list(List)   -> unicode:characters_to_binary(List);
to_binary(Atom)  when is_atom(Atom)   -> list_to_binary( atom_to_list(Atom) );
to_binary(Int)   when is_integer(Int) -> list_to_binary( integer_to_list(Int) );
to_binary(Float) when is_float(Float) -> list_to_binary( float_to_string(Float) );
to_binary(_) -> throw(other_value).

to_integer(Int)   when is_integer(Int) -> Int;
to_integer(Bin)   when is_binary(Bin)  -> list_to_integer( binary_to_list(Bin) );
to_integer(List)  when is_list(List)   -> list_to_integer(List);
to_integer(Float) when is_float(Float) -> round(Float);
to_integer(Atom)  when is_atom(Atom)   -> list_to_integer( atom_to_list(Atom) );
to_integer(_) -> throw(other_value).


%%-----------------------------------------------
%% @doc 任意类型转换为字符串
%% e.g. [{a},1] => "[{a},1]"
-spec term_to_string(term()) ->
    string().
%%-----------------------------------------------
term_to_string(Term) ->
    binary_to_list(list_to_binary(io_lib:format("~w", [Term]))).


%%-----------------------------------------------
%% @doc 字符串转换为 erlang 类型，其中字符串为 term_to_string 的返回值
%% e.g. "[{a},1]"  => [{a},1]
-spec string_to_term(string()) ->
    term().
%%-----------------------------------------------
string_to_term(Str) ->
    try
        {ok, Tokens, _} = erl_scan:string(Str ++ "."),
        {ok, Term} = erl_parse:parse_term(Tokens),
        Term
    catch _:_ ->
        error
    end.

%%-----------------------------------------------
%% @doc 任意类型转换为二进制
%% e.g. [{a},1] => <<"[{a},1]">>
-spec term_to_bitstring(term()) ->
    bitstring().
%%-----------------------------------------------
term_to_bitstring(Term) ->
    erlang:list_to_bitstring(io_lib:format("~w", [Term])).


%%-----------------------------------------------
%% @doc 二进制转换为 erlang 类型，其中二进制为 bitstring_to_term 的返回值
%% e.g. <<"[{a},1]">>  => [{a},1]
-spec bitstring_to_term(bitstring()) ->
    term().
%%-----------------------------------------------
bitstring_to_term(BitString) ->
    string_to_term(binary_to_list(BitString)).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
list_to_atom2(List) when is_list(List) ->
    case catch(list_to_existing_atom(List)) of
        Atom when is_atom(Atom) ->
        	Atom;
        _ ->
        	list_to_atom(List)
    end.

float_to_string(N) when is_integer(N) ->
    integer_to_list(N) ++ ".00";
float_to_string(F) when is_float(F) ->
    io_lib:format("~.2f", [F]).
