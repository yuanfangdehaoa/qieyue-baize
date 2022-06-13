%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_god_dungeai).

-include("attr.hrl").
-include("btree.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([init/1]).
-export([update_barriers/1]).
-export([update/1]).
-export([summon/1]).
-export([escape/1]).
-export([stat/1]).
-export([is_clear/1]).
-export([is_over/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(SceneSt=#scene_st{scene=SceneID}) ->
    DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),

    {hook_enter, [Actor]} = dunge_util:get_event(),
	#{barriers:=BarriersHp, wave:=SWave} = Actor#actor.enter,

	BarrierInfo = case BarriersHp == [] of
		true  ->
			[];
		false ->
			lists:filtermap(fun
		    	({CreepID,X,Y,AttrID,AttCoef,DefCoef}) ->
					CreepHp = case BarriersHp == ?nil of
						true  -> 0;
						false -> proplists:get_value(CreepID, BarriersHp, ?nil)
					end,

					case CreepHp == ?nil of
						true  ->
							false;
						false ->
							CreepOpts = case CreepHp == 0 of
				    			true  -> #{group=>1};
				    			false -> #{group=>1, aiargs=>#{hp=>CreepHp}}
				    		end,
				    		{true,{CreepID,X,Y,AttrID,creeplv,AttCoef,DefCoef,CreepOpts}}
					end
		    end, cfg_creep_born:find(SceneID))
	end,

    Barriers = creep_agent:add(BarrierInfo, SceneSt),
    % ?debug("Barriers----------------:~w", [Barriers]),

    dunge_util:set_state(DungeSt#dunge_st{
    	wave = SWave - 1,
    	opts = Opts#{wave=>SWave, barriers=>Barriers}
	}),
	?SUCCESS.

update_barriers(_SceneSt) ->
    DungeSt  = #dunge_st{opts=Opts} = dunge_util:get_state(),
    Barriers = maps:get(barriers, Opts, []),
	Barriers2 = lists:filtermap(fun
		(ActorID) ->
			case lists:member(ActorID, Barriers) of
				true  ->
					case scene_actor:get_actor(ActorID) of
						?nil  ->
							false;
						Actor ->
							Hp = ?_attr(Actor#actor.attr, ?ATTR_HP),
							case Hp > 0 of
								true  -> {true, {Actor#actor.id,Hp}};
								false -> false
							end
					end;
				false ->
					false
			end
	end, scene_actor:get_actids(?ACTOR_TYPE_CREEP)),
	dunge_util:set_state(DungeSt#dunge_st{
		opts = maps:put(barriers, Barriers2, Opts)
	}),
	?SUCCESS.

update(SceneSt) ->
	DungeSt  = dunge_util:get_state(),
	#dunge_st{roles=[RoleID], opts=Opts} = DungeSt,
	Barriers = maps:get(barriers, Opts, []),
	{hook_creep_dead, [_Atker, Defer]} = dunge_util:get_event(),
	case lists:member(Defer#actor.uid, Barriers) of
		true  ->
			% ?debug("update_barriers----------------~w", [Defer#actor.uid]),
			Barriers2 = lists:delete(Defer#actor.uid, Barriers),
			dunge_util:set_state(DungeSt#dunge_st{
				opts = maps:put(barriers, Barriers2, Opts)
			});
		false ->
			ignore
	end,
	dunge_god:send_info(RoleID, SceneSt),
	?SUCCESS.

summon(SceneSt) ->
	DungeSt = dunge_util:get_state(),
	#dunge_st{id=DungeID, wave=Wave, opts=Opts, roles=[RoleID]} = DungeSt,
	SWave = maps:get(wave, Opts),
	case Wave >= SWave of
		true  ->
			% ?debug("give_reward---------------------------~w", [Wave]),
			#actor{level=RoleLv} = scene_actor:get_actor(RoleID),
			Reward = dunge_god:calc_clear_reward(RoleLv, DungeID, Wave, Wave),
			role:route(RoleID, dunge_god, give_reward, [Reward]);
		false ->
			Reward = []
	end,
	Drops1 = maps:get(drops, Opts, #{}),
	Drops2 = lists:foldl(fun
		({ID,N,_}, Acc) ->
			ut_misc:maps_increase(ID, N, Acc)
	end, Drops1, Reward),
	Opts1 = maps:remove(escape, Opts),
	Opts2 = maps:put(drops, Drops2, Opts1),
	dunge_util:set_state(DungeSt#dunge_st{count=#{}, kill=#{}, opts=Opts2}),
	{X,Y} = cfg_game:dunge_god_escape(),
	dunge_aiwave:summon(#{dest=>#p_coord{x=X, y=Y}}, SceneSt),
	dunge_god:send_info(RoleID, SceneSt),
	?SUCCESS.

escape(SceneSt) ->
	DungeSt = #dunge_st{roles=[RoleID], opts=Opts} = dunge_util:get_state(),
	dunge_util:set_state(DungeSt#dunge_st{
		opts = ut_misc:maps_increase(escape, 1, Opts)
	}),
	dunge_god:send_info(RoleID, SceneSt),
	?SUCCESS.

stat(SceneSt) ->
	#dunge_st{roles=[RoleID], wave=Wave, opts=Opts} = dunge_util:get_state(),
	#{wave:=SWave, barriers:=Barriers} = Opts,
	EWave = case dunge_aiwave:is_over(SceneSt) of
		true  -> Wave;
		false -> Wave - 1
	end,

	Clear = EWave >= SWave,

	?ucast(RoleID, #m_dunge_over_toc{
		stype = SceneSt#scene_st.stype,
		id    = SceneSt#scene_st.dunge,
		clear = Clear,
		stat  = #{
			"start_wave" => SWave,
			"end_wave"   => Wave
		},
		reward = maps:get(drops, Opts, #{})
	}),

	role:route(RoleID, dunge_god, dunge_stat, [Clear,EWave,Barriers]),

	?SUCCESS.

is_clear(_SceneSt) ->
	#dunge_st{wave=CurWave, opts=Opts} = dunge_util:get_state(),
	SWave = maps:get(wave, Opts),
	CurWave /= SWave.

is_over(_SceneSt) ->
	#dunge_st{wave=Wave, opts=Opts} = dunge_util:get_state(),
	CurEscape = maps:get(escape, Opts, 0),
	MaxEscape = cfg_dunge_god:max_escape(Wave),
	% ?debug("is_over-----------------------:~w", [{CurEscape, MaxEscape}]),
	CurEscape >= MaxEscape.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
