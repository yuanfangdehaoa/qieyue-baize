% %%%=============================================================================
% %%% @author z.hua
% %%% @doc
% %%%
% %%% @end
% %%%=============================================================================

-module(ut_mysql).

% -include("game.hrl").
% -include("errno.hrl").

% %% API
% -export([select/1, select/2, select/3, select/4]).
% -export([insert/2]).
% -export([update/2, update/3]).
% -export([delete/1, delete/2]).
% -export([transaction/1]).

% -type db_error() :: {error, Errno :: integer(), Reason :: string()}.
% % Errno  : MySQL 自定义的错误码
% % Reason : MySQL 自定义的错误原因

% %%%-----------------------------------------------------------------------------
% %%% API Functions
% %%%-----------------------------------------------------------------------------

% %%-----------------------------------------------
% %% @doc 读取数据
% -spec select(Table, Fields, Where, AsFunc) -> Return when
% 	Table  :: atom(),         % 数据库表名
% 	Fields :: '*' | [atom()], % 要读取的字段名
% 	Where  :: string(),       % 筛选条件
% 	AsFunc :: as_list         % 返回类型
% 			| as_map
% 			| {as_rec, RecName :: atom(), RecFields :: [atom()]},
% 	Return :: {ok, [list() | map() | tuple()]} | db_error().
% %%-----------------------------------------------
% select(Table) ->
% 	select(Table, '*', "", as_list).

% select(Table, Fields) ->
% 	select(Table, Fields, "", as_list).

% select(Table, Fields, Where) ->
% 	select(Table, Fields, Where, as_list).

% select(Table, Fields, Where, AsFunc) ->
% 	Fields2 = case Fields == '*' of
% 		true  -> ["*"];
% 		false -> [ut_conv:to_list(F) || F <- Fields]
% 	end,
% 	Where2 = ?_if(Where == "", "", " WHERE " ++ Where),
% 	Query  = io_lib:format(
% 		"SELECT ~s FROM ~w" ++ Where2,
% 		[string:join(Fields2, ","), Table]
% 	),
% 	case mysql:fetch(?GDB_POOL, Query, 5000) of
% 		{data, Res}  ->
% 			{ok, to_erl(Res, AsFunc)};
% 		{error, Res} ->
% 			db_error(Res)
% 	end.


% %%-----------------------------------------------
% %% @doc 插入数据
% -spec insert(Table, KVs) -> Return when
% 	Table  :: atom(),
% 	KVs    :: [{Field :: atom(), Value :: any()}],
% 	Return :: ok | db_error().
% %%-----------------------------------------------
% insert(Table, KVs) ->
% 	Query = io_lib:format(
% 		"INSERT INTO ~w SET ~ts",
% 		[Table, to_sql(KVs, Table)]
% 	),
% 	do_write(Query).


% %%-----------------------------------------------
% %% @doc 更新数据
% -spec update(Table, KVs, Where) -> Return when
% 	Table  :: atom(),
% 	KVs    :: [{Field :: atom(), Value :: any()}],
% 	Where  :: string(),
% 	Return :: ok | db_error().
% %%-----------------------------------------------
% update(Table, KVs) ->
% 	update(Table, KVs, "").

% update(Table, KVs, Where) ->
% 	Where2 = ?_if(Where == "", "", " WHERE " ++ Where),
% 	Query  = io_lib:format(
% 		"UPDATE ~w SET ~ts" ++ Where2,
% 		[Table, to_sql(KVs, Table)]
% 	),
% 	do_write(Query).


% %%-----------------------------------------------
% %% @doc 删除数据
% -spec delete(Table, Where) -> Return when
% 	Table  :: atom(),
% 	Where  :: string(),
% 	Return :: ok | db_error().
% %%-----------------------------------------------
% delete(Table) ->
% 	delete(Table, "").

% delete(Table, Where) ->
% 	Where2 = ?_if(Where == "", "", " WHERE " ++ Where),
% 	Query  = io_lib:format("DELETE FROM ~w" ++ Where2, [Table]),
% 	do_write(Query).

% transaction(Fun) ->
% 	case catch mysql:transaction(?GDB_POOL, Fun) of
%         {atomic, Result} ->
%             Result;
%         {aborted, {Reason, _}} ->
%             ?error("db transaction error: ~p", [Reason]),
%             ?err(?ERR_GAME_SYS_ERROR);
%         {error, Reason} ->
%             ?error("db transaction error: ~p", [Reason]),
%             ?err(?ERR_GAME_SYS_ERROR);
%         Error ->
%             ?error("db transaction error: ~p", [Error]),
%             ?err(?ERR_GAME_SYS_ERROR)
%     end.

% %%%-----------------------------------------------------------------------------
% %%% Internal Functions
% %%%-----------------------------------------------------------------------------
% to_erl(Result, AsFunc) ->
% 	Cols = mysql:get_result_field_info(Result),
% 	Rows = mysql:get_result_rows(Result),

% 	Fields = lists:zipwith(fun
% 		({Table, Field, _, _}, Index) ->
% 			{ut_conv:to_atom(Table), ut_conv:to_atom(Field), Index}
% 	end, Cols, lists:seq(1, length(Cols))),

% 	[case AsFunc of
% 		as_list ->
% 			as_list(Fields, Values, []);
% 		as_map ->
% 			as_map(Fields, Values, #{});
% 		{as_rec, RecName, RecFields} ->
% 			as_rec(Fields, Values, RecName, RecFields)
% 	end || Values <- Rows].

% as_list([{Table, Field, _} | T1], [Value | T2], Acc) ->
% 	as_list(T1, T2, [to_erl_value(Table, Field, Value) | Acc]);
% as_list([], [], Acc) ->
% 	lists:reverse(Acc).

% as_map([{Table, Field, _} | T1], [Value | T2], Acc) ->
% 	Acc2 = maps:put(Field, to_erl_value(Table, Field, Value), Acc),
% 	as_map(T1, T2, Acc2);
% as_map([], [], Acc) ->
% 	Acc.

% as_rec(Fields, Values, RecName, RecFields) ->
% 	RecValues = lists:map(fun
% 		(Field) ->
% 			case lists:keyfind(Field, 2, Fields) of
% 				false ->
% 					undefined;
% 				{Table, _, Index} ->
% 					to_erl_value(Table, Field, lists:nth(Index, Values))
% 			end
% 	end, RecFields),
% 	list_to_tuple([RecName | RecValues]).

% to_erl_value(_, _, undefined) ->
% 	undefined;
% to_erl_value(Table, Field, Value) ->
% 	case table:field_type(Table, Field) of
% 		'int'  -> ut_conv:to_integer(Value);
% 		'bool' -> ut_conv:to_atom(Value);
% 		'str'  -> ut_conv:to_list(Value);
% 		'text' -> ut_conv:bitstring_to_term(Value)
% 	end.

% to_sql(KVs, Table) ->
% 	to_sql(KVs, Table, []).

% to_sql([{Field, Value} | T], Table, Acc) ->
% 	Set = case table:field_type(Table, Field) of
% 		'int'  -> io_lib:format("~w=~w", [Field, Value]);
% 		'bool' -> io_lib:format("~w='~w'", [Field, Value]);
% 		'str'  -> io_lib:format("~w='~ts'", [Field, Value]);
% 		'text' -> io_lib:format("~w='~ts'", [Field, to_sql_value(Value)])
% 	end,
% 	to_sql(T, Table, [Set | Acc]);
% to_sql([], _, Acc) ->
% 	string:join(lists:reverse(Acc), ",").

% to_sql_value(Value) ->
% 	ut_conv:term_to_bitstring(Value).

% do_write(Query) ->
% 	case mysql:fetch(?GDB_POOL, Query) of
% 		{updated, _} ->
% 			ok;
% 		{error, Res} ->
% 			Errno  = mysql:get_result_err_code(Res),
% 			Reason = mysql:get_result_reason(Res),
% 			{error, Errno, Reason}
% 	end.

% db_error(Res) ->
% 	Reason = mysql:get_result_reason(Res),
% 	?error("db error: ~p", [Reason]),
% 	?err(?ERR_GAME_SYS_ERROR).
