%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(task_counter).

-include("boss.hrl").
-include("creep.hrl").
-include("dunge.hrl").
-include("equip.hrl").
-include("game.hrl").
-include("item.hrl").
-include("table.hrl").
-include("task.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([update/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 升级
update(?EVENT_LEVEL, Level, _Target, _Conds) ->
	{'=', Level};
%% 对话
update(?EVENT_TALK, {NpcID, TaskID}, {NpcID, TaskID}, _Conds) ->
	{'=', 1};
%% 打怪
update(?EVENT_CREEP, {CreepID, Rarity}, CreepID, Conds) ->
	case check_creep_conds(Conds, {CreepID, Rarity}) of
		true  -> {'+', 1};
		false -> false
	end;
update(?EVENT_CREEP, {CreepID, Rarity}, Rarity, Conds) ->
	case check_creep_conds(Conds, {CreepID, Rarity}) of
		true  -> {'+', 1};
		false -> false
	end;
%% 采集
update(?EVENT_COLLECT, {CreepID,_Rarity}, CreepID, _Conds) ->
	{'+', 1};
%% 副本
update(?EVENT_DUNGE, {SType, Dunge, Floor, Opts}, SType, Conds) ->
	case check_dunge_conds(Conds, {SType, Dunge, Floor, Opts}) of
		true  -> {'+', 1};
		false -> false
	end;
update(?EVENT_DUNGE, {SType, Dunge, Floor, Opts}, Dunge, Conds) ->
	case check_dunge_conds(Conds, {SType, Dunge, Floor, Opts}) of
		true  -> {'+', 1};
		false -> false
	end;
% 副本进入
update(?EVENT_DUNGE_ENTER, {SType, Dunge, Floor}, SType, Conds) ->
	case check_dunge_conds(Conds, {SType, Dunge, Floor}) of
		true  -> {'+', 1};
		false -> false
	end;
% 副本进入
update(?EVENT_DUNGE_ENTER, {SType, Dunge, Floor}, Dunge, Conds) ->
	case check_dunge_conds(Conds, {SType, Dunge, Floor}) of
		true  -> {'+', 1};
		false -> false
	end;
%% 副本通关
update(?EVENT_DUNGE_FLOOR, {SType, Dunge, Floor}, SType, Conds) ->
	case check_dunge_conds(Conds, {SType, Dunge, Floor}) of
		true  -> {'=', Floor};
		false -> false
	end;
%% 副本通关
update(?EVENT_DUNGE_FLOOR, {SType, Dunge, Floor}, Dunge, Conds) ->
	case check_dunge_conds(Conds, {SType, Dunge, Floor}) of
		true  -> {'=', Floor};
		false -> false
	end;
%% 副本难度
update(?EVENT_DUNGE_STAR, {SType, Dunge, Floor, Star}, SType, Conds) ->
	case check_dunge_conds(Conds, {SType, Dunge, Floor, Star}) of
		true  -> {'=', Star};
		false -> false
	end;
%% 任务
update(?EVENT_TASK, {TaskType, _TaskID}, TaskType, _Conds) ->
	{'+', 1};
%% 觉醒
update(?EVENT_WAKE, WakeTimes, WakeTimes, _Conds) ->
	{'=', 1};
%% 收集
update(?EVENT_ITEM, {ItemID, _Num}, ItemID, _Conds) ->
	{'=', role_bag:get_num(ItemID)};
%% 战力
update(?EVENT_POWER, RolePower, _Target, _Conds) ->
	{'=', RolePower};
%% 装备穿戴
update(?EVENT_EQUIP, {_Slot, _ItemID, Equips}, _Target, Conds) ->
	Num = maps:fold(fun
		(_, CellID, Acc) ->
			{ok, Equip} = role_bag:get_item(CellID),
			case check_equip_conds(Conds, Equip) of
				true  -> Acc + 1;
				false -> Acc
			end
	end, 0, Equips),
	{'=', Num};
%% 强化
update(?EVENT_EQUIP_STRENGTH, {ItemID, Phase, Level}, CfgSType, Conds) when ItemID > 0 ->
	IsValidSType = case CfgSType == 0 of
		true  ->
			true;
		false ->
			#cfg_item{stype=SType} = cfg_item:find(ItemID),
			SType == CfgSType
	end,
	case IsValidSType andalso check_strength_conds(Conds, {ItemID, Phase, Level}) of
		true  -> {'+', 1};
		false -> false
	end;
% %% 合成
update(?EVENT_COMPOSE, ItemID, CfgType, Conds) ->
	CfgItem = #cfg_item{type=Type} = cfg_item:find(ItemID),
	case CfgType == 0 orelse Type == CfgType of
		true  ->
			case check_compose_conds(Conds, CfgItem) of
				true  -> {'+', 1};
				false -> false
			end;
		false ->
			false
	end;
%% 日常活跃
update(?EVENT_LIVENESS, Liveness, 1, _Conds) ->
	{'=', Liveness};
%% 护送
update(?EVENT_ESCORT, {Quality, _}, CfgQua, _Conds) when Quality >= CfgQua ->
	{'+', 1};
%% 添加好友
update(?EVENT_FRIEND, _Args, _Target, _Conds) ->
	{'+', 1};
%% 镶嵌宝石
update(?EVENT_STONE, AllStones, CfgLv, _Conds) ->
	Num = lists:foldl(fun
		(Stones, Acc1) ->
			maps:fold(fun
				(_, StoneID, Acc2) ->
					#cfg_stone{level=StoneLv} = cfg_stone:find(StoneID),
					case StoneLv >= CfgLv of
					 	true  ->
					 		Acc2 + 1;
					 	false ->
					 		Acc2
					end
			end, Acc1, Stones)
	end, 0, maps:values(AllStones)),
	{'=', Num};
%% 加入帮派
update(?EVENT_GUILD_JOIN, _Args, _Target, _Conds) ->
	{'+', 1};
%% 吞噬装备
update(?EVENT_EQUIP_SMELT, {Num, _Level}, _Target, _Conds) ->
	{'+', Num};
%% 市场上架
update(?EVENT_MARKET_SALE, Num, _Target, _Conds) ->
	{'+', Num};
%% 帮派捐献
update(?EVENT_GUILD_DONATE, ItemID, CfgColor, _Conds) ->
	#cfg_item{color=Color} = cfg_item:find(ItemID),
	case Color >= CfgColor of
		true  -> {'+', 1};
		false -> false
	end;
%% 竞技场排名
update(?EVENT_ARENA, Rank, TargetRank, _Conds) when Rank > 0 andalso Rank =< TargetRank ->
	{'+', 1};
%% 宠物融合
update(?EVENT_PET_COMPOSE, {Type, _PetId}, CfgType, _Conds) when Type >= CfgType ->
	{'+', 1};
%% 宝石升级
update(?EVENT_STONE_UPGRADE, _ItemID, _Target, _Conds) ->
	{'+', 1};
%% 送花
update(?EVENT_FLOWER, Flower, Target, _Conds) when Target == 0; Target == Flower ->
    {'+', 1};
%% 结婚
update(?EVENT_MARRY, _EventArgs, _Target, _Conds) ->
    {'+', 1};
%% 魔法卡寻宝
update(?EVENT_MC_HUNT, _EventArgs, _Target, _Conds) ->
    {'+', 1};
%% 参加活动
update(?EVENT_ACTIVITY_JOIN, ActID, ActID, _Conds) ->
	{'+', 1};
%% 装备洗练
update(?EVENT_EQUIP_REFINE, Color, TargetColor, _Conds) when Color >= TargetColor->
	{'+', 1};
%% 装备铸造
update(?EVENT_EQUIP_CAST, Level, Level, _Conds)->
	{'+', 1};
%% 异兽助战
update(?EVENT_BEAST_SUMMON, BeastID, Target, _Conds) when Target == 0 orelse BeastID == Target ->
	{'+', 1};
update(_Event, _EventArgs, _Target, _Conds) ->
	false.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_creep_conds([], _Args) ->
	true;
check_creep_conds([{boss_type, BossType} | T], {CreepID, Rarity}) ->
	case cfg_boss:find(CreepID) of
        #cfg_boss{type=BossType} ->
        	check_creep_conds(T, {CreepID, Rarity});
        _ ->
        	false
    end;
check_creep_conds([{level, Level}|T], {CreepID, Rarity}) ->
	case cfg_creep:find(CreepID) of
		#cfg_creep{level=Lv} when Lv >= Level ->
			check_creep_conds(T, {CreepID, Rarity});
		_ ->
			false
	end.


check_dunge_conds([], _Args) ->
	true;
% 经验副本获得经验
check_dunge_conds([{exp, CfgExp} | T], Args = {_SType, _Dunge, _Floor, Opts}) ->
	case proplists:get_value(exp, Opts, 0) >= CfgExp of
		true  ->
			check_dunge_conds(T, Args);
		false ->
			false
	end;
% 副本等级
check_dunge_conds([{level, CfgLv} | T], Args = {_SType, Dunge, _Floor}) ->
	#cfg_dunge{level=DungeLv} = cfg_dunge:find(Dunge),
	case DungeLv >= CfgLv of
		true  ->
			check_dunge_conds(T, Args);
		false ->
			false
	end;
% 副本id
check_dunge_conds([{dunge, CfgDunge} | T], Args = {_SType, Dunge, _Floor}) ->
	case Dunge == CfgDunge of
		true  ->
			check_dunge_conds(T, Args);
		false ->
			false
	end;
% 副本层数
check_dunge_conds([{floor, CfgFloor} | T], Args = {_SType, _Dunge, Floor}) ->
	case Floor >= CfgFloor of
		true  ->
			check_dunge_conds(T, Args);
		false ->
			false
	end.



check_strength_conds([], _Args) ->
	true;
check_strength_conds([{phase, CfgPhase} | T], Args = {_ItemID, Phase, _Level}) ->
	case Phase == CfgPhase of
		true  ->
			check_strength_conds(T, Args);
		false ->
			false
	end;
check_strength_conds([{level, CfgLv} | T], Args = {_ItemID, _Phase, Level}) ->
	case Level == CfgLv of
		true  ->
			check_strength_conds(T, Args);
		false ->
			false
	end.

check_equip_conds([{quality, CfgQua} | T], Equip) ->
	#cfg_item{color=Quality} = cfg_item:find(Equip#p_item.id),
	case Quality >= CfgQua of
		true  -> check_equip_conds(T, Equip);
		false -> false
	end;
check_equip_conds([{order, CfgOrder} | T], Equip) ->
	#cfg_equip{order=Order} = cfg_equip:find(Equip#p_item.id),
	case Order >= CfgOrder of
		true  -> check_equip_conds(T, Equip);
		false -> false
	end;
check_equip_conds([_ | T], Equip) ->
	check_equip_conds(T, Equip);
check_equip_conds([], _Equip) ->
	true.


check_compose_conds([{quality, CfgQua} | T], CfgItem) ->
	case CfgItem#cfg_item.color >= CfgQua of
		true  -> check_compose_conds(T, CfgItem);
		false -> false
	end;
check_compose_conds([{order, CfgOrder} | T], CfgItem) ->
	#cfg_equip{order=Order} = cfg_equip:find(CfgItem#cfg_item.id),
	case Order >= CfgOrder of
		true  -> check_compose_conds(T, CfgItem);
		false -> false
	end;
check_compose_conds([_ | T], CfgItem) ->
	check_compose_conds(T, CfgItem);
check_compose_conds([], _CfgItem) ->
	true.
