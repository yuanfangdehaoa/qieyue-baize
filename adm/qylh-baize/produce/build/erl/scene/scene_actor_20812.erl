-module(scene_actor_20812).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=819, y=919},
		#p_coord{x=840, y=919},
		#p_coord{x=819, y=940},
		#p_coord{x=840, y=940}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=860, y=940},
		#p_coord{x=880, y=940},
		#p_coord{x=860, y=960},
		#p_coord{x=880, y=960}
	].

%% 跳跃点
get_jump() ->
	[
	].

%% 安全区
get_safe() ->
	[
		{17, 40},
		{17, 41},
		{17, 42},
		{17, 43},
		{17, 44},
		{17, 45},
		{17, 46},
		{17, 47},
		{17, 48},
		{17, 49},
		{17, 50},
		{17, 51},
		{17, 52},
		{18, 39},
		{18, 40},
		{18, 41},
		{18, 42},
		{18, 43},
		{18, 44},
		{18, 45},
		{18, 46},
		{18, 47},
		{18, 48},
		{18, 49},
		{18, 50},
		{18, 51},
		{18, 52},
		{18, 53},
		{18, 54},
		{19, 39},
		{19, 40},
		{19, 41},
		{19, 42},
		{19, 43},
		{19, 44},
		{19, 45},
		{19, 46},
		{19, 47},
		{19, 48},
		{19, 49},
		{19, 50},
		{19, 51},
		{19, 52},
		{19, 53},
		{19, 54},
		{20, 37},
		{20, 38},
		{20, 39},
		{20, 40},
		{20, 41},
		{20, 42},
		{20, 43},
		{20, 44},
		{20, 45},
		{20, 46},
		{20, 47},
		{20, 48},
		{20, 49},
		{20, 50},
		{20, 51},
		{20, 52},
		{20, 53},
		{20, 54},
		{20, 55},
		{21, 37},
		{21, 38},
		{21, 39},
		{21, 40},
		{21, 41},
		{21, 42},
		{21, 43},
		{21, 44},
		{21, 45},
		{21, 46},
		{21, 47},
		{21, 48},
		{21, 49},
		{21, 50},
		{21, 51},
		{21, 52},
		{21, 53},
		{21, 54},
		{21, 55},
		{21, 56},
		{21, 57},
		{22, 37},
		{22, 38},
		{22, 39},
		{22, 40},
		{22, 41},
		{22, 42},
		{22, 43},
		{22, 44},
		{22, 45},
		{22, 46},
		{22, 47},
		{22, 48},
		{22, 49},
		{22, 50},
		{22, 51},
		{22, 52},
		{22, 53},
		{22, 54},
		{22, 55},
		{22, 56},
		{22, 57},
		{22, 58},
		{22, 59},
		{22, 60},
		{23, 37},
		{23, 38},
		{23, 39},
		{23, 40},
		{23, 41},
		{23, 42},
		{23, 43},
		{23, 44},
		{23, 45},
		{23, 46},
		{23, 47},
		{23, 48},
		{23, 49},
		{23, 50},
		{23, 51},
		{23, 52},
		{23, 53},
		{23, 54},
		{23, 55},
		{23, 56},
		{23, 57},
		{23, 58},
		{23, 59},
		{23, 60},
		{24, 36},
		{24, 37},
		{24, 38},
		{24, 39},
		{24, 40},
		{24, 41},
		{24, 42},
		{24, 43},
		{24, 44},
		{24, 45},
		{24, 46},
		{24, 47},
		{24, 48},
		{24, 49},
		{24, 50},
		{24, 51},
		{24, 52},
		{24, 53},
		{24, 54},
		{24, 55},
		{24, 56},
		{24, 57},
		{24, 58},
		{24, 59},
		{24, 60},
		{25, 36},
		{25, 37},
		{25, 38},
		{25, 39},
		{25, 40},
		{25, 41},
		{25, 42},
		{25, 43},
		{25, 44},
		{25, 45},
		{25, 46},
		{25, 47},
		{25, 48},
		{25, 49},
		{25, 50},
		{25, 51},
		{25, 52},
		{25, 53},
		{25, 54},
		{25, 55},
		{25, 56},
		{25, 57},
		{25, 58},
		{25, 59},
		{25, 60},
		{26, 35},
		{26, 36},
		{26, 37},
		{26, 38},
		{26, 39},
		{26, 40},
		{26, 41},
		{26, 42},
		{26, 43},
		{26, 44},
		{26, 45},
		{26, 46},
		{26, 47},
		{26, 48},
		{26, 49},
		{26, 50},
		{26, 51},
		{26, 52},
		{26, 53},
		{26, 54},
		{26, 55},
		{26, 56},
		{26, 57},
		{26, 58},
		{26, 59},
		{26, 60},
		{26, 61},
		{26, 62},
		{27, 35},
		{27, 36},
		{27, 37},
		{27, 38},
		{27, 39},
		{27, 40},
		{27, 41},
		{27, 42},
		{27, 43},
		{27, 44},
		{27, 45},
		{27, 46},
		{27, 47},
		{27, 48},
		{27, 49},
		{27, 50},
		{27, 51},
		{27, 52},
		{27, 53},
		{27, 54},
		{27, 55},
		{27, 56},
		{27, 57},
		{27, 58},
		{27, 59},
		{27, 60},
		{27, 61},
		{27, 62},
		{27, 63},
		{28, 35},
		{28, 36},
		{28, 37},
		{28, 38},
		{28, 39},
		{28, 40},
		{28, 41},
		{28, 42},
		{28, 43},
		{28, 44},
		{28, 45},
		{28, 46},
		{28, 47},
		{28, 48},
		{28, 49},
		{28, 50},
		{28, 51},
		{28, 52},
		{28, 53},
		{28, 54},
		{28, 55},
		{28, 56},
		{28, 57},
		{28, 58},
		{28, 59},
		{28, 60},
		{28, 61},
		{28, 62},
		{28, 63},
		{29, 34},
		{29, 35},
		{29, 36},
		{29, 37},
		{29, 38},
		{29, 39},
		{29, 40},
		{29, 41},
		{29, 42},
		{29, 43},
		{29, 44},
		{29, 45},
		{29, 46},
		{29, 47},
		{29, 48},
		{29, 49},
		{29, 50},
		{29, 51},
		{29, 52},
		{29, 53},
		{29, 54},
		{29, 55},
		{29, 56},
		{29, 57},
		{29, 58},
		{29, 59},
		{29, 60},
		{29, 61},
		{29, 62},
		{29, 63},
		{30, 34},
		{30, 35},
		{30, 36},
		{30, 37},
		{30, 38},
		{30, 39},
		{30, 40},
		{30, 41},
		{30, 42},
		{30, 43},
		{30, 44},
		{30, 45},
		{30, 46},
		{30, 47},
		{30, 48},
		{30, 49},
		{30, 50},
		{30, 51},
		{30, 52},
		{30, 53},
		{30, 54},
		{30, 55},
		{30, 56},
		{30, 57},
		{30, 58},
		{30, 59},
		{30, 60},
		{30, 61},
		{30, 62},
		{30, 63},
		{31, 34},
		{31, 35},
		{31, 36},
		{31, 37},
		{31, 38},
		{31, 39},
		{31, 40},
		{31, 41},
		{31, 42},
		{31, 43},
		{31, 44},
		{31, 45},
		{31, 46},
		{31, 47},
		{31, 48},
		{31, 49},
		{31, 50},
		{31, 51},
		{31, 52},
		{31, 53},
		{31, 54},
		{31, 55},
		{31, 56},
		{31, 57},
		{31, 58},
		{31, 59},
		{31, 60},
		{31, 61},
		{31, 62},
		{31, 63},
		{32, 34},
		{32, 35},
		{32, 36},
		{32, 37},
		{32, 38},
		{32, 39},
		{32, 40},
		{32, 41},
		{32, 42},
		{32, 43},
		{32, 44},
		{32, 45},
		{32, 46},
		{32, 47},
		{32, 48},
		{32, 49},
		{32, 50},
		{32, 51},
		{32, 52},
		{32, 53},
		{32, 54},
		{32, 55},
		{32, 56},
		{32, 57},
		{32, 58},
		{32, 59},
		{32, 60},
		{32, 61},
		{32, 62},
		{32, 63},
		{33, 34},
		{33, 35},
		{33, 36},
		{33, 37},
		{33, 38},
		{33, 39},
		{33, 40},
		{33, 41},
		{33, 42},
		{33, 43},
		{33, 44},
		{33, 45},
		{33, 46},
		{33, 47},
		{33, 48},
		{33, 49},
		{33, 50},
		{33, 51},
		{33, 52},
		{33, 53},
		{33, 54},
		{33, 55},
		{33, 56},
		{33, 57},
		{33, 58},
		{33, 59},
		{33, 60},
		{33, 61},
		{33, 62},
		{33, 63},
		{34, 32},
		{34, 33},
		{34, 34},
		{34, 35},
		{34, 36},
		{34, 37},
		{34, 38},
		{34, 39},
		{34, 40},
		{34, 41},
		{34, 42},
		{34, 43},
		{34, 44},
		{34, 45},
		{34, 46},
		{34, 47},
		{34, 48},
		{34, 49},
		{34, 50},
		{34, 51},
		{34, 52},
		{34, 53},
		{34, 54},
		{34, 55},
		{34, 56},
		{34, 57},
		{34, 58},
		{34, 59},
		{34, 60},
		{34, 61},
		{34, 62},
		{34, 63},
		{35, 32},
		{35, 33},
		{35, 34},
		{35, 35},
		{35, 36},
		{35, 37},
		{35, 38},
		{35, 39},
		{35, 40},
		{35, 41},
		{35, 42},
		{35, 43},
		{35, 44},
		{35, 45},
		{35, 46},
		{35, 47},
		{35, 48},
		{35, 49},
		{35, 50},
		{35, 51},
		{35, 52},
		{35, 53},
		{35, 54},
		{35, 55},
		{35, 56},
		{35, 57},
		{35, 58},
		{35, 59},
		{35, 60},
		{35, 61},
		{35, 62},
		{35, 63},
		{36, 32},
		{36, 33},
		{36, 34},
		{36, 35},
		{36, 36},
		{36, 37},
		{36, 38},
		{36, 39},
		{36, 40},
		{36, 41},
		{36, 42},
		{36, 43},
		{36, 44},
		{36, 45},
		{36, 46},
		{36, 47},
		{36, 48},
		{36, 49},
		{36, 50},
		{36, 51},
		{36, 52},
		{36, 53},
		{36, 54},
		{36, 55},
		{36, 56},
		{36, 57},
		{36, 58},
		{36, 59},
		{36, 60},
		{36, 61},
		{36, 62},
		{36, 63},
		{37, 32},
		{37, 33},
		{37, 34},
		{37, 35},
		{37, 36},
		{37, 37},
		{37, 38},
		{37, 39},
		{37, 40},
		{37, 41},
		{37, 42},
		{37, 43},
		{37, 44},
		{37, 45},
		{37, 46},
		{37, 47},
		{37, 48},
		{37, 49},
		{37, 50},
		{37, 51},
		{37, 52},
		{37, 53},
		{37, 54},
		{37, 55},
		{37, 56},
		{37, 57},
		{37, 58},
		{37, 59},
		{37, 60},
		{37, 61},
		{37, 62},
		{37, 63},
		{38, 32},
		{38, 33},
		{38, 34},
		{38, 35},
		{38, 36},
		{38, 37},
		{38, 38},
		{38, 39},
		{38, 40},
		{38, 41},
		{38, 42},
		{38, 43},
		{38, 44},
		{38, 45},
		{38, 46},
		{38, 47},
		{38, 48},
		{38, 49},
		{38, 50},
		{38, 51},
		{38, 52},
		{38, 53},
		{38, 54},
		{38, 55},
		{38, 56},
		{38, 57},
		{38, 58},
		{38, 59},
		{38, 60},
		{38, 61},
		{38, 62},
		{38, 63},
		{39, 32},
		{39, 33},
		{39, 34},
		{39, 35},
		{39, 36},
		{39, 37},
		{39, 38},
		{39, 39},
		{39, 40},
		{39, 41},
		{39, 42},
		{39, 43},
		{39, 44},
		{39, 45},
		{39, 46},
		{39, 47},
		{39, 48},
		{39, 49},
		{39, 50},
		{39, 51},
		{39, 52},
		{39, 53},
		{39, 54},
		{39, 55},
		{39, 56},
		{39, 57},
		{39, 58},
		{39, 59},
		{39, 60},
		{39, 61},
		{39, 62},
		{39, 63},
		{40, 32},
		{40, 33},
		{40, 34},
		{40, 35},
		{40, 36},
		{40, 37},
		{40, 38},
		{40, 39},
		{40, 40},
		{40, 41},
		{40, 42},
		{40, 43},
		{40, 44},
		{40, 45},
		{40, 46},
		{40, 47},
		{40, 48},
		{40, 49},
		{40, 50},
		{40, 51},
		{40, 52},
		{40, 53},
		{40, 54},
		{40, 55},
		{40, 56},
		{40, 57},
		{40, 58},
		{40, 59},
		{40, 60},
		{40, 61},
		{40, 62},
		{41, 32},
		{41, 33},
		{41, 34},
		{41, 35},
		{41, 36},
		{41, 37},
		{41, 38},
		{41, 39},
		{41, 40},
		{41, 41},
		{41, 42},
		{41, 43},
		{41, 44},
		{41, 45},
		{41, 46},
		{41, 47},
		{41, 48},
		{41, 49},
		{41, 50},
		{41, 51},
		{41, 52},
		{41, 53},
		{41, 54},
		{41, 55},
		{41, 56},
		{41, 57},
		{41, 58},
		{41, 59},
		{41, 60},
		{41, 61},
		{41, 62},
		{42, 32},
		{42, 33},
		{42, 34},
		{42, 35},
		{42, 36},
		{42, 37},
		{42, 38},
		{42, 39},
		{42, 40},
		{42, 41},
		{42, 42},
		{42, 43},
		{42, 44},
		{42, 45},
		{42, 46},
		{42, 47},
		{42, 48},
		{42, 49},
		{42, 50},
		{42, 51},
		{42, 52},
		{42, 53},
		{42, 54},
		{42, 55},
		{42, 56},
		{42, 57},
		{42, 58},
		{42, 59},
		{42, 60},
		{42, 61},
		{42, 62},
		{43, 32},
		{43, 33},
		{43, 34},
		{43, 35},
		{43, 36},
		{43, 37},
		{43, 38},
		{43, 39},
		{43, 40},
		{43, 41},
		{43, 42},
		{43, 43},
		{43, 44},
		{43, 45},
		{43, 46},
		{43, 47},
		{43, 48},
		{43, 49},
		{43, 50},
		{43, 51},
		{43, 52},
		{43, 53},
		{43, 54},
		{43, 55},
		{43, 56},
		{43, 57},
		{43, 58},
		{43, 59},
		{43, 60},
		{43, 61},
		{43, 62},
		{44, 32},
		{44, 33},
		{44, 34},
		{44, 35},
		{44, 36},
		{44, 37},
		{44, 38},
		{44, 39},
		{44, 40},
		{44, 41},
		{44, 42},
		{44, 43},
		{44, 44},
		{44, 45},
		{44, 46},
		{44, 47},
		{44, 48},
		{44, 49},
		{44, 50},
		{44, 51},
		{44, 52},
		{44, 53},
		{44, 54},
		{44, 55},
		{44, 56},
		{44, 57},
		{44, 58},
		{44, 59},
		{44, 60},
		{44, 61},
		{44, 62},
		{45, 32},
		{45, 33},
		{45, 34},
		{45, 35},
		{45, 36},
		{45, 37},
		{45, 38},
		{45, 39},
		{45, 40},
		{45, 41},
		{45, 42},
		{45, 43},
		{45, 44},
		{45, 45},
		{45, 46},
		{45, 47},
		{45, 48},
		{45, 49},
		{45, 50},
		{45, 51},
		{45, 52},
		{45, 53},
		{45, 54},
		{45, 55},
		{45, 56},
		{45, 57},
		{45, 58},
		{45, 59},
		{45, 60},
		{45, 61},
		{45, 62},
		{46, 32},
		{46, 33},
		{46, 34},
		{46, 35},
		{46, 36},
		{46, 37},
		{46, 38},
		{46, 39},
		{46, 40},
		{46, 41},
		{46, 42},
		{46, 43},
		{46, 44},
		{46, 45},
		{46, 46},
		{46, 47},
		{46, 48},
		{46, 49},
		{46, 50},
		{46, 51},
		{46, 52},
		{46, 53},
		{46, 54},
		{46, 55},
		{46, 56},
		{46, 57},
		{46, 58},
		{46, 59},
		{46, 60},
		{46, 61},
		{46, 62},
		{47, 32},
		{47, 33},
		{47, 34},
		{47, 35},
		{47, 36},
		{47, 37},
		{47, 38},
		{47, 39},
		{47, 40},
		{47, 41},
		{47, 42},
		{47, 43},
		{47, 44},
		{47, 45},
		{47, 46},
		{47, 47},
		{47, 48},
		{47, 49},
		{47, 50},
		{47, 51},
		{47, 52},
		{47, 53},
		{47, 54},
		{47, 55},
		{47, 56},
		{47, 57},
		{47, 58},
		{47, 59},
		{47, 60},
		{47, 61},
		{47, 62},
		{48, 32},
		{48, 33},
		{48, 34},
		{48, 35},
		{48, 36},
		{48, 37},
		{48, 38},
		{48, 39},
		{48, 40},
		{48, 41},
		{48, 42},
		{48, 43},
		{48, 44},
		{48, 45},
		{48, 46},
		{48, 47},
		{48, 48},
		{48, 49},
		{48, 50},
		{48, 51},
		{48, 52},
		{48, 53},
		{48, 54},
		{48, 55},
		{48, 56},
		{48, 57},
		{48, 58},
		{48, 59},
		{48, 60},
		{48, 61},
		{48, 62},
		{49, 32},
		{49, 33},
		{49, 34},
		{49, 35},
		{49, 36},
		{49, 37},
		{49, 38},
		{49, 39},
		{49, 40},
		{49, 41},
		{49, 42},
		{49, 43},
		{49, 44},
		{49, 45},
		{49, 46},
		{49, 47},
		{49, 48},
		{49, 49},
		{49, 50},
		{49, 51},
		{49, 52},
		{49, 53},
		{49, 54},
		{49, 55},
		{49, 56},
		{49, 57},
		{49, 58},
		{49, 59},
		{49, 60},
		{49, 61},
		{49, 62},
		{50, 32},
		{50, 33},
		{50, 34},
		{50, 35},
		{50, 36},
		{50, 37},
		{50, 38},
		{50, 39},
		{50, 40},
		{50, 41},
		{50, 42},
		{50, 43},
		{50, 44},
		{50, 45},
		{50, 46},
		{50, 47},
		{50, 48},
		{50, 49},
		{50, 50},
		{50, 51},
		{50, 52},
		{50, 53},
		{50, 54},
		{50, 55},
		{50, 56},
		{50, 57},
		{50, 58},
		{50, 59},
		{50, 60},
		{50, 61},
		{50, 62},
		{51, 32},
		{51, 33},
		{51, 34},
		{51, 35},
		{51, 36},
		{51, 37},
		{51, 38},
		{51, 39},
		{51, 40},
		{51, 41},
		{51, 42},
		{51, 43},
		{51, 44},
		{51, 45},
		{51, 46},
		{51, 47},
		{51, 48},
		{51, 49},
		{51, 50},
		{51, 51},
		{51, 52},
		{51, 53},
		{51, 54},
		{51, 55},
		{51, 56},
		{51, 57},
		{51, 58},
		{51, 59},
		{51, 60},
		{51, 61},
		{51, 62},
		{52, 32},
		{52, 33},
		{52, 34},
		{52, 35},
		{52, 36},
		{52, 37},
		{52, 38},
		{52, 39},
		{52, 40},
		{52, 41},
		{52, 42},
		{52, 43},
		{52, 44},
		{52, 45},
		{52, 46},
		{52, 47},
		{52, 48},
		{52, 49},
		{52, 50},
		{52, 51},
		{52, 52},
		{52, 53},
		{52, 54},
		{52, 55},
		{52, 56},
		{52, 57},
		{52, 58},
		{52, 59},
		{52, 60},
		{52, 61},
		{52, 62},
		{53, 32},
		{53, 33},
		{53, 34},
		{53, 35},
		{53, 36},
		{53, 37},
		{53, 38},
		{53, 39},
		{53, 40},
		{53, 41},
		{53, 42},
		{53, 43},
		{53, 44},
		{53, 45},
		{53, 46},
		{53, 47},
		{53, 48},
		{53, 49},
		{53, 50},
		{53, 51},
		{53, 52},
		{53, 53},
		{53, 54},
		{53, 55},
		{53, 56},
		{53, 57},
		{53, 58},
		{53, 59},
		{53, 60},
		{53, 61},
		{53, 62},
		{54, 32},
		{54, 33},
		{54, 34},
		{54, 35},
		{54, 36},
		{54, 37},
		{54, 38},
		{54, 39},
		{54, 40},
		{54, 41},
		{54, 42},
		{54, 43},
		{54, 44},
		{54, 45},
		{54, 46},
		{54, 47},
		{54, 48},
		{54, 49},
		{54, 50},
		{54, 51},
		{54, 52},
		{54, 53},
		{54, 54},
		{54, 55},
		{54, 56},
		{54, 57},
		{54, 58},
		{54, 59},
		{54, 60},
		{54, 61},
		{54, 62},
		{55, 32},
		{55, 33},
		{55, 34},
		{55, 35},
		{55, 36},
		{55, 37},
		{55, 38},
		{55, 39},
		{55, 40},
		{55, 41},
		{55, 42},
		{55, 43},
		{55, 44},
		{55, 45},
		{55, 46},
		{55, 47},
		{55, 48},
		{55, 49},
		{55, 50},
		{55, 51},
		{55, 52},
		{55, 53},
		{55, 54},
		{55, 55},
		{55, 56},
		{55, 57},
		{55, 58},
		{55, 59},
		{55, 60},
		{55, 61},
		{55, 62},
		{56, 32},
		{56, 33},
		{56, 34},
		{56, 35},
		{56, 36},
		{56, 37},
		{56, 38},
		{56, 39},
		{56, 40},
		{56, 41},
		{56, 42},
		{56, 43},
		{56, 44},
		{56, 45},
		{56, 46},
		{56, 47},
		{56, 48},
		{56, 49},
		{56, 50},
		{56, 51},
		{56, 52},
		{56, 53},
		{56, 54},
		{56, 55},
		{56, 56},
		{56, 57},
		{56, 58},
		{56, 59},
		{56, 60},
		{56, 61},
		{56, 62},
		{57, 32},
		{57, 33},
		{57, 34},
		{57, 35},
		{57, 36},
		{57, 37},
		{57, 38},
		{57, 39},
		{57, 40},
		{57, 41},
		{57, 42},
		{57, 43},
		{57, 44},
		{57, 45},
		{57, 46},
		{57, 47},
		{57, 48},
		{57, 49},
		{57, 50},
		{57, 51},
		{57, 52},
		{57, 53},
		{57, 54},
		{57, 55},
		{57, 56},
		{57, 57},
		{57, 58},
		{57, 59},
		{57, 60},
		{57, 61},
		{57, 62},
		{58, 32},
		{58, 33},
		{58, 34},
		{58, 35},
		{58, 36},
		{58, 37},
		{58, 38},
		{58, 39},
		{58, 40},
		{58, 41},
		{58, 42},
		{58, 43},
		{58, 44},
		{58, 45},
		{58, 46},
		{58, 47},
		{58, 48},
		{58, 49},
		{58, 50},
		{58, 51},
		{58, 52},
		{58, 53},
		{58, 54},
		{58, 55},
		{58, 56},
		{58, 57},
		{58, 58},
		{58, 59},
		{58, 60},
		{59, 32},
		{59, 33},
		{59, 34},
		{59, 35},
		{59, 36},
		{59, 37},
		{59, 38},
		{59, 39},
		{59, 40},
		{59, 41},
		{59, 42},
		{59, 43},
		{59, 44},
		{59, 45},
		{59, 46},
		{59, 47},
		{59, 48},
		{59, 49},
		{59, 50},
		{59, 51},
		{59, 52},
		{59, 53},
		{59, 54},
		{59, 55},
		{59, 56},
		{59, 57},
		{59, 58},
		{59, 59},
		{59, 60},
		{60, 32},
		{60, 33},
		{60, 34},
		{60, 35},
		{60, 36},
		{60, 37},
		{60, 38},
		{60, 39},
		{60, 40},
		{60, 41},
		{60, 42},
		{60, 43},
		{60, 44},
		{60, 45},
		{60, 46},
		{60, 47},
		{60, 48},
		{60, 49},
		{60, 50},
		{60, 51},
		{60, 52},
		{60, 53},
		{60, 54},
		{60, 55},
		{60, 56},
		{60, 57},
		{60, 58},
		{60, 59},
		{61, 32},
		{61, 33},
		{61, 34},
		{61, 35},
		{61, 36},
		{61, 37},
		{61, 38},
		{61, 39},
		{61, 40},
		{61, 41},
		{61, 42},
		{61, 43},
		{61, 44},
		{61, 45},
		{61, 46},
		{61, 47},
		{61, 48},
		{61, 49},
		{61, 50},
		{61, 51},
		{61, 52},
		{61, 53},
		{61, 54},
		{61, 55},
		{61, 56},
		{61, 57},
		{61, 58},
		{62, 32},
		{62, 33},
		{62, 34},
		{62, 35},
		{62, 36},
		{62, 37},
		{62, 38},
		{62, 39},
		{62, 40},
		{62, 41},
		{62, 42},
		{62, 43},
		{62, 44},
		{62, 45},
		{62, 46},
		{62, 47},
		{62, 48},
		{62, 49},
		{62, 50},
		{62, 51},
		{62, 52},
		{62, 53},
		{62, 54},
		{62, 55},
		{62, 56},
		{62, 57},
		{62, 58},
		{63, 32},
		{63, 33},
		{63, 34},
		{63, 35},
		{63, 36},
		{63, 37},
		{63, 38},
		{63, 39},
		{63, 40},
		{63, 41},
		{63, 42},
		{63, 43},
		{63, 44},
		{63, 45},
		{63, 46},
		{63, 47},
		{63, 48},
		{63, 49},
		{63, 50},
		{63, 51},
		{63, 52},
		{63, 53},
		{63, 54},
		{63, 55},
		{63, 56},
		{63, 57},
		{63, 58},
		{64, 32},
		{64, 33},
		{64, 34},
		{64, 35},
		{64, 36},
		{64, 37},
		{64, 38},
		{64, 39},
		{64, 40},
		{64, 41},
		{64, 42},
		{64, 43},
		{64, 44},
		{64, 45},
		{64, 46},
		{64, 47},
		{64, 48},
		{64, 49},
		{64, 50},
		{64, 51},
		{64, 52},
		{64, 53},
		{64, 54},
		{64, 55},
		{64, 56},
		{64, 57},
		{64, 58},
		{65, 32},
		{65, 33},
		{65, 34},
		{65, 35},
		{65, 36},
		{65, 37},
		{65, 38},
		{65, 39},
		{65, 40},
		{65, 41},
		{65, 42},
		{65, 43},
		{65, 44},
		{65, 45},
		{65, 46},
		{65, 47},
		{65, 48},
		{65, 49},
		{65, 50},
		{65, 51},
		{65, 52},
		{65, 53},
		{65, 54},
		{65, 55},
		{65, 56},
		{65, 57},
		{66, 32},
		{66, 33},
		{66, 34},
		{66, 35},
		{66, 36},
		{66, 37},
		{66, 38},
		{66, 39},
		{66, 40},
		{66, 41},
		{66, 42},
		{66, 43},
		{66, 44},
		{66, 45},
		{66, 46},
		{66, 47},
		{66, 48},
		{66, 49},
		{66, 50},
		{66, 51},
		{66, 52},
		{66, 53},
		{66, 54},
		{67, 32},
		{67, 33},
		{67, 34},
		{67, 35},
		{67, 36},
		{67, 37},
		{67, 38},
		{67, 39},
		{67, 40},
		{67, 41},
		{67, 42},
		{67, 43},
		{67, 44},
		{67, 45},
		{67, 46},
		{67, 47},
		{67, 48},
		{67, 49},
		{67, 50},
		{67, 51},
		{67, 52},
		{67, 53},
		{67, 54},
		{68, 34},
		{68, 35},
		{68, 36},
		{68, 37},
		{68, 38},
		{68, 39},
		{68, 40},
		{68, 41},
		{68, 42},
		{68, 43},
		{68, 44},
		{68, 45},
		{68, 46},
		{68, 47},
		{68, 48},
		{68, 49},
		{68, 50},
		{68, 51},
		{68, 52},
		{68, 53},
		{68, 54},
		{69, 35},
		{69, 36},
		{69, 37},
		{69, 38},
		{69, 39},
		{69, 40},
		{69, 41},
		{69, 42},
		{69, 43},
		{69, 44},
		{69, 45},
		{69, 46},
		{69, 47},
		{69, 48},
		{69, 49},
		{69, 50},
		{69, 51},
		{69, 52},
		{69, 53},
		{70, 35},
		{70, 36},
		{70, 37},
		{70, 38},
		{70, 39},
		{70, 40},
		{70, 41},
		{70, 42},
		{70, 43},
		{70, 44},
		{70, 45},
		{70, 46},
		{70, 47},
		{70, 48},
		{70, 49},
		{70, 50},
		{70, 51},
		{70, 52},
		{70, 53},
		{71, 37},
		{71, 38},
		{71, 39},
		{71, 40},
		{71, 41},
		{71, 42},
		{71, 43},
		{71, 44},
		{71, 45},
		{71, 46},
		{71, 47},
		{71, 48},
		{71, 49},
		{71, 50},
		{71, 51},
		{71, 52},
		{72, 37},
		{72, 38},
		{72, 39},
		{72, 40},
		{72, 41},
		{72, 42},
		{72, 43},
		{72, 44},
		{72, 45},
		{72, 46},
		{72, 47},
		{72, 48},
		{72, 49},
		{72, 50},
		{72, 51},
		{72, 52},
		{73, 40},
		{73, 41},
		{73, 42},
		{73, 43},
		{73, 44},
		{73, 45},
		{73, 46},
		{73, 47},
		{73, 48},
		{73, 49},
		{73, 50}
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
		{ 20812001,#p_coord{x=734, y=3258 } },
		{ 20812002,#p_coord{x=2887, y=2188 } },
		{ 20812003,#p_coord{x=5258, y=345 } },
		{ 20812004,#p_coord{x=2112, y=4715 } },
		{ 20812005,#p_coord{x=4513, y=3613 } },
		{ 20812006,#p_coord{x=8187, y=2048 } },
		{ 20812007,#p_coord{x=3988, y=6830 } },
		{ 20812008,#p_coord{x=6491, y=5554 } },
		{ 20812009,#p_coord{x=9330, y=4736 } },
		{ 20812010,#p_coord{x=8248, y=6662 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
