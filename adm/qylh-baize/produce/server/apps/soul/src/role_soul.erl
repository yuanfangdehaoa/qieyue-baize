%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_soul).

-include("table.hrl").
-include("game.hrl").
-include("item.hrl").
-include("log.hrl").
-include("errno.hrl").
-include("soul.hrl").
-include("bag.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("enum.hrl").

%% API
-export([auto_decompose/1, decompose/4]).
-export([get_attr/1]).
-export([get_strong_plus/0]).
-export([hook_login/1]).
-export([notify/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

notify(?EVENT_ITEM, {ItemID, _Num}, RoleSt)->
	#cfg_item{stype=SType} = cfg_item:find(ItemID),
	case SType == ?ITEM_STYPE_SOUL of
		true  -> auto_decompose(RoleSt);
		false -> ignore
	end.

hook_login(_RoleSt)->
	role_event:listen(?EVENT_ITEM, ?MODULE, notify).

get_attr(_AttrType)->
	#role_soul{souls=Souls} = role_data:get(?DB_ROLE_SOUL),
	#role_info{id=_RoleID} = role_data:get(?DB_ROLE_INFO),
	{TotalAttr, _Power} = maps:fold(fun
			(_K, CellId, {Attr, Acc}) ->
				case role_bag:get_item(CellId) of
					{ok, Item} ->
						#p_item{id=Id, extra=Level} = Item,
						#cfg_soul{base=Base, score=Score}
						= cfg_soul:find(Id),
						#cfg_soul_level{attrib = Attrib, fight=Fight}
						= cfg_soul_level:find(Id, Level),
						{mod_attr:sum([Attr, Base, Attrib]), Acc+Score+Fight};
					_->
						{Attr, Acc}
				end
		end, {#{}, 0}, Souls),
	role_event:event(?EVENT_SOUL_POWER, mod_attr:power(TotalAttr)),
	% ?ucast(RoleID, #m_magic_power_toc{power=Power}),
	TotalAttr.

%获取强化加成
get_strong_plus()->
	TotalAttr = get_attr(?ATTR_TYPE_NORMAL),
	maps:get(?ATTR_TARGET_ES, TotalAttr, 0).

auto_decompose(RoleSt)->
	#role_soul{auto=Auto, color=Color, souls=Souls} = role_data:get(?DB_ROLE_SOUL),
	#role_bag{cells=Cells, items=Items} = role_data:get(?DB_ROLE_BAG),
	#cell{used = Used, unused=UnUsed} = maps:get(?BAG_ID_RUNE, Cells),
	case Auto == 1 andalso length(UnUsed) < 25 of
		true ->
			CellIds = get_souls_color(Color, Used, Items, []),
			{Cost, Gain, _} = decompose(CellIds, [], [], Souls),
			role_bag:deal(Cost, Gain, ?LOG_SOUL_DECOMPOSE, RoleSt);
		false ->
			ignore
	end.

%分解
decompose([], Cost, Gain, Souls)->
	{Cost, Gain, Souls};
decompose([CellId|CellIdList], Cost, Gain, Souls)->
	{ok, Item} = role_bag:get_item(CellId),
	#p_item{id=ItemId, extra=Level, bag=BagID, bind=Bind} = Item,
	TotalCost2 = case Level /= ?nil of
		true ->
			#cfg_soul_level{total_cost=TotalCost} = cfg_soul_level:find(ItemId, Level),
			TotalCost;
		_->[]
	end,
	#cfg_soul{gain=Gain1} = cfg_soul:find(ItemId),
	Opts = #{bind => Bind},
	Gain2 = [{SoulID, Num, Opts} || {SoulID, Num} <- Gain1],
	Souls2 = case BagID == ?BAG_ID_SOUL_EQUIP of
		true ->
			Pos = get_pos_by_uid(CellId, Souls),
			case Pos > 0 of
				true  -> maps:remove(Pos, Souls);
				false -> Souls
			end;
		false ->
			Souls
	end,
	decompose(CellIdList,  [{cellid, CellId} | Cost], lists:merge3(Gain, TotalCost2, Gain2), Souls2).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

%根据颜色获取圣痕
get_souls_color(Color, Used, Items, Souls)->
	lists:foldl(fun
			(CellId, Lists)->
				#p_item{id=ItemId} = maps:get(CellId, Items),
				#cfg_item{color=ItemColor} = cfg_item:find(ItemId),
				case ItemColor =< Color of
					true  -> [CellId | Lists];
					false -> Lists
				end
		end, Souls, Used).

get_pos_by_uid(UID, Souls)->
	Lists = maps:to_list(Souls),
	case lists:keyfind(UID, 2, Lists) of
		false -> 0;
		{Pos, _} -> Pos
	end.
