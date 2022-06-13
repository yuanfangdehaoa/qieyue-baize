-ifndef(TEAM_HRL).
-define(TEAM_HRL, ok).

-define(k_team, '@data').

-define(apply_list, {'@apply_list', TeamId}). %%队伍申请列表

-define(invite_list, {'@invite_list', RoleId}).  %%角色被邀请列表

-define(team_id, {'@team_id', RoleId}).  %%记录角色的队伍id

-define(auto_accept_invite, {'@auto_accept_invite', RoleId}).  %%记录角色的自动接受邀请状态

-define(match_team_pool, {'@team_pool', TypeId}).

-define(match_role_pool, {'@role_pool', TypeId}).

-define(dunge_agree_ids, {'@dunge', TeamId}).  %%记录已同意请求的队员

-define(dunge_merge, {'@dunge_merge', RoleId}).  %记录合并次数

-define(MAX_TEAM_MEMBER, 3).

-define(TARGET_DUNGE_COUPLE, 23). %结婚副本目标

-record(cfg_team_target, {
	  id                 %%目标id
	, name               %%名称
	, sub_types          %%子目标
	}).

-record(cfg_team_target_sub, {
	  id                 %子目标id
	, name               %名称
	}).

-endif.

