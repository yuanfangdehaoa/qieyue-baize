%% Automatically generated, do not edit
%% Generated by parse_enum.go

-module(enum).

-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).


check_account(E) ->

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_career(E) ->

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_gender(E) ->

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_color(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_mail_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_item_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	E == 11 orelse

	E == 12 orelse

	E == 13 orelse

	E == 14 orelse

	E == 15 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_item_stype(E) ->

	E == 1001 orelse

	E == 1002 orelse

	E == 1003 orelse

	E == 1004 orelse

	E == 1005 orelse

	E == 1006 orelse

	E == 1007 orelse

	E == 1008 orelse

	E == 1009 orelse

	E == 1010 orelse

	E == 1011 orelse

	E == 1012 orelse

	E == 1013 orelse

	E == 4001 orelse

	E == 4002 orelse

	E == 4003 orelse

	E == 4004 orelse

	E == 4005 orelse

	E == 4006 orelse

	E == 5001 orelse

	E == 5002 orelse

	E == 5003 orelse

	E == 5004 orelse

	E == 5005 orelse

	E == 5006 orelse

	E == 5007 orelse

	E == 5008 orelse

	E == 5009 orelse

	E == 5010 orelse

	E == 6001 orelse

	E == 7001 orelse

	E == 7002 orelse

	E == 7003 orelse

	E == 7004 orelse

	E == 7005 orelse

	E == 3001 orelse

	E == 3002 orelse

	E == 3003 orelse

	E == 3004 orelse

	E == 3005 orelse

	E == 8001 orelse

	E == 8002 orelse

	E == 8003 orelse

	E == 8004 orelse

	E == 10001 orelse

	E == 10002 orelse

	E == 10003 orelse

	E == 10004 orelse

	E == 10005 orelse

	E == 10006 orelse

	E == 10007 orelse

	E == 10008 orelse

	E == 10009 orelse

	E == 10010 orelse

	E == 10011 orelse

	E == 10012 orelse

	E == 10012 orelse

	E == 10013 orelse

	E == 10014 orelse

	E == 10015 orelse

	E == 10016 orelse

	E == 10017 orelse

	E == 10018 orelse

	E == 10019 orelse

	E == 10022 orelse

	E == 10023 orelse

	E == 10024 orelse

	E == 10070 orelse

	E == 10071 orelse

	E == 10080 orelse

	E == 10081 orelse

	E == 10082 orelse

	E == 10083 orelse

	E == 10101 orelse

	E == 10102 orelse

	E == 10103 orelse

	E == 10104 orelse

	E == 10105 orelse

	E == 10106 orelse

	E == 10107 orelse

	E == 10121 orelse

	E == 10122 orelse

	E == 10141 orelse

	E == 10142 orelse

	E == 10143 orelse

	E == 10144 orelse

	E == 10145 orelse

	E == 10146 orelse

	E == 10147 orelse

	E == 10151 orelse

	E == 10152 orelse

	E == 10153 orelse

	E == 10154 orelse

	E == 10155 orelse

	E == 10160 orelse

	E == 10163 orelse

	E == 10165 orelse

	E == 10166 orelse

	E == 10167 orelse

	E == 10168 orelse

	E == 10169 orelse

	E == 10170 orelse

	E == 10171 orelse

	E == 10172 orelse

	E == 10173 orelse

	E == 10174 orelse

	E == 10175 orelse

	E == 10177 orelse

	E == 10179 orelse

	E == 10180 orelse

	E == 10182 orelse

	E == 10183 orelse

	E == 10201 orelse

	E == 10202 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_item(E) ->

	E == 90010001 orelse

	E == 90010002 orelse

	E == 90010003 orelse

	E == 90010004 orelse

	E == 90010005 orelse

	E == 90010006 orelse

	E == 90010007 orelse

	E == 90010008 orelse

	E == 90010009 orelse

	E == 90010010 orelse

	E == 90010011 orelse

	E == 90010012 orelse

	E == 90010013 orelse

	E == 90010014 orelse

	E == 90010015 orelse

	E == 90010016 orelse

	E == 90010017 orelse

	E == 90010018 orelse

	E == 90010019 orelse

	E == 90010020 orelse

	E == 90010021 orelse

	E == 90010022 orelse

	E == 90010023 orelse

	E == 90010024 orelse

	E == 90010025 orelse

	E == 90010026 orelse

	E == 90010027 orelse

	E == 90010028 orelse

	E == 90010029 orelse

	E == 90010030 orelse

	E == 90010031 orelse

	E == 90010033 orelse

	E == 90010034 orelse

	E == 90010035 orelse

	E == 90010037 orelse

	E == 90010038 orelse

	E == 90010039 orelse

	E == 90010040 orelse

	E == 90010041 orelse

	E == 90010042 orelse

	E == 90019001 orelse

	E == 90019002 orelse

	E == 11001 orelse

	E == 30010001 orelse

	E == 13200 orelse

	E == 13201 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_attr_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_attr(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	E == 11 orelse

	E == 12 orelse

	E == 13 orelse

	E == 14 orelse

	E == 15 orelse

	E == 16 orelse

	E == 17 orelse

	E == 18 orelse

	E == 19 orelse

	E == 20 orelse

	E == 21 orelse

	E == 22 orelse

	E == 23 orelse

	E == 24 orelse

	E == 25 orelse

	E == 26 orelse

	E == 27 orelse

	E == 28 orelse

	E == 29 orelse

	E == 30 orelse

	E == 31 orelse

	E == 32 orelse

	E == 33 orelse

	E == 34 orelse

	E == 35 orelse

	E == 36 orelse

	E == 37 orelse

	E == 38 orelse

	E == 39 orelse

	E == 40 orelse

	E == 41 orelse

	E == 42 orelse

	E == 43 orelse

	E == 44 orelse

	E == 45 orelse

	E == 46 orelse

	E == 1100 orelse

	E == 1102 orelse

	E == 1103 orelse

	E == 1104 orelse

	E == 1105 orelse

	E == 1106 orelse

	E == 1107 orelse

	E == 1108 orelse

	E == 1109 orelse

	E == 1110 orelse

	E == 1111 orelse

	E == 1112 orelse

	E == 1200 orelse

	E == 1202 orelse

	E == 1204 orelse

	E == 1205 orelse

	E == 1206 orelse

	E == 1207 orelse

	E == 1208 orelse

	E == 1209 orelse

	E == 1210 orelse

	E == 1211 orelse

	E == 1212 orelse

	E == 1302 orelse

	E == 1304 orelse

	E == 1305 orelse

	E == 1306 orelse

	E == 1404 orelse

	E == 1406 orelse

	E == 1502 orelse

	E == 1505 orelse

	E == 1604 orelse

	E == 2000 orelse

	E == 2001 orelse

	E == 2002 orelse

	E == 2003 orelse

	E == 2004 orelse

	E == 2005 orelse

	E == 2006 orelse

	E == 2007 orelse

	E == 2009 orelse

	E == 2010 orelse

	E == 2011 orelse

	E == 2012 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_event(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	E == 11 orelse

	E == 12 orelse

	E == 13 orelse

	E == 14 orelse

	E == 15 orelse

	E == 16 orelse

	E == 17 orelse

	E == 18 orelse

	E == 19 orelse

	E == 20 orelse

	E == 21 orelse

	E == 22 orelse

	E == 23 orelse

	E == 24 orelse

	E == 25 orelse

	E == 26 orelse

	E == 27 orelse

	E == 28 orelse

	E == 29 orelse

	E == 30 orelse

	E == 31 orelse

	E == 32 orelse

	E == 33 orelse

	E == 34 orelse

	E == 35 orelse

	E == 36 orelse

	E == 37 orelse

	E == 38 orelse

	E == 39 orelse

	E == 40 orelse

	E == 41 orelse

	E == 42 orelse

	E == 43 orelse

	E == 44 orelse

	E == 45 orelse

	E == 46 orelse

	E == 47 orelse

	E == 48 orelse

	E == 49 orelse

	E == 50 orelse

	E == 51 orelse

	E == 52 orelse

	E == 53 orelse

	E == 54 orelse

	E == 55 orelse

	E == 56 orelse

	E == 57 orelse

	E == 58 orelse

	E == 59 orelse

	E == 60 orelse

	E == 61 orelse

	E == 62 orelse

	E == 63 orelse

	E == 64 orelse

	E == 65 orelse

	E == 66 orelse

	E == 67 orelse

	E == 68 orelse

	E == 69 orelse

	E == 70 orelse

	E == 71 orelse

	E == 72 orelse

	E == 73 orelse

	E == 74 orelse

	E == 75 orelse

	E == 76 orelse

	E == 77 orelse

	E == 78 orelse

	E == 79 orelse

	E == 80 orelse

	E == 81 orelse

	E == 82 orelse

	E == 83 orelse

	E == 84 orelse

	E == 85 orelse

	E == 86 orelse

	E == 87 orelse

	E == 88 orelse

	E == 89 orelse

	E == 90 orelse

	E == 91 orelse

	E == 92 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_task_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	E == 90 orelse

	E == 91 orelse

	E == 92 orelse

	E == 93 orelse

	E == 94 orelse

	E == 95 orelse

	E == 96 orelse

	E == 97 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_task_state(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_activity_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_activity_group(E) ->

	E == 101 orelse

	E == 102 orelse

	E == 103 orelse

	E == 104 orelse

	E == 105 orelse

	E == 106 orelse

	E == 107 orelse

	E == 108 orelse

	E == 109 orelse

	E == 110 orelse

	E == 111 orelse

	E == 113 orelse

	E == 114 orelse

	E == 115 orelse

	E == 116 orelse

	E == 200 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_scene_state(E) ->

	E == 0 orelse

	E == 1 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_scene_kind(E) ->

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_scene_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_scene_stype(E) ->

	E == 301 orelse

	E == 302 orelse

	E == 303 orelse

	E == 304 orelse

	E == 305 orelse

	E == 306 orelse

	E == 307 orelse

	E == 308 orelse

	E == 309 orelse

	E == 310 orelse

	E == 311 orelse

	E == 312 orelse

	E == 313 orelse

	E == 314 orelse

	E == 315 orelse

	E == 316 orelse

	E == 317 orelse

	E == 318 orelse

	E == 319 orelse

	E == 320 orelse

	E == 401 orelse

	E == 402 orelse

	E == 403 orelse

	E == 404 orelse

	E == 405 orelse

	E == 406 orelse

	E == 409 orelse

	E == 501 orelse

	E == 502 orelse

	E == 503 orelse

	E == 504 orelse

	E == 505 orelse

	E == 506 orelse

	E == 507 orelse

	E == 508 orelse

	E == 509 orelse

	E == 510 orelse

	E == 511 orelse

	E == 512 orelse

	E == 513 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_scene_cost(E) ->

	E == 0 orelse

	E == 1 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_bctype(E) ->

	E == 0 orelse

	E == 1 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_scene_change(E) ->

	E == 0 orelse

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_teleport(E) ->

	E == 0 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_jump(E) ->

	E == 0 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_dunge_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_actor_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	E == 11 orelse

	E == 12 orelse

	E == 13 orelse

	E == 14 orelse

	E == 15 orelse

	E == 16 orelse

	E == 17 orelse

	E == 18 orelse

	E == 19 orelse

	E == 20 orelse

	E == 21 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_actor_state(E) ->

	E == 0 orelse

	E == 1 orelse

	E == 2 orelse

	E == 4 orelse

	E == 8 orelse

	E == 16 orelse

	E == 32 orelse

	E == 64 orelse

	E == 128 orelse

	E == 256 orelse

	E == 512 orelse

	E == 1024 orelse

	E == 2048 orelse

	E == 4096 orelse

	E == 8192 orelse

	E == 16384 orelse

	E == 32768 orelse

	E == 65536 orelse

	E == 131072 orelse

	E == 262144 orelse

	E == 524288 orelse

	E == 1048576 orelse

	E == 2097152 orelse

	E == 4194304 orelse

	E == 8388608 orelse

	E == 16777216 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_pkmode(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_creep_kind(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_creep_type(E) ->

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_creep_rarity(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	E == 11 orelse

	E == 12 orelse

	E == 13 orelse

	E == 14 orelse

	E == 15 orelse

	E == 16 orelse

	E == 17 orelse

	E == 18 orelse

	E == 19 orelse

	E == 20 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_boss_kind(E) ->

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_boss_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_skill_group(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	E == 11 orelse

	E == 12 orelse

	E == 13 orelse

	E == 20 orelse

	E == 21 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_skill_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_skill_aim(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_skill_area(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_skill_pos(E) ->

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	E == 11 orelse

	E == 12 orelse

	E == 13 orelse

	E == 14 orelse

	E == 15 orelse

	E == 16 orelse

	E == 17 orelse

	E == 18 orelse

	E == 19 orelse

	E == 20 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_attack_unit(E) ->

	E == 0 orelse

	E == 1 orelse

	E == 9 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_damage(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	E == 11 orelse

	E == 12 orelse

	E == 13 orelse

	E == 14 orelse

	E == 15 orelse

	E == 1002 orelse

	E == 1003 orelse

	E == 1004 orelse

	E == 1005 orelse

	E == 101 orelse

	E == 102 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_drop_rule(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_drop_mode(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_drop_belong(E) ->

	E == 0 orelse

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_revive_type(E) ->

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_buff_type(E) ->

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_buff_lap(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_buff_effect(E) ->

	E == 1101 orelse

	E == 1102 orelse

	E == 1201 orelse

	E == 1202 orelse

	E == 1203 orelse

	E == 1204 orelse

	E == 1205 orelse

	E == 1206 orelse

	E == 1207 orelse

	E == 1208 orelse

	E == 1209 orelse

	E == 1210 orelse

	E == 2201 orelse

	E == 2202 orelse

	E == 2203 orelse

	E == 2204 orelse

	E == 2205 orelse

	E == 2206 orelse

	E == 2207 orelse

	E == 2208 orelse

	E == 3001 orelse

	E == 3002 orelse

	E == 3003 orelse

	E == 3004 orelse

	E == 3005 orelse

	E == 3006 orelse

	E == 3007 orelse

	E == 3008 orelse

	E == 3009 orelse

	E == 3010 orelse

	E == 3011 orelse

	E == 3012 orelse

	E == 3013 orelse

	E == 3014 orelse

	E == 3015 orelse

	E == 3016 orelse

	E == 3017 orelse

	E == 3018 orelse

	E == 3019 orelse

	E == 3020 orelse

	E == 3021 orelse

	E == 3022 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_buff_vtype(E) ->

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_buff_id(E) ->

	E == 300410011 orelse

	E == 300410012 orelse

	E == 220610001 orelse

	E == 220610002 orelse

	E == 220610003 orelse

	E == 220610004 orelse

	E == 300410013 orelse

	E == 304100004 orelse

	E == 300410014 orelse

	E == 300410015 orelse

	E == 304010007 orelse

	E == 300410018 orelse

	E == 300410016 orelse

	E == 300410017 orelse

	E == 304010013 orelse

	E == 300410020 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_guild_post(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_guild_perm(E) ->

	E == 0 orelse

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_guild_log(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_guild_welfare(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_rank_id(E) ->

	E == 1001 orelse

	E == 1002 orelse

	E == 1008 orelse

	E == 1011 orelse

	E == 1012 orelse

	E == 1015 orelse

	E == 1019 orelse

	E == 1020 orelse

	E == 2001 orelse

	E == 2002 orelse

	E == 2003 orelse

	E == 2012 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_relation(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_train(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_tips_show(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 11 orelse

	E == 11 orelse

	E == 12 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_dead_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_wake_task_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_fight_state_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_vip_rights(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	E == 11 orelse

	E == 12 orelse

	E == 13 orelse

	E == 14 orelse

	E == 15 orelse

	E == 16 orelse

	E == 17 orelse

	E == 18 orelse

	E == 19 orelse

	E == 20 orelse

	E == 21 orelse

	E == 22 orelse

	E == 23 orelse

	E == 24 orelse

	E == 25 orelse

	E == 26 orelse

	E == 27 orelse

	E == 28 orelse

	E == 29 orelse

	E == 30 orelse

	E == 31 orelse

	E == 32 orelse

	E == 33 orelse

	E == 34 orelse

	E == 35 orelse

	E == 36 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_fashion_state_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 11 orelse

	E == 12 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_gift_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_vip_type(E) ->

	E == 0 orelse

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_role_state(E) ->

	E == 0 orelse

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_target_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_chat_channel(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 99 orelse

	E == 100 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_mail(E) ->

	E == 1000002 orelse

	E == 1000003 orelse

	E == 1000004 orelse

	E == 1000005 orelse

	E == 1000006 orelse

	E == 1000007 orelse

	E == 1000013 orelse

	E == 1000014 orelse

	E == 1100001 orelse

	E == 1113001 orelse

	E == 1113002 orelse

	E == 1113003 orelse

	E == 1113004 orelse

	E == 1132001 orelse

	E == 1134001 orelse

	E == 1134002 orelse

	E == 1135001 orelse

	E == 1135002 orelse

	E == 1135003 orelse

	E == 1135004 orelse

	E == 1203001 orelse

	E == 1204001 orelse

	E == 1400001 orelse

	E == 1400002 orelse

	E == 1400003 orelse

	E == 1400004 orelse

	E == 1400005 orelse

	E == 1400006 orelse

	E == 1400007 orelse

	E == 1603001 orelse

	E == 1603002 orelse

	E == 1604001 orelse

	E == 1602001 orelse

	E == 1602002 orelse

	E == 1602003 orelse

	E == 1602004 orelse

	E == 1602005 orelse

	E == 1602006 orelse

	E == 1602007 orelse

	E == 1602008 orelse

	E == 1602009 orelse

	E == 1602010 orelse

	E == 1602011 orelse

	E == 1602012 orelse

	E == 1605001 orelse

	E == 1605002 orelse

	E == 1605003 orelse

	E == 1606001 orelse

	E == 1606002 orelse

	E == 1606003 orelse

	E == 1607001 orelse

	E == 1607002 orelse

	E == 1607003 orelse

	E == 1607004 orelse

	E == 1607005 orelse

	E == 1607006 orelse

	E == 1607007 orelse

	E == 1607008 orelse

	E == 1607009 orelse

	E == 1607010 orelse

	E == 1608001 orelse

	E == 1608002 orelse

	E == 1608003 orelse

	E == 1608004 orelse

	E == 1609001 orelse

	E == 1700001 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_role_count(E) ->

	E == 1001 orelse

	E == 1002 orelse

	E == 1003 orelse

	E == 1004 orelse

	E == 1005 orelse

	E == 1006 orelse

	E == 1007 orelse

	E == 1008 orelse

	E == 1009 orelse

	E == 1010 orelse

	E == 1011 orelse

	E == 1012 orelse

	E == 1013 orelse

	E == 1014 orelse

	E == 1015 orelse

	E == 1016 orelse

	E == 1017 orelse

	E == 1018 orelse

	E == 1019 orelse

	E == 1020 orelse

	E == 1021 orelse

	E == 1022 orelse

	E == 1023 orelse

	E == 1024 orelse

	E == 1025 orelse

	E == 1026 orelse

	E == 1027 orelse

	E == 1028 orelse

	E == 1029 orelse

	E == 1030 orelse

	E == 1031 orelse

	E == 2001 orelse

	E == 2002 orelse

	E == 2003 orelse

	E == 2004 orelse

	E == 2005 orelse

	E == 2006 orelse

	E == 2007 orelse

	E == 2008 orelse

	E == 2009 orelse

	E == 2010 orelse

	E == 2011 orelse

	E == 2013 orelse

	E == 2014 orelse

	E == 2015 orelse

	E == 2016 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_yy_task_state(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_model_type(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	E == 7 orelse

	E == 8 orelse

	E == 9 orelse

	E == 10 orelse

	E == 11 orelse

	E == 12 orelse

	E == 13 orelse

	E == 14 orelse

	E == 15 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_wanted_task_state(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_red_envelope_state(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_progress_state(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_heal_type(E) ->

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_trade_type(E) ->

	E == 1 orelse

	E == 2 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_talent_group(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_cross_rule(E) ->

	E == 1024008 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_dunge_op(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_play_stat(E) ->

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	E == 6 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_play_op(E) ->

	E == 1 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_compete_period(E) ->

	E == 0 orelse

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_compete_phase(E) ->

	E == 0 orelse

	E == 1 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_compete_battle(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_cgw_period(E) ->

	E == 1 orelse

	E == 2 orelse

	E == 3 orelse

	E == 4 orelse

	E == 5 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

check_rolelog(E) ->

	E == 1000001 orelse

	E == 1107101 orelse

	E == 1107501 orelse

	E == 1107102 orelse

	E == 1107502 orelse

	E == 1109201 orelse

	E == 1109301 orelse

	E == 1109401 orelse

	E == 1109601 orelse

	E == 1109601 orelse

	E == 1109202 orelse

	E == 1109302 orelse

	E == 1109402 orelse

	E == 1109602 orelse

	E == 1108101 orelse

	E == 1108201 orelse

	E == 1108301 orelse

	E == 1108401 orelse

	E == 1108501 orelse

	E == 1108601 orelse

	E == 1108701 orelse

	E == 1108102 orelse

	E == 1108202 orelse

	E == 1108302 orelse

	E == 1108402 orelse

	E == 1108502 orelse

	E == 1108602 orelse

	E == 1108702 orelse

	E == 120001 orelse

	E == 120002 orelse

	E == 110601 orelse

	E == 110602 orelse

	E == 110603 orelse

	E == 120101 orelse

	throw({error, ?ERR_GAME_BAD_ARGS, []}).

