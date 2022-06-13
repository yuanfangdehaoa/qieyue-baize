-module(scene_actor_30102).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=2739, y=100},
		#p_coord{x=2760, y=100},
		#p_coord{x=2780, y=100},
		#p_coord{x=2800, y=100},
		#p_coord{x=2820, y=100},
		#p_coord{x=2739, y=120},
		#p_coord{x=2760, y=120},
		#p_coord{x=2780, y=120},
		#p_coord{x=2800, y=120},
		#p_coord{x=2820, y=120},
		#p_coord{x=2839, y=120},
		#p_coord{x=2739, y=139},
		#p_coord{x=2760, y=139},
		#p_coord{x=2780, y=139},
		#p_coord{x=2800, y=139},
		#p_coord{x=2820, y=139},
		#p_coord{x=2839, y=139},
		#p_coord{x=2739, y=160},
		#p_coord{x=2760, y=160},
		#p_coord{x=2780, y=160},
		#p_coord{x=2800, y=160},
		#p_coord{x=2820, y=160},
		#p_coord{x=2839, y=160},
		#p_coord{x=2760, y=180},
		#p_coord{x=2780, y=180},
		#p_coord{x=2800, y=180},
		#p_coord{x=2820, y=180},
		#p_coord{x=2839, y=180},
		#p_coord{x=2780, y=200},
		#p_coord{x=2800, y=200},
		#p_coord{x=2820, y=200},
		#p_coord{x=2839, y=200},
		#p_coord{x=2780, y=220},
		#p_coord{x=2800, y=220},
		#p_coord{x=2820, y=220},
		#p_coord{x=2839, y=220}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=2680, y=80},
		#p_coord{x=2700, y=80},
		#p_coord{x=2720, y=80},
		#p_coord{x=2739, y=80},
		#p_coord{x=2760, y=80},
		#p_coord{x=2660, y=100},
		#p_coord{x=2680, y=100},
		#p_coord{x=2700, y=100},
		#p_coord{x=2720, y=100},
		#p_coord{x=2739, y=100},
		#p_coord{x=2760, y=100},
		#p_coord{x=2660, y=120},
		#p_coord{x=2680, y=120},
		#p_coord{x=2700, y=120},
		#p_coord{x=2720, y=120},
		#p_coord{x=2739, y=120},
		#p_coord{x=2760, y=120},
		#p_coord{x=2660, y=139},
		#p_coord{x=2680, y=139},
		#p_coord{x=2700, y=139},
		#p_coord{x=2720, y=139},
		#p_coord{x=2739, y=139},
		#p_coord{x=2760, y=139},
		#p_coord{x=2660, y=160},
		#p_coord{x=2680, y=160},
		#p_coord{x=2700, y=160},
		#p_coord{x=2720, y=160},
		#p_coord{x=2739, y=160},
		#p_coord{x=2760, y=160},
		#p_coord{x=2680, y=180},
		#p_coord{x=2700, y=180},
		#p_coord{x=2720, y=180},
		#p_coord{x=2739, y=180},
		#p_coord{x=2760, y=180},
		#p_coord{x=2700, y=200},
		#p_coord{x=2720, y=200},
		#p_coord{x=2739, y=200},
		#p_coord{x=2760, y=200},
		#p_coord{x=2700, y=220},
		#p_coord{x=2720, y=220},
		#p_coord{x=2739, y=220},
		#p_coord{x=2760, y=220},
		#p_coord{x=2700, y=240},
		#p_coord{x=2720, y=240},
		#p_coord{x=2739, y=240},
		#p_coord{x=2760, y=240}
	].

%% 跳跃点
get_jump() ->
	[
	].

%% 安全区
get_safe() ->
	[
	].

%% 寻宝区
get_hunt() ->
	[
	].

%% NPC 列表
get_npcs() ->
	[
	].

%% 怪物列表
get_creeps() ->
	[
	].

%% 寻路点
get_waypoint() ->
	[
	].
