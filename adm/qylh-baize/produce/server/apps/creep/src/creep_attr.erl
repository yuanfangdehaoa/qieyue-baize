%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(creep_attr).

-include("attr.hrl").
-include("creep.hrl").
-include("dunge.hrl").
-include("faker.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([calc/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
calc(Actor, SceneSt) when SceneSt#scene_st.stype == ?SCENE_STYPE_DUNGE_MAGICTOWER ->
	#actor{id=CreepID, level=CreepLv} = Actor,
	#cfg_dunge_magic{power=StdPower} = cfg_dunge_magic:find(SceneSt#scene_st.floor),
	#dunge_st{roles=[RoleID]} = dunge_util:get_state(),
	% 怪物出生时，有可能玩家已经退出副本
	case scene_actor:get_actor(RoleID) of
		#actor{level=RoleLv, power=RolePower} ->
			Coef1 = cfg_creep_suppress:find(1, CreepID, CreepLv-RoleLv),
			Coef2 = cfg_creep_suppress:find(2, CreepID, StdPower-RolePower),
			Attr  = init_attr(Actor),
			Att2  = ut_math:ceil(?_attr(Attr,?ATTR_ATT) * (1+?_per(Coef1)) * (1+?_per(Coef2))),
			?_setattr(Attr, ?ATTR_ATT, Att2);
		_ ->
			#{}
	end;

calc(Actor, SceneSt) when SceneSt#scene_st.stype == ?SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER, ?is_creep(Actor) ->
	#actor{id=CreepID, level=CreepLv} = Actor,
	#cfg_dunge{power=StdPower} = cfg_dunge:find(SceneSt#scene_st.dunge),
	#dunge_st{roles=[RoleID | _]} = dunge_util:get_state(),
	% 怪物出生时，有可能玩家已经退出副本
	case scene_actor:get_actor(RoleID) of
		#actor{level=RoleLv, power=RolePower} ->
			Coef1 = cfg_creep_suppress:find(1, CreepID, CreepLv-RoleLv),
			Coef2 = cfg_creep_suppress:find(2, CreepID, StdPower-RolePower),
			Attr  = init_attr(Actor),
			Att2  = ut_math:ceil(?_attr(Attr,?ATTR_ATT) * (1+?_per(Coef1)) * (1+?_per(Coef2))),
			?_setattr(Attr, ?ATTR_ATT, Att2);
		_ ->
			#{}
	end;

calc(Actor, SceneSt) when SceneSt#scene_st.stype == ?SCENE_STYPE_COMBAT1V1 ->
	Attr  = Actor#actor.attr,
	IniAttr = Actor#actor.initattr,
	Attr1 = lists:foldl(fun({Code, Coef}, Attr0) ->
		maps:put(Code, round(maps:get(Code, Attr0, 0) * ?_per(Coef)), Attr0)
											end, Attr, cfg_combat1v1:weaken_robot()),
	Attr2 = lists:foldl(fun({Code, Coef}, Attr0) ->
		maps:put(Code, round(maps:get(Code, Attr0, 0) * ?_per(Coef)), Attr0)
											end, IniAttr, cfg_combat1v1:weaken_robot()),
	Attr1#{
		?ATTR_HP => maps:get(?ATTR_HPMAX, Attr2),
		?ATTR_HPMAX => maps:get(?ATTR_HPMAX, Attr2)
	};

calc(Actor, SceneSt) when SceneSt#scene_st.stype == ?SCENE_STYPE_COMPETE_BATTLE ->
	Attr  = Actor#actor.attr,
	Attr1 = lists:foldl(fun({Code, Coef}, Attr0) ->
		maps:put(Code, round(maps:get(Code, Attr0, 0) * ?_per(Coef)), Attr0)
	end, Attr, cfg_combat1v1:weaken_robot()),
	Attr1#{
		?ATTR_HP => maps:get(?ATTR_HPMAX, Attr1)
	};

calc(Actor, _SceneSt) when ?is_faker(Actor) ->
	[RoleAttr] = db:dirty_read(?DB_ROLE_ATTR, Actor#actor.attrid),
	FakerID = maps:get(faker_id, Actor#actor.aiargs),
	#cfg_faker{coef=CoefList} = cfg_faker:find(FakerID),
	#role_attr{attr=Attr} = RoleAttr,
	HpMax = round(?_attr(Attr,?ATTR_HPMAX)
		* ?_per(proplists:get_value(?ATTR_HPMAX, CoefList, ?PER_10000))),
	Attr#{
	    ?ATTR_ATT   => ?_attr(Attr,?ATTR_ATT)
	    	* ?_per(proplists:get_value(?ATTR_ATT, CoefList, ?PER_10000)),
	    ?ATTR_WRECK => ?_attr(Attr,?ATTR_WRECK)
	    	* ?_per(proplists:get_value(?ATTR_WRECK, CoefList, ?PER_10000)),
	    ?ATTR_DEF   => ?_attr(Attr,?ATTR_DEF)
	    	* ?_per(proplists:get_value(?ATTR_DEF, CoefList, ?PER_10000)),
	    ?ATTR_HPMAX => HpMax,
	    ?ATTR_HP    => HpMax,
	    ?ATTR_SPEED => ?_attr(Attr, ?ATTR_SPEED, cfg_game:role_speed())
	};

calc(Actor, _SceneSt) when not ?is_monst(Actor) ->
	#cfg_creep{speed=Speed} = cfg_creep:find(Actor#actor.id),
	#{?ATTR_SPEED=>Speed};

calc(Actor, _SceneSt) when ?is_robot(Actor) ->
	case Actor#actor.attr of
		?nil ->
			init_attr(Actor);
		_ ->
			Attr1 = Actor#actor.attr,
			Attr1#{
				?ATTR_HP => maps:get(?ATTR_HPMAX, Attr1)
			}
	end;

calc(Actor, SceneSt) when SceneSt#scene_st.stype == ?SCENE_STYPE_CROSS_GUILDWAR ->
	Attr = init_attr(Actor),
	case maps:get(repair, Actor#actor.exargs, false) of
		true  ->
			Attr#{
				?ATTR_HP => round(maps:get(?ATTR_HPMAX, Attr) / 2)
			};
		false ->
			Attr
	end;

calc(Actor, _SceneSt) ->
    init_attr(Actor).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
init_attr(Actor) ->
	#actor{id=CreepID, attrid=AttrID, level=Level, aiargs=AIArgs} = Actor,
	case cfg_creep_attr:find(AttrID, Level) of
		?nil ->
			?error("bad attr:~w", [{CreepID, AttrID, Level}]);
		Attr ->
			MaxHp = round(?_attr(Attr,?ATTR_HPMAX) * ?_per(Actor#actor.dfcoef)),
			CurHp = maps:get(hp, AIArgs, MaxHp),
			#cfg_creep{speed=Speed} = cfg_creep:find(Actor#actor.id),
			Attr#{
			    ?ATTR_ATT   => ?_attr(Attr,?ATTR_ATT) * ?_per(Actor#actor.atcoef),
			    ?ATTR_WRECK => ?_attr(Attr,?ATTR_WRECK) * ?_per(Actor#actor.atcoef),
			    ?ATTR_DEF   => ?_attr(Attr,?ATTR_DEF) * ?_per(Actor#actor.dfcoef),
			    ?ATTR_HPMAX => MaxHp,
			    ?ATTR_HP    => CurHp,
			    ?ATTR_SPEED => Speed
			}
	end.
