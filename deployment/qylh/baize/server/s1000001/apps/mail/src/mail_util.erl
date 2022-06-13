%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(mail_util).

-include("game.hrl").
-include("item.hrl").
-include("mail.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([p_mail/1]).
-export([attachment/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
p_mail(Mail) ->
    #p_mail{
		id     = Mail#mail.id,
		type   = Mail#mail.type,
		title  = Mail#mail.title,
		from   = Mail#mail.from,
		send   = Mail#mail.send,
		expire = Mail#mail.expire,
		read   = Mail#mail.read,
		attach = Mail#mail.items /= [] orelse Mail#mail.money /= #{},
		fetch  = Mail#mail.fetch
    }.

attachment(AttnID, Items) ->
	case role_cache:get_cache(AttnID) of
		{ok, #role_cache{level=RoleLv}} ->
			lists:foldl(fun
			    ({ItemID, Num, Opts}, {AccItems, AccMoney}) ->
			        #cfg_item{type=ItemType} = cfg_item:find(ItemID),
			        case ItemType == ?ITEM_TYPE_MONEY of
			            true  ->
			            	[{ItemID2, Num2}] = game_util:transform_gain(RoleLv, [{ItemID,Num}]),
			                {AccItems, ut_misc:maps_increase(ItemID2, Num2, AccMoney)};
			            false ->
			                Opts2 = case is_integer(Opts) of
			                    true  -> #{bind => item_util:calc_bind(Opts)};
			                    false -> Opts
			                end,
			                {[item_util:new_item(ItemID, Num, Opts2) | AccItems], AccMoney}
			        end;
			    (Item, {AccItems, AccMoney}) ->
			        {[Item | AccItems], AccMoney}
			end, {[], #{}}, to_items(AttnID, Items));
		_ ->
			?error("role not exist: ~w", [AttnID]),
			{[], #{}}
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
to_items(RoleID, Items) -> [to_item(RoleID, Item)||Item <- Items].
to_item(RoleID, {ItemIDs, Num}) when is_list(ItemIDs) ->
    to_item(RoleID, {ItemIDs, Num, #{}});
to_item(RoleID, {ItemIDs, Num, Opts}) when is_list(ItemIDs) ->
    {ok, #role_cache{gender=Gender}} = role:get_cache(RoleID),
    ItemID = lists:nth(Gender, ItemIDs),
    to_item(RoleID, {ItemID, Num, Opts});
to_item(_RoleID, {ItemID, Num}) when is_integer(ItemID) -> {ItemID, Num, #{}};
to_item(_RoleID, {ItemID, Num, Opts}) when is_integer(ItemID) ->
    Opts2 = case is_integer(Opts) of
        true  -> #{bind => item_util:calc_bind(Opts)};
        false -> Opts
    end,
    {ItemID, Num, Opts2};
to_item(_RoleID, Item) ->
    Item.
