%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fight_select).

-include("creep.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([select/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
select(Atker, ?nil, Attack, SceneSt) ->
	#skill{area=Area} = Attack#attack.skill,
	case Area == ?SKILL_AREA_SINGLE of
		true  -> [];
		false -> do_select(Atker, Attack, 0, Attack#attack.coord, SceneSt)
	end;
select(Atker, Major, Attack, SceneSt) ->
	#skill{area=Area} = Attack#attack.skill,
	case Area == ?SKILL_AREA_SINGLE of
		true  ->
			[Major];
		false ->
			#actor{uid=MajorID, coord=Center} = Major,
			Defers = do_select(Atker, Attack, MajorID, Center, SceneSt),
			[Major | Defers]
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_select(Atker, Attack, MajorID, Coord, SceneSt) ->
	#skill{aim=Aim, center=CenterType} = Attack#attack.skill,
	Center = ?_if(CenterType == 2, Coord, Atker#actor.coord),
	case Aim of
        ?SKILL_AIM_ENEMY ->
            select_enemy(Atker, Attack, MajorID, Center, SceneSt);
        ?SKILL_AIM_SELF  ->
        	[Atker];
        ?SKILL_AIM_ALLY  ->
            select_ally(Atker, Attack, MajorID, Center, SceneSt)
    end.

%% 选取技能范围内的敌方单位
select_enemy(Atker, Attack, MajorID, Center, SceneSt) ->
	#skill{cover={Cover1,Cover2}, dist=Dist} = Attack#attack.skill,
	#cfg_scene{safe=IsSafe} = cfg_scene:find(SceneSt#scene_st.scene),
	% 选取可攻击的玩家
	RoleIDs1 = case IsSafe andalso ?is_role(Atker) of
		true  -> [];
		false -> scene_actor:get_actids(?ACTOR_TYPE_ROLE, Center)
	end,
	RoleIDs2 = lists:delete(Atker#actor.uid, RoleIDs1),
	RoleIDs3 = lists:delete(MajorID, RoleIDs2),
	% 选取可攻击的怪物
	CreepIDs1 = scene_actor:get_actids(?ACTOR_TYPE_CREEP, Center),
	CreepIDs2 = lists:delete(Atker#actor.uid, CreepIDs1),
	CreepIDs3 = lists:delete(MajorID, CreepIDs2),
	Roles  = select_defers(Atker, Attack, Center, Cover1-1, Dist, ?ACTOR_TYPE_ROLE, RoleIDs3),
	Creeps = select_defers(Atker, Attack, Center, Cover2-1, Dist, ?ACTOR_TYPE_CREEP, CreepIDs3),
	Roles ++ Creeps.

select_defers(Atker, Attack, Center, Cover, SkillDist, Type, ActorIDs) ->
	#attack{skill=Skill} = Attack,
	Defers1 = lists:filtermap(fun
		(ActorID) ->
			Actor = scene_actor:get_actor(ActorID),
			if
				Actor == ?nil ->
					?error("nonexist actor: ~w", [{
						Atker#actor.uid,
						Atker#actor.id,
						Atker#actor.scene,
						Atker#actor.dunge,
						Center,
						ActorID
					}]),
					scene_actor:del_actid(ActorID, Type, Center),
					false;
				?is_death(Actor#actor.state) ->
					false;
				?is_coll(Actor) ->
					false;
				?is_tomb(Actor) ->
					false;
				?is_boss(Actor) ->
					case Skill#skill.group == ?SKILL_GROUP_ANGER of
						true  -> {true, Actor};
						false -> false
					end;
				true ->
					Dist = scene_util:calc_distance(Actor#actor.coord, Center),
					case Dist =< SkillDist of
						true  -> {true, Actor#actor{dist=Dist}};
						false -> false
					end
			end
	end, ActorIDs),
	Defers2 = lists:keysort(#actor.dist, Defers1),
	select_defers2(Defers2, Atker, Attack, Center, Cover, []).

select_defers2(_Defers, _Atker, _Attack, _Center, Conver, Acc) when Conver =< 0 ->
	Acc;
select_defers2([], _Atker, _Attack, _Center, _Cover, Acc) ->
	Acc;
select_defers2([Defer | T], Atker, Attack, Center, Cover, Acc) ->
	case is_in_area(Defer, Center, Attack) of
		true  ->
			Acc2 = ?_if(can_injure(Atker, Defer), [Defer | Acc], Acc),
			select_defers2(T, Atker, Attack, Center, Cover-1, Acc2);
		false ->
			select_defers2(T, Atker, Attack, Center, Cover, Acc)
	end.

is_in_area(Defer, Center, Attack) ->
	#attack{skill=Skill, dir=Dir} = Attack,
	#skill{area=Area, dist=Dist, radius=Radius} = Skill,
	case Area of
		?SKILL_AREA_RECT ->
			is_in_rect(Center, Defer#actor.coord, Dir, Dist, Radius);
		?SKILL_AREA_SECTOR ->
			is_in_sector(Center, Defer#actor.coord, Dir, Dist, Radius);
		?SKILL_AREA_CIRCLE ->
			is_in_circle(Center, Defer#actor.coord, Dir, Dist, Radius)
	end.

%% Coord2 是否在 Coord1 前方的矩形范围内
is_in_rect(Coord1, Coord2, Degree, Height, Width) ->
	Radian = -Degree * math:pi() / 180,
	#p_coord{x=X1, y=Y1} = Coord1,
	#p_coord{x=X2, y=Y2} = Coord2,
	% 平移变换
	X3 = X2 - X1,
	Y3 = Y2 - Y1,
	% 旋转变换
	X4 = X3 * math:cos(Radian) + Y3 * math:sin(Radian),
	Y4 = Y3 * math:cos(Radian) - X3 * math:sin(Radian),
	% 是否在矩形内
	-Width/2 =< X4 andalso X4 =< Width/2 andalso 0 =< Y4 andalso Y4 =< Height.

%% Coord2 是否在 Coord1 前方的扇形范围内
%% Alpha: Coord1 与 y 轴的夹角
%% Beta : Coord1 与 Coord2 的夹角
%% Theta: 技能的扇形夹角
is_in_sector(Coord1, Coord2, Alpha, Dist, Theta) ->
	case scene_util:is_nearby(Coord1, Coord2, Dist) of
		true  ->
			Beta = scene_util:calc_degree(Coord1, Coord2),
			Alpha-Theta/2 =< Beta andalso Beta =< Alpha+Theta/2;
		false ->
			false
	end.

%% Actor2 是否在 Actor1 前方的圆形范围内
is_in_circle(Coord1, Coord2, _Angle, _Dist, Radius) ->
	scene_util:is_nearby(Coord1, Coord2, Radius).

%% 是否可被攻击
can_injure(Atker, Defer) ->
	if
		?is_unbeat(Defer#actor.state) ->
			false;
		true ->
			SceneSt = scene_util:get_state(),
			ok == fight_filter:check_injure(Atker, Defer, SceneSt)
	end.


%% 选取技能范围内的友方单位
select_ally(Atker, _Attack, _MajorID, _Center, _SceneSt) when Atker#actor.team == 0 ->
	[Atker];
select_ally(Atker, Attack, MajorID, Center, _SceneSt) ->
	RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE, Center),
	#attack{skill=Skill, dir=Dir} = Attack,
	#skill{dist=Dist, radius=Radius} = Skill,
	lists:filtermap(fun
		(ActorID) ->
			Actor = scene_actor:get_actor(ActorID),
			case
				ActorID /= MajorID andalso
				Actor#actor.team == Atker#actor.team andalso
				is_in_circle(Atker, Actor, Dir, Dist, Radius)
			of
				true  -> {true, Actor};
				false -> false
			end
	end, RoleIDs).
