%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(update_common).

-include("game.hrl").
-include("mail.hrl").
-include("pay.hrl").
-include("table.hrl").

%% API
-export([update_item/1]).
-export([update_task/1]).
-export([delete_task/0]).
-export([update_bag/1,update_role_welfare/0,update_role_mchunt/0,update_role_searchtreasure/0]).
-export([export_payinfo/0]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
update_item(UpdateFun) when is_function(UpdateFun, 1) ->
	update_bag_item(UpdateFun),
	update_mail_item(UpdateFun),
	update_trade_item(UpdateFun),
	update_guild_depot_item(UpdateFun),
	ok.

update_task(TaskIDs) ->
	Func = fun
		({role_task, RoleID, Listen, Accept, Submit, Reward, Next}) ->
			Accept2 = role_task:reload(Accept, TaskIDs),
			{role_task, RoleID, Listen, Accept2, Submit, Reward, Next};
	    (R) ->
	        R
	end,
	update_behavior:transform(
		role_task,
		Func,
		[id, listen, accept, submit, reward, next]
	),
	ok.

delete_task() ->
	DelIDs = [
		50052, 52050, 52101, 52150, 52200, 52201, 52250, 52251, 52252, 52253,
		52300, 52500, 52550, 52702, 52703, 52750, 52751, 52800, 52801, 52802,
		52803, 54402, 54403, 52202
	],
	Func = fun
		({role_task, RoleID, Listen, Accept, Submit, Reward, Next}) ->
			Listen2 = maps:map(fun
				(_, TaskIDs) ->
					[ID || ID <- TaskIDs, not lists:member(ID, DelIDs)]
			end, Listen),
			Accept2 = maps:without(DelIDs, Accept),
			Submit2 = [ID || ID <- Submit, not lists:member(ID, DelIDs)],
			{role_task, RoleID, Listen2, Accept2, Submit2, Reward, Next};
	    (R) ->
	        R
	end,
	update_behavior:transform(
		role_task,
		Func,
		[id, listen, accept, submit, reward, next]
	),
	ok.

update_bag(BagIDs)->
    Func = fun
        ({role_bag, ID, COUNT, GROUP, CELLS, ITEMS, MONEY, EXCEED}) ->
            CELLS2 = lists:foldl(fun
                (BagID, Acc) ->
                    case maps:is_key(BagID, Acc) of
                        false ->
                            Cell = role_bag:new(BagID),
                            maps:put(BagID, Cell, Acc);
                        true ->
                            Acc
                    end
            end, CELLS, BagIDs),
            {role_bag, ID, COUNT, GROUP, CELLS2, ITEMS, MONEY, EXCEED};
        (R) ->
            R
    end,
    update_behavior:transform(role_bag, Func, record_info(fields, role_bag)),
    ok.

update_role_welfare()->
	Func = fun
					 ({role_welfare, ID, LEVEL, POWER, ONLINE, SIGN, NOTICE, RES,MISC}) ->

						 {role_welfare, ID, LEVEL, POWER, ONLINE, SIGN, NOTICE, RES,MISC,[]};
					 (R) ->
						 R
				 end,
	update_behavior:transform(role_welfare, Func, record_info(fields, role_welfare)),
	ok.

update_role_mchunt() ->
	Func = fun
					 ({role_mchunt, ID, TIMES, HUNT, DIG, ETIME, SCENE, POS,LUCK,_}) ->

						 {role_mchunt, ID, TIMES, HUNT, DIG, ETIME, SCENE, POS,LUCK};
					 (R) ->
						 R
				 end,
	update_behavior:transform(role_mchunt, Func, record_info(fields, role_mchunt)),
	ok.

update_role_searchtreasure() ->
	Func = fun
					 ({role_searchtreasure, ID, SERCHAR, YY, EQUIE}) ->

						 {role_searchtreasure, ID, SERCHAR, YY, EQUIE, 0};
					 (R) ->
						 R
				 end,
	update_behavior:transform(role_searchtreasure, Func, record_info(fields, role_searchtreasure)),
	ok.

export_payinfo() ->
	PayInfo = lists:foldl(fun
		(RolePay, Acc) ->
			#role_pay{id=RoleID, payments=Payments} = RolePay,
			[#role_info{userid=UserID}] = db:dirty_read(?DB_ROLE_INFO, RoleID),
			TotalGold = lists:sum([P#payment.gain_gold || P <- Payments]),
			ut_misc:maps_increase(UserID, TotalGold, Acc)
	end, #{}, db:dirty_match_all(?DB_ROLE_PAY)),
	maps:fold(fun
		(UserID, TotalGold, _) ->
			?_if(
				TotalGold > 0,
				?info("~p ~w", [UserID, TotalGold])
			)
	end, ok, PayInfo),
	ok.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
update_bag_item(UpdateFun)->
	Func = fun
		({role_bag, RoleID, Count, Group, Cells, Items, Money, Exceed}) ->
			Items2 = maps:fold(fun
				(CellID, Item, Acc) ->
					Item2 = UpdateFun(Item),
					maps:put(CellID, Item2, Acc)
			end, #{}, Items),
			{role_bag, RoleID, Count, Group, Cells, Items2, Money, Exceed};
		(R) ->
			R
	end,
	update_behavior:transform(
		role_bag,
		Func,
		[id, count, group, cells, items, money, exceed]
	),
	ok.

update_mail_item(UpdateFun)->
	Func = fun
		({mailbox, Owner, MailID, Mails}) ->
			Mails2 = maps:fold(fun
				(ID, Mail, Acc) ->
					Items2 = lists:foldl(fun
						(Item, Acc2) ->
							Item2 = UpdateFun(Item),
							[Item2 | Acc2]
					end, [], Mail#mail.items),
					maps:put(ID, Mail#mail{items=Items2}, Acc)
			end, #{}, Mails),
			{mailbox, Owner, MailID, Mails2};
		(R) ->
			R
	end,
	update_behavior:transform(
		mailbox,
		Func,
		[owner, mailid, mails]
	),
	ok.

update_trade_item(UpdateFun)->
	Func = fun
		({trade, ID, Type, Owner, Item, Time, Price, Tax}) ->
			Item2 = UpdateFun(Item),
			{trade, ID, Type, Owner, Item2, Time, Price, Tax};
		(R) ->
			R
	end,
	update_behavior:transform(
		trade,
		Func,
		[id, type, owner, item, time, price, tax]
	),
	ok.

update_guild_depot_item(UpdateFun)->
	Func = fun
		({guild_depot, ID, Cells, Items}) ->
			Items2 = maps:fold(fun
				(CellID, Item, Acc) ->
					Item2 = UpdateFun(Item),
					maps:put(CellID, Item2, Acc)
			end, #{}, Items),
			{guild_depot, ID, Cells, Items2};
		(R)->
			R
	end,
	update_behavior:transform(
		guild_depot,
		Func,
		[id, cells, items]
	),
	ok.
