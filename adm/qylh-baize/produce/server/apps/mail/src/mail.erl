%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(mail).

-include("game.hrl").
-include("item.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([send/2, send/3, send/4, send/6, send/7]).
-export([batch_send/2, batch_send/3, batch_send/4, batch_send/6]).
-export([cross_send/1, cross_send_center/1, cross_send_mail/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 系统给玩家发邮件
%% 详见 send_by_role/6
-spec send(
	integer(),
	integer(),
	string(),
	string(),
	[#p_item{} | {integer(), integer()}],
	integer()
) ->
	ok | error().
%%-----------------------------------------------
send(AttnID, MailID) ->
	{Title, Text} = cfg_mail:find(MailID),
	send(AttnID, MailID, Title, Text, [], cfg_game:mail_last()).

send(AttnID, MailID, Items) ->
	{Title, Text} = cfg_mail:find(MailID),
	send(AttnID, MailID, Title, Text, Items, cfg_game:mail_last()).

send(AttnID, MailID, Items, Args) when is_integer(MailID) ->
	{Title, Text} = cfg_mail:find(MailID),
	Text2 = io_lib:format(Text, Args),
	send(AttnID, MailID, Title, Text2, Items, cfg_game:mail_last());
send(AttnID, Title, Text, Items) ->
	send(AttnID, 0, Title, Text, Items, cfg_game:mail_last()).

send(AttnID, MailID, Title, Text, Items0, Last) ->
	send(AttnID, MailID, Title, Text, Items0, Last, ?MAIL_TYPE_SYSTEM).

send(AttnID, MailID, Title, Text, Items0, Last, Type) ->
	case cluster:is_local() of
		true  ->
			{Items, Money} = mail_util:attachment(AttnID, Items0),
			mail_server:send(
				[AttnID], {assistant(), Type, MailID, Title, Text, Items, Money, Last}
			),
			{ok, Items++maps:to_list(Money)};
		false ->
			mail_server:send(
				[AttnID], {assistant(), Type, MailID, Title, Text, Items0, Last}
			)
	end.

%%-----------------------------------------------
%% @doc 系统批量给玩家发邮件
%% 详见 send_by_role/6
-spec batch_send([RoleID :: integer()], integer(), string(), string(), list(), integer()) ->
	ok | error().
%%-----------------------------------------------
batch_send(AttnIDs, MailID) ->
	{Title, Text} = cfg_mail:find(MailID),
	batch_send(AttnIDs, MailID, Title, Text, [], cfg_game:mail_last()).

batch_send(AttnIDs, MailID, Items) ->
	{Title, Text} = cfg_mail:find(MailID),
	batch_send(AttnIDs, MailID, Title, Text, Items, cfg_game:mail_last()).

batch_send(AttnIDs, MailID, Items, Args) when is_integer(MailID) ->
	{Title, Text} = cfg_mail:find(MailID),
	Text2 = io_lib:format(Text, Args),
	batch_send(AttnIDs, MailID, Title, Text2, Items, cfg_game:mail_last());
batch_send(AttnIDs, Title, Text, Items) ->
	batch_send(AttnIDs, 0, Title, Text, Items, cfg_game:mail_last()).

batch_send(AttnIDs, MailID, Title, Text, Items, Last) ->
	mail_server:send(
		AttnIDs, {assistant(), ?MAIL_TYPE_SYSTEM, MailID, Title, Text, Items, Last}
	).


%% 批量发送邮件，支持所有服务器的玩家，跨服发送，通过center中心服去中转下发
cross_send(List) ->
	case case cluster:is_center() of
			true ->
				cross_send_center(List);
			false ->
				Center = cluster:get_center(),
				rpc:call(Center, ?MODULE, cross_send_center, [List])
		end of
		[] ->
			ok;
		ErrorNodes ->
			?error("cross_send error nodes : ~p~n", [{ErrorNodes}]),
			{error, ErrorNodes}
	end.

cross_send_center(List) when is_list(List) ->
	Nodes = cluster_util:get_local_nodes(),
	case lists:foldl(
		fun(#cls_node{name = Node}, Acc) ->
			case rpc:call(Node, ?MODULE, cross_send_mail, [List]) of
				ok ->
					Acc;
				_Err ->
					[Node|Acc]
			end
		end, [], Nodes) of
		[] ->
			[];
		ErrorNodes ->
			?error("cross_send error nodes : ~p~n", [{ErrorNodes}]),
			ErrorNodes
	end;

cross_send_center(Term) when is_binary(Term) ->
	cross_send_center(erlang:binary_to_term(Term)).


cross_send_mail(L) ->
	Pred =
		fun(T) ->
			case T of
				{Title, MailContent, GoodsList, RoleIds} when is_list(Title) andalso is_list(MailContent) andalso is_list(GoodsList) andalso is_list(RoleIds) ->
					true;
				{Title, MailContent, RoleIds} when is_list(Title) andalso is_list(MailContent) andalso is_list(RoleIds) ->
					true;
				_ ->
					false
			end
		end,
	case lists:all(Pred, L) of
		true ->
			F = fun cross_send_mail_fun/1,
			lists:foreach(F, L),
			?info("do cross_send_mail : ~p~n", [{L}]),
			ok;
		false ->
			?error("check data error ~n", []),
			error
	end.

cross_send_mail_fun({Title, Content, GoodsList, PlayerList}) ->
	lists:foreach(
		fun(RoleID) ->
			case role_util:is_local(RoleID) of
				true ->
					send(RoleID, Title, Content, GoodsList);
				false ->
					skip
			end
		end, PlayerList);
cross_send_mail_fun({Title, Content, PlayerList}) ->
	lists:foreach(
		fun({RoleID, GoodsList}) ->
			case role_util:is_local(RoleID) of
				true ->
					send(RoleID, Title, Content, GoodsList);
				false ->
					skip
			end
		end, PlayerList).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
assistant() ->
	cfg_lang:find(assist).
