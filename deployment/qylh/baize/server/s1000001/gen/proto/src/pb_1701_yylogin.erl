%% -*- coding: utf-8 -*-
%% @private
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1
-module(pb_1701_yylogin).

-export([encode_msg/1, encode_msg/2, encode_msg/3]).
-export([decode_msg/2, decode_msg/3]).
-export([merge_msgs/2, merge_msgs/3, merge_msgs/4]).
-export([verify_msg/1, verify_msg/2, verify_msg/3]).
-export([get_msg_defs/0]).
-export([get_msg_names/0]).
-export([get_group_names/0]).
-export([get_msg_or_group_names/0]).
-export([get_enum_names/0]).
-export([find_msg_def/1, fetch_msg_def/1]).
-export([find_enum_def/1, fetch_enum_def/1]).
-export([enum_symbol_by_value/2, enum_value_by_symbol/2]).
-export([get_service_names/0]).
-export([get_service_def/1]).
-export([get_rpc_names/1]).
-export([find_rpc_def/2, fetch_rpc_def/2]).
-export([fqbin_to_service_name/1]).
-export([service_name_to_fqbin/1]).
-export([fqbins_to_service_and_rpc_name/2]).
-export([service_and_rpc_name_to_fqbins/2]).
-export([get_package_name/0]).
-export([uses_packages/0]).
-export([gpb_version_as_string/0, gpb_version_as_list/0]).

-include("pb_1701_yylogin.hrl").
-include("gpb.hrl").

%% enumerated types

-export_type([]).

%% message types
-type m_yylogin_info_tos() :: #m_yylogin_info_tos{}.

-type m_yylogin_info_toc() :: #m_yylogin_info_toc{}.

-type m_yylogin_reward_tos() :: #m_yylogin_reward_tos{}.

-type m_yylogin_reward_toc() :: #m_yylogin_reward_toc{}.

-export_type(['m_yylogin_info_tos'/0, 'm_yylogin_info_toc'/0, 'm_yylogin_reward_tos'/0, 'm_yylogin_reward_toc'/0]).

-spec encode_msg(#m_yylogin_info_tos{} | #m_yylogin_info_toc{} | #m_yylogin_reward_tos{} | #m_yylogin_reward_toc{}) -> binary().
encode_msg(Msg) when tuple_size(Msg) >= 1 ->
    encode_msg(Msg, element(1, Msg), []).

-spec encode_msg(#m_yylogin_info_tos{} | #m_yylogin_info_toc{} | #m_yylogin_reward_tos{} | #m_yylogin_reward_toc{}, atom() | list()) -> binary().
encode_msg(Msg, MsgName) when is_atom(MsgName) ->
    encode_msg(Msg, MsgName, []);
encode_msg(Msg, Opts)
    when tuple_size(Msg) >= 1, is_list(Opts) ->
    encode_msg(Msg, element(1, Msg), Opts).

-spec encode_msg(#m_yylogin_info_tos{} | #m_yylogin_info_toc{} | #m_yylogin_reward_tos{} | #m_yylogin_reward_toc{}, atom(), list()) -> binary().
encode_msg(Msg, MsgName, Opts) ->
    case proplists:get_bool(verify, Opts) of
      true -> verify_msg(Msg, MsgName, Opts);
      false -> ok
    end,
    TrUserData = proplists:get_value(user_data, Opts),
    case MsgName of
      m_yylogin_info_tos ->
	  encode_msg_m_yylogin_info_tos(id(Msg, TrUserData),
					TrUserData);
      m_yylogin_info_toc ->
	  encode_msg_m_yylogin_info_toc(id(Msg, TrUserData),
					TrUserData);
      m_yylogin_reward_tos ->
	  encode_msg_m_yylogin_reward_tos(id(Msg, TrUserData),
					  TrUserData);
      m_yylogin_reward_toc ->
	  encode_msg_m_yylogin_reward_toc(id(Msg, TrUserData),
					  TrUserData)
    end.


encode_msg_m_yylogin_info_tos(_Msg, _TrUserData) ->
    <<>>.

encode_msg_m_yylogin_info_toc(Msg, TrUserData) ->
    encode_msg_m_yylogin_info_toc(Msg, <<>>, TrUserData).


encode_msg_m_yylogin_info_toc(#m_yylogin_info_toc{days =
						      F1,
						  list = F2},
			      Bin, TrUserData) ->
    B1 = begin
	   TrF1 = id(F1, TrUserData),
	   e_type_int32(TrF1, <<Bin/binary, 8>>, TrUserData)
	 end,
    begin
      TrF2 = id(F2, TrUserData),
      if TrF2 == [] -> B1;
	 true ->
	     e_field_m_yylogin_info_toc_list(TrF2, B1, TrUserData)
      end
    end.

encode_msg_m_yylogin_reward_tos(Msg, TrUserData) ->
    encode_msg_m_yylogin_reward_tos(Msg, <<>>, TrUserData).


encode_msg_m_yylogin_reward_tos(#m_yylogin_reward_tos{day
							  = F1},
				Bin, TrUserData) ->
    begin
      TrF1 = id(F1, TrUserData),
      e_type_int32(TrF1, <<Bin/binary, 8>>, TrUserData)
    end.

encode_msg_m_yylogin_reward_toc(Msg, TrUserData) ->
    encode_msg_m_yylogin_reward_toc(Msg, <<>>, TrUserData).


encode_msg_m_yylogin_reward_toc(#m_yylogin_reward_toc{day
							  = F1},
				Bin, TrUserData) ->
    begin
      TrF1 = id(F1, TrUserData),
      e_type_int32(TrF1, <<Bin/binary, 8>>, TrUserData)
    end.

e_field_m_yylogin_info_toc_list([Elem | Rest], Bin,
				TrUserData) ->
    Bin2 = <<Bin/binary, 16>>,
    Bin3 = e_type_int32(id(Elem, TrUserData), Bin2,
			TrUserData),
    e_field_m_yylogin_info_toc_list(Rest, Bin3, TrUserData);
e_field_m_yylogin_info_toc_list([], Bin, _TrUserData) ->
    Bin.

-compile({nowarn_unused_function,e_type_sint/3}).
e_type_sint(Value, Bin, _TrUserData) when Value >= 0 ->
    e_varint(Value * 2, Bin);
e_type_sint(Value, Bin, _TrUserData) ->
    e_varint(Value * -2 - 1, Bin).

-compile({nowarn_unused_function,e_type_int32/3}).
e_type_int32(Value, Bin, _TrUserData)
    when 0 =< Value, Value =< 127 ->
    <<Bin/binary, Value>>;
e_type_int32(Value, Bin, _TrUserData) ->
    <<N:64/unsigned-native>> = <<Value:64/signed-native>>,
    e_varint(N, Bin).

-compile({nowarn_unused_function,e_type_int64/3}).
e_type_int64(Value, Bin, _TrUserData)
    when 0 =< Value, Value =< 127 ->
    <<Bin/binary, Value>>;
e_type_int64(Value, Bin, _TrUserData) ->
    <<N:64/unsigned-native>> = <<Value:64/signed-native>>,
    e_varint(N, Bin).

-compile({nowarn_unused_function,e_type_bool/3}).
e_type_bool(true, Bin, _TrUserData) ->
    <<Bin/binary, 1>>;
e_type_bool(false, Bin, _TrUserData) ->
    <<Bin/binary, 0>>;
e_type_bool(1, Bin, _TrUserData) -> <<Bin/binary, 1>>;
e_type_bool(0, Bin, _TrUserData) -> <<Bin/binary, 0>>.

-compile({nowarn_unused_function,e_type_string/3}).
e_type_string(S, Bin, _TrUserData) ->
    Utf8 = unicode:characters_to_binary(S),
    Bin2 = e_varint(byte_size(Utf8), Bin),
    <<Bin2/binary, Utf8/binary>>.

-compile({nowarn_unused_function,e_type_bytes/3}).
e_type_bytes(Bytes, Bin, _TrUserData)
    when is_binary(Bytes) ->
    Bin2 = e_varint(byte_size(Bytes), Bin),
    <<Bin2/binary, Bytes/binary>>;
e_type_bytes(Bytes, Bin, _TrUserData)
    when is_list(Bytes) ->
    BytesBin = iolist_to_binary(Bytes),
    Bin2 = e_varint(byte_size(BytesBin), Bin),
    <<Bin2/binary, BytesBin/binary>>.

-compile({nowarn_unused_function,e_type_fixed32/3}).
e_type_fixed32(Value, Bin, _TrUserData) ->
    <<Bin/binary, Value:32/little>>.

-compile({nowarn_unused_function,e_type_sfixed32/3}).
e_type_sfixed32(Value, Bin, _TrUserData) ->
    <<Bin/binary, Value:32/little-signed>>.

-compile({nowarn_unused_function,e_type_fixed64/3}).
e_type_fixed64(Value, Bin, _TrUserData) ->
    <<Bin/binary, Value:64/little>>.

-compile({nowarn_unused_function,e_type_sfixed64/3}).
e_type_sfixed64(Value, Bin, _TrUserData) ->
    <<Bin/binary, Value:64/little-signed>>.

-compile({nowarn_unused_function,e_type_float/3}).
e_type_float(V, Bin, _) when is_number(V) ->
    <<Bin/binary, V:32/little-float>>;
e_type_float(infinity, Bin, _) ->
    <<Bin/binary, 0:16, 128, 127>>;
e_type_float('-infinity', Bin, _) ->
    <<Bin/binary, 0:16, 128, 255>>;
e_type_float(nan, Bin, _) ->
    <<Bin/binary, 0:16, 192, 127>>.

-compile({nowarn_unused_function,e_type_double/3}).
e_type_double(V, Bin, _) when is_number(V) ->
    <<Bin/binary, V:64/little-float>>;
e_type_double(infinity, Bin, _) ->
    <<Bin/binary, 0:48, 240, 127>>;
e_type_double('-infinity', Bin, _) ->
    <<Bin/binary, 0:48, 240, 255>>;
e_type_double(nan, Bin, _) ->
    <<Bin/binary, 0:48, 248, 127>>.

-compile({nowarn_unused_function,e_varint/3}).
e_varint(N, Bin, _TrUserData) -> e_varint(N, Bin).

-compile({nowarn_unused_function,e_varint/2}).
e_varint(N, Bin) when N =< 127 -> <<Bin/binary, N>>;
e_varint(N, Bin) ->
    Bin2 = <<Bin/binary, (N band 127 bor 128)>>,
    e_varint(N bsr 7, Bin2).


decode_msg(Bin, MsgName) when is_binary(Bin) ->
    decode_msg(Bin, MsgName, []).

decode_msg(Bin, MsgName, Opts) when is_binary(Bin) ->
    TrUserData = proplists:get_value(user_data, Opts),
    decode_msg_1_catch(Bin, MsgName, TrUserData).

-ifdef('OTP_RELEASE').
decode_msg_1_catch(Bin, MsgName, TrUserData) ->
    try decode_msg_2_doit(MsgName, Bin, TrUserData)
    catch Class:Reason:StackTrace -> error({gpb_error,{decoding_failure, {Bin, MsgName, {Class, Reason, StackTrace}}}})
    end.
-else.
decode_msg_1_catch(Bin, MsgName, TrUserData) ->
    try decode_msg_2_doit(MsgName, Bin, TrUserData)
    catch Class:Reason ->
        StackTrace = erlang:get_stacktrace(),
        error({gpb_error,{decoding_failure, {Bin, MsgName, {Class, Reason, StackTrace}}}})
    end.
-endif.

decode_msg_2_doit(m_yylogin_info_tos, Bin,
		  TrUserData) ->
    id(decode_msg_m_yylogin_info_tos(Bin, TrUserData),
       TrUserData);
decode_msg_2_doit(m_yylogin_info_toc, Bin,
		  TrUserData) ->
    id(decode_msg_m_yylogin_info_toc(Bin, TrUserData),
       TrUserData);
decode_msg_2_doit(m_yylogin_reward_tos, Bin,
		  TrUserData) ->
    id(decode_msg_m_yylogin_reward_tos(Bin, TrUserData),
       TrUserData);
decode_msg_2_doit(m_yylogin_reward_toc, Bin,
		  TrUserData) ->
    id(decode_msg_m_yylogin_reward_toc(Bin, TrUserData),
       TrUserData).



decode_msg_m_yylogin_info_tos(Bin, TrUserData) ->
    dfp_read_field_def_m_yylogin_info_tos(Bin, 0, 0,
					  TrUserData).

dfp_read_field_def_m_yylogin_info_tos(<<>>, 0, 0, _) ->
    #m_yylogin_info_tos{};
dfp_read_field_def_m_yylogin_info_tos(Other, Z1, Z2,
				      TrUserData) ->
    dg_read_field_def_m_yylogin_info_tos(Other, Z1, Z2,
					 TrUserData).

dg_read_field_def_m_yylogin_info_tos(<<1:1, X:7,
				       Rest/binary>>,
				     N, Acc, TrUserData)
    when N < 32 - 7 ->
    dg_read_field_def_m_yylogin_info_tos(Rest, N + 7,
					 X bsl N + Acc, TrUserData);
dg_read_field_def_m_yylogin_info_tos(<<0:1, X:7,
				       Rest/binary>>,
				     N, Acc, TrUserData) ->
    Key = X bsl N + Acc,
    case Key band 7 of
      0 ->
	  skip_varint_m_yylogin_info_tos(Rest, 0, 0, TrUserData);
      1 -> skip_64_m_yylogin_info_tos(Rest, 0, 0, TrUserData);
      2 ->
	  skip_length_delimited_m_yylogin_info_tos(Rest, 0, 0,
						   TrUserData);
      3 ->
	  skip_group_m_yylogin_info_tos(Rest, Key bsr 3, 0,
					TrUserData);
      5 -> skip_32_m_yylogin_info_tos(Rest, 0, 0, TrUserData)
    end;
dg_read_field_def_m_yylogin_info_tos(<<>>, 0, 0, _) ->
    #m_yylogin_info_tos{}.

skip_varint_m_yylogin_info_tos(<<1:1, _:7,
				 Rest/binary>>,
			       Z1, Z2, TrUserData) ->
    skip_varint_m_yylogin_info_tos(Rest, Z1, Z2,
				   TrUserData);
skip_varint_m_yylogin_info_tos(<<0:1, _:7,
				 Rest/binary>>,
			       Z1, Z2, TrUserData) ->
    dfp_read_field_def_m_yylogin_info_tos(Rest, Z1, Z2,
					  TrUserData).

skip_length_delimited_m_yylogin_info_tos(<<1:1, X:7,
					   Rest/binary>>,
					 N, Acc, TrUserData)
    when N < 57 ->
    skip_length_delimited_m_yylogin_info_tos(Rest, N + 7,
					     X bsl N + Acc, TrUserData);
skip_length_delimited_m_yylogin_info_tos(<<0:1, X:7,
					   Rest/binary>>,
					 N, Acc, TrUserData) ->
    Length = X bsl N + Acc,
    <<_:Length/binary, Rest2/binary>> = Rest,
    dfp_read_field_def_m_yylogin_info_tos(Rest2, 0, 0,
					  TrUserData).

skip_group_m_yylogin_info_tos(Bin, FNum, Z2,
			      TrUserData) ->
    {_, Rest} = read_group(Bin, FNum),
    dfp_read_field_def_m_yylogin_info_tos(Rest, 0, Z2,
					  TrUserData).

skip_32_m_yylogin_info_tos(<<_:32, Rest/binary>>, Z1,
			   Z2, TrUserData) ->
    dfp_read_field_def_m_yylogin_info_tos(Rest, Z1, Z2,
					  TrUserData).

skip_64_m_yylogin_info_tos(<<_:64, Rest/binary>>, Z1,
			   Z2, TrUserData) ->
    dfp_read_field_def_m_yylogin_info_tos(Rest, Z1, Z2,
					  TrUserData).

decode_msg_m_yylogin_info_toc(Bin, TrUserData) ->
    dfp_read_field_def_m_yylogin_info_toc(Bin, 0, 0,
					  id(undefined, TrUserData),
					  id([], TrUserData), TrUserData).

dfp_read_field_def_m_yylogin_info_toc(<<8,
					Rest/binary>>,
				      Z1, Z2, F@_1, F@_2, TrUserData) ->
    d_field_m_yylogin_info_toc_days(Rest, Z1, Z2, F@_1,
				    F@_2, TrUserData);
dfp_read_field_def_m_yylogin_info_toc(<<18,
					Rest/binary>>,
				      Z1, Z2, F@_1, F@_2, TrUserData) ->
    d_pfield_m_yylogin_info_toc_list(Rest, Z1, Z2, F@_1,
				     F@_2, TrUserData);
dfp_read_field_def_m_yylogin_info_toc(<<16,
					Rest/binary>>,
				      Z1, Z2, F@_1, F@_2, TrUserData) ->
    d_field_m_yylogin_info_toc_list(Rest, Z1, Z2, F@_1,
				    F@_2, TrUserData);
dfp_read_field_def_m_yylogin_info_toc(<<>>, 0, 0, F@_1,
				      R1, TrUserData) ->
    #m_yylogin_info_toc{days = F@_1,
			list = lists_reverse(R1, TrUserData)};
dfp_read_field_def_m_yylogin_info_toc(Other, Z1, Z2,
				      F@_1, F@_2, TrUserData) ->
    dg_read_field_def_m_yylogin_info_toc(Other, Z1, Z2,
					 F@_1, F@_2, TrUserData).

dg_read_field_def_m_yylogin_info_toc(<<1:1, X:7,
				       Rest/binary>>,
				     N, Acc, F@_1, F@_2, TrUserData)
    when N < 32 - 7 ->
    dg_read_field_def_m_yylogin_info_toc(Rest, N + 7,
					 X bsl N + Acc, F@_1, F@_2, TrUserData);
dg_read_field_def_m_yylogin_info_toc(<<0:1, X:7,
				       Rest/binary>>,
				     N, Acc, F@_1, F@_2, TrUserData) ->
    Key = X bsl N + Acc,
    case Key of
      8 ->
	  d_field_m_yylogin_info_toc_days(Rest, 0, 0, F@_1, F@_2,
					  TrUserData);
      18 ->
	  d_pfield_m_yylogin_info_toc_list(Rest, 0, 0, F@_1, F@_2,
					   TrUserData);
      16 ->
	  d_field_m_yylogin_info_toc_list(Rest, 0, 0, F@_1, F@_2,
					  TrUserData);
      _ ->
	  case Key band 7 of
	    0 ->
		skip_varint_m_yylogin_info_toc(Rest, 0, 0, F@_1, F@_2,
					       TrUserData);
	    1 ->
		skip_64_m_yylogin_info_toc(Rest, 0, 0, F@_1, F@_2,
					   TrUserData);
	    2 ->
		skip_length_delimited_m_yylogin_info_toc(Rest, 0, 0,
							 F@_1, F@_2,
							 TrUserData);
	    3 ->
		skip_group_m_yylogin_info_toc(Rest, Key bsr 3, 0, F@_1,
					      F@_2, TrUserData);
	    5 ->
		skip_32_m_yylogin_info_toc(Rest, 0, 0, F@_1, F@_2,
					   TrUserData)
	  end
    end;
dg_read_field_def_m_yylogin_info_toc(<<>>, 0, 0, F@_1,
				     R1, TrUserData) ->
    #m_yylogin_info_toc{days = F@_1,
			list = lists_reverse(R1, TrUserData)}.

d_field_m_yylogin_info_toc_days(<<1:1, X:7,
				  Rest/binary>>,
				N, Acc, F@_1, F@_2, TrUserData)
    when N < 57 ->
    d_field_m_yylogin_info_toc_days(Rest, N + 7,
				    X bsl N + Acc, F@_1, F@_2, TrUserData);
d_field_m_yylogin_info_toc_days(<<0:1, X:7,
				  Rest/binary>>,
				N, Acc, _, F@_2, TrUserData) ->
    {NewFValue, RestF} = {begin
			    <<Res:32/signed-native>> = <<(X bsl N +
							    Acc):32/unsigned-native>>,
			    id(Res, TrUserData)
			  end,
			  Rest},
    dfp_read_field_def_m_yylogin_info_toc(RestF, 0, 0,
					  NewFValue, F@_2, TrUserData).

d_field_m_yylogin_info_toc_list(<<1:1, X:7,
				  Rest/binary>>,
				N, Acc, F@_1, F@_2, TrUserData)
    when N < 57 ->
    d_field_m_yylogin_info_toc_list(Rest, N + 7,
				    X bsl N + Acc, F@_1, F@_2, TrUserData);
d_field_m_yylogin_info_toc_list(<<0:1, X:7,
				  Rest/binary>>,
				N, Acc, F@_1, Prev, TrUserData) ->
    {NewFValue, RestF} = {begin
			    <<Res:32/signed-native>> = <<(X bsl N +
							    Acc):32/unsigned-native>>,
			    id(Res, TrUserData)
			  end,
			  Rest},
    dfp_read_field_def_m_yylogin_info_toc(RestF, 0, 0, F@_1,
					  cons(NewFValue, Prev, TrUserData),
					  TrUserData).

d_pfield_m_yylogin_info_toc_list(<<1:1, X:7,
				   Rest/binary>>,
				 N, Acc, F@_1, F@_2, TrUserData)
    when N < 57 ->
    d_pfield_m_yylogin_info_toc_list(Rest, N + 7,
				     X bsl N + Acc, F@_1, F@_2, TrUserData);
d_pfield_m_yylogin_info_toc_list(<<0:1, X:7,
				   Rest/binary>>,
				 N, Acc, F@_1, E, TrUserData) ->
    Len = X bsl N + Acc,
    <<PackedBytes:Len/binary, Rest2/binary>> = Rest,
    NewSeq =
	d_packed_field_m_yylogin_info_toc_list(PackedBytes, 0,
					       0, E, TrUserData),
    dfp_read_field_def_m_yylogin_info_toc(Rest2, 0, 0, F@_1,
					  NewSeq, TrUserData).

d_packed_field_m_yylogin_info_toc_list(<<1:1, X:7,
					 Rest/binary>>,
				       N, Acc, AccSeq, TrUserData)
    when N < 57 ->
    d_packed_field_m_yylogin_info_toc_list(Rest, N + 7,
					   X bsl N + Acc, AccSeq, TrUserData);
d_packed_field_m_yylogin_info_toc_list(<<0:1, X:7,
					 Rest/binary>>,
				       N, Acc, AccSeq, TrUserData) ->
    {NewFValue, RestF} = {begin
			    <<Res:32/signed-native>> = <<(X bsl N +
							    Acc):32/unsigned-native>>,
			    id(Res, TrUserData)
			  end,
			  Rest},
    d_packed_field_m_yylogin_info_toc_list(RestF, 0, 0,
					   [NewFValue | AccSeq], TrUserData);
d_packed_field_m_yylogin_info_toc_list(<<>>, 0, 0,
				       AccSeq, _) ->
    AccSeq.

skip_varint_m_yylogin_info_toc(<<1:1, _:7,
				 Rest/binary>>,
			       Z1, Z2, F@_1, F@_2, TrUserData) ->
    skip_varint_m_yylogin_info_toc(Rest, Z1, Z2, F@_1, F@_2,
				   TrUserData);
skip_varint_m_yylogin_info_toc(<<0:1, _:7,
				 Rest/binary>>,
			       Z1, Z2, F@_1, F@_2, TrUserData) ->
    dfp_read_field_def_m_yylogin_info_toc(Rest, Z1, Z2,
					  F@_1, F@_2, TrUserData).

skip_length_delimited_m_yylogin_info_toc(<<1:1, X:7,
					   Rest/binary>>,
					 N, Acc, F@_1, F@_2, TrUserData)
    when N < 57 ->
    skip_length_delimited_m_yylogin_info_toc(Rest, N + 7,
					     X bsl N + Acc, F@_1, F@_2,
					     TrUserData);
skip_length_delimited_m_yylogin_info_toc(<<0:1, X:7,
					   Rest/binary>>,
					 N, Acc, F@_1, F@_2, TrUserData) ->
    Length = X bsl N + Acc,
    <<_:Length/binary, Rest2/binary>> = Rest,
    dfp_read_field_def_m_yylogin_info_toc(Rest2, 0, 0, F@_1,
					  F@_2, TrUserData).

skip_group_m_yylogin_info_toc(Bin, FNum, Z2, F@_1, F@_2,
			      TrUserData) ->
    {_, Rest} = read_group(Bin, FNum),
    dfp_read_field_def_m_yylogin_info_toc(Rest, 0, Z2, F@_1,
					  F@_2, TrUserData).

skip_32_m_yylogin_info_toc(<<_:32, Rest/binary>>, Z1,
			   Z2, F@_1, F@_2, TrUserData) ->
    dfp_read_field_def_m_yylogin_info_toc(Rest, Z1, Z2,
					  F@_1, F@_2, TrUserData).

skip_64_m_yylogin_info_toc(<<_:64, Rest/binary>>, Z1,
			   Z2, F@_1, F@_2, TrUserData) ->
    dfp_read_field_def_m_yylogin_info_toc(Rest, Z1, Z2,
					  F@_1, F@_2, TrUserData).

decode_msg_m_yylogin_reward_tos(Bin, TrUserData) ->
    dfp_read_field_def_m_yylogin_reward_tos(Bin, 0, 0,
					    id(undefined, TrUserData),
					    TrUserData).

dfp_read_field_def_m_yylogin_reward_tos(<<8,
					  Rest/binary>>,
					Z1, Z2, F@_1, TrUserData) ->
    d_field_m_yylogin_reward_tos_day(Rest, Z1, Z2, F@_1,
				     TrUserData);
dfp_read_field_def_m_yylogin_reward_tos(<<>>, 0, 0,
					F@_1, _) ->
    #m_yylogin_reward_tos{day = F@_1};
dfp_read_field_def_m_yylogin_reward_tos(Other, Z1, Z2,
					F@_1, TrUserData) ->
    dg_read_field_def_m_yylogin_reward_tos(Other, Z1, Z2,
					   F@_1, TrUserData).

dg_read_field_def_m_yylogin_reward_tos(<<1:1, X:7,
					 Rest/binary>>,
				       N, Acc, F@_1, TrUserData)
    when N < 32 - 7 ->
    dg_read_field_def_m_yylogin_reward_tos(Rest, N + 7,
					   X bsl N + Acc, F@_1, TrUserData);
dg_read_field_def_m_yylogin_reward_tos(<<0:1, X:7,
					 Rest/binary>>,
				       N, Acc, F@_1, TrUserData) ->
    Key = X bsl N + Acc,
    case Key of
      8 ->
	  d_field_m_yylogin_reward_tos_day(Rest, 0, 0, F@_1,
					   TrUserData);
      _ ->
	  case Key band 7 of
	    0 ->
		skip_varint_m_yylogin_reward_tos(Rest, 0, 0, F@_1,
						 TrUserData);
	    1 ->
		skip_64_m_yylogin_reward_tos(Rest, 0, 0, F@_1,
					     TrUserData);
	    2 ->
		skip_length_delimited_m_yylogin_reward_tos(Rest, 0, 0,
							   F@_1, TrUserData);
	    3 ->
		skip_group_m_yylogin_reward_tos(Rest, Key bsr 3, 0,
						F@_1, TrUserData);
	    5 ->
		skip_32_m_yylogin_reward_tos(Rest, 0, 0, F@_1,
					     TrUserData)
	  end
    end;
dg_read_field_def_m_yylogin_reward_tos(<<>>, 0, 0, F@_1,
				       _) ->
    #m_yylogin_reward_tos{day = F@_1}.

d_field_m_yylogin_reward_tos_day(<<1:1, X:7,
				   Rest/binary>>,
				 N, Acc, F@_1, TrUserData)
    when N < 57 ->
    d_field_m_yylogin_reward_tos_day(Rest, N + 7,
				     X bsl N + Acc, F@_1, TrUserData);
d_field_m_yylogin_reward_tos_day(<<0:1, X:7,
				   Rest/binary>>,
				 N, Acc, _, TrUserData) ->
    {NewFValue, RestF} = {begin
			    <<Res:32/signed-native>> = <<(X bsl N +
							    Acc):32/unsigned-native>>,
			    id(Res, TrUserData)
			  end,
			  Rest},
    dfp_read_field_def_m_yylogin_reward_tos(RestF, 0, 0,
					    NewFValue, TrUserData).

skip_varint_m_yylogin_reward_tos(<<1:1, _:7,
				   Rest/binary>>,
				 Z1, Z2, F@_1, TrUserData) ->
    skip_varint_m_yylogin_reward_tos(Rest, Z1, Z2, F@_1,
				     TrUserData);
skip_varint_m_yylogin_reward_tos(<<0:1, _:7,
				   Rest/binary>>,
				 Z1, Z2, F@_1, TrUserData) ->
    dfp_read_field_def_m_yylogin_reward_tos(Rest, Z1, Z2,
					    F@_1, TrUserData).

skip_length_delimited_m_yylogin_reward_tos(<<1:1, X:7,
					     Rest/binary>>,
					   N, Acc, F@_1, TrUserData)
    when N < 57 ->
    skip_length_delimited_m_yylogin_reward_tos(Rest, N + 7,
					       X bsl N + Acc, F@_1, TrUserData);
skip_length_delimited_m_yylogin_reward_tos(<<0:1, X:7,
					     Rest/binary>>,
					   N, Acc, F@_1, TrUserData) ->
    Length = X bsl N + Acc,
    <<_:Length/binary, Rest2/binary>> = Rest,
    dfp_read_field_def_m_yylogin_reward_tos(Rest2, 0, 0,
					    F@_1, TrUserData).

skip_group_m_yylogin_reward_tos(Bin, FNum, Z2, F@_1,
				TrUserData) ->
    {_, Rest} = read_group(Bin, FNum),
    dfp_read_field_def_m_yylogin_reward_tos(Rest, 0, Z2,
					    F@_1, TrUserData).

skip_32_m_yylogin_reward_tos(<<_:32, Rest/binary>>, Z1,
			     Z2, F@_1, TrUserData) ->
    dfp_read_field_def_m_yylogin_reward_tos(Rest, Z1, Z2,
					    F@_1, TrUserData).

skip_64_m_yylogin_reward_tos(<<_:64, Rest/binary>>, Z1,
			     Z2, F@_1, TrUserData) ->
    dfp_read_field_def_m_yylogin_reward_tos(Rest, Z1, Z2,
					    F@_1, TrUserData).

decode_msg_m_yylogin_reward_toc(Bin, TrUserData) ->
    dfp_read_field_def_m_yylogin_reward_toc(Bin, 0, 0,
					    id(undefined, TrUserData),
					    TrUserData).

dfp_read_field_def_m_yylogin_reward_toc(<<8,
					  Rest/binary>>,
					Z1, Z2, F@_1, TrUserData) ->
    d_field_m_yylogin_reward_toc_day(Rest, Z1, Z2, F@_1,
				     TrUserData);
dfp_read_field_def_m_yylogin_reward_toc(<<>>, 0, 0,
					F@_1, _) ->
    #m_yylogin_reward_toc{day = F@_1};
dfp_read_field_def_m_yylogin_reward_toc(Other, Z1, Z2,
					F@_1, TrUserData) ->
    dg_read_field_def_m_yylogin_reward_toc(Other, Z1, Z2,
					   F@_1, TrUserData).

dg_read_field_def_m_yylogin_reward_toc(<<1:1, X:7,
					 Rest/binary>>,
				       N, Acc, F@_1, TrUserData)
    when N < 32 - 7 ->
    dg_read_field_def_m_yylogin_reward_toc(Rest, N + 7,
					   X bsl N + Acc, F@_1, TrUserData);
dg_read_field_def_m_yylogin_reward_toc(<<0:1, X:7,
					 Rest/binary>>,
				       N, Acc, F@_1, TrUserData) ->
    Key = X bsl N + Acc,
    case Key of
      8 ->
	  d_field_m_yylogin_reward_toc_day(Rest, 0, 0, F@_1,
					   TrUserData);
      _ ->
	  case Key band 7 of
	    0 ->
		skip_varint_m_yylogin_reward_toc(Rest, 0, 0, F@_1,
						 TrUserData);
	    1 ->
		skip_64_m_yylogin_reward_toc(Rest, 0, 0, F@_1,
					     TrUserData);
	    2 ->
		skip_length_delimited_m_yylogin_reward_toc(Rest, 0, 0,
							   F@_1, TrUserData);
	    3 ->
		skip_group_m_yylogin_reward_toc(Rest, Key bsr 3, 0,
						F@_1, TrUserData);
	    5 ->
		skip_32_m_yylogin_reward_toc(Rest, 0, 0, F@_1,
					     TrUserData)
	  end
    end;
dg_read_field_def_m_yylogin_reward_toc(<<>>, 0, 0, F@_1,
				       _) ->
    #m_yylogin_reward_toc{day = F@_1}.

d_field_m_yylogin_reward_toc_day(<<1:1, X:7,
				   Rest/binary>>,
				 N, Acc, F@_1, TrUserData)
    when N < 57 ->
    d_field_m_yylogin_reward_toc_day(Rest, N + 7,
				     X bsl N + Acc, F@_1, TrUserData);
d_field_m_yylogin_reward_toc_day(<<0:1, X:7,
				   Rest/binary>>,
				 N, Acc, _, TrUserData) ->
    {NewFValue, RestF} = {begin
			    <<Res:32/signed-native>> = <<(X bsl N +
							    Acc):32/unsigned-native>>,
			    id(Res, TrUserData)
			  end,
			  Rest},
    dfp_read_field_def_m_yylogin_reward_toc(RestF, 0, 0,
					    NewFValue, TrUserData).

skip_varint_m_yylogin_reward_toc(<<1:1, _:7,
				   Rest/binary>>,
				 Z1, Z2, F@_1, TrUserData) ->
    skip_varint_m_yylogin_reward_toc(Rest, Z1, Z2, F@_1,
				     TrUserData);
skip_varint_m_yylogin_reward_toc(<<0:1, _:7,
				   Rest/binary>>,
				 Z1, Z2, F@_1, TrUserData) ->
    dfp_read_field_def_m_yylogin_reward_toc(Rest, Z1, Z2,
					    F@_1, TrUserData).

skip_length_delimited_m_yylogin_reward_toc(<<1:1, X:7,
					     Rest/binary>>,
					   N, Acc, F@_1, TrUserData)
    when N < 57 ->
    skip_length_delimited_m_yylogin_reward_toc(Rest, N + 7,
					       X bsl N + Acc, F@_1, TrUserData);
skip_length_delimited_m_yylogin_reward_toc(<<0:1, X:7,
					     Rest/binary>>,
					   N, Acc, F@_1, TrUserData) ->
    Length = X bsl N + Acc,
    <<_:Length/binary, Rest2/binary>> = Rest,
    dfp_read_field_def_m_yylogin_reward_toc(Rest2, 0, 0,
					    F@_1, TrUserData).

skip_group_m_yylogin_reward_toc(Bin, FNum, Z2, F@_1,
				TrUserData) ->
    {_, Rest} = read_group(Bin, FNum),
    dfp_read_field_def_m_yylogin_reward_toc(Rest, 0, Z2,
					    F@_1, TrUserData).

skip_32_m_yylogin_reward_toc(<<_:32, Rest/binary>>, Z1,
			     Z2, F@_1, TrUserData) ->
    dfp_read_field_def_m_yylogin_reward_toc(Rest, Z1, Z2,
					    F@_1, TrUserData).

skip_64_m_yylogin_reward_toc(<<_:64, Rest/binary>>, Z1,
			     Z2, F@_1, TrUserData) ->
    dfp_read_field_def_m_yylogin_reward_toc(Rest, Z1, Z2,
					    F@_1, TrUserData).

read_group(Bin, FieldNum) ->
    {NumBytes, EndTagLen} = read_gr_b(Bin, 0, 0, 0, 0, FieldNum),
    <<Group:NumBytes/binary, _:EndTagLen/binary, Rest/binary>> = Bin,
    {Group, Rest}.

%% Like skipping over fields, but record the total length,
%% Each field is <(FieldNum bsl 3) bor FieldType> ++ <FieldValue>
%% Record the length because varints may be non-optimally encoded.
%%
%% Groups can be nested, but assume the same FieldNum cannot be nested
%% because group field numbers are shared with the rest of the fields
%% numbers. Thus we can search just for an group-end with the same
%% field number.
%%
%% (The only time the same group field number could occur would
%% be in a nested sub message, but then it would be inside a
%% length-delimited entry, which we skip-read by length.)
read_gr_b(<<1:1, X:7, Tl/binary>>, N, Acc, NumBytes, TagLen, FieldNum)
  when N < (32-7) ->
    read_gr_b(Tl, N+7, X bsl N + Acc, NumBytes, TagLen+1, FieldNum);
read_gr_b(<<0:1, X:7, Tl/binary>>, N, Acc, NumBytes, TagLen,
          FieldNum) ->
    Key = X bsl N + Acc,
    TagLen1 = TagLen + 1,
    case {Key bsr 3, Key band 7} of
        {FieldNum, 4} -> % 4 = group_end
            {NumBytes, TagLen1};
        {_, 0} -> % 0 = varint
            read_gr_vi(Tl, 0, NumBytes + TagLen1, FieldNum);
        {_, 1} -> % 1 = bits64
            <<_:64, Tl2/binary>> = Tl,
            read_gr_b(Tl2, 0, 0, NumBytes + TagLen1 + 8, 0, FieldNum);
        {_, 2} -> % 2 = length_delimited
            read_gr_ld(Tl, 0, 0, NumBytes + TagLen1, FieldNum);
        {_, 3} -> % 3 = group_start
            read_gr_b(Tl, 0, 0, NumBytes + TagLen1, 0, FieldNum);
        {_, 4} -> % 4 = group_end
            read_gr_b(Tl, 0, 0, NumBytes + TagLen1, 0, FieldNum);
        {_, 5} -> % 5 = bits32
            <<_:32, Tl2/binary>> = Tl,
            read_gr_b(Tl2, 0, 0, NumBytes + TagLen1 + 4, 0, FieldNum)
    end.

read_gr_vi(<<1:1, _:7, Tl/binary>>, N, NumBytes, FieldNum)
  when N < (64-7) ->
    read_gr_vi(Tl, N+7, NumBytes+1, FieldNum);
read_gr_vi(<<0:1, _:7, Tl/binary>>, _, NumBytes, FieldNum) ->
    read_gr_b(Tl, 0, 0, NumBytes+1, 0, FieldNum).

read_gr_ld(<<1:1, X:7, Tl/binary>>, N, Acc, NumBytes, FieldNum)
  when N < (64-7) ->
    read_gr_ld(Tl, N+7, X bsl N + Acc, NumBytes+1, FieldNum);
read_gr_ld(<<0:1, X:7, Tl/binary>>, N, Acc, NumBytes, FieldNum) ->
    Len = X bsl N + Acc,
    NumBytes1 = NumBytes + 1,
    <<_:Len/binary, Tl2/binary>> = Tl,
    read_gr_b(Tl2, 0, 0, NumBytes1 + Len, 0, FieldNum).

merge_msgs(Prev, New)
    when element(1, Prev) =:= element(1, New) ->
    merge_msgs(Prev, New, element(1, Prev), []).

merge_msgs(Prev, New, MsgName) when is_atom(MsgName) ->
    merge_msgs(Prev, New, MsgName, []);
merge_msgs(Prev, New, Opts)
    when element(1, Prev) =:= element(1, New),
	 is_list(Opts) ->
    merge_msgs(Prev, New, element(1, Prev), Opts).

merge_msgs(Prev, New, MsgName, Opts) ->
    TrUserData = proplists:get_value(user_data, Opts),
    case MsgName of
      m_yylogin_info_tos ->
	  merge_msg_m_yylogin_info_tos(Prev, New, TrUserData);
      m_yylogin_info_toc ->
	  merge_msg_m_yylogin_info_toc(Prev, New, TrUserData);
      m_yylogin_reward_tos ->
	  merge_msg_m_yylogin_reward_tos(Prev, New, TrUserData);
      m_yylogin_reward_toc ->
	  merge_msg_m_yylogin_reward_toc(Prev, New, TrUserData)
    end.

-compile({nowarn_unused_function,merge_msg_m_yylogin_info_tos/3}).
merge_msg_m_yylogin_info_tos(_Prev, New, _TrUserData) ->
    New.

-compile({nowarn_unused_function,merge_msg_m_yylogin_info_toc/3}).
merge_msg_m_yylogin_info_toc(#m_yylogin_info_toc{list =
						     PFlist},
			     #m_yylogin_info_toc{days = NFdays, list = NFlist},
			     TrUserData) ->
    #m_yylogin_info_toc{days = NFdays,
			list =
			    if PFlist /= undefined, NFlist /= undefined ->
				   'erlang_++'(PFlist, NFlist, TrUserData);
			       PFlist == undefined -> NFlist;
			       NFlist == undefined -> PFlist
			    end}.

-compile({nowarn_unused_function,merge_msg_m_yylogin_reward_tos/3}).
merge_msg_m_yylogin_reward_tos(#m_yylogin_reward_tos{},
			       #m_yylogin_reward_tos{day = NFday}, _) ->
    #m_yylogin_reward_tos{day = NFday}.

-compile({nowarn_unused_function,merge_msg_m_yylogin_reward_toc/3}).
merge_msg_m_yylogin_reward_toc(#m_yylogin_reward_toc{},
			       #m_yylogin_reward_toc{day = NFday}, _) ->
    #m_yylogin_reward_toc{day = NFday}.


verify_msg(Msg) when tuple_size(Msg) >= 1 ->
    verify_msg(Msg, element(1, Msg), []);
verify_msg(X) ->
    mk_type_error(not_a_known_message, X, []).

verify_msg(Msg, MsgName) when is_atom(MsgName) ->
    verify_msg(Msg, MsgName, []);
verify_msg(Msg, Opts) when tuple_size(Msg) >= 1 ->
    verify_msg(Msg, element(1, Msg), Opts);
verify_msg(X, _Opts) ->
    mk_type_error(not_a_known_message, X, []).

verify_msg(Msg, MsgName, Opts) ->
    TrUserData = proplists:get_value(user_data, Opts),
    case MsgName of
      m_yylogin_info_tos ->
	  v_msg_m_yylogin_info_tos(Msg, [MsgName], TrUserData);
      m_yylogin_info_toc ->
	  v_msg_m_yylogin_info_toc(Msg, [MsgName], TrUserData);
      m_yylogin_reward_tos ->
	  v_msg_m_yylogin_reward_tos(Msg, [MsgName], TrUserData);
      m_yylogin_reward_toc ->
	  v_msg_m_yylogin_reward_toc(Msg, [MsgName], TrUserData);
      _ -> mk_type_error(not_a_known_message, Msg, [])
    end.


-compile({nowarn_unused_function,v_msg_m_yylogin_info_tos/3}).
-dialyzer({nowarn_function,v_msg_m_yylogin_info_tos/3}).
v_msg_m_yylogin_info_tos(#m_yylogin_info_tos{}, _Path,
			 _) ->
    ok;
v_msg_m_yylogin_info_tos(X, Path, _TrUserData) ->
    mk_type_error({expected_msg, m_yylogin_info_tos}, X,
		  Path).

-compile({nowarn_unused_function,v_msg_m_yylogin_info_toc/3}).
-dialyzer({nowarn_function,v_msg_m_yylogin_info_toc/3}).
v_msg_m_yylogin_info_toc(#m_yylogin_info_toc{days = F1,
					     list = F2},
			 Path, TrUserData) ->
    v_type_int32(F1, [days | Path], TrUserData),
    if is_list(F2) ->
	   _ = [v_type_int32(Elem, [list | Path], TrUserData)
		|| Elem <- F2],
	   ok;
       true ->
	   mk_type_error({invalid_list_of, int32}, F2,
			 [list | Path])
    end,
    ok;
v_msg_m_yylogin_info_toc(X, Path, _TrUserData) ->
    mk_type_error({expected_msg, m_yylogin_info_toc}, X,
		  Path).

-compile({nowarn_unused_function,v_msg_m_yylogin_reward_tos/3}).
-dialyzer({nowarn_function,v_msg_m_yylogin_reward_tos/3}).
v_msg_m_yylogin_reward_tos(#m_yylogin_reward_tos{day =
						     F1},
			   Path, TrUserData) ->
    v_type_int32(F1, [day | Path], TrUserData), ok;
v_msg_m_yylogin_reward_tos(X, Path, _TrUserData) ->
    mk_type_error({expected_msg, m_yylogin_reward_tos}, X,
		  Path).

-compile({nowarn_unused_function,v_msg_m_yylogin_reward_toc/3}).
-dialyzer({nowarn_function,v_msg_m_yylogin_reward_toc/3}).
v_msg_m_yylogin_reward_toc(#m_yylogin_reward_toc{day =
						     F1},
			   Path, TrUserData) ->
    v_type_int32(F1, [day | Path], TrUserData), ok;
v_msg_m_yylogin_reward_toc(X, Path, _TrUserData) ->
    mk_type_error({expected_msg, m_yylogin_reward_toc}, X,
		  Path).

-compile({nowarn_unused_function,v_type_int32/3}).
-dialyzer({nowarn_function,v_type_int32/3}).
v_type_int32(N, _Path, _TrUserData)
    when -2147483648 =< N, N =< 2147483647 ->
    ok;
v_type_int32(N, Path, _TrUserData) when is_integer(N) ->
    mk_type_error({value_out_of_range, int32, signed, 32},
		  N, Path);
v_type_int32(X, Path, _TrUserData) ->
    mk_type_error({bad_integer, int32, signed, 32}, X,
		  Path).

-compile({nowarn_unused_function,mk_type_error/3}).
-spec mk_type_error(_, _, list()) -> no_return().
mk_type_error(Error, ValueSeen, Path) ->
    Path2 = prettify_path(Path),
    erlang:error({gpb_type_error,
		  {Error, [{value, ValueSeen}, {path, Path2}]}}).


-compile({nowarn_unused_function,prettify_path/1}).
-dialyzer({nowarn_function,prettify_path/1}).
prettify_path([]) -> top_level;
prettify_path(PathR) ->
    list_to_atom(lists:append(lists:join(".",
					 lists:map(fun atom_to_list/1,
						   lists:reverse(PathR))))).


-compile({nowarn_unused_function,id/2}).
-compile({inline,id/2}).
id(X, _TrUserData) -> X.

-compile({nowarn_unused_function,v_ok/3}).
-compile({inline,v_ok/3}).
v_ok(_Value, _Path, _TrUserData) -> ok.

-compile({nowarn_unused_function,m_overwrite/3}).
-compile({inline,m_overwrite/3}).
m_overwrite(_Prev, New, _TrUserData) -> New.

-compile({nowarn_unused_function,cons/3}).
-compile({inline,cons/3}).
cons(Elem, Acc, _TrUserData) -> [Elem | Acc].

-compile({nowarn_unused_function,lists_reverse/2}).
-compile({inline,lists_reverse/2}).
'lists_reverse'(L, _TrUserData) -> lists:reverse(L).
-compile({nowarn_unused_function,'erlang_++'/3}).
-compile({inline,'erlang_++'/3}).
'erlang_++'(A, B, _TrUserData) -> A ++ B.

get_msg_defs() ->
    [{{msg, m_yylogin_info_tos}, []},
     {{msg, m_yylogin_info_toc},
      [#field{name = days, fnum = 1, rnum = 2, type = int32,
	      occurrence = required, opts = []},
       #field{name = list, fnum = 2, rnum = 3, type = int32,
	      occurrence = repeated, opts = []}]},
     {{msg, m_yylogin_reward_tos},
      [#field{name = day, fnum = 1, rnum = 2, type = int32,
	      occurrence = required, opts = []}]},
     {{msg, m_yylogin_reward_toc},
      [#field{name = day, fnum = 1, rnum = 2, type = int32,
	      occurrence = required, opts = []}]}].


get_msg_names() ->
    [m_yylogin_info_tos, m_yylogin_info_toc,
     m_yylogin_reward_tos, m_yylogin_reward_toc].


get_group_names() -> [].


get_msg_or_group_names() ->
    [m_yylogin_info_tos, m_yylogin_info_toc,
     m_yylogin_reward_tos, m_yylogin_reward_toc].


get_enum_names() -> [].


fetch_msg_def(MsgName) ->
    case find_msg_def(MsgName) of
      Fs when is_list(Fs) -> Fs;
      error -> erlang:error({no_such_msg, MsgName})
    end.


-spec fetch_enum_def(_) -> no_return().
fetch_enum_def(EnumName) ->
    erlang:error({no_such_enum, EnumName}).


find_msg_def(m_yylogin_info_tos) -> [];
find_msg_def(m_yylogin_info_toc) ->
    [#field{name = days, fnum = 1, rnum = 2, type = int32,
	    occurrence = required, opts = []},
     #field{name = list, fnum = 2, rnum = 3, type = int32,
	    occurrence = repeated, opts = []}];
find_msg_def(m_yylogin_reward_tos) ->
    [#field{name = day, fnum = 1, rnum = 2, type = int32,
	    occurrence = required, opts = []}];
find_msg_def(m_yylogin_reward_toc) ->
    [#field{name = day, fnum = 1, rnum = 2, type = int32,
	    occurrence = required, opts = []}];
find_msg_def(_) -> error.


find_enum_def(_) -> error.


-spec enum_symbol_by_value(_, _) -> no_return().
enum_symbol_by_value(E, V) ->
    erlang:error({no_enum_defs, E, V}).


-spec enum_value_by_symbol(_, _) -> no_return().
enum_value_by_symbol(E, V) ->
    erlang:error({no_enum_defs, E, V}).



get_service_names() -> [].


get_service_def(_) -> error.


get_rpc_names(_) -> error.


find_rpc_def(_, _) -> error.



-spec fetch_rpc_def(_, _) -> no_return().
fetch_rpc_def(ServiceName, RpcName) ->
    erlang:error({no_such_rpc, ServiceName, RpcName}).


%% Convert a a fully qualified (ie with package name) service name
%% as a binary to a service name as an atom.
-spec fqbin_to_service_name(_) -> no_return().
fqbin_to_service_name(X) ->
    error({gpb_error, {badservice, X}}).


%% Convert a service name as an atom to a fully qualified

%% (ie with package name) name as a binary.
-spec service_name_to_fqbin(_) -> no_return().
service_name_to_fqbin(X) ->
    error({gpb_error, {badservice, X}}).


%% Convert a a fully qualified (ie with package name) service name
%% and an rpc name, both as binaries to a service name and an rpc
%% name, as atoms.
-spec fqbins_to_service_and_rpc_name(_, _) -> no_return().
fqbins_to_service_and_rpc_name(S, R) ->
    error({gpb_error, {badservice_or_rpc, {S, R}}}).


%% Convert a service name and an rpc name, both as atoms,
%% to a fully qualified (ie with package name) service name and
%% an rpc name as binaries.
-spec service_and_rpc_name_to_fqbins(_, _) -> no_return().
service_and_rpc_name_to_fqbins(S, R) ->
    error({gpb_error, {badservice_or_rpc, {S, R}}}).


get_package_name() -> undefined.


%% Whether or not the message names
%% are prepended with package name or not.
uses_packages() -> false.



gpb_version_as_string() ->
    "4.5.1".

gpb_version_as_list() ->
    [4,5,1].
