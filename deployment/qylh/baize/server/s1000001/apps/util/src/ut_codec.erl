%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(ut_codec).

%% API
-export([read_bool/1, read_bool_list/1, write_bool/1, write_bool_list/1]).
-export([read_int8/1, read_int8_list/1, write_int8/1, write_int8_list/1]).
-export([read_int16/1, read_int16_list/1, write_int16/1, write_int16_list/1]).
-export([read_int32/1, read_int32_list/1, write_int32/1, write_int32_list/1]).
-export([read_int64/1, read_int64_list/1, write_int64/1, write_int64_list/1]).
-export([read_double/1, read_double_list/1, write_double/1, write_double_list/1]).
-export([read_string/1, read_string_list/1, write_string/1, write_string_list/1]).
-export([read_record/2, read_record_list/2, write_record/2, write_record_list/2]).

-compile({inline,[
    read_bool/1, write_bool/1,
    read_int8/1, write_int8/1,
    read_int16/1, write_int16/1,
    read_int32/1, write_int32/1,
    read_int64/1, write_int64/1,
    read_double/1, write_double/1,
    read_string/1, write_string/1,
    read_record/2, write_record/2
]}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
read_bool(<<Val:8, Rest/binary>>) ->
    {Val > 0, Rest}.

read_int8(<<Val:8/signed, Rest/binary>>) ->
    {Val, Rest}.

read_int16(<<Val:16/signed, Rest/binary>>) ->
    {Val, Rest}.

read_int32(<<Val:32/signed, Rest/binary>>) ->
    {Val, Rest}.

read_int64(<<Val:64/signed, Rest/binary>>) ->
    {Val, Rest}.

read_double(<<Val:64/float, Rest/binary>>) ->
    {Val, Rest}.

read_string(<<Len:16, Val:Len/binary-unit:8, Rest/binary>>) ->
    {unicode:characters_to_list(Val, 'utf8'), Rest}.

read_record(Bin, Reader) ->
	Reader(Bin).

read_bool_list(<<Len:16, Rest/binary>>) ->
    read_list(Len, [], fun read_bool/1, Rest).

read_int8_list(<<Len:16, Rest/binary>>) ->
    read_list(Len, [], fun read_int8/1, Rest).

read_int16_list(<<Len:16, Rest/binary>>) ->
    read_list(Len, [], fun read_int16/1, Rest).

read_int32_list(<<Len:16, Rest/binary>>) ->
    read_list(Len, [], fun read_int32/1, Rest).

read_int64_list(<<Len:16, Rest/binary>>) ->
    read_list(Len, [], fun read_int64/1, Rest).

read_double_list(<<Len:16, Rest/binary>>) ->
    read_list(Len, [], fun read_double/1, Rest).

read_string_list(<<Len:16, Rest/binary>>) ->
    read_list(Len, [], fun read_string/1, Rest).

read_record_list(<<Len:16, Rest/binary>>, Reader) ->
    read_list(Len, [], Reader, Rest).

write_bool(undefined) ->
    <<0:8>>;
write_bool(Val) ->
    case Val of true -> <<1:8>>; false -> <<0:8>> end.

write_int8(undefined) ->
    <<0:8/signed>>;
write_int8(Val) ->
    <<Val:8/signed>>.

write_int16(undefined) ->
    <<0:16/signed>>;
write_int16(Val) ->
    <<Val:16/signed>>.

write_int32(undefined) ->
    <<0:32/signed>>;
write_int32(Val) ->
    <<Val:32/signed>>.

write_int64(undefined) ->
    <<0:64/signed>>;
write_int64(Val) ->
    <<Val:64/signed>>.

write_double(undefined) ->
    <<0:64/float>>;
write_double(Val) ->
    <<Val:64/float>>.

write_string(undefined) ->
    <<0:16>>;
write_string(Val) when is_list(Val) ->
    Bin = unicode:characters_to_binary(Val, utf8),
    <<(byte_size(Bin)):16, Bin/binary>>;
write_string(Bin) when is_binary(Bin) ->
    <<(byte_size(Bin)):16, Bin/binary>>.

write_record(undefined, _) ->
    <<0:8>>;
write_record(Val, Writer) ->
    <<1:8, (Writer(Val))/binary>>.


write_bool_list(List) ->
    write_list(List, fun write_bool/1).

write_int8_list(List) ->
    write_list(List, fun write_int8/1).

write_int16_list(List) ->
    write_list(List, fun write_int16/1).

write_int32_list(List) ->
    write_list(List, fun write_int32/1).

write_int64_list(List) ->
    write_list(List, fun write_int64/1).

write_double_list(List) ->
    write_list(List, fun write_double/1).

write_string_list(List) ->
    write_list(List, fun write_string/1).

write_record_list(List, Writer) ->
    write_list(List, Writer).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
read_list(0, List, _Reader, Bin) ->
    {lists:reverse(List), Bin};
read_list(Len, List, Reader, Bin) ->
    {Val, Rest} = Reader(Bin),
    read_list(Len - 1, [Val | List], Reader, Rest).

write_list(undefined, _) ->
    <<0:16>>;
write_list(List, Writer) ->
    Len = length(List),
    Bin = list_to_binary([Writer(Val) || Val <- List]),
    <<Len:16, Bin/binary>>.