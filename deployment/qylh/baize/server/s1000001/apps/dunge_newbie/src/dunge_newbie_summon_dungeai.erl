%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_newbie_summon_dungeai).

-include("dunge.hrl").
-include("figure.hrl").
-include("game.hrl").
-include("pet.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([enter_opts/2]).
-export([hook_leave/2]).
-export([summon_oldpet/2]).

-define(SPECIAL_PET, 49999997).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
enter_opts(_Entry, RoleSt) ->
	EnterOpts = case role_pet:get_fight() of
		{ok, OldPet} ->
			#cfg_pet{order=OldOrder} = cfg_pet:find(OldPet#p_item.id),
			#{old_pet=>OldPet#p_item.uid, old_order=>OldOrder};
		?nil ->
			#{}
	end,
	{ok, [NewPet]} = role_bag:gain(
		[{?SPECIAL_PET,1}], ?LOG_DUNGE_NEWBIE_SUMMON, ?nil, RoleSt, true
	),
	?debug("pre_enter---------------:~w", [NewPet]),
	Tos = #m_pet_set_tos{uid=NewPet#p_item.uid, is_fight=1},
	pet_handler:handle(?PET_SET, Tos, RoleSt),
	EnterOpts.

hook_leave(Actor, _SceneSt) ->
	#actor{pid=RolePid, enter=EnterOpts} = Actor,
	OldPetUID = maps:get(old_pet, EnterOpts, 0),
	OldOrder  = maps:get(old_order, EnterOpts, 0),
	role:route(RolePid, ?MODULE, summon_oldpet, {OldPetUID,OldOrder}).

summon_oldpet({OldPetUID,OldOrder}, RoleSt) ->
	#cfg_pet{order=Order} = cfg_pet:find(?SPECIAL_PET),
	?debug("summon_oldpet-----------------------:~w", [OldOrder]),
	catch role_bag:cost([{?SPECIAL_PET,1}], ?LOG_DUNGE_NEWBIE_SUMMON, RoleSt),
	case OldPetUID > 0 of
		true  ->
			Tos = #m_pet_set_tos{uid=OldPetUID, is_fight=1},
			pet_handler:handle(?PET_SET, Tos, RoleSt);
		false ->
			role_pet:delete_skills(Order, 0, RoleSt),
			role_figure:update_pet(0, RoleSt)
	end,
	RolePet  = role_data:get(?DB_ROLE_PET),
	RolePet2 = RolePet#role_pet{
		pets        = maps:remove(Order, RolePet#role_pet.pets),
		strong      = maps:remove(Order, RolePet#role_pet.strong),
		strong_attr = maps:remove(Order, RolePet#role_pet.strong_attr),
		costs       = maps:remove(Order, RolePet#role_pet.costs)
	},
	role_data:set(RolePet2).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
