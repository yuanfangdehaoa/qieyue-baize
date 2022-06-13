%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(achieve_handler).

-include("achieve.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("item.hrl").
-include("equip.hrl").
-include("task.hrl").

%% API
-export([handle/3]).
-export([hook_login/1]).
-export([notify/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%获取信息
handle(?ACHIEVE_INFO, _Tos, RoleSt)->
	#role_achieve{achieves=Achieves} = role_data:get(?DB_ROLE_ACHIEVE),
	{ok, #m_achieve_info_toc{achieves=maps:values(Achieves)}, RoleSt};

%领奖
handle(?ACHIEVE_REWARD, Tos, RoleSt)->
	#m_achieve_reward_tos{id=Id} = Tos,
	RoleAchieve = #role_achieve{achieves=Achieves} = role_data:get(?DB_ROLE_ACHIEVE),
	PAchieve = maps:get(Id, Achieves, ?nil),
	?_check(PAchieve /= ?nil, ?ERR_ACHIEVE_DATA_WRONG),
	#p_achieve{state=State} = PAchieve,
	?_check(State == 1, ?ERR_ACHIEVE_STATE_WRONG),
	#cfg_achieve{reward=Gain} = cfg_achieve:find(Id),
	role_bag:gain(Gain, ?LOG_ACHIEVE_REWARD, RoleSt),
	PAchieve2 = PAchieve#p_achieve{state=2},
	Achieves2 = maps:put(Id, PAchieve2, Achieves),
	role_data:set(RoleAchieve#role_achieve{achieves=Achieves2}),
	?ucast(#m_achieve_info_toc{achieves=[PAchieve2]}),
	{ok, #m_achieve_reward_toc{id=Id}, RoleSt}.


hook_login(_RoleSt) ->
    init_listener().


notify(Event, Id, Args, RoleSt)->
	RoleAchieve = #role_achieve{achieves=Achieves} = role_data:get(?DB_ROLE_ACHIEVE),
	#cfg_achieve{target=Target,point=Point} = cfg_achieve:find(Id),
	{Event, Goal, Num} = Target,
	case is_finish(Event, Goal, Args) of
		{true, Op, Add} ->
			PAchieve = maps:get(Id, Achieves, #p_achieve{id=Id,num=0,state=0}),
			#p_achieve{num=P} = PAchieve,
			NewP = calc(P, Op, Add),
			State = case NewP >= Num of
				true  -> 1;
				false -> 0
			end,
			PAchieve2 = PAchieve#p_achieve{num=NewP, state=State},
			Achieves2 = maps:put(Id, PAchieve2, Achieves),
			role_data:set(RoleAchieve#role_achieve{achieves=Achieves2}),
			case State == 1 of
				true ->
					role_event:remove(Event, ?MODULE, notify, Id),
					?ucast(#m_achieve_info_toc{achieves=[PAchieve2]}),
					case Point > 0 of
						true  ->
							role_event:event(?EVENT_ACHIEVE, Point);
						false -> igore
					end;
				false ->
					igore
			end;
		false ->
			igore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
init_listener()->
	#role_achieve{achieves=Achieves} = role_data:get(?DB_ROLE_ACHIEVE),
	lists:foreach(fun
			(Id) ->
				#cfg_achieve{target=Target} = cfg_achieve:find(Id),
				case Target of
					{Event, _Goal, Num} ->
						case need_listen(Id, Achieves, Num) of
							true ->
								case Target of
									{Event, _, _} ->
										role_event:listen(Event, ?MODULE, notify, Id);
									_ ->
										igore
								end;
							false ->
								igore
						end;
					_ ->
						ignore
				end
		end, cfg_achieve:list()).

%是否需要监听
need_listen(Id, Achieves, Num)->
	PAchieve = maps:get(Id, Achieves, ?nil),
	case PAchieve of
		?nil ->
			true;
		#p_achieve{num=P} ->
			case P < Num of
				true  -> true;
				false -> false
			end
	end.

is_finish(?EVENT_LEVEL, Level, Level2)->
	case Level2 >= Level of
		true  -> {true, '=', 1};
		false -> false
	end;

is_finish(?EVENT_CREEP, CreepID, {CreepID, _Rarity})->
	{true, '+', 1};

is_finish(?EVENT_CREEP, 0, {_CreepID, _Rarity})->
	{true, '+', 1};

is_finish(?EVENT_ACHIEVE, _Goal, Point)->
	{true, '+', Point};

is_finish(?EVENT_TRAIN_ORDER, {level, Type, Level}, {Type, _Order, Level2})->
	case Level2 >= Level of
		true  -> {true, '=', 1};
		false -> false
	end;

is_finish(?EVENT_MORPH_STAR, {Type, List}, {Type, ID, _Star})->
	case lists:member(ID, List) of
		true  -> {true, '=', 1};
		false -> false
	end;

is_finish(?EVENT_WAKE, Wake, Wake)->
	{true, '=', 1};

is_finish(?EVENT_TRAIN_ORDER, {order, Type, Order}, {Type, Order, _Level})->
	{true, '=', 1};

is_finish(?EVENT_MAKE_SUIT, Level, {Level, _Slot, _Order})->
	{true, '+', 1};

is_finish(?EVENT_EQUIP, Slot, {Slot, _ItemId, _Equips})->
	{true, '=', 1};

is_finish(?EVENT_EQUIP, {Star, Color}, {_Slot, ItemId, _Equips})->
	#cfg_item{color=Color2} = cfg_item:find(ItemId),
	#cfg_equip{star=Star2} = cfg_equip:find(ItemId),
	case Star2 >= Star andalso Color2 >= Color of
		true  -> {true, '+', 1};
		false -> false
	end;

is_finish(?EVENT_TASK, Type, {Type, _TaskID})->
	{true, '+', 1};

is_finish(?EVENT_TASK, {Type, Event}, {Type, TaskID})->
	#cfg_task{goals=Goals} = cfg_task:find(TaskID),
	[{Event2, _Target, _Amount, _SceneID, _, _Conds} | _T] = Goals,
	case Event == Event2 of
		true  -> {true, '+', 1};
		false -> false
	end;

is_finish(?EVENT_PET_FIGHT, Order, {_IsFight, Order, _ItemId})->
	{true, '=', 1};

is_finish(?EVENT_PET_EVOLUTION, _Goal, ?nil)->
	{true, '+', 1};

is_finish(?EVENT_PET_STRONG, _Goal, ?nil)->
	{true, '+', 1};

is_finish(?EVENT_DUNGE_STAR, {Dunge, Floor, Star}, {_Stype, Dunge, Floor, Star})->
	{true, '+', 1};

is_finish(?EVENT_ESCORT, _Goal, _Quality)->
	{true, '+', 1};

is_finish(?EVENT_ATTEND_ACTIVITY, ActivityGroup, ActivityGroup)->
	{true, '+', 1};

is_finish(?EVENT_DUNGE_INSPIRE, _Goal, ?nil)->
	{true, '+', 1};

is_finish(?EVENT_ROLE_DEATH, _Goal, ?nil)->
	{true, '+', 1};

is_finish(?EVENT_KILL_ROLE, 0, {_SceneID, _Crime})->
	{true, '+', 1};

is_finish(?EVENT_KILL_ROLE, {crime, Crime}, {_SceneID, Crime2})->
	case Crime2 >= Crime of
		true -> {true, '+', 1};
		false -> false
	end;

is_finish(?EVENT_KILL_ROLE, {scene, SceneID}, {SceneID2, _Crime})->
	Check =
		case erlang:is_list(SceneID) andalso lists:member(SceneID2, SceneID) of
			true ->
				true;
			false ->
				SceneID == SceneID2
		end,
	case Check of
		true ->
			{true, '+', 1};
		false ->
			false
	end;

is_finish(?EVENT_WELFARE_SIGN, _Goal, ?nil)->
	{true, '+', 1};

is_finish(?EVENT_OPEN_BAG, BagID, {BagID, Num})->
	{true, '+', Num};

is_finish(?EVENT_ITEM, ItemId, {ItemId, Num})->
	{true, '+', Num};

is_finish(?EVENT_EQUIP_SMELT, Level, {_Num, Level2})->
	case Level2 >= Level of
		true  -> {true, '=', 1};
		false -> false
	end;

is_finish(?EVENT_BEAST_SUMMON, 0, _BeastID) ->
	{true, '+', 1};

is_finish(?EVENT_BEAST_SUMMON, BeastID, BeastID) ->
	{true, '=', 1};

is_finish(?EVENT_QUESTION, 0, _Args) ->
	{true, '+', 1};

is_finish(?EVENT_GUILD_JOIN, 0, _Args) ->
	{true, '=', 1};

is_finish(?EVENT_GUILD_DONATE, 0, _ItemID) ->
	{true, '+', 1};

is_finish(?EVENT_SEND_REDENVELOPE, TypeId, TypeId) ->
	{true, '+', 1};

is_finish(?EVENT_GWAR_WIN, 0, _Args)->
	{true, '+', 1};

is_finish(?EVENT_GWAR_WIN, ZoneID, ZoneID2)->
	case ZoneID2 =< ZoneID of
		true  -> {true, '+', 1};
		false -> false
	end;

is_finish(?EVENT_GWAR_BREAK, 0, _Breakup)->
	{true, '+', 1};

is_finish(_Event, _Goal, _Args)->
	false.


calc(_P, '=', Num) ->
    Num;
calc(P, '+', Num) ->
    P+Num.

