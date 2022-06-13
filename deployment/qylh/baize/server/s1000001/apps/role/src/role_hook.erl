%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_hook).

-include("game.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("table.hrl").

-include_lib("eunit/include/eunit.hrl").

%% API
-export([hook_login/1]).
-export([hook_logout/1]).
-export([hook_upgrade/2]).
-export([hook_wake/2]).
-export([hook_finish/2]).
-export([hook_sysopen/2]).
-export([hook_reset/1]).
-export([hook_expire/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 登录
hook_login(RoleSt) ->
	lists:foldl(fun
		(Mod, AccSt) ->
			case Mod:hook_login(AccSt) of
				{ok, AccSt2} when is_record(AccSt2, role_st) ->
					AccSt2;
				_ ->
					AccSt
			end
	end, RoleSt, [
		  role_vip
		, role_bag
		, role_task
		, friend_recommend
		, role_misc
		, role_title
		, friend_server
		, mchunt_handler
		, role_target
		, daily_handler
		, weekly_handler
		, rank_util
		, yunying_task
		, achieve_handler
		, firstpay_handler
		, actpay_handler
		, actinvest_handler
		, role_wanted
		, role_redenvelope
		, dating_manager
		, role_marriage
		, role_magiccard
		, findback_handler
		, role_wake
		, role_offmsg
		, role_afk
		, fashion_handler
		, god_equips_handler
		, role_skill
	]).

%% 登出
hook_logout(RoleSt) ->
	lists:foreach(fun
		(Mod) ->
			Mod:hook_logout(RoleSt)
	end, [
		  team_server
		, friend_server
		, role_afk
		, mirror_manager
		, combat1v1_matcher
	]).

%% 升级
hook_upgrade(NewLv, RoleSt) ->
	lists:foreach(fun
		(Mod) ->
			Mod:hook_upgrade(NewLv, RoleSt)
	end, [
		  role_task
		, role_misc
		, role_wake
		, role_mall
		, role_jobtitle
		, role_target
		, team_server
		, role_skill
		, mirror_manager
		, yunying_handler
		, dating_manager
		, activity_handler
		, friend_recommend
		, role_talent
		, boss_handler
		, timeboss_handler
	]).

hook_wake(NewWake, RoleSt) ->
	lists:foreach(fun
		(Mod) ->
			Mod:hook_wake(NewWake, RoleSt)
	end, [
		  yunying_handler
	]).

%% 完成任务
hook_finish(TaskID, RoleSt) ->
	lists:foreach(fun
		(Mod) ->
			Mod:hook_finish(TaskID, RoleSt)
	end, [
		  role_misc
		, role_wake
	]).

%% 系统开放
hook_sysopen(?nil, _RoleSt) ->
	ignore;
hook_sysopen({Mod, Args}, RoleSt) ->
	?_if(
		game_util:is_exported(Mod, ?FUNCTION_NAME, 2),
		Mod:hook_sysopen(Args, RoleSt)
	);
hook_sysopen(Mod, RoleSt) ->
	?_if(
		game_util:is_exported(Mod, ?FUNCTION_NAME, 1),
		Mod:hook_sysopen(RoleSt)
	).

%% 重置计数器
hook_reset(RoleSt) ->
	#role_count{reset=LstSecs} = role_data:get(?DB_ROLE_COUNT),
	NowSecs = ut_time:seconds(),
	{NowDate, {NowHour,_,_}} = ut_time:seconds_to_datetime(NowSecs),
	NowDoW  = ut_time:day_of_week(NowDate),
	try
		findback_handler:hook_reset(LstSecs, NowSecs, RoleSt)
	catch Class1:Reason1:Stacktrace1 ->
		?stacktrace(Class1, Reason1, Stacktrace1)
	end,
	Reseted   = do_reset(NowDate, NowHour, NowDoW, NowSecs, LstSecs, RoleSt),
	RoleCount = role_data:get(?DB_ROLE_COUNT),
	role_data:set(RoleCount#role_count{reset=NowSecs}),
	lists:foreach(fun
		({_Mod,Group,Key}) ->
			if
				Group == ?ROLE_COUNT_VIP_WELFARE, Key == 1 ->
					role_vip:post_reset(NowDoW, NowHour, RoleSt);
				Key == ?ROLE_COUNT_ESCORT_COUNT ->
					escort_handler:post_reset(NowDoW, NowHour, RoleSt);
				true ->
					ignore
			end
	end, Reseted).

%% 道具过期
hook_expire({_, _, CellID}, RoleSt) ->
	case role_bag:get_item(CellID) of
		{ok, Item} ->
			lists:foreach(fun
				(Mod) ->
					Mod:hook_expire(Item, RoleSt)
			end, [
				  role_equip
				, role_pet
			]);
		_ ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_reset(NowDate, NowHour, NowDoW, NowSecs, LstSecs, RoleSt) ->
	LstDate = ut_time:seconds_to_date(LstSecs),
	lists:foldl(fun
		({Mod, Group, Key, DoW, Hour}, Acc) ->
			NeedRst = need_reset(LstDate, LstSecs, NowDate, NowSecs, DoW, Hour),
			% ?debug("reset:=====~p", [{Mod, Group, Key, DoW, Hour, NeedRst}]),
			case NeedRst of
				true  ->
					try
						case Mod == role_count of
							true  ->
								role_count:hook_reset(Group, Key, RoleSt);
							false ->
								code:ensure_loaded(Mod),
								?_if(
									erlang:function_exported(Mod, hook_reset, 3),
									Mod:hook_reset(NowDoW, NowHour, RoleSt)
								),
								?_if(
									erlang:function_exported(Mod, hook_reset, 5),
									Mod:hook_reset(NowDoW, NowHour, Group, Key, RoleSt)
								)
						end,
						[{Mod,Group,Key} | Acc]
					catch Class2:Reason2:Stacktrace2 ->
						?stacktrace(Class2, Reason2, Stacktrace2),
						Acc
					end;
				false ->
					Acc
			end
	end, [], cfg_reset:list()).

need_reset(LstDate, LstSecs, NowDate, NowSecs, RstDoW, RstHour) ->
	DiffSecs = NowSecs - LstSecs,
	if
		RstDoW == 0, DiffSecs >= 1*?SECONDS_PER_DAY ->
			true;
		RstDoW == 0 ->
			need_reset2(LstDate, LstSecs, NowDate, NowSecs, RstDoW, RstHour);
		RstDoW /= 0, DiffSecs >= 7*?SECONDS_PER_DAY ->
			true;
		RstDoW /= 0 ->
			need_reset2(LstDate, LstSecs, NowDate, NowSecs, RstDoW, RstHour)
	end.

need_reset2(LstDate, _LstSecs, NowDate, _NowSecs, _RstDoW, _RstHour) when LstDate > NowDate ->
	false;
need_reset2(LstDate, LstSecs, NowDate, NowSecs, RstDoW, RstHour) ->
	case RstDoW == 0 orelse (RstDoW == ut_time:day_of_week(LstDate)) of
		true  ->
			RstSecs = ut_time:datetime_to_seconds({LstDate,{RstHour,0,0}}),
			% ?debug("----:~w", [{ut_time:seconds_to_datetime(LstSecs), ut_time:seconds_to_datetime(RstSecs), ut_time:seconds_to_datetime(NowSecs)}]),
			case LstSecs < RstSecs andalso RstSecs =< NowSecs of
				true  ->
					true;
				false ->
					NextDate = ut_time:add_days(LstDate, 1),
					need_reset2(NextDate, LstSecs, NowDate, NowSecs, RstDoW, RstHour)
			end;
		false ->
			NextDate = ut_time:add_days(LstDate, 1),
			need_reset2(NextDate, LstSecs, NowDate, NowSecs, RstDoW, RstHour)
	end.

need_reset_test_() ->
	NowDateTime1 = {{2020,5,18}, {20,0,0}},
	NowDateTime2 = {{2020,5,18}, {21,0,0}},
	NowDateTime3 = {{2020,5,18}, {0,0,0}},
	[
		?_assertEqual(
			true,
			need_reset_test_helper({{2020,5,17},{20,0,0}}, NowDateTime1, 0, 21)
		),
		?_assertEqual(
			true,
			need_reset_test_helper({{2020,5,17},{20,0,1}}, NowDateTime1, 0, 21)
		),
		?_assertEqual(
			false,
			need_reset_test_helper({{2020,5,17},{21,0,0}}, NowDateTime1, 0, 21)
		),
		?_assertEqual(
			true,
			need_reset_test_helper({{2020,5,17},{21,0,0}}, NowDateTime2, 0, 21)
		),
		?_assertEqual(
			true,
			need_reset_test_helper({{2020,5,17},{21,0,1}}, NowDateTime2, 0, 21)
		),
		?_assertEqual(
			true,
			need_reset_test_helper({{2020,5,17},{21,0,1}}, NowDateTime2, 0, 0)
		),
		?_assertEqual(
			true,
			need_reset_test_helper({{2020,5,17},{21,0,1}}, NowDateTime3, 0, 0)
		),

		?_assertEqual(
			true,
			need_reset_test_helper({{2020,5,11},{20,0,0}}, NowDateTime1, 1, 21)
		),
		?_assertEqual(
			true,
			need_reset_test_helper({{2020,5,11},{20,0,1}}, NowDateTime1, 1, 21)
		),
		?_assertEqual(
			false,
			need_reset_test_helper({{2020,5,11},{21,0,0}}, NowDateTime1, 1, 21)
		),
		?_assertEqual(
			true,
			need_reset_test_helper({{2020,5,11},{21,0,0}}, NowDateTime2, 1, 21)
		),
		?_assertEqual(
			true,
			need_reset_test_helper({{2020,5,11},{21,0,1}}, NowDateTime2, 1, 21)
		),
		?_assertEqual(
			false,
			need_reset_test_helper({{2020,5,12},{20,0,0}}, NowDateTime1, 1, 21)
		),
		?_assertEqual(
			true,
			need_reset_test_helper({{2020,5,12},{20,0,0}}, NowDateTime2, 1, 21)
		)
	].

need_reset_test_helper(LstDateTime, NowDateTime, RstDoW, RstHour) ->
	{LstDate, _} = LstDateTime,
	LstSecs = ut_time:datetime_to_seconds(LstDateTime),
	{NowDate, _} = NowDateTime,
	NowSecs = ut_time:datetime_to_seconds(NowDateTime),
	need_reset(LstDate, LstSecs, NowDate, NowSecs, RstDoW, RstHour).
