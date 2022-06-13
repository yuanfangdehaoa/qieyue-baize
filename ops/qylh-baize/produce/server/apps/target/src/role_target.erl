%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_target).

-include("game.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("target.hrl").
-include("enum.hrl").
-include("equip.hrl").
-include("item.hrl").
-include("pet.hrl").

%% API
-export([hook_upgrade/2]).
-export([hook_login/1]).
-export([notify/4]).
-export([hook_reset/3]).



%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_reset(_DoW, _Hour, RoleSt)->
	check_targets(RoleSt).

%升级
hook_upgrade(NewLv, RoleSt)->
	case NewLv >= cfg_game:target_openlv() of
		true  -> check_targets(RoleSt);
		false -> ignor
	end.

hook_login(_RoleSt)->
	init_listener().

notify(Event, TaskId, Args, RoleSt)->
	#cfg_target_task{goals=Goals} = cfg_target_task:find(TaskId),
	[{Event, Goal, Num}] = Goals,
	case is_finish(Event, Goal, Args) of
		{true, Add}->
			RoleTarget = #role_target{tasks=Tasks} = role_data:get(?DB_ROLE_TARGET),
			TargetTask = maps:get(TaskId, Tasks, #p_target_task{id=TaskId,finished=[],status=0}),
			#p_target_task{finished=Finished} = TargetTask,
			Finished2 = lists:umerge(Add, Finished),
			Status = case length(Finished2) >= Num of
				true  ->
					role_event:remove(Event, ?MODULE, notify, TaskId),
					1;
				false -> 0
			end,
			TargetTask2 = TargetTask#p_target_task{status=Status, finished=Finished2},
			Tasks2 = maps:put(TaskId, TargetTask2, Tasks),
			role_data:set(RoleTarget#role_target{tasks=Tasks2}),
			update_task(TaskId, TargetTask2, RoleSt),
			check_targets(RoleSt);
		{true, sum, Add}->
			RoleTarget = #role_target{tasks=Tasks} = role_data:get(?DB_ROLE_TARGET),
			TargetTask = maps:get(TaskId, Tasks, #p_target_task{id=TaskId,finished=[],status=0}),
			#p_target_task{finished=Finished} = TargetTask,
			Finished2 = lists:merge(Add, Finished),
			Sum = lists:sum(Finished2),
			Finished3 = [Sum],
			Status = case Sum >= Num of
				true  ->
					role_event:remove(Event, ?MODULE, notify, TaskId),
					1;
				false ->
					0
			end,
			TargetTask2 = TargetTask#p_target_task{status=Status, finished=Finished3},
			Tasks2 = maps:put(TaskId, TargetTask2, Tasks),
			role_data:set(RoleTarget#role_target{tasks=Tasks2}),
			update_task(TaskId, TargetTask2, RoleSt),
			check_targets(RoleSt);
		_ ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
init_listener()->
	#role_target{tasks=Tasks} = role_data:get(?DB_ROLE_TARGET),
	Ids = cfg_target_task:task_ids(),
	lists:foreach(fun
			(TaskId) ->
				case is_task_finish(TaskId, Tasks) of
					true  ->
						ignore;
					false ->
						#cfg_target_task{goals=Goals} = cfg_target_task:find(TaskId),
						[{Event, _Target, _NUm}] = Goals,
						role_event:listen(Event, ?MODULE, notify, TaskId)
				end
		end, Ids).

%任务是否完成
is_task_finish(TaskId, Tasks)->
	case maps:get(TaskId, Tasks, ?nil) of
		?nil ->
			false;
		#p_target_task{status=Status} ->
			case Status of
				0 -> false;
				_ -> true
			end
	end.

%检查主题开放
check_targets(RoleSt)->
	Ids = cfg_target:get_ids(),
	RoleTarget = #role_target{tasks=Tasks, targets=Targets} = role_data:get(?DB_ROLE_TARGET),
	Targets2 = finish_targets(maps:to_list(Targets), Targets, Tasks, RoleSt),
	Targets3 = check_target(Ids, Targets2, RoleSt),
	role_data:set(RoleTarget#role_target{targets=Targets3}).


check_target([], Targets, _RoleSt)->
	Targets;
check_target([Id|Ids], Targets, RoleSt)->
	#cfg_target{pre_id=PreId, limit=Limit} = cfg_target:find(Id),
	Status = maps:get(Id, Targets, ?nil),
	Targets2 = case Status == ?nil andalso is_target_finish(PreId, Targets)
		andalso can_open(Limit) of
		true  ->
			NewTargets = maps:put(Id, 0, Targets),
			update_target(Id, 0, RoleSt),
			NewTargets;
		false ->
			Targets
	end,
	check_target(Ids, Targets2, RoleSt).

%检查完成主题
finish_targets([], Targets, _TargetTasks, _RoleSt)->
	Targets;
finish_targets([{Id, Status}|TargetList], Targets, TargetTasks, RoleSt)->
	Targets2 = case Status == 0 of
		true->
			#cfg_target{tasks=Tasks} = cfg_target:find(Id),
			case is_tasks_finish(Tasks, TargetTasks) of
				true ->
					update_target(Id, 1, RoleSt),
					maps:put(Id, 1, Targets);
				false ->
					Targets
			end;
		false->
			Targets
	end,
	finish_targets(TargetList, Targets2, TargetTasks, RoleSt).

%主题是否完成
is_target_finish(Id, Targets)->
	case Id == 0 of
		true  -> true;
		false ->
			Status = maps:get(Id, Targets, ?nil),
			case Status of
				1 -> true;
				2 -> true;
				_ -> false
			end
	end.

%是否可以开放
can_open([])->
	true;
can_open([ Limit | Limits])->
	Flag = case Limit of
		{level, NeedLevel} ->
			#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
			?_if(Level >= NeedLevel, true);
		{open_days, NeedDays} ->
			Days = game_env:get_opened_days(),
			?_if(Days >= NeedDays, true)
	end,
	case Flag of
		true  -> can_open(Limits);
		false -> false
	end.


%是否所有任务都已完成
is_tasks_finish([], _TargetTasks) ->
	true;
is_tasks_finish([TaskId|Tasks], TargetTasks)->
	case maps:get(TaskId, TargetTasks, ?nil) of
		?nil -> false;
		#p_target_task{status=Status} ->
			case Status == 0 of
				true ->
					false;
				false ->
					is_tasks_finish(Tasks, TargetTasks)
			end
	end.


%更新任务
update_task(TaskId, Task, RoleSt)->
	UpTask = #{TaskId => Task},
	?ucast(#m_target_info_toc{tasks=UpTask}).

%更新主题
update_target(Id, Status, RoleSt)->
	UpTarget = #{Id=>Status},
	?ucast(#m_target_info_toc{targets=UpTarget}).


is_finish(?EVENT_POWER, Goal, Power)->
	{Power >= Goal, [Goal]};

is_finish(?EVENT_EQUIP, {Slot, Order, Color, Star}, {Slot, ItemId, _Equips})->
	#cfg_item{color=Color2} = cfg_item:find(ItemId),
	#cfg_equip{order=Order2, star=Star2} = cfg_equip:find(ItemId),
	case Order2>=Order andalso Color2>=Color andalso Star2 >= Star of
		true  -> {true, [Slot]};
		false -> false
	end;

is_finish(?EVENT_EQUIP, {Color, Star}, {Slot, ItemId, _Equips})->
	#cfg_item{color=Color2} = cfg_item:find(ItemId),
	#cfg_equip{star=Star2} = cfg_equip:find(ItemId),
	case Color2>=Color andalso Star2 >= Star of
		true  -> {true, [Slot]};
		false -> false
	end;

is_finish(?EVENT_EQUIP, [ItemId1, ItemId2], {_Slot, ItemId, _Equips})->
	case lists:member(ItemId, [ItemId1, ItemId2]) of
		true  -> {true, [ItemId]};
		false -> false
	end;

is_finish(?EVENT_TRAIN_ORDER, {Type, Order, Star}, {Type, Order2, Star2})->
	case Order2 >= Order andalso Star2 >= Star of
		true  -> {true, [Type]};
		false -> false
	end;


is_finish(?EVENT_MAKE_SUIT, {Slot, Order}, {_Level, Slot, Order2})->
	case Order2 >= Order of
		true  -> {true, [Slot]};
		false -> false
	end;

is_finish(?EVENT_COMPOSE, {Color, Star}, ItemId)->
	#cfg_item{color=Color2, type=Type} = cfg_item:find(ItemId),
	case Type == ?ITEM_TYPE_EQUIP of
		true ->
			#cfg_equip{star=Star2} = cfg_equip:find(ItemId),
			case Color2 >= Color andalso Star2 >= Star of
				true  -> {true, [ItemId]};
				false -> false
			end;
		false ->
			false
	end;

%获得宠物
is_finish(?EVENT_ITEM, Quality, {ItemId, Num})->
	case cfg_pet:find(ItemId) of
		?nil ->
			false;
		#cfg_pet{quality=Quality2} ->
			case Quality2 >= Quality of
				true  -> {true, sum, [Num]};
				false -> false
			end
	end;

is_finish(?EVENT_PET_COMPOSE, Quality, {_Type, PetId})->
	case check_pet(Quality, [PetId]) of
		{true, _PetId2} -> {true, sum, [1]};
		false -> false
	end;

is_finish(?EVENT_PET_STRONG, 0, ?nil)->
	{true, sum, [1]};

is_finish(?EVENT_BEAST_SUMMON, 0, BeastID)->
	{true, [BeastID]};

is_finish(?EVENT_BEAST_SUMMON, BeastID, BeastID)->
	{true, [BeastID]};

is_finish(?EVENT_PET_EVOLUTION, {IsFight, Evolution} ,{IsFight, Evolution})->
	{true, [Evolution]};

is_finish(?EVENT_PET_FIGHT, {IsFight, Quality}, {IsFight2, _Order, PetId})->
	case IsFight2 >= IsFight of
		true ->
			case check_pet(Quality, [PetId]) of
				{true, PetId2} -> {true, [PetId2]};
				false -> false
			end;
		false ->
			false
	end;

is_finish(?EVENT_PAY, Gold, {GainGold, _TodayOld, _TodayNew})->
	case GainGold >= Gold of
		true  -> {true, [GainGold]};
		false -> false
	end;

is_finish(?EVENT_VIP_CARD, CardId, CardId)->
	{true, [CardId]};

is_finish(?EVENT_VIPLV, VipLv, VipLv2) when VipLv2 >= VipLv->
	{true, [VipLv2]};

is_finish(?EVENT_SEARCH_TREASURE, 0, Count)->
	{true, sum, [Count]};

is_finish(?EVENT_MC_HUNT, 0, Type)->
	case Type of
		1 -> {true, sum, [1]};
		2 -> {true, sum, [10]};
		_ -> false
	end;

is_finish(?EVENT_VIP_MCARD, _Goal, _Args) ->
	{true, [0]};

is_finish(?EVENT_INVEST, _Goal, {_, Grade}) ->
	{true, [Grade]};

is_finish(_Event, _Goal, _Args)->
	false.


%检查宠物
check_pet(_Quality, [])->
	false;
check_pet(Quality, [PetId | PetIds])->
	#cfg_pet{quality=Quality2} = cfg_pet:find(PetId),
	case Quality2 >= Quality of
		true  -> {true, PetId};
		false -> check_pet(Quality, PetIds)
	end.
