%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(config_check).

-include("creep.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("yunying.hrl").
-include("enum.hrl").

%% API
-export([run/0]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
run() ->
	ErrList = check_scene()
		++ check_creep()
		++ check_drop()
		++ check_market()
		++ check_yunying_reward()
		++ check_skill(),
	lists:foreach(fun
		(Err) ->
			io:format(Err)
	end, ErrList),
	?_if(ErrList /= [], halt(1)),
	ok.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 场景检测
check_scene() ->
    lists:foldl(fun
        (SceneID, Acc) ->
            check_scene_born(SceneID)
            	++ check_scene_reborn(SceneID)
            	++ check_scene_creeps(SceneID)
            	++ Acc
    end, [], cfg_scene:scenes()).

check_scene_born(SceneID) ->
	#cfg_scene{type=Type} = cfg_scene:find(SceneID),
	case Type == ?SCENE_TYPE_CITY orelse Type == ?SCENE_TYPE_FIELD of
		true  ->
			case scene_config:born(SceneID) == [] of
			    true  ->
			    	[io_lib:format("scene[~w] had no born coord~n", [SceneID])];
			    false ->
			        []
			end;
		false ->
			[]
	end.

check_scene_reborn(SceneID) ->
	#cfg_scene{type=Type} = cfg_scene:find(SceneID),
	case Type == ?SCENE_TYPE_CITY orelse Type == ?SCENE_TYPE_FIELD of
		true  ->
			case scene_config:reborn(SceneID) == [] of
			    true  ->
			        [io_lib:format("scene[~w] had no reborn coord~n", [SceneID])];
			    false ->
			        []
			end;
		false ->
			[]
	end.

check_scene_creeps(SceneID) ->
    lists:foldl(fun
        ({CreepID, _}, Acc) ->
            check_scene_creep(SceneID, CreepID) ++ Acc
    end, [], scene_config:creeps(SceneID)).

check_scene_creep(SceneID, CreepID) ->
	case cfg_creep:find(CreepID) == ?nil of
	    true  ->
	    	[io_lib:format("scene[~w] had nonexist creep[~w]~n", [SceneID, CreepID])];
	    false ->
	        []
	end.

%% 怪物检测
check_creep() ->
	lists:foldl(fun
		(CreepID, Acc) ->
			CfgCreep = cfg_creep:find(CreepID),
			#cfg_creep{drops=Drops, skills1=Skills1, skills2=Skills2} = CfgCreep,
			check_creep_drops(CreepID, Drops)
				++ check_creep_skill(CreepID, [E || {E,_} <- Skills1])
				++ check_creep_skill(CreepID, Skills2)
				++ Acc
	end, [], cfg_creep:creeps()).

check_creep_drops(CreepID, Drops) ->
	lists:foldl(fun
		({DropID, _}, Acc) ->
			check_creep_drop(CreepID, DropID) ++ Acc
	end, [], Drops).

check_creep_drop(CreepID, DropID) ->
	case lists:member(DropID, cfg_drop:drops()) of
		true  ->
			[];
		false ->
			[io_lib:format("creep[~w] had nonexist drop[~w]~n", [CreepID, DropID])]
	end.

check_creep_skill(CreepID, SkillIDs) ->
	lists:foldl(fun
		(SkillID, Acc) ->
			case SkillID > 0 andalso cfg_skill_level:find(SkillID, 1) of
				?nil ->
					[io_lib:format("creep[~w] had nonexist skill[~w]~n", [CreepID, SkillID]) | Acc];
				_ ->
					Acc
			end
	end, [], SkillIDs).

%% 掉落检测
check_drop() ->
    lists:foldl(fun
        (DropID, Acc) ->
        	check_drop_item(DropID) ++ Acc
    end, [], cfg_drop:drops()).

check_drop_item(DropID) ->
	case cfg_drop:find(DropID) of
		{1, Items} ->
			check_drop_item2(DropID, Items);
		{2, [{_, _, WtList}]} ->
			Items = lists:flatten([E || {E, _} <- WtList]),
			check_drop_item2(DropID, Items);
		{3, PropList} ->
			Items = lists:flatten([E || {E, _} <- PropList]),
			check_drop_item2(DropID, Items)
	end.

check_drop_item2(DropID, Items) ->
	lists:foldl(fun
		(ItemInfo, Acc) ->
			check_item(ItemInfo, "drop[~w] had nonexist item[~p]~n", [DropID]) ++ Acc
	end, [], Items).

check_market() ->
	lists:foldl(fun
		(ItemID, Acc) ->
			check_item({ItemID, ?nil}, "market had nonexist item[~w]~n", []) ++ Acc
	end, [], cfg_market_item:all()).

check_yunying_reward() ->
	lists:foldl(fun
		({YYActID, RewardID}, Acc1) ->
			Mod = yunying_util:cfg_reward_mod(YYActID),
			#cfg_yunying_reward{reward=Rewards} = Mod:find(YYActID, RewardID),
			lists:foldl(fun
				(Reward, Acc2) ->
					check_item(Reward, "yunying_reward[~w,~w] had nonexist item[~w]~n", [YYActID, RewardID]) ++ Acc2
			end, Acc1, Rewards)
	end, [], cfg_yunying_reward:all()),
	lists:foldl(fun
		({YYActID, RewardID}, Acc1) ->
			Mod = yunying_util:cfg_reward_mod(YYActID),
			#cfg_yunying_reward{reward=Rewards} = Mod:find(YYActID, RewardID),
			lists:foldl(fun
				(Reward, Acc2) ->
					check_item(Reward, "festival_reward[~w,~w] had nonexist item[~w]~n", [YYActID, RewardID]) ++ Acc2
			end, Acc1, Rewards)
	end, [], cfg_festival_reward:all()).

check_item({ItemID, _}, Format, Args) when is_integer(ItemID) ->
	case cfg_item:find(ItemID) == ?nil of
		true  -> [io_lib:format(Format, Args ++ [ItemID])];
		false -> []
	end;
check_item({ItemID, _, _}, Format, Args) when is_integer(ItemID) ->
	case cfg_item:find(ItemID) == ?nil of
		true  -> [io_lib:format(Format, Args ++ [ItemID])];
		false -> []
	end;
check_item({ItemIDs, _}, Format, Args) when is_list(ItemIDs) ->
	lists:foldl(fun
		(ItemID, Acc) ->
			case cfg_item:find(ItemID) == ?nil of
				true  -> [io_lib:format(Format, Args ++ [ItemID]) | Acc];
				false -> Acc
			end
	end, [], ItemIDs);
check_item({ItemIDs, _, _}, Format, Args) when is_list(ItemIDs) ->
	lists:foldl(fun
		(ItemID, Acc) ->
			case cfg_item:find(ItemID) == ?nil of
				true  -> [io_lib:format(Format, Args ++ [ItemID]) | Acc];
				false -> Acc
			end
	end, [], ItemIDs);
check_item(ItemInfo, Format, Args) ->
	[io_lib:format(Format, Args ++ [ItemInfo])].


check_skill() ->
	lists:foldl(fun
		(SkillID, Acc) ->
			check_skill(SkillID) ++ Acc
	end, [], cfg_skill:all()).

check_skill(SkillID) ->
	Levels = cfg_skill_level:levels(SkillID),
	case Levels == ?nil of
		true  ->
			[io_lib:format("skill ~w not config in skill_level~n", [SkillID])];
		false ->
			lists:foldl(fun
				(SkillLv, Acc) ->
					CfgLevel = cfg_skill_level:find(SkillID, SkillLv),
					#cfg_skill_level{buffs=Buffs, abuffs=ABuffs, dbuffs=DBuffs} = CfgLevel,
					check_skill_buffs(SkillID, SkillLv, Buffs ++ ABuffs ++ DBuffs) ++ Acc
			end, [], Levels)
	end.

check_skill_buffs(SkillID, SkillLv, Buffs) ->
	lists:foldl(fun
		(BuffID, Acc) when is_integer(BuffID) ->
			check_skill_buff(SkillID, SkillLv, BuffID) ++ Acc;
		({BuffID, _}, Acc) ->
			check_skill_buff(SkillID, SkillLv, BuffID) ++ Acc
	end, [], Buffs).

check_skill_buff(SkillID, SkillLv, BuffID) ->
	case cfg_buff:find(BuffID) == ?nil of
		true  ->
			[io_lib:format("skill ~w(~w) had nonexist buff ~w~n", [SkillID, SkillLv, BuffID])];
		false ->
			[]
	end.