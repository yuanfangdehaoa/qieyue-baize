%% @author rong
%% @doc
-module(web_bag_api).

-include("game.hrl").
-include("table.hrl").
-include("item.hrl").
-include("proto.hrl").
-include("log.hrl").
-include("bag.hrl").

-export([info/1, del/1]).
-export([reduce_item/2]).

% 获取玩家背包信息
info(Req) ->
    #{role_id := RoleID, bag_id := BagID}
        = cowboy_req:match_qs([{role_id, int}, {bag_id, int}], Req),
    web_util:validate_sign([RoleID, BagID], Req),
    {ok, [Bag]} = case role:is_alive(RoleID) of
        true ->
            role:get_data(RoleID, [?DB_ROLE_BAG]);
        false ->
            [B] = db:dirty_read(?DB_ROLE_BAG, RoleID),
            {ok, [B]}
    end,
    #role_bag{cells=Cells, items = All} = Bag,
    Cell  = maps:get(BagID, Cells),
    Items = maps:values( maps:with(Cell#cell.used, All) ),
    Data = lists:map(fun(Item) ->
        #cfg_item{name=Name} = cfg_item:find(Item#p_item.id),
        #{
            <<"uid">>  => Item#p_item.uid,
            <<"id">>   => Item#p_item.id,
            <<"name">> => ut_conv:to_binary(Name),
            <<"num">>  => Item#p_item.num
        }
    end, Items),
    web_reply:ok(Data, Req).

del(Req) ->
    #{role_id:=RoleID, uid:=CellID, num:=Num}
        = cowboy_req:match_qs([{role_id, int},{uid, int}, {num, int}], Req),
    case cowboy_req:method(Req) of
        <<"DELETE">> ->
            web_util:validate_sign([RoleID,CellID,Num], Req),
            Cost = case Num of
                999999 ->
                    [{cellid, CellID}];
                _ ->
                    [{cellid, CellID, Num}]
            end,
            case role:is_alive(RoleID) of
                true ->
                    role:route(RoleID, ?MODULE, reduce_item, Cost);
                false ->
                    role_bag:dirty_deal(RoleID, Cost, [], 0, ?nil)
            end,
            web_reply:ok(Req);
        _ ->
            web_reply:error(Req)
    end.

reduce_item(Cost, RoleSt) ->
    role_bag:cost(Cost, ?LOG_GM_DO, RoleSt).
