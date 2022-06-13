%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_figure).

-include("attr.hrl").
-include("figure.hrl").
-include("game.hrl").
-include("morph.hrl").
-include("mount.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([update_mount/3]).
-export([update_wing/2]).
-export([update_talis/2]).
-export([update_weapon/2]).
-export([update_offhand/2]).
-export([update_god/2]).
-export([update_fashion/3]).
-export([update_jobtitle/2]).
-export([update_title/2]).
-export([update_illusion/2]).
-export([update_pet/2]).
-export([update_team/2]).
-export([update_baby/2]).
-export([update_baby_wing/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 更新坐骑
update_mount(ResID, IsShow, RoleSt) ->
	Aspect  = #p_aspect{model=ResID, show=IsShow},
	Aspect2 = update_figure(?FIGURE_MOUNT, Aspect, RoleSt),

	RoleAttr = #role_attr{attr=Attr} = role_data:get(?DB_ROLE_ATTR),
	Speed = role_attr:speed(),
	Attr2 = ?_setattr(Attr, ?ATTR_SPEED, Speed),

	role_data:set(RoleAttr#role_attr{attr=Attr2}),
	update_actor([{mount,Speed,?FIGURE_MOUNT,Aspect2}], RoleSt).

%% 更新翅膀
update_wing(Wing, RoleSt) ->
	Aspect = update_model(?FIGURE_WING, Wing, RoleSt),
	update_actor([{figure, ?FIGURE_WING, Aspect}], RoleSt).

%% 更新法宝
update_talis(Talis, RoleSt) ->
	Aspect = update_model(?FIGURE_TALIS, Talis, RoleSt),
	update_actor([{figure, ?FIGURE_TALIS, Aspect}], RoleSt).

%% 更新神兵
update_weapon(Weapon, RoleSt) ->
	Aspect = update_model(?FIGURE_WEAPON, Weapon, RoleSt),
	update_actor([{figure, ?FIGURE_WEAPON, Aspect}], RoleSt).

%% 更新副手
update_offhand(OffHand, RoleSt) ->
	Aspect = update_model(?FIGURE_OFFHAND, OffHand, RoleSt),
	update_actor([{figure, ?FIGURE_OFFHAND, Aspect}], RoleSt).

% 更新神灵
update_god(God, RoleSt) ->
	Aspect = update_model(?FIGURE_GOD, God, RoleSt),
	update_actor([{figure, ?FIGURE_GOD, Aspect}], RoleSt).

%% 更新时装
update_fashion(Locus, Model, RoleSt)->
	AspectKey = case Locus of
		?FASHION_STATE_TYPE_CLOTHES   -> ?FIGURE_FASHION_CLOTHES;
		?FASHION_STATE_TYPE_HEAD      -> ?FIGURE_FASHION_HEADDRESS;
		?FASHION_STATE_TYPE_WEAPON    -> ?FIGURE_WEAPON;
		?FASHION_STATE_TYPE_SHIELD    -> ?FIGURE_FASHION_SHIELD;
		?FASHION_STATE_TYPE_FOOTPRINT -> ?FIGURE_FASHION_FOOTPRINT;
		?FASHION_STATE_TYPE_FRAME     -> ?FIGURE_FASHION_FRAME;
		?FASHION_STATE_TYPE_BUBBLE    -> ?FIGURE_FASHION_BUBBLE
	end,
	Aspect = update_model(AspectKey, Model, RoleSt),
	update_actor([{figure, AspectKey, Aspect}], RoleSt),
	if
		Locus == ?FASHION_STATE_TYPE_FRAME;
		Locus == ?FASHION_STATE_TYPE_BUBBLE ->
			icon_handler:update_icon(Locus, Model, RoleSt);
		true ->
			ignore
	end.

%% 更新头衔
update_jobtitle(Jobtitle, RoleSt) ->
	Aspect = update_model(?FIGURE_JOBTITLE, Jobtitle, RoleSt),
	update_actor([{figure, ?FIGURE_JOBTITLE, Aspect}], RoleSt).

%% 更新称号
update_title(Title, RoleSt)->
	Aspect = update_model(?FIGURE_TITLE, Title, RoleSt),
	update_actor([{figure, ?FIGURE_TITLE, Aspect}], RoleSt).

%% 更新日常幻化
update_illusion(UpdAspect, RoleSt) ->
	Aspect = update_figure(?FIGURE_ILLUSION, UpdAspect, RoleSt),
	update_actor([{figure, ?FIGURE_ILLUSION, Aspect}], RoleSt).

%更新宠物
update_pet(Pet, RoleSt)->
	Aspect = update_model(?FIGURE_PET, Pet, RoleSt),
	update_actor([{figure, ?FIGURE_PET, Aspect}], RoleSt).

%更新队伍
update_team({TeamID, Captain}, RoleSt)->
	update_actor([{team, TeamID, Captain}], RoleSt);
update_team(TeamID, RoleSt)->
	%update_model(?FIGURE_TEAM, Team, RoleSt),
	Captain = team_server:get_captain(TeamID),
	update_actor([{team, TeamID, Captain}], RoleSt).

%更新子女
update_baby(BabyID, RoleSt)->
	Aspect = update_model(?FIGURE_BABY, BabyID, RoleSt),
	update_actor([{figure, ?FIGURE_BABY, Aspect}], RoleSt).

%更新子女翅膀
update_baby_wing(WingID, RoleSt)->
	Aspect = update_model(?FIGURE_BABY_WING, WingID, RoleSt),
	update_actor([{figure, ?FIGURE_BABY_WING, Aspect}], RoleSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
update_model(AspectKey, Model, RoleSt) ->
	Aspect = case Model == 0 of
		true  -> #p_aspect{show=false};
		false -> #p_aspect{model=Model, show=true}
	end,
	update_figure(AspectKey, Aspect, RoleSt).


update_figure(AspectKey, UpdAspect, RoleSt) ->
	RoleInfo = #role_info{figure=Figure} = role_data:get(?DB_ROLE_INFO),
	OldAspect = maps:get(AspectKey, Figure, #p_aspect{}),
	#p_aspect{model=OldModel, skin=OldSkin, show=OldShow} = OldAspect,
	#p_aspect{model=UpdModel, skin=UpdSkin, show=UpdShow} = UpdAspect,
	NewModel = ?_if(UpdModel == ?nil, OldModel, UpdModel),
	NewSkin  = ?_if(UpdSkin == ?nil, OldSkin, UpdSkin),
	NewShow  = ?_if(UpdShow == ?nil, OldShow, UpdShow),
	NewAspect = #p_aspect{model=NewModel, skin=NewSkin, show=NewShow},
	Figure2 = maps:put(AspectKey, NewAspect, Figure),
	role_data:set(RoleInfo#role_info{figure=Figure2}),
	AspectKey2 = io_lib:format("figure.~s", [AspectKey]),
	?ucast(#m_role_update_toc{aspect=#{AspectKey2=>NewAspect}}),
	NewAspect.

update_actor(Update, RoleSt) ->
	#role_st{role=RoleID, spid=ScenePid} = RoleSt,
	scene:update_actor(ScenePid, RoleID, Update).
